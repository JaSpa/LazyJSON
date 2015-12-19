//
//  JSON.swift
//  LazyJSON
//
//  Created by Janek Spaderna on 16.12.15.
//  Copyright © 2015 jds. All rights reserved.
//

typealias JSONArray = [AnyObject]
typealias JSONObject = [String: AnyObject]

private class TypeBox {
    enum Type {
        case Null
        case String(Swift.String)
        case Number(NSNumber)
        case Array(JSONArray)
        case Object(JSONObject)
        case Unresolved(AnyObject)

        var value: AnyObject {
            switch self {
                case let .String(string): return string
                case let .Number(number): return number
                case let .Array(array): return array
                case let .Object(object): return object
                case let .Unresolved(value): return value
                case .Null: return kCFNull
            }
        }
    }

    var type: Type
    let path: KeyPath

    init(json: AnyObject, path: KeyPath = KeyPath()) {
        self.type = .Unresolved(json)
        self.path = path
    }

    func get() throws -> NSNumber {
        guard case let .Number(num) = try resolve() else { return try typeError() }
        return num
    }

    func get() throws -> String {
        guard case let .String(str) = try resolve() else { return try typeError() }
        return str
    }

    func get() throws -> JSONArray {
        guard case let .Array(ary) = try resolve() else { return try typeError() }
        return ary
    }

    func get() throws -> JSONObject {
        guard case let .Object(obj) = try resolve() else { return try typeError() }
        return obj
    }

    func resolve() throws -> Type {
        guard case let .Unresolved(value) = type else { return type }

        switch value {
        case let value as String: type = .String(value)
        case let value as NSNumber: type = .Number(value)
        case let value as [AnyObject]: type = .Array(value)
        case let value as [String: AnyObject]: type = .Object(value)
        default:
            type = .Null
            throw JSONError.NullValue(path: path)
        }

        return type
    }

    func typeError<T>() throws -> T {
        throw JSONError.InvalidType(path: path, expected: T.self, value: type.value)
    }
}

public struct JSON {
    private let data: TypeBox

    init(_ json: AnyObject) {
        data = TypeBox(json: json)
    }

    private init(_ json: AnyObject, path: KeyPath) {
        data = TypeBox(json: json, path: path)
    }

    func getNumber() throws -> NSNumber {
        return try data.get()
    }

    func getString() throws -> String {
        return try data.get()
    }

    func getArray() throws -> LazyMapSequence<EnumerateSequence<[AnyObject]>, JSON> {
        let ary: [AnyObject] = try data.get()
        return ary.enumerate().lazy.map { JSON($1, path: self.data.path + String($0)) }
    }

    func get(path: [KeyPathElem]) throws -> JSON {
        var json = self

        for key in path {
            let path = data.path + key

            switch key {
                case let .Key(key):
                    let object: JSONObject = try data.get()
                    guard let value = object[key] else { throw JSONError.MissingKey(path: path) }
                    json = JSON(value, path: path)

                case let .Index(idx):
                    let array: JSONArray = try data.get()
                    guard 0 <= idx && idx < array.count else { throw JSONError.InvalidIndex(path: path, value: array) }
                    json = JSON(array[idx], path: path)
            }
        }

        return json
    }

    func objectGenerator() throws -> AnyGenerator<(String, JSON)> {
        let object: JSONObject = try data.get()
        var generator = object.generate()
        return anyGenerator { [path = data.path] in
            generator.next().map {
                ($0, JSON($1, path: path + $0))
            }
        }
    }
}
