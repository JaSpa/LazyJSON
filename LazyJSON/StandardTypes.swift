//
//  StandardTypes.swift
//  LazyJSON
//
//  Created by Janek Spaderna on 16.12.15.
//  Copyright © 2015 jds. All rights reserved.
//

extension Bool: Decodable {
    public static var decoder: Decoder<Bool>.Function {
        return { json in try json.getNumber() as Bool }
    }
}

extension Int: Decodable {
    public static var decoder: Decoder<Int>.Function {
        return { json in try json.getNumber() as Int }
    }
}

extension Int64: Decodable {
    public static var decoder: Decoder<Int64>.Function {
        return { json in try json.getNumber().longLongValue }
    }
}

extension Float: Decodable {
    public static var decoder: Decoder<Float>.Function {
        return { json in try json.getNumber() as Float }
    }
}

extension Double: Decodable {
    public static var decoder: Decoder<Double>.Function {
        return { json in try json.getNumber() as Double }
    }
}

extension String: Decodable {
    public static var decoder: Decoder<String>.Function {
        return { json in try json.getString() }
    }
}
