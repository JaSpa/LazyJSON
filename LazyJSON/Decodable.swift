//
//  Decodable.swift
//  LazyJSON
//
//  Created by Janek Spaderna on 16.12.15.
//  Copyright © 2015 jds. All rights reserved.
//

public struct Decoder<T> {
    public typealias Function = JSON throws -> T
}

public protocol Decodable {
    typealias DecodedType
    static var decoder: Decoder<DecodedType>.Function { get }
}
