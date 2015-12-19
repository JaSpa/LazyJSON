//
//  Decoding.swift
//  LazyJSON
//
//  Created by Janek Spaderna on 18.12.15.
//  Copyright © 2015 jds. All rights reserved.
//

public func decode<A: Decodable where A.DecodedType == A>(json: AnyObject, root: KeyPathElem...) throws -> A {
    return try A.decode(json, root: root)
}

public func decode<A: Decodable where A.DecodedType == A>(json: AnyObject, root: KeyPathElem...) throws -> [A] {
    return try [A].decode(json, root: root)
}

public func decode<A: Decodable where A.DecodedType == A>(json: AnyObject, root: KeyPathElem...) throws -> [String: A] {
    return try [String: A].decode(json, root: root)
}

public extension Decodable {
    static func decode(json: AnyObject, root: [KeyPathElem] = []) throws -> DecodedType {
        return try decoder(JSON(json).get(root))
    }
}

public extension Array where Element: Decodable {
    typealias DecodedType = [Element.DecodedType]
    static func decode(json: AnyObject, root: [KeyPathElem] = []) throws -> DecodedType {
        return try Element.decodeArray(JSON(json).get(root))
    }
}

public extension Dictionary where Value: Decodable {
    typealias DecodedType = [String: Value.DecodedType]
    static func decode(json: AnyObject, root: [KeyPathElem] = []) throws -> DecodedType {
        return try Value.decodeDictionary(JSON(json).get(root))
    }
}
