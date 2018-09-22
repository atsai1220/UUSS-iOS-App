//
//  VideoViewController.swift
//  USS-Mobile-Response-iOS
//
//  Created by Charlie Barber on 9/14/18.
//  Copyright © 2018 Andrew Tsai. All rights reserved.
//

import Foundation
import UIKit
import Photos
import MobileCoreServices

class VideoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    var imagePickerController: UIImagePickerController?
    var collectionReference: String = ""
    var safeArea: UILayoutGuide?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        safeArea = self.view.safeAreaLayoutGuide
        imagePickerController = UIImagePickerController()
        imagePickerController!.delegate = self

        self.view.backgroundColor = UIColor(red: 195.0/255.0, green: 81.0/255.0, blue: 47.0/255.0, alpha: 1.0)
        
        let videoBoxTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(videoBoxTapped))
        let titleBoxTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(titleBoxTapped))
        let descriptionBoxTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(descriptionBoxTapped))
        let notesBoxTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(notesBoxTapped))
        
        let videoBox: UIInputView = UIInputView()
        videoBox.addGestureRecognizer(videoBoxTap)
        videoBox.translatesAutoresizingMaskIntoConstraints = false
        videoBox.backgroundColor = UIColor.white
        videoBox.layer.borderColor = UIColor.black.cgColor
        videoBox.layer.borderWidth = 5.0
        videoBox.layer.cornerRadius = 5.0
        videoBox.layer.shadowRadius = 3.0
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
        
        let titleBox: UIInputView = UIInputView()
        titleBox.addGestureRecognizer(titleBoxTap)
        titleBox.translatesAutoresizingMaskIntoConstraints = false
        titleBox.backgroundColor = UIColor.white
        titleBox.layer.borderColor = UIColor.black.cgColor
        titleBox.layer.borderWidth = 5.0
        titleBox.layer.cornerRadius = 5.0
        titleBox.layer.shadowRadius = 3.0
        titleBox.layer.shadowOffset = CGSize(width: 0.0, height: 5.0)
        titleBox.layer.shadowOpacity = 1.0
        titleBox.layer.shadowColor = UIColor.black.cgColor
        self.view.addSubview(titleBox)
        
        let titleLabel: UILabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Add Title"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 25.0)
        titleLabel.textColor = UIColor.black
        titleBox.addSubview(titleLabel)
        
        let descriptionBox: UIInputView = UIInputView()
        descriptionBox.addGestureRecognizer(descriptionBoxTap)
        descriptionBox.translatesAutoresizingMaskIntoConstraints = false
        descriptionBox.backgroundColor = UIColor.white
        descriptionBox.layer.borderColor = UIColor.black.cgColor
        descriptionBox.layer.borderWidth = 5.0
        descriptionBox.layer.cornerRadius = 5.0
        descriptionBox.layer.shadowRadius = 3.0
        descriptionBox.layer.shadowOffset = CGSize(width: 0.0, height: 5.0)
        descriptionBox.layer.shadowOpacity = 1.0
        descriptionBox.layer.shadowColor = UIColor.black.cgColor
        self.view.addSubview(descriptionBox)
        
        let descriptionLabel: UILabel = UILabel()
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.text = "Add Description"
        descriptionLabel.font = UIFont.boldSystemFont(ofSize: 25.0)
        descriptionLabel.textColor = UIColor.black
        descriptionBox.addSubview(descriptionLabel)
        
        let notesBox: UIInputView = UIInputView()
        notesBox.addGestureRecognizer(notesBoxTap)
        notesBox.translatesAutoresizingMaskIntoConstraints = false
        notesBox.backgroundColor = UIColor.white
        notesBox.layer.borderColor = UIColor.black.cgColor
        notesBox.layer.borderWidth = 5.0
        notesBox.layer.cornerRadius = 5.0
        notesBox.layer.shadowRadius = 3.0
        notesBox.layer.shadowOffset = CGSize(width: 0.0, height: 5.0)
        notesBox.layer.shadowOpacity = 1.0
        notesBox.layer.shadowColor = UIColor.black.cgColor
        self.view.addSubview(notesBox)
        
        let notesLabel: UILabel = UILabel()
        notesLabel.translatesAutoresizingMaskIntoConstraints = false
        notesLabel.text = "Add Notes"
        notesLabel.font = UIFont.boldSystemFont(ofSize: 25.0)
        notesLabel.textColor = UIColor.black
        notesBox.addSubview(notesLabel)
        
        
        let logo: UIImageView = UIImageView(image: UIImage(named: "DNR"))
        
        logo.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(logo)
        
        let views: [String: Any] = ["logo": logo, "videoBox": videoBox, "titleBox": titleBox, "descriptionBox": descriptionBox, "notesBox": notesBox]
    
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[logo(<=50)]", options: [], metrics: nil, views: views))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[logo(<=50)]", options: [], metrics: nil, views: views))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[videoBox]-|", options: [], metrics: nil, views: views))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[titleBox]-|", options: [], metrics: nil, views: views))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[titleBox(<=75)]", options: [], metrics: nil, views: views))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[descriptionBox]-|", options: [], metrics: nil, views: views))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[descriptionBox(<=125)]", options: [], metrics: nil, views: views))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[notesBox]-|", options: [], metrics: nil, views: views))
//        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[notesBox(<=150)]", options: [], metrics: nil, views: views))

        NSLayoutConstraint.activate([
            logo.topAnchor.constraintEqualToSystemSpacingBelow(safeArea!.topAnchor, multiplier: 2.0),
            logo.centerXAnchor.constraintEqualToSystemSpacingAfter(self.view.centerXAnchor, multiplier: 1.0),
            videoBox.topAnchor.constraintEqualToSystemSpacingBelow(safeArea!.topAnchor, multiplier: 10.0),
            videoBox.bottomAnchor.constraintEqualToSystemSpacingBelow(safeArea!.topAnchor, multiplier: 35.0),
            videoBox.centerXAnchor.constraintEqualToSystemSpacingAfter(videoBoxLabel.centerXAnchor, multiplier: 1.0),
            videoBox.centerYAnchor.constraintEqualToSystemSpacingBelow(videoBoxLabel.centerYAnchor, multiplier: 1.0),
            titleBox.topAnchor.constraintEqualToSystemSpacingBelow(videoBox.bottomAnchor, multiplier: 2.0),
            titleLabel.centerXAnchor.constraintEqualToSystemSpacingAfter(titleBox.centerXAnchor, multiplier: 1.0),
            titleLabel.centerYAnchor.constraintEqualToSystemSpacingBelow(titleBox.centerYAnchor, multiplier: 1.0),
            descriptionBox.topAnchor.constraintEqualToSystemSpacingBelow(titleBox.bottomAnchor, multiplier: 2.0),
            descriptionLabel.centerXAnchor.constraintEqualToSystemSpacingAfter(descriptionBox.centerXAnchor, multiplier: 1.0),
            descriptionLabel.centerYAnchor.constraintEqualToSystemSpacingBelow(descriptionBox.centerYAnchor, multiplier: 1.0),
            notesBox.topAnchor.constraintEqualToSystemSpacingBelow(descriptionBox.bottomAnchor, multiplier: 2.0),
            notesBox.bottomAnchor.constraintEqualToSystemSpacingBelow(safeArea!.bottomAnchor, multiplier: 1.0),
            notesLabel.centerXAnchor.constraintEqualToSystemSpacingAfter(notesBox.centerXAnchor, multiplier: 1.0),
            notesLabel.centerYAnchor.constraintEqualToSystemSpacingBelow(notesBox.centerYAnchor, multiplier: 1.0)
            ])
    }
    
    
    func videoIsAvailable(for sourceType: UIImagePickerControllerSourceType) -> Bool
    {
        let types = UIImagePickerController.availableMediaTypes(for: .camera)
        
        for type in types!
        {
            if(type == kUTTypeMovie as String)
            {
                return true
            }
        }
        
        return false
    }
    
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
//    {
//        <#code#>
//    }
//
//    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
//    {
//        <#code#>
//    }
    
