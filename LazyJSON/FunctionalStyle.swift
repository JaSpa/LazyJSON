//
//  Applicative.swift
//  LazyJSON
//
//  Created by Janek Spaderna on 18.12.15.
//  Copyright © 2015 jds. All rights reserved.
//

infix operator <^> { associativity left precedence 130 }
infix operator <*> { associativity left precedence 130 }
infix operator >>- { associativity left precedence 100 }
infix operator <|> { associativity left precedence 140 }

public func <^><A, B, C>(f: B -> C, value: A throws -> B) -> A throws -> C {
    return { f(try value($0)) }
}

public func <*><A, B, C>(f: A throws -> B -> C, value: A throws -> B) -> A throws -> C {
    return { try f($0)(try value($0)) }
}

public func >>-<A, B, C>(f: B throws -> C, value: A throws -> B) -> A throws -> C {
    return { try f(try value($0)) }
}

public func <|><A, B>(f: A throws -> B, g: A throws -> B) -> A throws -> B {
    return { json in
        do {
            return try f(json)
        } catch let e1 {
            do {
                return try g(json)
            } catch let e2 {
                throw e1.mergeWith(e2)
            }
        }
    }
}

public func ??<A, B>(f: A throws -> B, @autoclosure(escaping) fallback: () -> B) -> A -> B {
    return {
        do {
            return try f($0)
        } catch _ {
            return fallback()
        }
    }
}

public func curry<A, B, R>(f: (A, B) -> R) -> A -> B -> R {
    return { a in
           { b in f(a, b) } }
}

public func curry<A, B, C, R>(f: (A, B, C) -> R) -> A -> B -> C -> R {
    return { a in
           { b in
           { c in f(a, b, c) } } }
}

public func curry<A, B, C, D, R>(f: (A, B, C, D) -> R) -> A -> B -> C -> D -> R {
        return { a in
               { b in
               { c in
               { d in f(a, b, c, d) } } } }
}
