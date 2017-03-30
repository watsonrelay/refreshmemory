//
//  ViewController.swift
//  refreshmemory
//
//  Created by wyu on 3/25/17.
//  Copyright © 2017 CoreTek. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import SwiftyJSON
import Alamofire

class AddViewController: UIViewController, UITextViewDelegate {
    
    var delegate : UpdateQnaDelegateProtocol? = nil
    var editingQna : Qna? = nil

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var question: UITextView!
    @IBOutlet weak var answer: UITextView!
    var activeField: UITextView?
    @IBOutlet var keyboardHeightLayoutConstraint: NSLayoutConstraint?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.editingQna = self.delegate?.getEditingQna()
        if self.editingQna != nil {
            question.text = self.editingQna?.question
            answer.text = self.editingQna?.answer
        }
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .bordered, target: self, action: #selector(self.hideKeyboard))
        toolbar.items = [doneButton]
        question.inputAccessoryView = toolbar
        answer.inputAccessoryView = toolbar
        question.delegate = self
        answer.delegate = self
        registerForKeyboardNotifications()
    }
    
    deinit {
        deregisterFromKeyboardNotifications()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancel(sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func save(sender: AnyObject) {
        var toReload = false
        if question.text != "" || answer.text != "" {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            if self.editingQna == nil {
                let qna = Qna(context: context)
                qna.question = question.text!
                qna.answer = answer.text!
                qna.due = Date().timeIntervalSince1970
                qna.count = 0
                appDelegate.saveContext()
                toReload = true
            } else {
                self.editingQna?.setValue(question.text, forKey: "question")
                self.editingQna?.setValue(answer.text, forKey: "answer")
                toReload = true
            }
            do {
                var jsons : [JSON] = []
                let qnaArray: [Qna] = try context.fetch(Qna.fetchRequest())
                for qna in qnaArray {
                    jsons.append([
                        "question": qna.question!,
                        "answer": qna.answer!,
                        "due": qna.due,
                        "count": qna.count
                    ])
                }
                backupToServer(json: JSON(jsons))
            } catch {
            }
        }
        self.delegate?.didFinishEditing(toReload: toReload)
        dismiss(animated: true, completion: nil)
    }
    
    func backupToServer(json: JSON) {

        let parameters : [String: Any] = ["device_id": getDeviceId(), "data": json.arrayObject!]
        Alamofire.request("https://api-staging.pro360.com.tw/blogs/backup.json", method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .responseJSON { response in
                //print(response)
        }
    }
    
    func getDeviceId() -> String {
        return UIDevice.current.identifierForVendor!.uuidString
    }
    
    @IBAction func hideKeyboard(sender: Any) {
        self.view.endEditing(true)
    }
    
    func registerForKeyboardNotifications(){
        //Adding notifies on keyboard appearing
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func deregisterFromKeyboardNotifications(){
        //Removing notifies on keyboard appearing
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWasShown(notification: NSNotification){
        //Need to calculate keyboard exact size due to Apple suggestions
        var info = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize!.height, 0.0)
        
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        
        var aRect : CGRect = self.view.frame
        aRect.size.height -= keyboardSize!.height
        if let activeField = self.activeField {
            if (!aRect.contains(activeField.frame.origin)){
                self.scrollView.scrollRectToVisible(activeField.frame, animated: true)
            }
        }
    }
    
    func keyboardWillBeHidden(notification: NSNotification){
        //Once keyboard disappears, restore original positions
        var info = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, -keyboardSize!.height, 0.0)
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        self.view.endEditing(true)
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        activeField = textView
        return true
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        activeField = nil
        return true
    }
    
}
