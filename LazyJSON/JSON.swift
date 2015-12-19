//
//  JSON.swift
//  LazyJSON
//
//  Created by Janek Spaderna on 16.12.15.
//  Copyright © 2015 jds. All rights reserved.
//

import Foundation

private class TypeBox {
    enum Type {
        case Null
        case String(Swift.String)
        case Number(NSNumber)
        case Array(NSArray)
        case Object(NSDictionary)
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

    func get() throws -> NSArray {
        guard case let .Array(ary) = try resolve() else { return try typeError() }
        return ary
    }

    func get() throws -> NSDictionary {
        guard case let .Object(obj) = try resolve() else { return try typeError() }
        return obj
    }

    func resolve() throws -> Type {
        guard case let .Unresolved(value) = type else { return type }

        switch value {
        case let value as String: type = .String(value)
        case let value as NSNumber: type = .Number(value)
        case let value as NSArray: type = .Array(value)
        case let value as NSDictionary: type = .Object(value)
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

    public var path: KeyPath {
        return data.path
    }

    var isNull: Bool {
        return (try? data.resolve()).map { type in
            if case .Null = type {
                return true
            } else {
                return false
            }
        } ?? true
    }

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

    func getArray() throws -> LazyMapSequence<EnumerateSequence<NSArray>, JSON> {
        let ary: NSArray = try data.get()
        return ary.enumerate().lazy.map { JSON($1, path: self.data.path + String($0)) }
    }

    func get(path: [KeyPathElem]) throws -> JSON {
        var json = self

        for key in path {
            let path = json.data.path + key

            switch key {
                case let .Key(key):
                    let object: NSDictionary = try json.data.get()
                    guard let value = object[key] else { throw JSONError.MissingKey(path: path) }
                    json = JSON(value, path: path)

                case let .Index(idx):
                    let array: NSArray = try json.data.get()
                    guard 0 <= idx && idx < array.count else { throw JSONError.InvalidIndex(path: path, value: array as [AnyObject]) }
                    json = JSON(array[idx], path: path)
            }
        }

        return json
    }

    func objectGenerator() throws -> AnyGenerator<(String, JSON)> {
        let object: NSDictionary = try data.get()
        let generator = object.generate()
        return anyGenerator { [path = data.path] in
            generator.next().map {
                let key = $0 as! String
                return (key, JSON($1, path: path + key))
            }
        }
    }
}
