//
//  ViewController.swift
//  NLP_Assignment3
//
//  Created by Hamid Ismail on 17/05/2016.
//  Copyright © 2016 ThatClose. All rights reserved.
//

import UIKit
import CHCSVParser
import KVNProgress
import Bayes

class ViewController: UIViewController {

    var stopWords: Set<String>?
    
    var eventSpace = EventSpace<String, String>()
    var postiveClassName = "positive"
    var negativeClassName = "negative"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PredictSegue" {
            let predictController = segue.destinationViewController as! PredictViewController
            predictController.eventSpace = self.eventSpace
            predictController.stopWords = self.stopWords
        }
    }
    
    @IBAction func trainButtonTapped(sender: UIButton) {
        
        KVNProgress.showWithStatus("Parsing training data...")
        guard let fileURL = NSBundle.mainBundle().URLForResource("labeledTrainData", withExtension: "tsv") else {
            fatalError("Unable to locate csv file")
        }
        
        do {
            let stopWordsPath = NSBundle.mainBundle().pathForResource("stopwords", ofType: "txt")
            let stopWordsContent = try String(contentsOfFile: stopWordsPath!)
            stopWords = Set(stopWordsContent.componentsSeparatedByString("\n"))
        } catch let error as NSError {
            debugPrint("Error while reading stop words: \(error)")
        }
        
        guard let _ = stopWords else {
            fatalError("Unable to locate stopwords file")
        }
        
        let delimiter = "\t".utf16.first!
        let options: CHCSVParserOptions = [.SanitizesFields, .TrimsWhitespace, .UsesFirstLineAsKeys, .RecognizesBackslashesAsEscapes]
        do {
            let reviews = try NSArray.init(contentsOfDelimitedURL: fileURL, options: options, delimiter: delimiter, error: ())
            
            
            KVNProgress.showWithStatus("Sanitizing training data...");
            
//            var sanitizedReviews: Array<(id: Int, sentiment: Bool, review: String)> = Array()
            
            let countedSet: NSCountedSet = NSCountedSet()
            for (i, reviewDict) in reviews.enumerate() {
                let review = reviewDict as! [String : AnyObject]
                let sanitizedReview = (review["review"] as! String).sanitize(stopWords: stopWords!)
                
                let features = sanitizedReview.componentsSeparatedByString(" ")
                let category = review["sentiment"]!.boolValue == true ? postiveClassName : negativeClassName
                eventSpace.observe(category, features: features)
                
                if (i+1)%500 == 0 {
                    KVNProgress.showWithStatus("Trained \(i+1, reviews.count, "reviews outof ", countedSet.allObjects.count)");
                }
                
                /*
                sanitizedReviews.append((review["id"]!.integerValue, review["sentiment"]!.boolValue, sanitizedReview))
                
                let range = sanitizedReview.startIndex..<sanitizedReview.endIndex
                sanitizedReview.enumerateSubstringsInRange(range, options: .ByWords, { (substring, substringRange, enclosingRange, inout stop: Bool) in
                    countedSet.addObject(substring!)
                })
                */
            }
            KVNProgress.dismiss()
            KVNProgress.showSuccessWithStatus("Training completed")
            
//            debugPrint("first diction: \(sanitizedReviews.first!, sanitizedReviews.count)")
        } catch let error as NSError {
            debugPrint("error while parsing csv file: " + error.localizedDescription)
        }
    }
    
}

extension String {
    func sanitize(stopWords stopWords: Set<String>) -> String {
        var string = self
        string = self.stripHtml()
        string = string.componentsSeparatedByCharactersInSet(NSCharacterSet.letterCharacterSet().invertedSet).joinWithSeparator(" ").lowercaseString
        
        while string.rangeOfString("  ") != nil {
            string = string.stringByReplacingOccurrencesOfString("  ", withString: " ")
        }
        
        let range: Range = string.startIndex..<string.endIndex
        var tokens: [String] = []
        string.enumerateSubstringsInRange(range, options: .ByWords, { (substring, substringRange, enclosingRange, inout stop: Bool) in
            
            if stopWords.indexOf(substring!) == nil {
                (substring! as NSString).getTagForWordWithCompletion({ (tag: String?, currentEntity: String?, tokenRange: NSRange, sentenceRange: NSRange) in
                    if let tag = tag {
                        tokens.append(tag)
                    } else {
                        tokens.append(substring!)
                    }
                })
            }
        })
        
        string = tokens.joinWithSeparator(" ")
        return string
    }
}

