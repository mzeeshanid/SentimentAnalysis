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
    
    var reviews: NSArray = NSArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        UIApplication.sharedApplication().idleTimerDisabled = true
        
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
        self.performSelector(#selector(startTheAlgorithm), withObject: nil, afterDelay: 0.3)
    }
    
    func startTheAlgorithm() {
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
            reviews = try NSArray.init(contentsOfDelimitedURL: fileURL, options: options, delimiter: delimiter, error: ())
            
            
            KVNProgress.showWithStatus("Sanitizing training data...");
            
//            self.classifyDataUsingBaysian(0)
            
            reviews.enumerateObjectsUsingBlock({ (reviewDict: AnyObject, i: Int, stop: UnsafeMutablePointer<ObjCBool>) in
                let review = reviewDict as! [String : AnyObject]
                let sanitizedReview = (review["review"] as! String).sanitize(stopWords: self.stopWords!)
                
                let features = sanitizedReview.componentsSeparatedByString(" ")
                let category = review["sentiment"]!.boolValue == true ? self.postiveClassName : self.negativeClassName
                self.eventSpace.observe(category, features: features)
                
                if (i+1)%500 == 0 {
                    KVNProgress.showWithStatus("Trained \(i+1, self.reviews.count, "reviews outof ", self.reviews.count)");
                }
            })
            
            /*
            for (i, reviewDict) in reviews.enumerate() {
                let review = reviewDict as! [String : AnyObject]
                let sanitizedReview = (review["review"] as! String).sanitize(stopWords: stopWords!)
                
                let features = sanitizedReview.componentsSeparatedByString(" ")
                let category = review["sentiment"]!.boolValue == true ? postiveClassName : negativeClassName
                eventSpace.observe(category, features: features)
                
                if (i+1)%500 == 0 {
                    KVNProgress.showWithStatus("Trained \(i+1, reviews.count, "reviews outof ", reviews.count)");
                }
            }
            */
            
            KVNProgress.dismiss()
            KVNProgress.showSuccessWithStatus("Training completed")

        } catch let error as NSError {
            debugPrint("error while parsing csv file: " + error.localizedDescription)
        }
    }
    
    /*
    func classifyDataUsingBaysian(index: Int) {
        if index < reviews.count {
            
            let reviewDict = reviews[index]
            let review = reviewDict as! [String : AnyObject]
            let sanitizedReview = (review["review"] as! String).sanitize(stopWords: stopWords!)
            
            let features = sanitizedReview.componentsSeparatedByString(" ")
            let category = review["sentiment"]!.boolValue == true ? postiveClassName : negativeClassName
            eventSpace.observe(category, features: features)
            
            let newIndex = index + 1
            self.classifyDataUsingBaysian(newIndex)
        }
    }
    */
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