//    override func viewWillAppear(_ animated: Bool)
//    {
//        super.viewWillAppear(animated)
//        AppDelegate.AppUtility.lockOrientation(.all)
//    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        AppDelegate.AppUtility.lockOrientation(.portrait)
    }
    
    func selectionDidChange(_ textInput: UITextInput?)
    {
        print("Video Box touched")
    }
    
    func selectionWillChange(_ textInput: UITextInput?)
    {
        print("test")
    }
    
    func textWillChange(_ textInput: UITextInput?)
    {
        print("test")
    }
    
    func textDidChange(_ textInput: UITextInput?)
    {
        print("test")
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        print("recorded movie")
        imagePickerController?.dismiss(animated: true, completion: nil)
    }
    
    func showActionSheet()
    {
//        let actionSheet: UIAlertController = UIAlertController(title: "Choose Video Source", message: "Take a new video or use a video from your library", preferredStyle: .actionSheet)
        
        let actionSheet: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        actionSheet.addAction(UIAlertAction(title: "New Video", style: .default, handler: {(alert: UIAlertAction) -> Void in
            print("new Video")
            
            if(UIImagePickerController.isSourceTypeAvailable(.camera))
            {
                self.imagePickerController!.sourceType = .camera
                
                if(self.videoIsAvailable(for: self.imagePickerController!.sourceType))
                {
                    
                   self.imagePickerController!.mediaTypes = [kUTTypeMovie as String]
                    
                   self.present(self.imagePickerController!, animated: true, completion: nil)
                }
                else
                {
                    let alert: UIAlertController = UIAlertController(title: "Video Unavailable", message: "Video is not available on your device", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Choose Video", style: .default, handler: {(alert: UIAlertAction) -> Void in
            print("Video")
        }))
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {(alert: UIAlertAction)-> Void in
            actionSheet.dismiss(animated: true, completion: nil)
        })
        
        cancelAction.setValue(UIColor.red, forKey: "titleTextColor")
        
        actionSheet.addAction(cancelAction)
        
        self.present(actionSheet, animated: true, completion: nil)
        
    }
    
    @objc func videoBoxTapped()
    {
        print("videoBox tapped")
        
        showActionSheet()
    }
    
    @objc func titleBoxTapped()
    {
        print("TitleBox tapped")
    }
    
    @objc func descriptionBoxTapped()
    {
        print("Description box tapped")
    }
    
    @objc func notesBoxTapped()
    {
        print("Notes Box tapped")
    }
    
    
}
