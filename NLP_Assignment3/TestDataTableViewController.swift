//
//  TestDataTableViewController.swift
//  NLP_Assignment3
//
//  Created by Muhammad Zeeshan on 23/05/2016.
//  Copyright © 2016 ThatClose. All rights reserved.
//

import UIKit

class TestDataTableViewController: UITableViewController {
    var testData: [TestDataModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        if testData.count > 0 {
            
            let correctPredictions = testData.filter { (testDataModel: TestDataModel) -> Bool in
                return testDataModel.actualClass == testDataModel.predictedClass
            }
            
            let correctCount = correctPredictions.count
            let correctPercent = (Float(correctCount) / Float(testData.count)) * 100.0
            navigationItem.prompt = String(format: "%.2f %% correct predictions", correctPercent)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
    }
}

//MARK: UITableViewDatasource

extension TestDataTableViewController {
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return testData.count
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "TestDataCell"
        let cell = self.tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! TestDataCell
        
        cell.configureCell(indexPath, testData: testData[indexPath.row])
        
        return cell
    }
}