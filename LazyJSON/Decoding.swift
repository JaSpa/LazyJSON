//
//  Decoding.swift
//  LazyJSON
//
//  Created by Janek Spaderna on 18.12.15.
//  Copyright © 2015 jds. All rights reserved.
//

public extension Decodable {
    static func decode(json: AnyObject, root: String...) throws -> DecodedType {
        return try decoder(JSON(json).get(root))
    }
}

public extension Array where Element: Decodable, Element.DecodedType == Element {
    typealias DecodedType = [Element]
    static func decode(json: AnyObject, root: String...) throws -> DecodedType {
        return try Element.decodeArray(JSON(json).get(root))
    }
}

public extension Dictionary where Value: Decodable, Value.DecodedType == Value {
    typealias DecodedType = [String: Value.DecodedType]
    static func decode(json: AnyObject, root: String...) throws -> DecodedType {
        return try Value.decodeDictionary(JSON(json).get(root))
    }
}

public func decode<A: Decodable>(json: AnyObject) throws -> A.DecodedType {
    return try A.decode(json)
}

public func key<A: Decodable where A.DecodedType == A>(path: String...) -> Decoder<A>.Function {
    return { try A.decoder(try $0.get(path)) }
}

public func optKey<A: Decodable where A.DecodedType == A>(path: String...) -> Decoder<A?>.Function {
    return optional(path, decoder: A.decoder)
}

public func arrKey<A: Decodable where A.DecodedType == A>(path: String...) -> Decoder<[A]>.Function {
    return { try A.decodeArray(try $0.get(path)) }
}

public func optArrKey<A: Decodable where A.DecodedType == A>(path: String...) -> Decoder<[A]?>.Function {
    return optional(path, decoder: A.decodeArray)
}

public func dictKey<A: Decodable where A.DecodedType == A>(path: String...) -> Decoder<[String: A]>.Function {
    return { try A.decodeDictionary(try $0.get(path)) }
}

public func optDictKey<A: Decodable where A.DecodedType == A>(path: String...) -> Decoder<[String: A]?>.Function {
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

private func optional<A>(path: [String], decoder: Decoder<A>.Function) -> Decoder<A?>.Function {
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

