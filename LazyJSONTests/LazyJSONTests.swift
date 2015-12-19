//
//  LazyJSONTests.swift
//  LazyJSONTests
//
//  Created by Janek Spaderna on 16.12.15.
//  Copyright © 2015 jds. All rights reserved.
//

import XCTest
import LazyJSON

enum NilError: ErrorType {
    case Unexpected(String)
}

class LazyJSONTests: XCTestCase {

    func testPerformance() {
        do {
            guard let data =
                NSBundle(forClass: LazyJSONTests.self)
                    .URLForResource("big_data", withExtension: "json")
                    .flatMap(NSData.init) else {

                throw NilError.Unexpected("can't load the json file")
            }

            let json = try NSJSONSerialization.JSONObjectWithData(data, options: [])
            var firstElem: [TestModel]? = nil

            measureBlock {
                do {
                    let parsed: [TestModel] = try decode(json, root: "types")
                    if firstElem == nil { firstElem = parsed }
                } catch {
                    XCTFail("unexpected error: \(error)")
                }
            }

            print(firstElem?.count ?? 0, "elements parsed")
        } catch {
            XCTFail("unexpected error: \(error)")
        }
    }
}
