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

class VideoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate
{
    var imagePickerController: UIImagePickerController?
    var collectionReference: String = ""
    var safeArea: UILayoutGuide?
//    var videoBox: UIImageView?
    var videoBoxLabel: UILabel?
    var titleBox: UITextView?
    var titleLabel: UILabel?
    var descriptionBox: UITextView?
    var descriptionLabel: UILabel?
    var notesBox: UITextView?
    var notesLabel: UILabel?
    var videoUrl: URL?
    var videoThumbnail: UIImage?
    var fileManager: FileManager?
    var videoPath: NSURL?
    var activeTextView: UITextView?
    var origInsets: UIEdgeInsets?
    
    let videoBox: UIImageView =
    {
        var videoBox: UIImageView = UIImageView()
        videoBox.translatesAutoresizingMaskIntoConstraints = false
        videoBox.backgroundColor = UIColor.white
        videoBox.layer.borderColor = UIColor.black.cgColor
        videoBox.layer.borderWidth = 5.0
        videoBox.layer.cornerRadius = 5.0
        videoBox.layer.shadowRadius = 3.0
        videoBox.layer.shadowOffset = CGSize(width: 0.0, height: 5.0)
        videoBox.layer.shadowOpacity = 1.0
        videoBox.layer.shadowColor = UIColor.black.cgColor
        
        return videoBox
    }()
    
