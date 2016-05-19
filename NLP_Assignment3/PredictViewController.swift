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
        
        let classifier = BayesianClassifier(eventSpace: eventSpace)
        
        let sanitizedReview = textField.text!.sanitize(stopWords: stopWords!)
        resultLabel.text = "Result: \(classifier.classify(sanitizedReview.componentsSeparatedByString(" ")))"
    }
}
