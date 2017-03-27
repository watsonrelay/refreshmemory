//
//  EditTableViewController.swift
//  refreshmemory
//
//  Created by wyu on 3/26/17.
//  Copyright © 2017 CoreTek. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class EditTableViewController: BaseTableViewController, UpdateQnaDelegateProtocol {
    
    var delegate : UpdateQnaDelegateProtocol? = nil
    
    @IBAction func done(sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! EditTableViewCell
        
        let userDefaults = UserDefaults.standard
        let qna = userDefaults.value(forKey: "qna")
        let data = JSON(data: qna as! Data)
        let json = data[indexPath.row]
        
        cell.questionTitle?.text = json["question"].stringValue
        cell.answerTitle?.text = json["answer"].stringValue
        cell.countDisplay.text = json["count"].stringValue
        
        let myFormatter = DateFormatter()
        myFormatter.dateFormat = "yy/MM/dd HH:mm"
        cell.timeDisplay.text = myFormatter.string(from: Date(timeIntervalSince1970: json["due"].doubleValue))
        
        return cell
    }
   
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            if QnaData.remove(at: indexPath.row) {
                self.delegate?.didFinishEditing(toReload: true)
                self.tableView.reloadData()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "addQnaSegue") {
            let addVC : AddViewController = segue.destination as! AddViewController
            addVC.delegate = self
        }
    }
    
}