    let toolBar: UIToolbar =
    {
        var toolBar: UIToolbar = UIToolbar()
        toolBar.translatesAutoresizingMaskIntoConstraints = false
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        var doneButtonItem: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneEnteringText))
        var flexibleSpace: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolBar.setItems([flexibleSpace, doneButtonItem], animated: true)
        return toolBar
    }()
    
    var scrollView: UIScrollView =
    {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.isUserInteractionEnabled = true
        return scrollView
    }()
    
    var containerView: UIView =
    {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.isUserInteractionEnabled = true
        return containerView
    }()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        safeArea = self.view.safeAreaLayoutGuide
        imagePickerController = UIImagePickerController()
        imagePickerController!.delegate = self
        
        let saveButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveVideoData))
        self.navigationItem.rightBarButtonItem = saveButton

        scrollView.backgroundColor = UIColor.lightGray
        scrollView.addSubview(containerView)

        self.view.addSubview(scrollView)
        

        let videoBoxTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(videoBoxTapped))
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDisplayed), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHidden), name: Notification.Name.UIKeyboardWillHide, object: nil)
        
        videoBox.isUserInteractionEnabled = true
        videoBox.addGestureRecognizer(videoBoxTap)
        containerView.addSubview(videoBox)

        videoBoxLabel = UILabel()
        videoBoxLabel!.translatesAutoresizingMaskIntoConstraints = false
        videoBoxLabel!.text = "Add Video"
        videoBoxLabel!.font = UIFont.boldSystemFont(ofSize: 25.0)
        videoBoxLabel!.textColor = UIColor.black
        videoBox.addSubview(videoBoxLabel!)
        
        titleBox = UITextView()
        titleBox!.delegate = self
        titleBox!.textAlignment = .center
        titleBox!.tag = 0
        titleBox!.textContainerInset = UIEdgeInsets(top: 25.0, left: 20.0, bottom: 10.0, right: 20.0)
        titleBox!.font = UIFont.boldSystemFont(ofSize: 25.0)
        titleBox!.textColor = UIColor.black
        titleBox!.inputAccessoryView = toolBar
        titleBox!.translatesAutoresizingMaskIntoConstraints = false
        titleBox!.layer.borderColor = UIColor.black.cgColor
        titleBox!.layer.borderWidth = 5.0
        titleBox!.layer.cornerRadius = 5.0
        titleBox!.layer.shadowRadius = 3.0
        titleBox!.layer.shadowOffset = CGSize(width: 0.0, height: 10.0)
        titleBox!.layer.shadowOpacity = 1.0
        titleBox!.layer.shadowColor = UIColor.black.cgColor
        containerView.addSubview(titleBox!)

        titleLabel = UILabel()
        titleLabel!.translatesAutoresizingMaskIntoConstraints = false
        titleLabel!.text = "Add Title"
        titleLabel!.font = UIFont.boldSystemFont(ofSize: 25.0)
        titleLabel!.textColor = UIColor.black
        titleBox!.addSubview(titleLabel!)

        descriptionBox = UITextView()
        descriptionBox!.delegate = self
        descriptionBox!.tag = 1
        descriptionBox!.textContainerInset = UIEdgeInsets(top: 25.0, left: 20.0, bottom: 10.0, right: 20.0)
        descriptionBox!.font = UIFont.boldSystemFont(ofSize: 25.0)
        descriptionBox!.inputAccessoryView = toolBar
        descriptionBox!.translatesAutoresizingMaskIntoConstraints = false
        descriptionBox!.backgroundColor = UIColor.white
        descriptionBox!.layer.borderColor = UIColor.black.cgColor
        descriptionBox!.layer.borderWidth = 5.0
        descriptionBox!.layer.cornerRadius = 5.0
        descriptionBox!.layer.shadowRadius = 3.0
        descriptionBox!.layer.shadowOffset = CGSize(width: 0.0, height: 5.0)
        descriptionBox!.layer.shadowOpacity = 1.0
        descriptionBox!.layer.shadowColor = UIColor.black.cgColor
        scrollView.addSubview(descriptionBox!)

        descriptionLabel = UILabel()
        descriptionLabel!.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel!.text = "Add Description"
        descriptionLabel!.font = UIFont.boldSystemFont(ofSize: 25.0)
        descriptionLabel!.textColor = UIColor.black
        descriptionBox!.addSubview(descriptionLabel!)

        notesBox = UITextView()
        notesBox!.delegate = self
        notesBox!.tag = 2
        notesBox!.textContainerInset = UIEdgeInsets(top: 25.0, left: 20.0, bottom: 10.0, right: 20.0)
        notesBox!.font = UIFont.boldSystemFont(ofSize: 25.0)
        notesBox!.inputAccessoryView = toolBar
        notesBox!.translatesAutoresizingMaskIntoConstraints = false
        notesBox!.backgroundColor = UIColor.white
        notesBox!.layer.borderColor = UIColor.black.cgColor
        notesBox!.layer.borderWidth = 5.0
        notesBox!.layer.cornerRadius = 5.0
        notesBox!.layer.shadowRadius = 3.0
        notesBox!.layer.shadowOffset = CGSize(width: 0.0, height: 5.0)
        notesBox!.layer.shadowOpacity = 1.0
        notesBox!.layer.shadowColor = UIColor.black.cgColor
        scrollView.addSubview(notesBox!)

        notesLabel = UILabel()
        notesLabel!.translatesAutoresizingMaskIntoConstraints = false
        notesLabel!.text = "Add Notes"
        notesLabel!.font = UIFont.boldSystemFont(ofSize: 25.0)
        notesLabel!.textColor = UIColor.black
        notesBox!.addSubview(notesLabel!)
        
        
        let logo: UIImageView = UIImageView(image: UIImage(named: "DNR"))

        logo.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(logo)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: self.view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            containerView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            containerView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor),
            logo.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20.0),
            logo.centerXAnchor.constraint(equalTo: containerView.centerXAnchor, constant: 1.0),
            logo.heightAnchor.constraint(equalToConstant: 50.0),
            logo.widthAnchor.constraint(equalToConstant: 50.0),
            videoBox.topAnchor.constraint(equalTo: logo.bottomAnchor, constant: 15.0),
            videoBox.heightAnchor.constraint(equalToConstant: 200.0),
            videoBox.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.9),
            videoBox.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            videoBoxLabel!.centerXAnchor.constraint(equalTo: videoBox.centerXAnchor),
            videoBoxLabel!.centerYAnchor.constraint(equalTo: videoBox.centerYAnchor),
            titleBox!.topAnchor.constraint(equalTo: videoBox.bottomAnchor, constant: 15.0),
            titleBox!.heightAnchor.constraint(equalToConstant: 75.0),
            titleBox!.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.9),
            titleBox!.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            titleLabel!.centerXAnchor.constraint(equalTo: titleBox!.centerXAnchor),
            titleLabel!.centerYAnchor.constraint(equalTo: titleBox!.centerYAnchor),
            descriptionBox!.topAnchor.constraint(equalTo: titleBox!.bottomAnchor, constant: 15.0),
            descriptionBox!.heightAnchor.constraint(equalToConstant: 150.0),
            descriptionBox!.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.9),
            descriptionBox!.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            descriptionLabel!.centerXAnchor.constraintEqualToSystemSpacingAfter(descriptionBox!.centerXAnchor, multiplier: 1.0),
            descriptionLabel!.centerYAnchor.constraintEqualToSystemSpacingBelow(descriptionBox!.centerYAnchor, multiplier: 1.0),
            notesBox!.topAnchor.constraint(equalTo: descriptionBox!.bottomAnchor, constant: 15.0),
            notesBox!.heightAnchor.constraint(equalToConstant: 175.0),
            notesBox!.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.9),
            notesBox!.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            notesLabel!.centerXAnchor.constraintEqualToSystemSpacingAfter(notesBox!.centerXAnchor, multiplier: 1.0),
            notesLabel!.centerYAnchor.constraintEqualToSystemSpacingBelow(notesBox!.centerYAnchor, multiplier: 1.0)
            ])
    }
    
    func videoIsAvailable(for sourceType: UIImagePickerControllerSourceType ) -> Bool
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
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        AppDelegate.AppUtility.lockOrientation(.portrait)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        switch picker.sourceType
        {
            case .camera:
               
                videoPath = info[UIImagePickerControllerMediaURL] as? NSURL
                print("path is \(videoPath!.relativePath!)")
                
                if(UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(videoPath!.absoluteString!))
                {
                    videoThumbnail = createVideoThumbnail(from: videoPath!.absoluteString!)
                    UISaveVideoAtPathToSavedPhotosAlbum(videoPath!.relativePath!, self, #selector(videoSaved) , nil)
                    self.videoBox.image = videoThumbnail
                    self.videoBoxLabel!.removeFromSuperview()
                }
                else
                {
                    let alert: UIAlertController = UIAlertController(title: "Error", message: "The video could not be saved to your camera roll", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
                
                imagePickerController!.dismiss(animated: true, completion: nil)
            
            case .savedPhotosAlbum:
            
                videoPath = info[UIImagePickerControllerMediaURL] as? NSURL
                let image: UIImage = createVideoThumbnail(from: self.videoPath!.absoluteString!)
            
                self.videoBox.image = image
                self.videoBoxLabel!.removeFromSuperview()
            
                imagePickerController!.dismiss(animated: true, completion: nil)
            
            case .photoLibrary:
                break
        }
        
    }
    
    
    func createVideoThumbnail(from url: String) -> UIImage
    {
            print(URL(string: url)!)
            let asset = AVAsset(url: URL(string: url)!)
            let assetImgGenerate = AVAssetImageGenerator(asset: asset)
            assetImgGenerate.appliesPreferredTrackTransform = true
        
            let time = CMTimeMakeWithSeconds(1.0, 600)
            do {
                let img = try assetImgGenerate.copyCGImage(at: time, actualTime: nil)
                let thumbnail = UIImage(cgImage: img)
                return thumbnail
            }
            catch
            {
                print(error.localizedDescription)
                return UIImage()
            }
    }
    
    @objc func videoSaved(video: String,  didFinishSavingWithError: NSError, contextInfo: Any)
    {
        let alert: UIAlertController = UIAlertController(title: "Video Saved", message: "Your video was successfully saved to your camera roll", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func showActionSheet()
    {
        
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
            print("Existing Video")
            
            if(UIImagePickerController.isSourceTypeAvailable(.camera))
            {
                self.imagePickerController!.sourceType = .savedPhotosAlbum
                self.imagePickerController!.mediaTypes = [kUTTypeMovie as String]
                self.present(self.imagePickerController!, animated: true, completion: nil)
            }
            else
            {
                let alert: UIAlertController = UIAlertController(title: "No Photo Library", message: "There was a problem accessing your camera roll", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }))
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {(alert: UIAlertAction)-> Void in
            actionSheet.dismiss(animated: true, completion: nil)
        })
        
        cancelAction.setValue(UIColor.red, forKey: "titleTextColor")
        
        actionSheet.addAction(cancelAction)
        
        self.present(actionSheet, animated: true, completion: nil)
        
    }
    
    @objc func doneEnteringText()
    {
        self.activeTextView = nil
        self.view.endEditing(true)
    }

    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool
    {
        switch textView.tag
        {
            case 0:
                self.titleLabel!.removeFromSuperview()
                self.activeTextView = textView
                return true
            case 1:
                self.descriptionLabel!.removeFromSuperview()
                self.activeTextView = textView
                return true
            case 2:
                self.notesLabel!.removeFromSuperview()
                self.activeTextView = textView
                return true
            default:
                return false
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView)
    {
        switch textView.tag
        {
            case 0:
                if(textView.text.count == 0)
                {
                    self.titleBox!.addSubview(self.titleLabel!)
                    NSLayoutConstraint.activate([
                            self.titleLabel!.centerXAnchor.constraintEqualToSystemSpacingAfter(self.titleBox!.centerXAnchor, multiplier: 1.0),
                            self.titleLabel!.centerYAnchor.constraintEqualToSystemSpacingBelow(self.titleBox!.centerYAnchor, multiplier: 1.0)
                        ])
                }
            case 1:
                if(textView.text.count == 0)
                {
                    self.descriptionBox!.addSubview(self.descriptionLabel!)
                    NSLayoutConstraint.activate([
                            self.descriptionLabel!.centerXAnchor.constraintEqualToSystemSpacingAfter(self.descriptionBox!.centerXAnchor, multiplier: 1.0),
                            self.descriptionLabel!.centerYAnchor.constraintEqualToSystemSpacingBelow(self.descriptionBox!.centerYAnchor, multiplier: 1.0)
                        ])
                }
            case 2:
                if(textView.text.count == 0)
                {
                    self.notesBox!.addSubview(self.notesLabel!)
                    NSLayoutConstraint.activate([
                            self.notesLabel!.centerXAnchor.constraintEqualToSystemSpacingAfter(self.notesBox!.centerXAnchor, multiplier: 1.0),
                            self.notesLabel!.centerYAnchor.constraintEqualToSystemSpacingBelow(self.notesBox!.centerYAnchor, multiplier: 1.0)
                        ])
                }
            default:
                break
        }
    }
    
    @objc func videoBoxTapped()
    {
        print("videoBoxTapped")
        showActionSheet()
    }
    
    @objc func keyboardDisplayed(notification: Notification)
    {
        let infoDict: NSDictionary = notification.userInfo! as NSDictionary
        let keyboardSize: CGRect = (infoDict[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue

        let contentInsets: UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height, 0.0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets

        let rect: CGRect = self.view.frame
    
        if(rect.contains(activeTextView!.frame.origin))
        {
            scrollView.scrollRectToVisible(activeTextView!.frame, animated: true)
        }
    }
    
    @objc func keyboardHidden(notification: Notification)
    {
        let infoDict: NSDictionary = notification.userInfo! as NSDictionary
        let keyboardSize: CGRect = (infoDict[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue

        let contentInsets: UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0 - keyboardSize.height, 0.0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
    
    @objc func saveVideoData()
    {
        saveVideoToDisk()
        var localVideoEntry: LocalEntry = LocalEntry()
      
        localVideoEntry.localFileName = self.titleBox!.text
        localVideoEntry.collectionRef = self.collectionReference
        localVideoEntry.description = self.descriptionBox!.text
        localVideoEntry.notes = self.notesBox!.text
        localVideoEntry.fileType = FileType.VIDEO.rawValue
        localVideoEntry.videoURL = self.videoPath!.absoluteString
        
        var oldEntries = getLocalEntriesFromDisk()
        oldEntries.append(localVideoEntry)
        saveLocalEntriesToDisk(entries: oldEntries)
        self.navigationController!.popToRootViewController(animated: true)
    }
    
    func saveVideoToDisk()
    {
        fileManager = FileManager.default
        let docURL: [URL] = fileManager!.urls(for: .documentDirectory, in: .userDomainMask)
        self.videoUrl = docURL[0].appendingPathComponent("\(self.titleBox!.text)" + "/")
        print(videoUrl!.relativeString)
        
        do
        {
            let videoData: Data? = try Data(contentsOf: videoPath! as URL)
            fileManager!.createFile(atPath: self.videoUrl!.relativePath, contents: videoData, attributes: nil)
        }
        catch
        {
            let alert: UIAlertController = UIAlertController(title: "Error", message: "There was a problem getting the video data for saving the file. Please try again", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}
