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

public func <^><A, B, C>(f: B throws -> C, value: A throws -> B) -> A throws -> C {
    return { try f(try value($0)) }
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

public func ??<A, B>(f: A throws -> B, @autoclosure(escaping) fallback: () throws -> B) -> A throws -> B {
    return {
        do {
            return try f($0)
        } catch _ {
            return try fallback()
        }
    }
}
