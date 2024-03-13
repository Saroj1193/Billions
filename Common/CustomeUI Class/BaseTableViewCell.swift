//
//  BaseTableViewCell.swift
//  BillionsApp
//
//  Created by tristate22 on 07.03.24.
//

import UIKit

class BaseTableViewCell: UITableViewCell {
    //declare the `UISwipeGestureRecognizer`
    let swipeGesture = UISwipeGestureRecognizer()

    //a call back to notify the swipe in `cellForRowAt` as follow.
    var replyCallBack : ( () -> Void)?
    var view1 = UIView()
    var img = UIImageView()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setSwipeGesture(){
            // Add the swipe gesture and set the direction to the right or left according to your needs
            swipeGesture.direction = .right
            contentView.addGestureRecognizer(swipeGesture)
            
            // Add a target to the swipe gesture to handle the swipe
            swipeGesture.addTarget(self, action: #selector(handleSwipe(_:)))
     }
    
    @objc func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
                // Animate the action view onto the screen when the user swipes right
                if gesture.direction == .right {
                    UIView.animate(withDuration: 0.3) {
                        self.view1.transform = CGAffineTransform(translationX: self.contentView.frame.width / 1.5, y: 0)
                        self.img.transform = CGAffineTransform(translationX: self.contentView.frame.width / 1.5, y: 0)
                        // Schedule a timer to restore the cell after 0.2 seconds or change it according to your needs
                        Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { (_) in
                            UIView.animate(withDuration: 0.2) {
                                self.view1.transform = .identity
                                self.img.transform = .identity

                                //callback to notify in cellForRowAt
                                self.replyCallBack?()

                                //your code when
                            }
                        }
                    }
                } else {
                    // Animate the action view off the screen when the user swipes left

                UIView.animate(withDuration: 0.3) {
                    self.view1.transform = .identity
                    self.img.transform = .identity

                }
            }
        }
}
