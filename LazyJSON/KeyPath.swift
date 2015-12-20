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

public extension KeyPath {

    var bottomUpGenerator: AnyGenerator<KeyPathElem> {
        var path = self

        return anyGenerator {
            guard case let .Elem(parent, elem) = path else { return nil }
            path = parent
            return elem
        }
    }

    var keyPathArray: [KeyPathElem] {
        return bottomUpGenerator.reverse()
    }

    var isRoot: Bool {
        if case .Root = self {
            return true
        } else {
            return false
        }
    }
}

extension KeyPath: CustomStringConvertible {
    public var description: String {
        return isRoot ? "/" : keyPathArray.map { String($0) }.joinWithSeparator(".")
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
