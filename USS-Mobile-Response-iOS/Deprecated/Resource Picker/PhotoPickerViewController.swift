//
//  PhotoPickerViewController.swift
//  USS-Mobile-Response-iOS
//
//  Created by Andrew Tsai on 8/2/18.
//  Copyright © 2018 Andrew Tsai. All rights reserved.
//

import UIKit
import Photos
import CoreLocation

class PhotoPickerViewController: UIViewController, UIImagePickerControllerDelegate, CLLocationManagerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UITextViewDelegate
{
    var collectionReference: String = ""
    let textFieldLimit = 60
    
    var imageLabel: UILabel = {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Image: "
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        return label
    }()
    
    var titleLabel: UILabel = {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Title: "
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        return label
    }()
    
    var descriptionLabel: UILabel = {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Description: "
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        return label
    }()
    
    var notesLabel: UILabel = {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Notes: "
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        return label
    }()
    
    var imageView: UIImageView = {
        var imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = UIColor.white
        imageView.tintColor = UIColor.blue
        imageView.contentMode = .center
        imageView.contentScaleFactor = 1.5
        imageView.clipsToBounds = true
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.gray.cgColor
        imageView.layer.cornerRadius = 5
        imageView.layer.masksToBounds = true
        
        return imageView
    }()
    
    var titleTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.backgroundColor = UIColor.white
        textField.layer.borderColor = UIColor.gray.cgColor
        textField.layer.borderWidth = 1
        textField.layer.cornerRadius = 5
        textField.layer.masksToBounds = true
        
