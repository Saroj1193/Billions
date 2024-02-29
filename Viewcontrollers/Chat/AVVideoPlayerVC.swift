//
//  AVVideoPlayerVC.swift
//  BillionsApp
//
//  Created by Tristate on 09.11.21.
//


import UIKit
import AVKit

class AVVideoPlayerVC: AVPlayerViewController {
    var btnSwipeDownCallBack:(()->())?
    override func viewDidLoad() {
        super.viewDidLoad()
        showsPlaybackControls =  true
        view.backgroundColor = .clear
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction(_:)))
        swipeDown.direction = .down
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(swipeDown)
    }

    @objc func swipeAction(_ gesture: UISwipeGestureRecognizer){
        if gesture.direction == .down {
            btnSwipeDownCallBack?()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        player?.pause()
        player?.seek(to: .zero)
    }
}
