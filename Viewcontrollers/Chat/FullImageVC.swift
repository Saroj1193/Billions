//
//  FullImageVC.swift
//  Smylee App
//
//  Created by Tristate on 11/11/20.
//  Copyright © 2020 Tristate. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import SDWebImage

typealias FullImageDismissHandler = (_ viewController: FullImageVC) -> ()

class FullImageVC: BaseViewController, UIScrollViewDelegate {
    var photo = [MessageListModel]()
    
    open var didDismissHandler: FullImageDismissHandler?
    
    @IBOutlet var fullImg: UIImageView!
    @IBOutlet weak var scrollZoom: UIScrollView!
    @IBOutlet var btnCross: UIButton!
    
    var longPressGestureHandler: ((UILongPressGestureRecognizer) -> ())?
    let playerController = AVVideoPlayerVC()
    
    lazy private(set) var doubleTapGestureRecognizer: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.handleDoubleTapWithGestureRecognizer(_:)))
        gesture.numberOfTapsRequired = 2
        return gesture
    }()
    
    lazy private(set) var longPressGestureRecognizer: UILongPressGestureRecognizer = {
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPressWithGestureRecognizer(_:)))
        return gesture
    }()
    
    var image = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fullImg.image = image
        scrollZoom.minimumZoomScale = 1
        scrollZoom.maximumZoomScale = 6.0
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction(_:)))
        swipeDown.direction = .down
        self.scrollZoom.isUserInteractionEnabled = true
        self.scrollZoom.addGestureRecognizer(swipeDown)
        self.btnCross.isHidden = true
//        
//        if photo[0]["localVideoUrl"] as? String ?? "" != "" || photo[0]["videoUrl"] as? String ?? "" != "" {
////            playerController.view.insertSubview(scrollZoom, at: 0) //addSubview(scrollZoom)
//            
//            playerController.view.frame = view.bounds
//            if let urlString = photo[0]["videoUrl"] as? String, let url = URL(string: urlString) {
//                let avAsset = AVURLAsset(url: url)
//                // AVPlayerItem with AVURLAsset we've just created
//                let avPlayerItem = AVPlayerItem(asset: avAsset)
//                
//                // retrieve external metadatas of AVPlayerItem
//                var metadata = avPlayerItem.externalMetadata
//
//                // Creation new metadata for thumbnail
//                let thumbnailMetadata = AVMutableMetadataItem()
//                thumbnailMetadata.keySpace = AVMetadataKeySpace.common
//                thumbnailMetadata.key = AVMetadataKey.commonKeyArtwork as NSString
//                thumbnailMetadata.identifier = AVMetadataIdentifier.commonIdentifierArtwork
//
//                thumbnailMetadata.dataType = kCMMetadataBaseDataType_JPEG as String
//                thumbnailMetadata.value = NSData.init(data: photo[0]["localImage"] as? Data ?? Data())
//                thumbnailMetadata.extendedLanguageTag = "und" as String
//                    
//                if let metadataItem = thumbnailMetadata.copy() as? AVMetadataItem {
//                    metadata.append(metadataItem)
//                }
//                
//                avPlayerItem.externalMetadata = metadata
//                
//                playerController.player = AVPlayer(playerItem: avPlayerItem) //AVPlayer(url: url)
//                view.addSubview(playerController.view)
//            }
//            playerController.view.addGestureRecognizer(doubleTapGestureRecognizer)
//            playerController.btnSwipeDownCallBack = {
//                self.dismiss(animated: true, completion: nil)
//            }
//        }
//        else {
//            view.addGestureRecognizer(doubleTapGestureRecognizer)
//            view.addGestureRecognizer(longPressGestureRecognizer)
//        }
        
        if let image = photo[0].localImage {
            self.fullImg.image = UIImage.init(data: image)
        } else if let thumbnailImage = photo[0].thumbnailImageUrl {
            loadThumbnailImage(thumbnailImage: thumbnailImage)
        } else {
            loadFullSizeImage()
        }
    }
    
    @objc func swipeAction(_ gesture: UISwipeGestureRecognizer){
        if gesture.direction == .down {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    private func loadThumbnailImage(thumbnailImage: String) {
        self.showSpinner()
        if let thumbnailImageURL = URL.init(string: thumbnailImage) {
            SDWebImageManager.shared.loadImage(with: thumbnailImageURL, options: [.scaleDownLargeImages, .continueInBackground],
                                               progress: nil) { (image, _, error, _, _, _) in
                self.hideSpinner()
                if error != nil {
                    self.loadFullSizeImage()
                } else {
                    self.fullImg.image = image
                }
            }
        }
    }
    
    private func loadFullSizeImage() {
        self.showSpinner()
        if let ImageURL = URL.init(string: photo[0].imageUrl ?? "") {
            SDWebImageManager.shared.loadImage(with: ImageURL, options: [.scaleDownLargeImages, .continueInBackground],
                                               progress: nil) { (image, _, error, _, _, _) in
                self.hideSpinner()
                if error != nil {
                    
                } else {
                    self.fullImg.image = image
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    //MARK:-IBAction
    
    @IBAction func btnBackAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return fullImg
    }
    
    open func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        scrollView.panGestureRecognizer.isEnabled = true
    }
    
    open func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        // There is a bug, especially prevalent on iPhone 6 Plus, that causes zooming to render all other gesture recognizers ineffective.
        // This bug is fixed by disabling the pan gesture recognizer of the scroll view when it is not needed.
        if (scrollView.zoomScale == scrollView.minimumZoomScale) {
            scrollView.panGestureRecognizer.isEnabled = false;
        }
    }
    
    @objc private func handleDoubleTapWithGestureRecognizer(_ recognizer: UITapGestureRecognizer) {
//        if photo[0]["videoUrl"] as? String ?? "" != "" || photo[0]["localVideoUrl"] as? String ?? "" != "" {
//            if playerController.videoGravity != .resizeAspectFill {
//                playerController.videoGravity = .resizeAspectFill
//            } else {
//                playerController.videoGravity = .resizeAspect
//            }
//            return
//        }
        
        let pointInView = recognizer.location(in: self.fullImg)
        var newZoomScale = scrollZoom.maximumZoomScale
        
        if self.scrollZoom.zoomScale >= self.scrollZoom.maximumZoomScale ||  abs(self.scrollZoom.zoomScale - self.scrollZoom.maximumZoomScale) <= 0.01 {
            newZoomScale = self.scrollZoom.minimumZoomScale
        }
        
        let scrollViewSize = self.scrollZoom.bounds.size
        let width = scrollViewSize.width / newZoomScale
        let height = scrollViewSize.height / newZoomScale
        let originX = pointInView.x - (width / 2.0)
        let originY = pointInView.y - (height / 2.0)
        
        let rectToZoom = CGRect(x: originX, y: originY, width: width, height: height)
        self.scrollZoom.zoom(to: rectToZoom, animated: true)
    }
    
    @objc private func handleLongPressWithGestureRecognizer(_ recognizer: UILongPressGestureRecognizer) {
        if recognizer.state == UIGestureRecognizer.State.began {
            longPressGestureHandler?(recognizer)
        }
    }
    
    open override func dismiss(animated flag: Bool, completion: (() -> Void)?) {
      if presentedViewController != nil {
        super.dismiss(animated: flag, completion: completion)
        return
      }
      
      super.dismiss(animated: flag) { () -> Void in
        let isStillOnscreen = self.view.window != nil
        
        if !isStillOnscreen {
          self.didDismissHandler?(self)
        }
        completion?()
      }
    }
}
