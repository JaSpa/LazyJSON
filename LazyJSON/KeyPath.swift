//
//  KeyPath.swift
//  LazyJSON
//
//  Created by Janek Spaderna on 16.12.15.
//  Copyright © 2015 jds. All rights reserved.
//

public enum KeyPath {
    case Root
    indirect case Elem(KeyPath, String)

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
            pathElems.append(elem)
            path = parent
        }

        return pathElems.reverse().joinWithSeparator(".")
    }
}

func +(parent: KeyPath, child: String) -> KeyPath {
    return .Elem(parent, child)
}

func +(parent: KeyPath, childPath: [String]) -> KeyPath {
    return childPath.reduce(parent, combine: KeyPath.Elem)
}
