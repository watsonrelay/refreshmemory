//
//  MainTableViewController.swift
//  refreshmemory
//
//  Created by wyu on 3/25/17.
//  Copyright © 2017 CoreTek. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import UserNotifications
import SwiftyJSON

class MainTableViewController: BaseTableViewController, UNUserNotificationCenterDelegate, UpdateQnaDelegateProtocol, MainTableViewCellDelegate {
    
    var isGrantedNotificationAccess : Bool = false
    var timer : Timer!
    var selectedIndexPath : IndexPath? = nil
    let questionColor = UIColor(red: 248/255, green: 248/255, blue: 232/255, alpha: 1.0)
    let answerColor = UIColor(red: 240/255, green: 240/255, blue: 208/255, alpha: 1.0)
    
    func onTimer() {
        //NSLog("##########__________########## onTimer")
        reloadData()
    }
    
    override func reloadData() {
        var updated : [Qna] = []
        do {
            let request: NSFetchRequest<Qna> = Qna.fetchRequest()
            request.predicate = NSPredicate(format: "due < %lf", Date().timeIntervalSince1970)
            updated = try context.fetch(request)
            updated.sort{$0.due < $1.due}
        } catch {
            NSLog("Failed to reloadData")
        }
        if updated != qnaArray {
            qnaArray = updated
            self.tableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //NSLog("##########__________########## set Timer")
        timer = Timer.scheduledTimer(timeInterval: 20, target: self, selector: #selector(onTimer), userInfo: nil, repeats: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge],
            completionHandler: {
                (granted, error) in self.isGrantedNotificationAccess = granted
            }
        )
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //NSLog("##########__________########## stop Timer")
        timer.invalidate()
    }
    
    func qnaSwiped(qna: Qna, direction: UISwipeGestureRecognizerDirection) {
        if direction == UISwipeGestureRecognizerDirection.left {
            NSLog("LEFT swipeDetected")
            qna.setValue(Date().timeIntervalSince1970 + 3600, forKey: "due")
        } else if direction == UISwipeGestureRecognizerDirection.right {
            NSLog("RIGHT swipeDetected")
            qna.setValue(Date().timeIntervalSince1970 + 8 * 3600, forKey: "due")
        }
        qna.setValue(qna.count + 1, forKey: "count")
        reloadData()
        notify(updated: qna)
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return qnaArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MainTableViewCell
        let qna = qnaArray[indexPath.row]
        if (indexPath == selectedIndexPath) {
            cell.questionTitle?.text = "Answer:"
            cell.answerTitle?.text = qna.answer
            cell.contentView.subviews[0].backgroundColor = answerColor
        } else {
            cell.questionTitle?.text = "Question:"
            cell.answerTitle?.text = qna.question
            cell.contentView.subviews[0].backgroundColor = questionColor
        }
        cell.delegate = self
        cell.qna = qna
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            let qna = qnaArray[indexPath.row]
            qna.setValue(Date().timeIntervalSince1970 + 8 * 3600, forKey: "due")
            qna.setValue(qna.count + 1, forKey: "count")
            reloadData()
            notify(updated: qna)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath == selectedIndexPath) {
            selectedIndexPath = nil
            tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.left)
        } else {
            let prevIndexPath = selectedIndexPath
            selectedIndexPath = indexPath
            tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.right)
            if prevIndexPath != nil {
                tableView.reloadRows(at: [prevIndexPath!], with: UITableViewRowAnimation.none)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String {
        return "Dismiss";
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func notify(updated: Qna) {
        if isGrantedNotificationAccess {
            //Set the content of the notification
            let content = UNMutableNotificationContent()
            content.title = "Reminder:"
            content.subtitle = updated.question!
            content.body = updated.answer!
            
            //Set the trigger of the notification -- here a timer.
            let now = Date().timeIntervalSince1970
            let time = updated.due - now
            //NSLog("##########__________########## notify after \(time)")
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: time, repeats: false)
            
            //Set the request for the notification from the above
            let request = UNNotificationRequest(identifier: "refresh.memory \(now)", content: content, trigger: trigger)
            
            //Add the notification to the currnet notification center
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "addQnaSegue") {
            let addVC : AddViewController = segue.destination as! AddViewController
            addVC.delegate = self
        } else if (segue.identifier == "editQnaSegue") {
            let navC : UINavigationController = segue.destination as! UINavigationController
            let editVC : EditTableViewController = navC.topViewController as! EditTableViewController
            editVC.delegate = self
        }
    }
    
}
