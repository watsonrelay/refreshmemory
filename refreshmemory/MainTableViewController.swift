//
//  MainTableViewController.swift
//  refreshmemory
//
//  Created by wyu on 3/25/17.
//  Copyright © 2017 CoreTek. All rights reserved.
//

import Foundation
import UIKit
import UserNotifications
import SwiftyJSON

class MainTableViewController: BaseTableViewController, UNUserNotificationCenterDelegate, UpdateQnaDelegateProtocol {
    
    var isGrantedNotificationAccess : Bool = false
    var timer : Timer!
    
    func onTimer() {
        //NSLog("##########__________########## onTimer")
        self.tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //NSLog("##########__________########## set Timer")
        self.tableView.reloadData()
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

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return QnaData.getVisibleCount()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MainTableViewCell
        
        let userDefaults = UserDefaults.standard
        let qna = userDefaults.value(forKey: "qna")
        let data = JSON(data: qna as! Data)
        let json = data[indexPath.row]

        cell.questionTitle?.text = json["question"].stringValue
        cell.answerTitle?.text = json["answer"].stringValue
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            let updated = QnaData.dismiss(at: indexPath.row)
            if updated != JSON.null {
                self.tableView.reloadData()
                notify(updated: updated)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String {
        return "Dismiss";
    }
    
    func notify(updated: JSON) {
        if isGrantedNotificationAccess {
            //Set the content of the notification
            let content = UNMutableNotificationContent()
            content.title = "Reminder:"
            content.subtitle = updated["question"].stringValue
            content.body = updated["answer"].stringValue
            
            //Set the trigger of the notification -- here a timer.
            let now = Date().timeIntervalSince1970
            let time = updated["due"].doubleValue - now
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
