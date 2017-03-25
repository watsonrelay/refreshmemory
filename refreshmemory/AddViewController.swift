//
//  ViewController.swift
//  refreshmemory
//
//  Created by wyu on 3/25/17.
//  Copyright © 2017 CoreTek. All rights reserved.
//

import UIKit
import SwiftyJSON

class AddViewController: UIViewController {
    
    var delegate : AddQnaDelegateProtocol? = nil

    @IBOutlet weak var question: UITextField!
    @IBOutlet weak var answer: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancel(sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func save(sender: AnyObject) {
        
        let qna = QnaData(question: question.text!, answer: answer.text!)
        let result = qna.append()
        if result != nil {
            self.delegate?.didAddQna()
        }
        
        /*
        let newData: JSON = [[
            "question": question.text!,
            "answer": answer.text!
        ]]
        
        let userDefaults = UserDefaults.standard
        let qna = userDefaults.value(forKey: "qna")
        let updated : JSON
        if (qna != nil) {
            var json = JSON(data: qna as! Data)
            updated = JSON(json.arrayObject! + newData.arrayObject!)
        } else {
            updated = newData
        }
        
        do {
            let data = try updated.rawData()
            let userDefaults = UserDefaults.standard
            userDefaults.setValue(data, forKey: "qna")
            userDefaults.synchronize() // don't forget this!!!!
            self.delegate?.didAddQna()
        } catch {
            
        }
 */
        dismiss(animated: true, completion: nil)
    }
    
}

protocol AddQnaDelegateProtocol {
    func didAddQna()
}
