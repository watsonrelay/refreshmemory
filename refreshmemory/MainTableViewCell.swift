//
//  MainTableViewCell.swift
//  refreshmemory
//
//  Created by wyu on 3/26/17.
//  Copyright © 2017 CoreTek. All rights reserved.
//

import Foundation
import UIKit

protocol MainTableViewCellDelegate {
    func qnaSwiped(qna: Qna, direction: UISwipeGestureRecognizerDirection)
}

class MainTableViewCell : UITableViewCell {
    
    @IBOutlet weak var questionTitle: UILabel!
    @IBOutlet weak var answerTitle: UILabel!
    
    var originalCenter = CGPoint()
    var commitDirection : UISwipeGestureRecognizerDirection? = nil
    var delegate: MainTableViewCellDelegate?
    var qna: Qna?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let recognizer = UIPanGestureRecognizer(target: self, action: #selector(MainTableViewCell.handlePan(_:)))
        recognizer.delegate = self
        addGestureRecognizer(recognizer)
    }
    
    @IBAction func handlePan(_ sender: UIPanGestureRecognizer) {
        if sender.state == UIGestureRecognizerState.began {
            originalCenter = center
        } else if sender.state == UIGestureRecognizerState.changed {
            let translation = sender.translation(in: self)
            center = CGPoint.init(x: originalCenter.x + translation.x, y: originalCenter.y)
            var threshold = frame.size.width > 320.0 ? 160.0 : frame.size.width / 2.0
            if frame.origin.x < -threshold {
                commitDirection = UISwipeGestureRecognizerDirection.left
            } else if frame.origin.x > threshold {
                commitDirection = UISwipeGestureRecognizerDirection.right
            } else {
                commitDirection = nil
            }
        } else if sender.state == UIGestureRecognizerState.ended {
            let originalFrame = CGRect(x: 0, y: frame.origin.y, width: bounds.size.width, height: bounds.size.height)
            if commitDirection != nil {
                if delegate != nil && qna != nil {
                    delegate!.qnaSwiped(qna: qna!, direction: commitDirection!)
                }
            } else {
                UIView.animate(withDuration: 0.2, animations: {self.frame = originalFrame})
            }
        }
    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
            let translation = panGestureRecognizer.translation(in: superview!)
            if fabs(translation.x) > fabs(translation.y) {
                return true
            }
            return false
        }
        return false
    }

}
