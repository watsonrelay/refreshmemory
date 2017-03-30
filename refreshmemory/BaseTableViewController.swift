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

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var editingQna : Qna? = nil
    var qnaArray : [Qna] = []
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ""
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
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
        if at.row >= 0 && at.row < self.qnaArray.count {
            self.editingQna = self.qnaArray[at.row]
            performSegue(withIdentifier: "addQnaSegue", sender: nil)
        }
    }
    
    func getEditingQna() -> Qna? {
        return self.editingQna
    }
    
    func didFinishEditing(toReload: Bool) {
        self.editingQna = nil
        if toReload {
            self.reloadData()
        }
    }
    
    func reloadData() {
    }
}

protocol UpdateQnaDelegateProtocol {
    func didFinishEditing(toReload: Bool)
    func getEditingQna() -> Qna?
}

