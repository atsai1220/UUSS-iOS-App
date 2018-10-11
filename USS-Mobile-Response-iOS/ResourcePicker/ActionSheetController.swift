//
//  ActionSheetController.swift
//  USS-Mobile-Response-iOS
//
//  Created by Andrew Tsai on 10/9/18.
//  Copyright © 2018 Andrew Tsai. All rights reserved.
//

import UIKit

class ActionSheetController: NSObject {
    
    var currentMode: ActionSheetMode?
    var imagePickerController: UIImagePickerController?
    
    enum ActionSheetMode: String {
        case PHOTOS = "PHOTOS"
        case VIDEOS = "VIDEOS"
        case AUDIOS = "AUDIOS"
        case PDFS = "PDFS"
    }
    
    init(mode: ActionSheetMode) {
        currentMode = mode
    }
    
 
    
    func configureActionSheet() {
        if let mode = currentMode {
            switch mode {
                case .PHOTOS:
                    print("Photo Mode")
                case .VIDEOS:
                    print("Video Mode")
                case .AUDIOS:
                    print("Audio Mode")
                case .PDFS:
                    print("PDF Mode")
            }
        }
    }
    
//    func showPhotosMode() {
//        checkPhotoPermission()
//        // Create and modify an UIAlertController.actionSheet to allow option between Camera or Photo Library.
//        let actionSheet = UIAlertController(title: "Photo Source", message: "Please choose a source for image upload.", preferredStyle: .actionSheet)
//
//        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action: UIAlertAction) in
//            if UIImagePickerController.isSourceTypeAvailable(.camera) {
//                self.imagePickerController!.sourceType = .camera
//                self.present(self.imagePickerController, animated: true, completion: nil)
//            }
//        }))
//        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (action: UIAlertAction) in
//            self.imagePickerController.sourceType = .photoLibrary
//            self.present(self.imagePickerController, animated: true, completion: nil)
//        }))
//        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
//
//        self.present(actionSheet, animated: true, completion: nil)
//    }
    
//    private func checkPhotoPermission() {
//        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
//        switch photoAuthorizationStatus {
//        case .authorized:
//            print("Access is granted by user")
//        case .notDetermined:
//            PHPhotoLibrary.requestAuthorization({
//                (newStatus) in
//                print("status is \(newStatus)")
//                if newStatus ==  PHAuthorizationStatus.authorized {
//                    /* do stuff here */
//                    print("success")
//                }
//            })
//            print("It is not determined until now")
//        case .restricted:
//            // same same
//            print("User do not have access to photo album.")
//        case .denied:
//            // same same
//            print("User has denied the permission.")
//        }
//    }
}
