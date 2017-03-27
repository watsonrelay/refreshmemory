//
//  QnaData.swift
//  refreshmemory
//
//  Created by wyu on 3/25/17.
//  Copyright © 2017 CoreTek. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire

struct QnaData {
    var question: String
    var answer: String
    var due: Double
    var count: Int
}

extension QnaData {
    
    init() {
        self.question = ""
        self.answer = ""
        self.due = 0.0
        self.count = 0
    }

    init?(json: [String: Any]) {
        guard let question = json["question"] as? String,
            let answer = json["answer"] as? String
            else {
                return nil
        }
        
        self.question = question
        self.answer = answer
        self.due = (json["due"] as? Double)!
        self.count = (json["count"] as? Int)!
    }
    
    func prepend() -> JSON? {
        let newData: JSON = [[
            "question": question,
            "answer": answer,
            "due": due,
            "count": count
        ]]
        
        let userDefaults = UserDefaults.standard
        let qna = userDefaults.value(forKey: "qna")
        let updated : JSON
        if (qna != nil) {
            var json = JSON(data: qna as! Data)
            updated = JSON(newData.arrayObject! + json.arrayObject!)
        } else {
            updated = newData
        }
        
        do {
            let data = try updated.rawData()
            userDefaults.setValue(data, forKey: "qna")
            userDefaults.synchronize()
            backupToServer(json: updated)
        } catch {
        }
        return updated
    }
    
    static func get(at: Int) -> JSON {
        let userDefaults = UserDefaults.standard
        let qna = userDefaults.value(forKey: "qna")
        if (qna != nil) {
            var json = JSON(data: qna as! Data)
            if at >= 0 && json.count > at {
                return json[at]
            }
        }
        return JSON.null        
    }
    
    func update(at: Int) -> Bool {
        let userDefaults = UserDefaults.standard
        let qna = userDefaults.value(forKey: "qna")
        if qna != nil {
            let jsons = JSON(data: qna as! Data)
            var jsonArray = jsons.arrayValue
            if at >= 0 && at < jsonArray.count {
                let target = jsons[at];
                jsonArray.remove(at: at)
                let updated: JSON = [
                    "question": self.question,
                    "answer": self.answer,
                    "due": target["due"].doubleValue,
                    "count": target["count"].intValue
                ]
                jsonArray.insert(updated, at: at)
                do {
                    let data = try JSON(jsonArray).rawData()
                    userDefaults.setValue(data, forKey: "qna")
                    userDefaults.synchronize()
                    return true
                } catch {
                }
            }
        }
        return false
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
                    return true
                } catch {
                }
            }
        }
        return false
    }
    
    static func dismiss(at: Int) -> JSON {
        let userDefaults = UserDefaults.standard
        let qna = userDefaults.value(forKey: "qna")
        var updated : JSON = JSON.null
        if qna != nil {
            let jsons = JSON(data: qna as! Data)
            var jsonArray = jsons.arrayValue
            if at >= 0 && at < jsonArray.count {
                let target = jsons[at];
                jsonArray.remove(at: at)
                if target["count"].intValue < 7 {
                    updated = [
                        "question": target["question"].stringValue,
                        "answer": target["answer"].stringValue,
                        "due": Date().timeIntervalSince1970 + 8 * 3600,
                        "count": target["count"].intValue + 1
                    ]
                    jsonArray.append(updated)
                }
                do {
                    let data = try JSON(jsonArray).rawData()
                    userDefaults.setValue(data, forKey: "qna")
                    userDefaults.synchronize()
                } catch {
                }
            }
        }
        return updated
    }
    
    static func getCount() -> Int {
        let userDefaults = UserDefaults.standard
        let qna = userDefaults.value(forKey: "qna")
        if qna != nil {
            return JSON(data: qna as! Data).count
        }
        return 0
    }
    
    static func getVisibleCount() -> Int {
        let userDefaults = UserDefaults.standard
        let qna = userDefaults.value(forKey: "qna")
        if qna != nil {
            let jsons = JSON(data: qna as! Data)
            if jsons.count > 0 {
                let now = Date().timeIntervalSince1970
                for index in 0...jsons.count - 1 {
                    if (jsons[index]["due"].doubleValue > now) {
                        //print("visible count\(index), now:\(now), due:\(jsons[index]["due"].doubleValue)")
                        return index
                    }
                }
            }
            //print("visible count \(jsons.count) (all)")
            return jsons.count
        }
        return 0
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
}
