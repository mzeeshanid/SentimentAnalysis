//
//  ViewController.swift
//  NLP_Assignment3
//
//  Created by Hamid Ismail on 17/05/2016.
//  Copyright © 2016 ThatClose. All rights reserved.
//

import UIKit
import CHCSVParser

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        guard let fileURL = NSBundle.mainBundle().URLForResource("labeledTrainData", withExtension: "tsv") else {
            fatalError("Unable to locate csv file")
        }
        
        let delimiter = "\t".utf16.first!
        let options: CHCSVParserOptions = [.SanitizesFields, .TrimsWhitespace, .UsesFirstLineAsKeys, .RecognizesBackslashesAsEscapes]
        do {
            let parsedArray = try NSArray.init(contentsOfDelimitedURL: fileURL, options: options, delimiter: delimiter, error: ())
            debugPrint("first diction: \(parsedArray.firstObject!, parsedArray.count)")
        } catch let error as NSError {
            debugPrint("error while parsing csv file: " + error.localizedDescription)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

