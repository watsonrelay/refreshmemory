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

class MainTableViewController: UITableViewController, AddQnaDelegateProtocol {
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let userDefaults = UserDefaults.standard
        let qna = userDefaults.value(forKey: "qna")
        if qna != nil {
            let data = JSON(data: qna as! Data)
            return (data.arrayObject?.count)!
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let userDefaults = UserDefaults.standard
        let qna = userDefaults.value(forKey: "qna")
        let data = JSON(data: qna as! Data)
        let json = data[indexPath.row]

        cell.textLabel?.text = json["question"].stringValue
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
    
    override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String {
        return "Dismiss";
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "addQnaSegue") {
            let addVC : AddViewController = segue.destination as! AddViewController
            addVC.delegate = self
        }
    }
    
    func didAddQna() {
        self.tableView.reloadData()
    }

    
}
