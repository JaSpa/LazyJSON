//
//  JSON.swift
//  LazyJSON
//
//  Created by Janek Spaderna on 16.12.15.
//  Copyright © 2015 jds. All rights reserved.
//


public struct JSON {
    private let path: KeyPath
    private let value: AnyObject

    init(_ json: AnyObject) {
        self.path = KeyPath()
        self.value = json
    }

    private init(_ json: AnyObject, path: KeyPath) {
        self.path = path
        self.value = json
    }

    func getNumber() throws -> NSNumber {
        return try get();
    }

    func getString() throws -> String {
        return try get();
    }

    func getDictionary() throws -> [String: AnyObject] {
        return try get()
    }

    func getArray() throws -> LazyMapSequence<EnumerateSequence<[AnyObject]>, JSON> {
        let ary: [AnyObject] = try get()
        return ary.enumerate().lazy.map { JSON($1, path: self.path + String($0)) }
    }

    func get(path: [String]) throws -> JSON {
        var json = self

        for key in path {
            let object = try json.getDictionary()
            let newPath = json.path + key
            guard let value = object[key] else { throw JSONError.MissingKey(path: newPath) }
            json = JSON(value, path: newPath)
        }

        return json
    }

    func objectGenerator() throws -> AnyGenerator<(String, JSON)> {
        var generator = try getDictionary().generate()
        return anyGenerator {
            generator.next().map {
                ($0, JSON($1, path: self.path + $0))
            }
        }
    }

    private func get<T>() throws -> T {
        guard let ret = value as? T else {
            throw JSONError.InvalidType(path: path, expected: T.self, value: value)
        }

        return ret
    }
}
