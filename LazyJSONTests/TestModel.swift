//
//  TestModel.swift
//  LazyJSON
//
//  Created by Janek Spaderna on 18.12.15.
//  Copyright © 2015 jds. All rights reserved.
//

import LazyJSON

struct User {
    let id: Int
    let name: String
    let email: String?
}

extension User: Decodable {
    typealias DecodedType = User
    static var decoder: Decoder<DecodedType>.Function {
        return curry(self.init)
            <^> key("id")
            <*> key("userinfo", "name") <|> key("name")
            <*> optKey("email")
    }
}

struct TestModel {
    let numerics: TestModelNumerics
    let string: String
    let bool: Bool
    let stringArray: [String]
    let stringArrayOpt: [String]?
    let eStringArray: [String]
    let eStringArrayOpt: [String]?
    let userOpt: User?
    let dict: [String: String]
}

extension TestModel: Decodable {
    typealias DecodedType = TestModel
    static var decoder: Decoder<DecodedType>.Function {
        let curriedInit = curry(self.init)
        return curriedInit
            <^> key("numerics")
            <*> key("nested", "string")
            <*> key("bool")
            <*> arrKey("string_array")
            <*> optArrKey("string_array_opt")
            <*> arrKey("embedded", "string_array")
            <*> optArrKey("embedded", "string_array_opt")
            <*> optKey("user_opt")
            <*> dictKey("dict")
    }
}

struct TestModelNumerics {
    let int: Int
    let int64: Int64
    let double: Double
    let float: Float
    let intOpt: Int?
}

extension TestModelNumerics: Decodable {
    typealias DecodedType = TestModelNumerics
    static var decoder: Decoder<DecodedType>.Function {
        return curry(self.init)
            <^> key("int")
            <*> key("int64")
            <*> key("double")
            <*> key("float")
            <*> optKey("int_opt")
    }
}

private func curry<A, B, C, D, E, R>(f: (A, B, C, D, E) -> R) -> A -> B -> C -> D -> E -> R {
    return
        { a in
        { b in
        { c in
        { d in
        { e in f(a, b, c, d, e) } } } } }
}

private func curry<A, B, C, D, E, G, H, I, J, R>(f: (A, B, C, D, E, G, H, I, J) -> R) -> A -> B -> C -> D -> E -> G -> H -> I -> J -> R {
    return
        { a in
        { b in
        { c in
        { d in
        { e in
        { g in
        { h in
        { i in
        { j in f(a, b, c, d, e, g, h, i, j) } } } } } } } } }
}
