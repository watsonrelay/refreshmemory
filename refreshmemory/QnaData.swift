//
//  QnaData.swift
//  refreshmemory
//
//  Created by wyu on 3/25/17.
//  Copyright © 2017 CoreTek. All rights reserved.
//

import Foundation
import SwiftyJSON

struct QnaData {
    var question: String
    var answer: String
}

extension QnaData {
    
    init() {
        self.question = ""
        self.answer = ""
    }
/*
    init?(question: String, answer: String) {
        self.question = question
        self.answer = answer
    }
*/
    init?(json: [String: Any]) {
        guard let question = json["question"] as? String,
            let answer = json["answer"] as? String
            else {
                return nil
        }
        
        self.question = question
        self.answer = answer
    }
    
    func append() -> JSON? {
        let newData: JSON = [[
            "question": question,
            "answer": answer
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
            userDefaults.setValue(data, forKey: "qna")
            userDefaults.synchronize()
        } catch {
        }
        return updated
    }
    
    static func remove(at: Int) -> Bool {
        let userDefaults = UserDefaults.standard
        let qna = userDefaults.value(forKey: "qna")
        if (qna != nil) {
            var json = JSON(data: qna as! Data)
            if (json.arrayObject?.count == 1) {
                userDefaults.removeObject(forKey: "qna")
                userDefaults.synchronize()
                return true
            } else if ((json.arrayObject?.count)! > 1) {
                json.arrayObject?.remove(at: at)
                let updated = JSON(json.arrayObject!)
                do {
                    let data = try updated.rawData()
                    userDefaults.setValue(data, forKey: "qna")
                    userDefaults.synchronize()
                } catch {
                }
                return true
            }
        }
        return false
    }
    
}
