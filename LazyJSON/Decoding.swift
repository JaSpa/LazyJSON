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

public func key<A: Decodable where A.DecodedType == A>(path: KeyPathElem...) -> Decoder<A>.Function {
    return { try A.decoder(try $0.get(path)) }
}

public func optKey<A: Decodable where A.DecodedType == A>(path: KeyPathElem...) -> Decoder<A?>.Function {
    return optional(path, decoder: A.decoder)
}

public func arrKey<A: Decodable where A.DecodedType == A>(path: KeyPathElem...) -> Decoder<[A]>.Function {
    return { try A.decodeArray(try $0.get(path)) }
}

public func optArrKey<A: Decodable where A.DecodedType == A>(path: KeyPathElem...) -> Decoder<[A]?>.Function {
    return optional(path, decoder: A.decodeArray)
}

public func dictKey<A: Decodable where A.DecodedType == A>(path: KeyPathElem...) -> Decoder<[String: A]>.Function {
    return { try A.decodeDictionary(try $0.get(path)) }
}

public func optDictKey<A: Decodable where A.DecodedType == A>(path: KeyPathElem...) -> Decoder<[String: A]?>.Function {
    return optional(path, decoder: A.decodeDictionary)
}

private extension Decodable {
    static func decodeArray(json: JSON) throws -> [DecodedType] {
        return try json.getArray().map(decoder)
    }

    static func decodeDictionary(json: JSON) throws -> [String: DecodedType] {
        var result: [String: DecodedType] = [:]

        for (key, value) in try json.objectGenerator() {
            result[key] = try decoder(value)
        }

        return result
    }
}

private func optional<A>(path: [KeyPathElem], decoder: Decoder<A>.Function) -> Decoder<A?>.Function {
    return { json in
        let value: JSON

        do {
            value = try json.get(path)
        } catch JSONError.MissingKey {
            return nil
        } catch {
            throw error
        }

        return try decoder(value)
    }
}

