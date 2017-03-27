//
//  MainTableViewController.swift
//  refreshmemory
//
//  Created by wyu on 3/25/17.
//  Copyright © 2017 CoreTek. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class BaseTableViewController: UITableViewController {
    
    var editingIndexPath : IndexPath? = nil

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return QnaData.getCount()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let userDefaults = UserDefaults.standard
        let qna = userDefaults.value(forKey: "qna")
        let data = JSON(data: qna as! Data)
        let json = data[indexPath.row]
        
        cell.textLabel?.text = json["question"].stringValue + json["due"].stringValue// + json["count"].stringValue
        cell.detailTextLabel?.text = json["answer"].stringValue
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ""
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            if QnaData.remove(at: indexPath.row) {
                self.tableView.reloadData()
            }
        }
    }
    
    @IBAction func longPressDetected(_ sender: UILongPressGestureRecognizer) {
        if sender.state == UIGestureRecognizerState.began {
            let touchPoint = sender.location(in: self.view)
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                toEdit(at: indexPath)
            }
        }
    }
    
    func toEdit(at: IndexPath) {
        NSLog("to edit row \(at)")
        self.editingIndexPath = at
        performSegue(withIdentifier: "addQnaSegue", sender: nil)
        
    }
    
    func getEditingIndexPath() -> IndexPath? {
        return self.editingIndexPath
    }
    
    func didFinishEditing(toReload: Bool) {
        self.editingIndexPath = nil
        if toReload {
            self.tableView.reloadData()
        }
    }
    
}

protocol UpdateQnaDelegateProtocol {
    func didFinishEditing(toReload: Bool)
    func getEditingIndexPath() -> IndexPath?
}

