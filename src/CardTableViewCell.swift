//
//  CardTableViewCell.swift
//  Reading Vocabulary
//
//  Created by Raul Beltrán Beltrán on 16/03/2017.
//  Copyright © 2017 Raul Beltrán Beltrán. All rights reserved.
//

import UIKit

protocol SlidingCellDelegate {
    func isLeftTop() -> Bool
    func isRightTop() -> Bool
    // Tell the TableView that a swipe happened.
    func hasPerformedSwipe(touch: CGPoint, direction: Int)
    func hasPerformedTap(touch: CGPoint)
}

class CardTableViewCell: UITableViewCell {
    
    //MARK: Properties

    var slidingDelegate: SlidingCellDelegate?
    var originalCenter = CGPoint()
    var deleteOnDragRelease = false
    var touch = CGPoint()

    var rightLabel: UILabel!, leftLabel: UILabel!
    let kUICuesMargin: CGFloat = 10, kUICuesWidth: CGFloat = 50
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        // utility method for creating the contextual cues
        func createCueLabel(alignment: NSTextAlignment) -> UILabel {
            let label = UILabel(frame: CGRect.null)
            label.textColor = UIColor.white
            label.font = UIFont.boldSystemFont(ofSize: 14)
            label.backgroundColor = UIColor.white
            label.textAlignment = alignment
            return label
        }
        
        // labels for context cues
        rightLabel = createCueLabel(alignment: .left)
        leftLabel = createCueLabel(alignment: .right)
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // Add a PAN gesture.
        let pRecognizer = UIPanGestureRecognizer(target: self, action: #selector(CardTableViewCell.handlePan(_:)))
        pRecognizer.delegate = self
        addGestureRecognizer(pRecognizer)
        
        // Add a TAP gesture.
        // Adding the PAN gesture to a cell disables the built-in tap responder (didSelectRowAtIndexPath)
        // so TAP is added here for both; swipe and tap actions.
        let tRecognizer = UITapGestureRecognizer(target: self, action: #selector(CardTableViewCell.handleTap(_:)))
        tRecognizer.delegate = self
        addGestureRecognizer(tRecognizer)
        
        addSubview(rightLabel)
        rightLabel.frame = CGRect(x: -kUICuesWidth - kUICuesMargin, y: 0, width: kUICuesWidth, height: bounds.size.height)
        addSubview(leftLabel)
        leftLabel.frame = CGRect(x: bounds.size.width + kUICuesMargin, y: 0, width: kUICuesWidth, height: bounds.size.height)
    }
    
    //MARK: Actions
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {

        if let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
            let translation = panGestureRecognizer.translation(in: superview!)

            if (fabs(translation.x) > fabs(translation.y)) {
                // Look for swipe.
                touch = panGestureRecognizer.location(in: superview)
                return true
            }
            // Not left or right, must be up or down.
            return false
        } else if gestureRecognizer is UITapGestureRecognizer {
            touch = gestureRecognizer.location(in: superview)
            return true
        }
        return false
    }
    
    @objc func handleTap(_ recognizer: UITapGestureRecognizer){
        // Call function to get indexPath since didSelectRowAtIndexPath will be disabled.
        slidingDelegate?.hasPerformedTap(touch: touch)
    }
    
    @objc func handlePan(_ recognizer: UIPanGestureRecognizer) {
        
        if recognizer.state == .began {
            originalCenter = center
        }
        
        if recognizer.state == .changed {
            let translation = recognizer.translation(in: self)
            center = CGPoint(x: originalCenter.x + translation.x, y: originalCenter.y)
            // PAN is 1/2 width of the cell.
            deleteOnDragRelease = (frame.origin.x < -frame.size.width/2) || (frame.origin.x > frame.size.width/2)

            // fade the contextual clues
            let labelAlpha = fabs(frame.origin.x) / (frame.size.width / 2.0)
            
            if (translation.x < 0) {
                leftLabel.alpha = labelAlpha
                
                // indicate when the user has pulled the item far enough to invoke the given action
                if (slidingDelegate?.isLeftTop())! {
                    leftLabel.backgroundColor = deleteOnDragRelease ? UIColor.red : UIColor.orange
                } else {
                    leftLabel.backgroundColor = UIColor.gray
                }
            } else {            
                rightLabel.alpha = labelAlpha
                
                if (slidingDelegate?.isRightTop())! {
                    rightLabel.backgroundColor = deleteOnDragRelease ? UIColor.red : UIColor.orange
                } else {
                    rightLabel.backgroundColor = UIColor.gray
                }
            }
        }
        
        if recognizer.state == .ended {
            let originalFrame = CGRect(x: 0, y: frame.origin.y, width: bounds.size.width, height: bounds.size.height)
            
            if deleteOnDragRelease {
                slidingDelegate?.hasPerformedSwipe(touch: touch, direction: Int(recognizer.translation(in: self).x))
            }
            
            // After 'swipe animate back to origin slowly.
            UIView.animate(withDuration: 0.2, animations: {self.frame = originalFrame})
            rightLabel.alpha = 0
            leftLabel.alpha = 0
        }
    }

}
