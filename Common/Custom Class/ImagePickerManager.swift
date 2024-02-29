//
//  ImagePickerManager.swift
//  
//
//  Created by Tristate Technology on 09/12/19.
//  Copyright © 2019 Tristate. All rights reserved.
//

import UIKit
import AssetsLibrary
import Photos
import PhotosUI

class ImagePickerManager: NSObject{
    static let sharedInstance = ImagePickerManager()
    
    public typealias imageComplition = ( _ image : UIImage?,_ strName : String?,_ error : Error?) -> Void
    public typealias videoComplition = ( _ url : URL?,_ strName : String?,_ error : Error?) -> Void
    var complation = {( _ image : UIImage?,_ strName : String?,_ error : Error?) -> Void in  }
    var complationVideo = {( _ url : URL?,_ strName : String?,_ error : Error?) -> Void in  }
    
    enum galleryMode {
        case photo, video
    }
    fileprivate var gMode = galleryMode.photo
    
    override init() {
        super.init()
    }
    
    func openCameraAndPhotoLibrary(_ viewController : BaseViewController,isEdit : Bool = true,_ imageComplition : @escaping imageComplition){
        let alert:UIAlertController = UIAlertController(title: ConstantText.lngChooseImage, message: nil, preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: ConstantText.lngCamera, style: .default) {
            UIAlertAction in
            self.openCamara(viewController, isEdit: isEdit, imageComplition)
        }
        let gallaryAction = UIAlertAction(title: ConstantText.lngGallery, style: .default) {
            UIAlertAction in
            self.openPhotoLibrary(viewController, isEdit: isEdit, imageComplition)
        }
        let cancelAction = UIAlertAction(title: ConstantText.lngCanacel, style: .cancel) {
            UIAlertAction in
        }
        alert.addAction(cameraAction)
        alert.addAction(gallaryAction)
        alert.addAction(cancelAction)
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = viewController.view
            popoverController.sourceRect = CGRect(x: viewController.view.bounds.midX, y: viewController.view.bounds.maxY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        viewController.present(alert, animated: true, completion: nil)
    }
    
    func openCamara(_ vc : BaseViewController,isEdit : Bool,_ imageComplition : @escaping imageComplition){
        
        
        ImagePickerManager.sharedInstance.checkPermissionForCamera(authorizedRequested: {
            let picker = UIImagePickerController()
            picker.delegate = self
            if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera)) {
                DispatchQueue.main.async {
                    picker.sourceType = UIImagePickerController.SourceType.camera
                    self.gMode = .photo
                    picker.allowsEditing = isEdit
                    picker.cameraDevice = .front
                    picker.isEditing = isEdit
                    vc.present(picker, animated: true, completion: nil)
                    self.complation = imageComplition
                }
                
            }
            else {
                DispatchQueue.main.async {
                    vc.view.makeToast(ConstantText.lngDontHaveCamera)
                }
                
                
               
            }
        }) {
            DispatchQueue.main.async {
                vc.showAlertWithOkAndCancelHandler(string: ConstantText.lngCameraPermission, strOk: ConstantText.lngSettings, strCancel: ConstantText.lngCanacel, handler: { (isSettings) in
                    if isSettings{
                        UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!, options: [:], completionHandler: { (_ ) in
                            
                        })
                    }
                })
            }
            
        }
    }
    
    func openPhotoLibrary(_ vc : BaseViewController,isEdit : Bool,_ imageComplition : @escaping imageComplition){
        self.checkPhotoLibraryPermission(authorizedRequested: {
            if (UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary)) {
                DispatchQueue.main.async {
                    let picker = UIImagePickerController()
                    picker.delegate = self
                    self.gMode = .photo
                    picker.sourceType = UIImagePickerController.SourceType.photoLibrary
                    picker.allowsEditing = isEdit
                    picker.isEditing = isEdit
                    picker.modalPresentationStyle = .fullScreen
                    vc.present(picker, animated: true, completion: nil)
                    self.complation = imageComplition
                }
                
            }else{
                //no photoLibrary
                DispatchQueue.main.async {
                    vc.view.makeToast(ConstantText.lngDontHavePhoto)
                }
                
                
                
            }
        }) {
            //deniedRequested
            DispatchQueue.main.async {
                vc.showAlertWithOkAndCancelHandler(string: ConstantText.lngPhotoPermission, strOk: ConstantText.lngSettings, strCancel: ConstantText.lngCanacel, handler: { (isSettings) in
                    if isSettings{
                        UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!, options: [:], completionHandler: { (_ ) in
                            
                        })
                    }
                })
            }
            
        }
        
    }
    
    func openVideoLibrary(_ vc : BaseViewController, duration : Int,isEdit : Bool,_ videoComplition : @escaping videoComplition){
        DispatchQueue.main.async {
            self.checkPhotoLibraryPermission(authorizedRequested: {
                if (UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary)) {
                    DispatchQueue.main.async {
                        let picker = UIImagePickerController()
                        picker.delegate = self
                     self.gMode = .video
                        picker.sourceType = UIImagePickerController.SourceType.photoLibrary
                        picker.mediaTypes = ["public.movie"]
                     picker.videoMaximumDuration = TimeInterval(duration)
                        picker.allowsEditing = isEdit
                        picker.isEditing = isEdit
                        picker.modalPresentationStyle = .fullScreen
                        vc.present(picker, animated: true, completion: nil)
                        self.complationVideo = videoComplition
                    }
                    
                }else{
                    //no photoLibrary
                    DispatchQueue.main.async {
                        vc.view.makeToast(ConstantText.lngDontHavePhoto)
                    }
                 
                    
                }
            }) {
                //deniedRequested
                DispatchQueue.main.async {
                    vc.showAlertWithOkAndCancelHandler(string: ConstantText.lngPhotoPermission, strOk: ConstantText.lngSettings, strCancel: ConstantText.lngCanacel, handler: { (isSettings) in
                           if isSettings{
                               UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!, options: [:], completionHandler: { (_ ) in
                                   
                               })
                           }
                       })
                }
             
            }
        }
           
           
       }
    
    private func checkPermissionForCamera(authorizedRequested : @escaping () -> Swift.Void,deniedRequested : @escaping () -> Swift.Void) -> Void {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
           case .authorized:
            
               authorizedRequested()
           case .denied:
               deniedRequested()
           case .restricted:
               deniedRequested()
           case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted) in
                   DispatchQueue.main.async {
                       if granted {
                           authorizedRequested()
                       } else {
                           deniedRequested()
                       }
                   }
               })
            @unknown default: break
               
           }

    }
    
    private func checkPhotoLibraryPermission(authorizedRequested : @escaping () -> Swift.Void,deniedRequested : @escaping () -> Swift.Void) {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized:
            //handle authorized status
            authorizedRequested()
            break
        case .denied, .restricted :
            //handle denied status
            deniedRequested()
            break
        case .notDetermined:
            // ask for permissions
            PHPhotoLibrary.requestAuthorization() { status in
                switch status {
                case .authorized:
                    // as above
                    authorizedRequested()
                    break
                case .denied, .restricted:
                    deniedRequested()
                    break
                case .notDetermined:
                    // won't happen but still
                    break
                 default:
                    break;
                }
            }
            break
         default:
            break;
        }
    }
    
}

