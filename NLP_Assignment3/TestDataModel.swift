//
//  TestDataModel.swift
//  NLP_Assignment3
//
//  Created by Muhammad Zeeshan on 23/05/2016.
//  Copyright © 2016 ThatClose. All rights reserved.
//

import Foundation

class TestDataModel: NSObject {
    
    var review: String = ""
    var actualClass: String = ""
    var predictedClass: String = ""
    
    convenience init(review: String, actualClass: String, predictedClass: String) {
        self.init()
        
        self.review = review
        self.actualClass = actualClass
        self.predictedClass = predictedClass
    }
    
}
