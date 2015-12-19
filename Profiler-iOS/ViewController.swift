//
//  ViewController.swift
//  Profiler-iOS
//
//  Created by Janek Spaderna on 18.12.15.
//  Copyright © 2015 jds. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    private let json: AnyObject = {
        let url = NSBundle.mainBundle().URLForResource("test", withExtension: "json")!
        let data = NSData(contentsOfURL: url)!
        return try! NSJSONSerialization.JSONObjectWithData(data, options: [])
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        let startTime = CACurrentMediaTime()
        let people = try? [Person].decode(json)
        let endTime = CACurrentMediaTime()

        print(endTime - startTime, "sec elapsed")
        print(people?.count ?? 0, "people parsed")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

