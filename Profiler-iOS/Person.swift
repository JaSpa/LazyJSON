//
//  Test.swift
//  TestingStuff
//
//  Created by Rui Peres on 15/11/2015.
//  Copyright © 2015 Test. All rights reserved.
//

import LazyJSON

struct Person {
    let firstName: String
    let secondName: String?
    let age: Int
    let hobbies: [String]
    let description: String
}

extension Person: Decodable {
    static var decoder: Decoder<Person>.Function {
        return curry(self.init)
            <^> key(.Key("firstName"))
            <*> optKey(.Key("secondName"))
            <*> key(.Key("age"))
            <*> arrKey(.Key("hobbies"))
            <*> key(.Key("description"))
    }
}

private func curry<A, B, C, D, E, R>(f: (A, B, C, D, E) -> R) -> A -> B -> C -> D -> E -> R {
    return { a in { b in { c in { d in { e in f(a,b,c,d,e) } } } } }
}
