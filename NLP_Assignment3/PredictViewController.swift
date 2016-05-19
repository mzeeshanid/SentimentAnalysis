//
//  PredictViewController.swift
//  NLP_Assignment3
//
//  Created by Hamid Ismail on 19/05/2016.
//  Copyright © 2016 ThatClose. All rights reserved.
//

import UIKit
import Bayes

class PredictViewController: UIViewController {
    
    @IBOutlet var textField: UITextField!
    @IBOutlet var resultLabel: UILabel!
    
    var eventSpace: EventSpace<String, String>!
    var stopWords: Set<String>?
    
    //MARK: My IBActions
    
    @IBAction func textFieldDidEndOnExit(sender: UITextField) {
        
    }
    
    @IBAction func predictButtonTapped(sender: UIButton) {
        
        guard let _ = textField.text where textField.text?.characters.count > 0 else {
            let alertController = UIAlertController(title: "Enter Some Text", message: "Enter some text to get prediction (Positive or Negative)", preferredStyle: .Alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: .Cancel, handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
            return
        }
        
        let classifier = BayesianClassifier(eventSpace: eventSpace)
        
        let sanitizedReview = textField.text!.sanitize(stopWords: stopWords!)
        resultLabel.text = "Result: \(classifier.classify(sanitizedReview.componentsSeparatedByString(" ")))"
    }
}
