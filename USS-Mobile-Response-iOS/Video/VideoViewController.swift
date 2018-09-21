//
//  VideoViewController.swift
//  USS-Mobile-Response-iOS
//
//  Created by Charlie Barber on 9/14/18.
//  Copyright © 2018 Andrew Tsai. All rights reserved.
//

import UIKit
import Photos
import MobileCoreServices

class VideoViewController: UIViewController, UIImagePickerControllerDelegate
{
    var imagePickerController: UIImagePickerController?
    var collectionReference: String = ""
    var safeArea: UILayoutGuide?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        safeArea = self.view.safeAreaLayoutGuide
        
        let backgrondImage: UIImageView = UIImageView(image: UIImage(named: "granite"))
       
        backgrondImage.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(backgrondImage)
        
        let videoBox: UIInputView = UIInputView()
        videoBox.translatesAutoresizingMaskIntoConstraints = false
        videoBox.backgroundColor = UIColor.white
        videoBox.layer.borderColor = UIColor.black.cgColor
        videoBox.layer.borderWidth = 5.0
        videoBox.layer.cornerRadius = 5.0
        videoBox.layer.shadowRadius = 25.0
        videoBox.layer.shadowOffset = CGSize(width: 0.0, height: 5.0)
        videoBox.layer.shadowOpacity = 1.0
        videoBox.layer.shadowColor = UIColor.black.cgColor
        self.view.addSubview(videoBox)
        
        let videoBoxLabel: UILabel = UILabel()
        videoBoxLabel.translatesAutoresizingMaskIntoConstraints = false
        videoBoxLabel.text = "Add Video"
        videoBoxLabel.font = UIFont.boldSystemFont(ofSize: 25.0)
        videoBoxLabel.textColor = UIColor.black
        videoBox.addSubview(videoBoxLabel)
        
        
        let views: [String: Any] = ["backgroundImg": backgrondImage, "videoBox": videoBox]
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[backgroundImg]|", options: [], metrics: nil, views: views))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[backgroundImg]|", options: [], metrics: nil, views: views))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[videoBox]-|", options: [], metrics: nil, views: views))
        
        NSLayoutConstraint.activate([
            videoBox.topAnchor.constraintEqualToSystemSpacingBelow(safeArea!.topAnchor, multiplier: 2.0),
            videoBox.bottomAnchor.constraintEqualToSystemSpacingBelow(safeArea!.topAnchor, multiplier: 30.0),
            videoBox.centerXAnchor.constraintEqualToSystemSpacingAfter(videoBoxLabel.centerXAnchor, multiplier: 1.0),
            videoBox.centerYAnchor.constraintEqualToSystemSpacingBelow(videoBoxLabel.centerYAnchor, multiplier: 1.0)
            ])
    }
    
    
//    func videoIsAvailable(for sourceType: UIImagePickerController.SourceType) -> Bool
//    {
//        let types = UIImagePickerController.availableMediaTypes(for: .camera)
//        
//        for type in types!
//        {
//            if(type == kUTTypeMovie as String)
//            {
//                return true
//            }
//        }
//        
//        return false
//    }
    
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
//    {
//        <#code#>
//    }
//
//    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
//    {
//        <#code#>
//    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        AppDelegate.AppUtility.lockOrientation(.all)
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        AppDelegate.AppUtility.lockOrientation(.portrait)
    }
}

//imagePickerController = UIImagePickerController()
////        imagePickerController!.delegate = self
//
//if(UIImagePickerController.isSourceTypeAvailable(.camera))
//{
//    imagePickerController!.sourceType = .camera
//
//    if(videoIsAvailable(for: imagePickerController!.sourceType))
//    {
//        imagePickerController!.mediaTypes = [kUTTypeMovie as String]
//
//        self.present(imagePickerController!, animated: true, completion: nil)
//    }
//    else
//    {
//        let alert: UIAlertController = UIAlertController(title: "Video Unavailable", message: "Video is not available on your device", preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
//        self.present(alert, animated: true, completion: nil)
//    }
//}
