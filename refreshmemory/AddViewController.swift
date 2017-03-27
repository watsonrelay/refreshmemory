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
    
    var delegate : UpdateQnaDelegateProtocol? = nil
    var indexPath : IndexPath? = nil

    @IBOutlet weak var question: UITextView!
    @IBOutlet weak var answer: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.indexPath = self.delegate?.getEditingIndexPath()
        if self.indexPath != nil {
            let json = QnaData.get(at: (self.indexPath?.row)!)
            question.text = json["question"].stringValue
            answer.text = json["answer"].stringValue
        }
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
            let qna = QnaData(question: question.text!, answer: answer.text!, due: 0, count: 0)
            if self.indexPath == nil {
                let result = qna.prepend()
                if result != nil {
                    toReload = true
                }
            } else {
                toReload = qna.update(at: (self.indexPath?.row)!)
            }
        }
        self.delegate?.didFinishEditing(toReload: toReload)
        dismiss(animated: true, completion: nil)
    }
    
}