        return textField
    }()
    
    var descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.layer.borderColor = UIColor.gray.cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 5
        textView.layer.masksToBounds = true
        return textView
    }()
    
    var notesTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.layer.borderColor = UIColor.gray.cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 5
        textView.layer.masksToBounds = true
        return textView
    }()
    
    var imageURL: URL?
    var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    var containerView: UIView = {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        return containerView
    }()
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveAndUpload)), animated: true)
        
        scrollView.addSubview(containerView)
        view.addSubview(scrollView)
        view.backgroundColor = UIColor(red: 211/225, green: 211/225, blue: 211/225, alpha: 1)
    
        titleTextField.delegate = self
        descriptionTextView.delegate = self
        notesTextView.delegate = self

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGestureRecognizer)
        
        containerView.addSubview(imageLabel)
        containerView.addSubview(imageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(titleTextField)
        containerView.addSubview(descriptionLabel)
        containerView.addSubview(descriptionTextView)
        containerView.addSubview(notesLabel)
        containerView.addSubview(notesTextView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            containerView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16),
            containerView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1),
            imageLabel.topAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.topAnchor),
            imageLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            imageLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            imageView.topAnchor.constraintEqualToSystemSpacingBelow(imageLabel.bottomAnchor, multiplier: 1),
            imageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            imageView.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 1, constant: -16),
            imageView.heightAnchor.constraint(equalToConstant: 200),
            titleLabel.topAnchor.constraintEqualToSystemSpacingBelow(imageView.bottomAnchor, multiplier: 1.5),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            titleTextField.topAnchor.constraintEqualToSystemSpacingBelow(titleLabel.bottomAnchor, multiplier: 1),
            titleTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            titleTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            titleTextField.heightAnchor.constraint(equalToConstant: 40),
            descriptionLabel.topAnchor.constraintEqualToSystemSpacingBelow(titleTextField.bottomAnchor, multiplier: 1.5),
            descriptionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            descriptionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            descriptionTextView.topAnchor.constraintEqualToSystemSpacingBelow(descriptionLabel.bottomAnchor, multiplier: 1),
            descriptionTextView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            descriptionTextView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            descriptionTextView.heightAnchor.constraint(equalToConstant: 100),
            notesLabel.topAnchor.constraintEqualToSystemSpacingBelow(descriptionTextView.bottomAnchor, multiplier: 1.5),
            notesLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            notesLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            notesTextView.topAnchor.constraintEqualToSystemSpacingBelow(notesLabel.bottomAnchor, multiplier: 1),
            notesTextView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            notesTextView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            notesTextView.heightAnchor.constraint(equalToConstant: 100),
            notesTextView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
            ])
        
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
//        scrollView.contentSize = containerView.frame.size
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    @objc func keyboardWillShow(notification:NSNotification)
    {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification:NSNotification)
    {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0 {
                self.view.frame.origin.y += keyboardSize.height
            }
            self.view.frame.origin.y = 0
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        guard let text = textField.text else { return true }
        let newLength = text.count + string.count - range.length
        return newLength <= textFieldLimit
    }
    
    @objc func imageTapped()
    {
        showActionSheet(imageView: self.imageView)
    }
    
    @objc
    func saveAndUpload()
    {
        if (titleTextField.text?.isEmpty)! || (descriptionTextView.text?.isEmpty)!  || (notesTextView.text?.isEmpty)!{
            displayErrorMessage(title: "Empty fields.", message: "Please complete form.")
            return
        }
        if imageView.image == nil {
            displayErrorMessage(title: "Empty image.", message: "Please select an image.")
            return
        }
        print("4-1: Create local device entry")
        let savedName = createLocalEntry()
        print("4-2: HTTP uploading with custom plugin")
        httpUpload()
        print("4-3: Create resource on resource space")
        createResourceSpaceEntry(imageName: savedName)
        print("4-4: Add resource to selected collection")
        addResourceToCollection()
        print("4-4: Confirmation and update local history")
        self.navigationController?.popToRootViewController(animated: true)
    }
        
    func createLocalEntry() -> String
    {
        var newEntry = LocalEntry()
        var savedImageName = ""
        if let possibleImageURL = self.imageURL {
            savedImageName = saveImageAtDocumentDirectory(url: possibleImageURL)
        }
        else {
            savedImageName = saveExistingImageAtDocumentDirectory(image: self.imageView.image!)
        }
        newEntry.name = titleTextField.text!
        newEntry.description = descriptionTextView.text!
        newEntry.notes = notesTextView.text
        newEntry.collectionRef = self.collectionReference
        newEntry.localFileName = savedImageName
        newEntry.fileType = FileType.PHOTO.rawValue
        newEntry.submissionStatus = SubmissionStatus.LocalOnly.rawValue
        var oldEntries = getLocalEntriesFromDisk()
        oldEntries.append(newEntry)
        saveLocalEntriesToDisk(entries: oldEntries)
        return savedImageName
    }
    
    func httpUpload()
    {
        
    }
    
    func createResourceSpaceEntry(imageName: String) {
        let urlString = "https://geodata.geology.utah.gov/api/?"
        let privateKey = "7d510414a826c1af09d864e70c3656964839664786b8e774bafb7c10adc5fea1"
        let imageURL = getImageFromLocalEntriesDirectory(imageName: imageName)
        print("URL GOES HERE??")
        print(imageURL!)
        let queryString = "user=atsai-uuss&function=create_resource&param1=1&param2=0&param3=\(imageURL!)&param4=&param5=&param6=&param7="
        let signature = "&sign=" + (privateKey + queryString).sha256()!
        let completeURL = urlString + queryString + signature
        print(completeURL)
        guard let url = URL(string: completeURL) else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            }
            guard let data = data else { return }
            // JSON decodign and parsing
            do {
                // decode retrieved data with JSONDecoder
                let resourceSpaceData = try JSONDecoder().decode([Hazard].self, from: data)
                // return to main queue
                DispatchQueue.main.async {
                    
                    print(type(of: resourceSpaceData[0]))
                    // reload tableview or something
                    
                }
            } catch let jsonError {
                print(jsonError)
            }
            }.resume()
        print("done...?")
        print(completeURL)
    }
    
    func addResourceToCollection() {
        
    }

    private func displayErrorMessage(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Okay", style: .default, handler: {
            (action) in alert.dismiss(animated: true, completion: nil)
        })
        alert.addAction(dismissAction)
        present(alert, animated: true, completion: nil)
    }
    
    func showActionSheet(imageView: UIImageView) {

        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        
        // Create and modify an UIAlertController.actionSheet to allow option between Camera or Photo Library.
        let actionSheet = UIAlertController(title: "Photo Source", message: "Please choose a source for image upload.", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action: UIAlertAction) in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                imagePickerController.sourceType = .camera
                self.present(imagePickerController, animated: true, completion: nil)
            }
        }))
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (action: UIAlertAction) in
            imagePickerController.sourceType = .photoLibrary
            self.present(imagePickerController, animated: true, completion: nil)
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(actionSheet, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        self.imageView.image = image
        self.imageView.contentMode = .scaleAspectFill
        if let newURL = info[UIImagePickerControllerImageURL] as? URL {
            self.imageURL = newURL
        }
        else {
            
            PHPhotoLibrary.shared().performChanges({
                let assetChangeRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
                var currentLocation: CLLocation!
                if( CLLocationManager.authorizationStatus() == .authorizedWhenInUse ||
                    CLLocationManager.authorizationStatus() ==  .authorizedAlways){
                    
                    currentLocation = self.locationManager.location
                    
                }
                assetChangeRequest.location = currentLocation
            }) { (success, error) in
                if success {
                    
                } else {
                    let ac = UIAlertController(title: "Save error", message: error?.localizedDescription, preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(ac, animated: true)
                }
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    @objc
    func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer)
    {
        if let error = error {
            // we got back an error!
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
