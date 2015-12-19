//
//  KeyPath.swift
//  LazyJSON
//
//  Created by Janek Spaderna on 16.12.15.
//  Copyright © 2015 jds. All rights reserved.
//

public enum KeyPathElem {
    case Key(String)
    case Index(Int)
}

extension KeyPathElem: StringLiteralConvertible, IntegerLiteralConvertible {
    public init(unicodeScalarLiteral value: String) {
        self = .Key(value)
    }

    public init(extendedGraphemeClusterLiteral value: String) {
        self = .Key(value)
    }

    public init(stringLiteral value: String) {
        self = .Key(value)
    }

    public init(integerLiteral value: Int) {
        self = .Index(value)
    }
}

extension KeyPathElem: CustomStringConvertible {
    public var description: String {
        switch self {
        case let .Key(key): return key
        case let .Index(idx): return String(idx)
        }
    }
}

public enum KeyPath {
    case Root
    indirect case Elem(parent: KeyPath, element: KeyPathElem)

    init() {
        self = .Root
    }
}

extension KeyPath: CustomStringConvertible {
    public var description: String {
        // Just a .Root node is shown as `/'
        guard case .Elem = self else { return "/" }

        // A path is show without the leading `/'
        // but the path elements separated by `.'
        var pathElems: [String] = []
        var path = self

        while case let .Elem(parent, elem) = path {
            pathElems.append(String(elem))
            path = parent
        }

        return pathElems.reverse().joinWithSeparator(".")
    }
}

func +(parent: KeyPath, child: KeyPathElem) -> KeyPath {
    return .Elem(parent: parent, element: child)
}

func +(parent: KeyPath, child: String) -> KeyPath {
    return .Elem(parent: parent, element: .Key(child))
}

func +(parent: KeyPath, index: Int) -> KeyPath {
    return .Elem(parent: parent, element: .Index(index))
}
