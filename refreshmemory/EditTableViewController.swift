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
    
    override func reloadData() {
        do {
            qnaArray = try context.fetch(Qna.fetchRequest())
            qnaArray.sort{$0.due < $1.due}
        } catch {
            NSLog("Failed to getCoreData")
            qnaArray = []
        }
        self.tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return qnaArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! EditTableViewCell

        let myFormatter = DateFormatter()
        myFormatter.dateFormat = "yy/MM/dd HH:mm"

        let qna = qnaArray[indexPath.row]
        cell.questionTitle?.text = qna.question
        cell.answerTitle?.text = qna.answer
        cell.countDisplay.text = "\(qna.count)"
        cell.timeDisplay.text = myFormatter.string(from: Date(timeIntervalSince1970: qna.due))
        
        return cell
    }
   
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            let qna = qnaArray[indexPath.row]
            context.delete(qna)
            do {
                try context.save()
            } catch let error as NSError {
                print("Error While Deleting Note: \(error.userInfo)")
            }
            reloadData()
            self.delegate?.didFinishEditing(toReload: true)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "addQnaSegue") {
            let addVC : AddViewController = segue.destination as! AddViewController
            addVC.delegate = self
        }
    }
    
}