extension ImagePickerManager : UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard gMode == .photo else {
            if let urlMedia = info[UIImagePickerController.InfoKey.mediaURL] as? URL{
                self.complationVideo(urlMedia , "" , nil)
                picker.dismiss(animated: true, completion: nil)
            }
            return
        }
        
        picker .dismiss(animated: true, completion: nil)
        var image : UIImage?
        
        if let img = info[UIImagePickerController.InfoKey.editedImage] as? UIImage{
            image = img
        }else if let originalImg = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            image = originalImg
        }else{
            image = nil
        }
        var strImageName = ""
        if #available(iOS 11.0, *) {
            if (info[.imageURL] as? NSURL) != nil {
                let imageUrl          = info[.imageURL] as! NSURL
                let imageName :String! = imageUrl.pathExtension
                strImageName = "\(Int(Date().timeIntervalSince1970))."
                strImageName = strImageName.appending(imageName)
            }else{
                strImageName = "\(Int(Date().timeIntervalSince1970)).png"
            }
        } else {
            strImageName = "\(Int(Date().timeIntervalSince1970)).png"
        }
        guard image != nil else {
            self.complation(nil,nil,"enable to get image" as? Error)
            return
        }
        self.complation(image,strImageName,nil)
        
    }
   
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker .dismiss(animated: true, completion: nil)
        
        self.complation(nil,nil,nil)
    }
}

extension UIViewController {
    func showAlertWithOkAndCancelHandler(string: String,strOk:String,strCancel : String,handler: @escaping (_ isOkBtnPressed : Bool)->Void)
    {
        let alert = UIAlertController(title: "", message: string, preferredStyle: .alert)
        
        let alertOkayAction = UIAlertAction(title: strOk, style: .default) { (alert) in
            handler(true)
        }
        let alertCancelAction = UIAlertAction(title: strCancel, style: .default) { (alert) in
            handler(false)
        }
        alert.addAction(alertCancelAction)
        alert.addAction(alertOkayAction)
        
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
}
