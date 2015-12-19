//
//  DecodingOperators.swift
//  LazyJSON
//
//  Created by Janek Spaderna on 19.12.15.
//  Copyright © 2015 jds. All rights reserved.
//

// Decodables

prefix operator <~ {}
prefix operator <~? {}

public prefix func <~<A: Decodable where A.DecodedType == A>(path: KeyPathElem) -> Decoder<A>.Function {
    return <~[path]
}

public prefix func <~<A: Decodable where A.DecodedType == A>(path: [KeyPathElem]) -> Decoder<A>.Function {
    return key(path)
}

public prefix func <~?<A: Decodable where A.DecodedType == A>(path: KeyPathElem) -> Decoder<A?>.Function {
    return <~?[path]
}

public prefix func <~?<A: Decodable where A.DecodedType == A>(path: [KeyPathElem]) -> Decoder<A?>.Function {
    return optKey(path)
}

// Arrays

prefix operator <| {}
prefix operator <|? {}

public prefix func <|<A: Decodable where A.DecodedType == A>(path: KeyPathElem) -> Decoder<[A]>.Function {
    return <|[path]
}

public prefix func <|<A: Decodable where A.DecodedType == A>(path: [KeyPathElem]) -> Decoder<[A]>.Function {
    return arrKey(path)
}

public prefix func <|?<A: Decodable where A.DecodedType == A>(path: KeyPathElem) -> Decoder<[A]?>.Function {
    return <|?[path]
}

public prefix func <|?<A: Decodable where A.DecodedType == A>(path: [KeyPathElem]) -> Decoder<[A]?>.Function {
    return optArrKey(path)
}

// Dictionaries

prefix operator <& {}
prefix operator <&? {}

public prefix func <&<A: Decodable where A.DecodedType == A>(path: KeyPathElem) -> Decoder<[String: A]>.Function {
    return <&[path]
}

public prefix func <&<A: Decodable where A.DecodedType == A>(path: [KeyPathElem]) -> Decoder<[String: A]>.Function {
    return dictKey(path)
}

public prefix func <&?<A: Decodable where A.DecodedType == A>(path: KeyPathElem) -> Decoder<[String: A]?>.Function {
    return <&?[path]
}

public prefix func <&?<A: Decodable where A.DecodedType == A>(path: [KeyPathElem]) -> Decoder<[String: A]?>.Function {
    return optDictKey(path)
}
