//
//  Encoding.swift
//  LazyJSON
//
//  Created by Janek Spaderna on 16.01.16.
//  Copyright © 2016 jds. All rights reserved.
//

/*
public enum JSONValue {
    case Null
    case Number(NSNumber)
    case String(Swift.String)
    case Array([JSONValue])
    case Dictionary([Swift.String: JSONValue])
}*/

public protocol JSONObject {}

extension Array: JSONObject {}
extension Dictionary: JSONObject {}
extension String: JSONObject {}
extension NSNumber: JSONObject {}

extension JSONObject {
    var getObject: AnyObject {
        guard let object = self as? AnyObject else { fatalError("invalid JSONObject: \(self)") }
        return object
    }
}

public typealias JSONElement = (key: String, value: JSONObject)

public protocol BasicEncodable {
    func _encodeObject() -> JSONObject
}

public protocol Encodable: BasicEncodable {
    func encode() -> [JSONElement]
}

extension Encodable {
    public func _encodeObject() -> JSONObject {
        return Dictionary(sequence: encode())
    }
}

extension BasicEncodable {
    public func encodeAsObject() -> AnyObject {
        return _encodeObject().getObject
    }

    public func encodeAsData(prettyPrinted pretty: Bool = false) throws -> NSData {
        return try NSJSONSerialization.dataWithJSONObject(
            _encodeObject().getObject, options: pretty ? .PrettyPrinted : [])
    }
}

infix operator <~ { precedence 105 }
infix operator <| { precedence 105 }
infix operator <& { precedence 105 }

public func <~<A: BasicEncodable>(key: String, a: A) -> JSONElement {
    return (key, a._encodeObject())
}

public func <|<S: SequenceType where S.Generator.Element: BasicEncodable>(key: String, seq: S) -> JSONElement {
    return (key, seq.map { $0._encodeObject() })
}

public func <&<A: BasicEncodable, S: SequenceType where S.Generator.Element == (String, A)>(key: String, seq: S) -> JSONElement {
    return (key, Dictionary(sequence: seq.lazy.map { ($0, $1._encodeObject()) }))
}

public func <&<A: BasicEncodable>(key: String, dictionary: [String: A]) -> JSONElement {
    return (key, dictionary.mapValues { $0._encodeObject() })
}

extension String: BasicEncodable {
    public func _encodeObject() -> JSONObject {
        return self
    }
}

extension Int: BasicEncodable {
    public func _encodeObject() -> JSONObject {
        return self as NSNumber
    }
}

private extension Dictionary {
    init<S: SequenceType where S.Generator.Element == Element>(sequence: S) {
        self = [:]
        for (key, value) in sequence {
            self[key] = value
        }
    }

    func mapValues<T>(f: Value -> T) -> [Key: T] {
        return Dictionary<Key, T>(sequence: zip(keys, values.map(f)))
    }
}
