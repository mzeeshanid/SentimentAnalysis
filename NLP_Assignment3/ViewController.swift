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
        
        var stopWords: Set<String>?
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
            
            var sanitizedReviews: Array<(id: Int, sentiment: Bool, review: String)> = Array()
            
            let countedSet: NSCountedSet = NSCountedSet()
            for (i, reviewDict) in reviews.enumerate() {
                let review = reviewDict as! [String : AnyObject]
                let sanitizedReview = (review["review"] as! String).sanitize(stopWords: stopWords!)
                sanitizedReviews.append((review["id"]!.integerValue, review["sentiment"]!.boolValue, sanitizedReview))
                
                let range = sanitizedReview.startIndex..<sanitizedReview.endIndex
                sanitizedReview.enumerateSubstringsInRange(range, options: .ByWords, { (substring, substringRange, enclosingRange, inout stop: Bool) in
                    countedSet.addObject(substring!)
                })
                
                if (i+1)%1000 == 0 {
                    debugPrint("Review %d of: \(i+1, reviews.count, countedSet.allObjects.count)")
                }
            }
            
            debugPrint("first diction: \(sanitizedReviews.first!, sanitizedReviews.count)")
        } catch let error as NSError {
            debugPrint("error while parsing csv file: " + error.localizedDescription)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            
            let linguisticRange = substring!.startIndex..<substring!.endIndex
            let languageMap: [String : [String]] = ["Latn" : ["en"]]
            let orthography = NSOrthography.init(dominantScript: "Latn", languageMap: languageMap)
            substring?.enumerateLinguisticTagsInRange(linguisticRange, scheme: NSLinguisticTagSchemeLemma, options: NSLinguisticTaggerOptions.OmitWhitespace, orthography: orthography, { (tag: String, tokenRange: Range<Index>?, sentenceRange: Range<Index>?, inout stop: Bool) in
                
                if let tokenRange = tokenRange {
                    debugPrint("tag: \(tag, tokenRange)")
                }
            })
            
            if stopWords.indexOf(substring!) == nil {
                tokens.append(substring!)
            }
        })
        
        string = tokens.joinWithSeparator(" ")
        return string
    }
}

