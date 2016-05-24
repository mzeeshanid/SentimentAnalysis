//
//  TestDataCell.swift
//  NLP_Assignment3
//
//  Created by Muhammad Zeeshan on 23/05/2016.
//  Copyright © 2016 ThatClose. All rights reserved.
//

import UIKit

class TestDataCell: UITableViewCell {
    @IBOutlet var lblReview: UILabel!
    
    func configureCell(indexPath: NSIndexPath, testData: TestDataModel) {
        lblReview.text = testData.review
        
        if testData.predictedClass != testData.actualClass {
            self.contentView.backgroundColor = UIColor.redColor().colorWithAlphaComponent(0.5)
        } else {
            self.contentView.backgroundColor = UIColor.whiteColor()
        }
    }
}
