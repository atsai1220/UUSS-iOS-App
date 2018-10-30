//
//  LocalEntryTableViewController.swift
//  USS-Mobile-Response-iOS
//
//  Created by Andrew Tsai on 10/5/18.
//  Copyright © 2018 Andrew Tsai. All rights reserved.
//

import UIKit
import Photos
import CoreLocation
import MobileCoreServices
import PDFKit

class LocalEntryTableViewController: UITableViewController, UITextViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, CLLocationManagerDelegate, UIPickerViewDelegate, UIPickerViewDataSource, PDFDelegate, Mp3Delegate
{
    let infoCellId = "infoCellId"
    let resourceCellId = "resourceCellId"
    let hazardCellId = "hazardCellId"
    let subcategoryCellId = "subcategoryCellId"
    let collectionCellId = "collectionCellId"
    let additionalButtonCellId = "additionalButtonCellId"
    let alternativeFileCellId = "alternativeFileCellId"
    let locationManager = CLLocationManager()
    let imagePickerController = UIImagePickerController()
    
    // Resource Info section related
    var previewImage: UIImage?
    var submissionStatus: SubmissionStatus = SubmissionStatus.LocalOnly
    var resourceType: FileType = FileType.PHOTO
    var resourceSelected = false
    var imageURL: URL?
    
    // Hazards related
    var hazardSelected = false
    var subcategorySelected = false
    var collectionSelected = false
    var entryReference: String?
    var selectedHazard: String?
    var selectedSubcategory: String?
    var selectedCollection: String?
    var allHazards: [Hazard] = []
    var allCategories: [Hazard] = []
    var allCollections: [Hazard] = []
    var hazardTitles: [String] = []
    var subcategoryTitles: [String] = []
    var collectionTitles: [String] = []
    var hazardsDictionary: [String: [Hazard]] = [:]
    var categoryDictionary: [String: [Hazard]] = [:]
    var collectionDictionary: [String: [Hazard]] = [:]
    let hazardPicker = UIPickerView()
    let subcategoryPicker = UIPickerView()
    let collectionPicker = UIPickerView()
    var collectionOnly = false
    var videoData: Data?
    var videoThumbnail: UIImage?
    var videoUrl: URL?
    var videoThumbnailURL: URL?
    var localFileName: String?
    var pdfCollectionViewController: PdfCollectionViewController?
    var pdfURL: URL?
    
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
    var showPicker = false
    
    // Alt files related
    var pickingForAltFiles = false
    var altFiles: [AltFile] = []
    var localEntry: LocalEntry?
    
    // MARK: - Picker View
    
    func removeAllPickerView() {
        if hazardPicker.isDescendant(of: self.view) {
            UIView.animate(withDuration: 0.3, animations: {
                self.hazardPicker.alpha = 0.0
            }) { (done) in
                if done {
                    self.hazardPicker.removeFromSuperview()
                }
            }
        }
        if subcategoryPicker.isDescendant(of: self.view) {
            UIView.animate(withDuration: 0.3, animations: {
                self.subcategoryPicker.alpha = 0.0
            }) { (done) in
                if done {
                    self.subcategoryPicker.removeFromSuperview()
                }
            }
        }
        if collectionPicker.isDescendant(of: self.view) {
            UIView.animate(withDuration: 0.3, animations: {
                self.collectionPicker.alpha = 0.0
            }) { (done) in
                if done {
                    self.collectionPicker.removeFromSuperview()
                }
            }
        }
    }
    
    func toggleHazardPickerView() {
        if !hazardPicker.isDescendant(of: self.view) {
            view.addSubview(hazardPicker)
            UIView.animate(withDuration: 0.3) {
                self.hazardPicker.alpha = 1.0
            }
            hazardPicker.delegate = self
            hazardPicker.dataSource = self
            hazardPicker.translatesAutoresizingMaskIntoConstraints = false
            self.showPicker = true
            
            hazardPicker.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
            hazardPicker.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
            hazardPicker.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
            
        } else {
            UIView.animate(withDuration: 0.3, animations: {
                self.hazardPicker.alpha = 0.0
            }) { (done) in
                if done {
                    self.hazardPicker.removeFromSuperview()
                }
            }
            self.showPicker = false
        }
    }
    
    @objc func toggleCategoryPickerView() {
        if !subcategoryPicker.isDescendant(of: self.view) {
            view.addSubview(subcategoryPicker)
            UIView.animate(withDuration: 0.3) {
                self.subcategoryPicker.alpha = 1.0
            }
            subcategoryPicker.delegate = self
            subcategoryPicker.dataSource = self
            subcategoryPicker.translatesAutoresizingMaskIntoConstraints = false
            
            subcategoryPicker.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
            subcategoryPicker.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
            subcategoryPicker.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
            
        } else {
            UIView.animate(withDuration: 0.3, animations: {
                self.subcategoryPicker.alpha = 0.0
            }) { (done) in
                if done {
                    self.subcategoryPicker.removeFromSuperview()
                }
            }
        }
    }
    
    @objc func toggleCollectionPickerView() {
        if !collectionPicker.isDescendant(of: self.view) {
            view.addSubview(collectionPicker)
            UIView.animate(withDuration: 0.3) {
                self.collectionPicker.alpha = 1.0
            }
            collectionPicker.delegate = self
            collectionPicker.dataSource = self
            collectionPicker.translatesAutoresizingMaskIntoConstraints = false
            
            collectionPicker.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
            collectionPicker.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
            collectionPicker.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
            
        } else {
            UIView.animate(withDuration: 0.3, animations: {
                self.collectionPicker.alpha = 0.0
            }) { (done) in
                if done {
                    self.collectionPicker.removeFromSuperview()
                }
            }
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.isEqual(hazardPicker) {
            return self.hazardTitles.count
        }
        else if pickerView.isEqual(subcategoryPicker) {
            return self.subcategoryTitles.count
        }
        else {
            return self.collectionTitles.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.isEqual(hazardPicker) {
            if self.hazardTitles.count > 0 {
                return self.hazardTitles[row]
            }
        }
        else if pickerView.isEqual(subcategoryPicker) {
            if self.subcategoryTitles.count > 0 {
                return self.subcategoryTitles[row]
            }
        }
        else {
            if self.collectionTitles.count > 0 {
                return self.collectionTitles[row]
            }
        }
        return "Should never happen"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row == 0 {
            return
        }
        else if pickerView.isEqual(hazardPicker) {
            if self.hazardTitles.count > 0 {
                self.hazardSelected = true
                self.selectedHazard = self.hazardTitles[row]
                toggleHazardPickerView()
                loadCollectionAndCategoryArrays()
                
                if subcategoryTitles.count - 1 == 0 && collectionTitles.count - 1 > 0 {
                    collectionOnly = true
                } else {
                    collectionOnly = false
                }
 
                if subcategoryTitles.count - 1 > 0 && collectionTitles.count - 1 > 0 {
                    tableView.beginUpdates()
                    if tableView.numberOfRows(inSection: 0) == 2 {
                        tableView.insertRows(at: [IndexPath(row: 2, section: 0)], with: .fade)
                        tableView.insertRows(at: [IndexPath(row: 3, section: 0)], with: .fade)
                    } else if tableView.numberOfRows(inSection: 0) == 3 {
                        tableView.deleteRows(at: [IndexPath(row: 2, section: 0)], with: .fade)
                        tableView.insertRows(at: [IndexPath(row: 2, section: 0)], with: .fade)
                        tableView.insertRows(at: [IndexPath(row: 3, section: 0)], with: .fade)
                    } else {
                        tableView.deleteRows(at: [IndexPath(row: 2, section: 0)], with: .fade)
                        tableView.deleteRows(at: [IndexPath(row: 3, section: 0)], with: .fade)
                        tableView.insertRows(at: [IndexPath(row: 2, section: 0)], with: .fade)
                        tableView.insertRows(at: [IndexPath(row: 3, section: 0)], with: .fade)
                    }
                    
                    tableView.endUpdates()
                }
                else if subcategoryTitles.count - 1 == 0 && collectionTitles.count - 1 > 0 {
                    tableView.beginUpdates()
                    if tableView.numberOfRows(inSection: 0) == 2 {
                        self.tableView.insertRows(at: [IndexPath(row: 2, section: 0)], with: .fade)
                    } else if tableView.numberOfRows(inSection: 0) == 3 {
                        self.tableView.deleteRows(at: [IndexPath(row: 2, section: 0)], with: .fade)
                        self.tableView.insertRows(at: [IndexPath(row: 2, section: 0)], with: .fade)
                    } else if collectionOnly {
                        tableView.deleteRows(at: [IndexPath(row: 2, section: 0)], with: .fade)
                        tableView.deleteRows(at: [IndexPath(row: 3, section: 0)], with: .fade)
                        self.tableView.insertRows(at: [IndexPath(row: 2, section: 0)], with: .fade)
                    } else {
                        print("didSelectRow: does this ever hapen?")
                        tableView.deleteRows(at: [IndexPath(row: 2, section: 0)], with: .fade)
                        tableView.deleteRows(at: [IndexPath(row: 3, section: 0)], with: .fade)
                        self.tableView.insertRows(at: [IndexPath(row: 2, section: 0)], with: .fade)
                    }
                    tableView.endUpdates()
                   
                }
                self.subcategorySelected = false
                self.collectionSelected = false
                self.selectedSubcategory = nil
                self.selectedCollection = nil
                tableView.reloadData()
            }
        }
        else if pickerView.isEqual(subcategoryPicker) {
            if self.subcategoryTitles.count > 0 {
                self.subcategorySelected = true
                self.selectedSubcategory = self.subcategoryTitles[row]
                
                toggleCategoryPickerView()
                // load collection titles
                loadOnlyCollectionArray()
                
                if tableView.numberOfRows(inSection: 0) == 3 {
                    tableView.beginUpdates()
                    tableView.insertRows(at: [IndexPath(row: 3, section: 0)], with: .fade)
                    tableView.endUpdates()
                }
                self.collectionSelected = false
                self.selectedCollection = nil
                tableView.beginUpdates()
                tableView.reloadRows(at: [IndexPath(row: 2, section: 0)], with: .fade)
                tableView.reloadRows(at: [IndexPath(row: 3, section: 0)], with: .fade)
                tableView.endUpdates()
            }
        }
        else {
            if self.collectionTitles.count - 1 > 0 {
                toggleCollectionPickerView()
                self.collectionSelected = true
                self.entryReference = self.allCollections.first(where: { (collection) -> Bool in
                    if collection.name == self.collectionTitles[row] {
                        return true
                    } else {
                        return false
                    }
                })?.ref
                self.selectedCollection = self.collectionTitles[row]
                let rows = tableView.numberOfRows(inSection: 0)
                tableView.reloadRows(at: [IndexPath(row: rows - 1, section: 0)], with: .fade)
            }
        }
        
    }
    
    // MARK: - Action sheet
    
    
    func showResourceTypeActionSheet() {
        self.pickingForAltFiles = true
        let actionSheet = UIAlertController(title: "Resource type", message: "Please choose a resource type.", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Photo (.JPEG and .TIF)", style: .default, handler: { (action: UIAlertAction) in
            self.resourceType = FileType.PHOTO
            self.showFileSourceActionSheet()
        }))
        actionSheet.addAction(UIAlertAction(title: "Video (.MOV and .MP4)", style: .default, handler: { (action: UIAlertAction) in
            self.resourceType = FileType.VIDEO
            self.showFileSourceActionSheet()
        }))
        actionSheet.addAction(UIAlertAction(title: "Audio (.MP3)", style: .default, handler: { (action: UIAlertAction) in
            self.resourceType = FileType.AUDIO
            // TODO: implement showing and receiving audio files as alternative file
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .vertical
            layout.sectionInset = UIEdgeInsets(top: 25.0, left: 20.0, bottom: 25.0, right: 20.0)
            let mp3CollectionVC = Mp3CollectionViewController(collectionViewLayout: layout)
            mp3CollectionVC.mp3Delegate = self
            self.navigationController?.pushViewController(mp3CollectionVC, animated: true)
        }))
        actionSheet.addAction(UIAlertAction(title: "Documents (.PDF)", style: .default, handler: { (action: UIAlertAction) in
            self.resourceType = FileType.DOCUMENT
            // TODO: implement showing and receiving pdf files as alternative file
            let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
            layout.scrollDirection = .vertical
            layout.sectionInset = UIEdgeInsets(top: 25.0, left: 10.0, bottom: 2.0, right: 10.0)
            let pdfCollectionVC = PdfCollectionViewController(collectionViewLayout: layout)
            pdfCollectionVC.pdfDelegate = self
            self.navigationController?.pushViewController(pdfCollectionVC, animated: true)
//            self.pdfCollectionViewController = PdfCollectionViewController(collectionViewLayout: layout)
//            self.pdfCollectionViewController?.pdfDelegate = self
//            self.navigationController?.pushViewController(self.pdfCollectionViewController!, animated: true)
            
        }))
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {(alert: UIAlertAction)-> Void in
            self.pickingForAltFiles = false
            actionSheet.dismiss(animated: true, completion: nil)
        })
        cancelAction.setValue(UIColor.red, forKey: "titleTextColor")
        actionSheet.addAction(cancelAction)
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    @objc func selectingMainImage() {
        self.resourceType = .PHOTO
        self.pickingForAltFiles = false
        showFileSourceActionSheet()
    }
    
    @objc private func showFileSourceActionSheet() {
        switch resourceType {
        case .PHOTO:
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
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
            let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {(alert: UIAlertAction)-> Void in
                self.pickingForAltFiles = false
                actionSheet.dismiss(animated: true, completion: nil)
            })
            cancelAction.setValue(UIColor.red, forKey: "titleTextColor")
            actionSheet.addAction(cancelAction)
            self.present(actionSheet, animated: true, completion: nil)
            
        case .VIDEO:
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            let actionSheet: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            actionSheet.addAction(UIAlertAction(title: "Take Video", style: .default, handler: {(alert: UIAlertAction) -> Void in
                if(UIImagePickerController.isSourceTypeAvailable(.camera)) {
                    self.imagePickerController.sourceType = .camera
                    if(self.videoFormatIsAvailable(for: imagePickerController.sourceType)) {
                        self.imagePickerController.mediaTypes = [kUTTypeMovie as String]
                        self.present(self.imagePickerController, animated: true, completion: nil)
                    }
                    else {
                        let alert: UIAlertController = UIAlertController(title: "Video Unavailable", message: "Video is not available on your device", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }))
            actionSheet.addAction(UIAlertAction(title: "Choose Video", style: .default, handler: {(alert: UIAlertAction) -> Void in
                if(UIImagePickerController.isSourceTypeAvailable(.camera)) {
                    self.imagePickerController.sourceType = .savedPhotosAlbum
                    self.imagePickerController.mediaTypes = [kUTTypeMovie as String]
                    self.present(self.imagePickerController, animated: true, completion: nil)
                }
                else
                {
                    let alert: UIAlertController = UIAlertController(title: "No Photo Library", message: "There was a problem accessing your camera roll", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }))
            let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {(alert: UIAlertAction)-> Void in
                self.pickingForAltFiles = false
                actionSheet.dismiss(animated: true, completion: nil)
            })
            cancelAction.setValue(UIColor.red, forKey: "titleTextColor")
            actionSheet.addAction(cancelAction)
            self.present(actionSheet, animated: true, completion: nil)
        default:
            print("Should never happen")
        }
    }
    
    // MARK: - MP3 functions
    
    func returnMp3(with mp3URL: URL) {
        let altFile = AltFile.init(name: mp3URL.deletingPathExtension().lastPathComponent, url: mp3URL.path, type: FileType.AUDIO.rawValue)
        self.altFiles.append(altFile)
        self.tableView.beginUpdates()
        self.tableView.reloadSections(IndexSet([3]), with: .fade)
        self.tableView.endUpdates()
    }
    
    // MARK: - PDF functions
    
    func returnPDF(with pdfURL: URL)
    {
        let altFile = AltFile.init(name: pdfURL.deletingPathExtension().lastPathComponent, url: pdfURL.path, type: FileType.DOCUMENT.rawValue)
        let pdfImage = drawPDFfromURL(url: pdfURL)
        saveExistingImageAtDocumentDirectory(with: pdfURL.lastPathComponent, image: pdfImage!)
        self.altFiles.append(altFile)
        self.tableView.beginUpdates()
        self.tableView.reloadSections(IndexSet([3]), with: .fade)
        self.tableView.endUpdates()
    }
    
    func drawPDFfromURL(url: URL) -> UIImage?
    {
        guard let document = CGPDFDocument(url as CFURL) else { return nil }
        guard let page = document.page(at: 1) else { return nil }
        
        let pageRect = page.getBoxRect(.mediaBox)
        let renderer = UIGraphicsImageRenderer(size: pageRect.size)
        let img = renderer.image { ctx in
            UIColor.white.set()
            ctx.fill(pageRect)
            
            ctx.cgContext.translateBy(x: 0.0, y: pageRect.size.height)
            ctx.cgContext.scaleBy(x: 1.0, y: -1.0)
            
            ctx.cgContext.drawPDFPage(page)
        }
        
        return img
    }
    
    // MARK: - Photo/Video functions
    
    func videoFormatIsAvailable(for sourceType: UIImagePickerControllerSourceType ) -> Bool
    {
        let types = UIImagePickerController.availableMediaTypes(for: .camera)
        for type in types! {
            if(type == kUTTypeMovie as String) {
                return true
            }
        }
        return false
    }
    
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
        {
            if !self.pickingForAltFiles {
                if resourceType == .PHOTO {
                    if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
                        previewImage = pickedImage
                        tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
                        self.resourceSelected = true
                        
                        if let newURL = info[UIImagePickerControllerImageURL] as? URL {
                            self.imageURL = newURL
                        }
                        else
                        {
                            PHPhotoLibrary.shared().performChanges({
                                let assetChangeRequest = PHAssetChangeRequest.creationRequestForAsset(from: pickedImage)
                                var currentLocation: CLLocation!
                                if( CLLocationManager.authorizationStatus() == .authorizedWhenInUse ||
                                    CLLocationManager.authorizationStatus() ==  .authorizedAlways)
                                {
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
                    }
                    picker.dismiss(animated: true, completion: nil)
                } else {
                    let url = info[UIImagePickerControllerMediaURL] as? URL
                    
                    videoThumbnail = createVideoThumbnail(from: url!.absoluteString)
                    localFileName = saveExistingImageAtDocumentDirectory(image: videoThumbnail!)
                    
                    tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
                    self.resourceSelected = true
                    
                    do
                    {
                        videoData = try Data(contentsOf: url!)
                    }
                    catch
                    {
                        let alert: UIAlertController = UIAlertController(title: "Error", message: "Could not save video data", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                    
                    imagePickerController.dismiss(animated: true, completion: nil)
                    
                    // TODO: Add geo-locating for videos, audio, and pdfs
                }
            } else {
                if resourceType == .PHOTO {
                    if let imageURL = info[UIImagePickerControllerImageURL] as? URL {
                        let image = UIImage(contentsOfFile: imageURL.path)
                        let imageName = saveExistingImageAtDocumentDirectory(image: image!)
                        let imagePath = getDocumentsURL().appendingPathComponent(imageName).path
                        let fileNameWithoutExtension = NSURL(fileURLWithPath: imageName).deletingPathExtension?.lastPathComponent ?? ""
                        let altFile = AltFile.init(name: fileNameWithoutExtension, url: imagePath, type: FileType.PHOTO.rawValue)
                        self.altFiles.append(altFile)
                    } else {
                        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
                            let imageName = saveExistingImageAtDocumentDirectory(image: image)
                            let imageURL = getDocumentsURL().appendingPathComponent(imageName)
                            let fileNameWithoutExtension = NSURL(fileURLWithPath: imageName).deletingPathExtension?.lastPathComponent ?? ""
                            let altFile = AltFile.init(name: fileNameWithoutExtension, url: imageURL.path, type: FileType.PHOTO.rawValue)
                            self.altFiles.append(altFile)
                        }
                    }
                    self.tableView.beginUpdates()
                    self.tableView.reloadSections(IndexSet([3]), with: UITableViewRowAnimation.fade)
                    self.tableView.endUpdates()
                    picker.dismiss(animated: true, completion: nil)
                } else {
                    if let videoURL = info[UIImagePickerControllerMediaURL] as? URL {
                        let image = createVideoThumbnail(from: videoURL.absoluteString)
                        let videoName = saveExistingImageAtDocumentDirectory(image: image)
                        let fileNameWithoutExtension = NSURL(fileURLWithPath: videoName).deletingPathExtension?.lastPathComponent ?? ""
                        let altFile = AltFile.init(name: fileNameWithoutExtension, url: videoURL.path, type: FileType.VIDEO.rawValue)
                        self.altFiles.append(altFile)
                        self.tableView.beginUpdates()
                        self.tableView.reloadSections(IndexSet([3]), with: UITableViewRowAnimation.fade)
                        self.tableView.endUpdates()
                    }
                    picker.dismiss(animated: true, completion: nil)
                }
            }

    }
    
    func createVideoThumbnail(from url: String) -> UIImage
    {
        let asset = AVAsset(url: URL(string: url)!)
        let assetImgGenerate = AVAssetImageGenerator(asset: asset)
        assetImgGenerate.appliesPreferredTrackTransform = true
        
        let time = CMTimeMakeWithSeconds(1.0, 600)
        do
        {
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
    // MARK: - API and local Saving/Uploading functions
    
    @objc func saveCheckAndUpload() {
        let titleCell = tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as! LocalEntryTableViewCell
        let descriptionCell = tableView.cellForRow(at: IndexPath(row: 1, section: 1)) as! LocalEntryTableViewCell
        let notesCell = tableView.cellForRow(at: IndexPath(row: 2, section: 1)) as! LocalEntryTableViewCell
        if titleCell.textView.text.isEmpty || descriptionCell.textView.text.isEmpty || notesCell.textView.text.isEmpty {
            displayErrorMessage(title: "Empty fields.", message: "Please complete form.")
        } else if !resourceSelected {
            displayErrorMessage(title: "Empty fields.", message: "Please complete form.")
        } else if !collectionSelected {
            displayErrorMessage(title: "Empty fields.", message: "Please complete form.")
        } else {
            let savedName = createLocalEntry()
            let networkVC = NetworkViewController()
            networkVC.modalPresentationStyle = .overFullScreen
            networkVC.modalTransitionStyle = .crossDissolve
            let oldEntries = getLocalEntriesFromDisk()
            let currentEntry = oldEntries.first { (entry) -> Bool in
                if entry.localFileName == savedName {
                    return true
                } else {
                    return false
                }
            }
            networkVC.localEntry = currentEntry
            self.navigationController?.present(networkVC, animated: true, completion: nil)
            //            httpUpload()
            //            createResourceSpaceEntry(fileName: savedName)
            //            addResourceToCollection()
            self.navigationController?.popToRootViewController(animated: true)
        }
        
    }
    
    func createLocalEntryDirectory() {
        let fileManager: FileManager = FileManager.default
        let docDir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
        let tempDocDir = docDir!.appendingPathComponent("local-entries")
        
        if(!fileManager.fileExists(atPath: tempDocDir.relativePath))
        {
            do
            {
                try fileManager.createDirectory(at: tempDocDir, withIntermediateDirectories: false, attributes: nil)
            }
            catch
            {
                print(error.localizedDescription)
            }
        }
    }
    
    func createLocalEntry() -> String {
        let titleCell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as! LocalEntryTableViewCell
        let descriptionCell = self.tableView.cellForRow(at: IndexPath(row: 1, section: 1)) as! LocalEntryTableViewCell
        let notesCell = self.tableView.cellForRow(at: IndexPath(row: 2, section: 1)) as! LocalEntryTableViewCell
        var newEntry = LocalEntry()
        newEntry.name = titleCell.textView.text
        newEntry.description = descriptionCell.textView.text
        newEntry.notes = notesCell.textView.text
        newEntry.collectionRef = self.entryReference
        
        // Create/check for local resource entry folder
        createLocalEntryDirectory()
        
        // Copy image to local entries directory
        var savedImageName = ""
        if let possibleImageURL = self.imageURL {
            savedImageName = saveImageAtDocumentDirectory(url: possibleImageURL)
        } else {
            savedImageName = saveExistingImageAtDocumentDirectory(image: self.previewImage!)
        }
        let savedImageURL = getDocumentsURL().appendingPathComponent(savedImageName)
        let localEntryURL = getDocumentsURL().appendingPathComponent("local-entries").appendingPathComponent(savedImageName)
        do {
            try FileManager.default.moveItem(at: savedImageURL, to: localEntryURL)
        } catch {
            print(error.localizedDescription)
        }
        
        // Copy each alt file to local entry directory
        for var altFile in self.altFiles {
            let localEntryURL = getDocumentsURL().appendingPathComponent("local-entries").appendingPathComponent(URL(fileURLWithPath: altFile.url).lastPathComponent)
            
            do {
                try FileManager.default.copyItem(at: URL(fileURLWithPath: altFile.url), to: localEntryURL)
            } catch {
                print(error.localizedDescription)
            }
            altFile.url = localEntryURL.path
        }
        newEntry.localFileName = savedImageName
        newEntry.fileType = FileType.PHOTO.rawValue
        newEntry.submissionStatus = SubmissionStatus.LocalOnly.rawValue
        newEntry.altFiles = self.altFiles
        updateLocalEntries(with: newEntry)
        return newEntry.localFileName!
    }

    func httpUpload() {
        
    }
    
    func createResourceSpaceEntry(fileName: String) {
        
    }
    
    func addResourceToCollection() {
        
    }
    
    // MARK: - API Functions
    
    func loadCollectionAndCategoryArrays() {
        self.subcategoryTitles.removeAll()
        self.collectionTitles.removeAll()
        self.allCategories.removeAll()
        self.allCollections.removeAll()
        // retrieve all top-level categories and collections
        let hazardsArray = self.hazardsDictionary[self.selectedHazard!]!
        
        // take care of collection items
        for hazard in hazardsArray {
            // is collection
            if hazard.theme3 == "" {
                if self.allCollections.contains(where: { (target: Hazard) -> Bool in
                    target.name == hazard.name
                }) {
                }
                else {
                    self.allCollections.append(hazard)
                }
            }
        }
        
        for collection in self.allCollections  {
            if self.collectionTitles.contains(where: { (insideName) -> Bool in
                insideName == collection.name
            }) {
            
            } else {
                self.collectionTitles.append(collection.name)
            }
        }
        
        // take care of category dictionary (key: category name, value: Hazard item)
        self.categoryDictionary = hazardsArray.reduce([String: [Hazard]]()) {
            (dict, category) in
            var tempDict = dict
            if var array = tempDict[category.theme3] {
                if array.contains(where: { (insideCategory: Hazard) -> Bool in
                    insideCategory.name == category.name
                }) {
                    
                }
                else {
                    if category.theme3 != "" {
                        array.append(category)
                        tempDict.updateValue(array, forKey: category.theme3)
                    }
                }
            }
            else {
                if category.theme3 != "" {
                    let newArray: [Hazard] = [category]
                    tempDict[category.theme3] = newArray
                }
            }
            return tempDict
        }
        
        for (key, _) in self.categoryDictionary {
            if self.subcategoryTitles.contains(where: { (insideName) -> Bool in
                insideName == key
            }) {
                
            }
            else {
                self.subcategoryTitles.append(key)
            }
        }
        self.subcategoryTitles = self.subcategoryTitles.sorted(by: { $0 < $1 })
        self.collectionTitles = self.collectionTitles.sorted(by: { $0 < $1 })
        self.subcategoryTitles.insert("Please select an item", at: 0)
        self.collectionTitles.insert("Please select an item", at: 0)
    }
    
    
    func loadOnlyCollectionArray() {
        self.collectionTitles.removeAll()
        self.allCollections.removeAll()
        let categoryArray = self.categoryDictionary[self.selectedSubcategory!]!
        
        // take care of collection items
        for hazard in categoryArray {
            // is collection
                if self.allCollections.contains(where: { (target: Hazard) -> Bool in
                    target.name == hazard.name
                }) {
                }
                else {
                    self.allCollections.append(hazard)
                }
        }
        
        for collection in self.allCollections  {
            if self.collectionTitles.contains(where: { (insideName) -> Bool in
                insideName == collection.name
            }) {
                
            } else {
                self.collectionTitles.append(collection.name)
            }
        }
        self.collectionTitles = self.collectionTitles.sorted(by: { $0 < $1 })
        self.collectionTitles.insert("Please select an item", at: 0)
    }
    
    
    @objc func collectAndShowHazards() {
        collectHazards()
    }
    
    
    @objc func collectAndShowCategories() {
        removeAllPickerView()
        self.showPicker = true
        toggleCategoryPickerView()
    }
    
    
    @objc func collectAndShowCollections() {
        removeAllPickerView()
        self.showPicker = true
        toggleCollectionPickerView()
    }
    
    
    @objc func collectHazards() {
        // Show activity indicator
        activityIndicator.center = view.center
        let activityBackground = UIView(frame: view.frame)
        activityBackground.tag = 99
        activityBackground.backgroundColor = UIColor(white: 0, alpha: 0.5)
        view.addSubview(activityBackground)
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        // check Internet connection
        let internetTestObject = Reachability()
        if internetTestObject.hasInternet() {
            loadHazardsFromApi()
        }
        else {
            if localHazardsFromDiskExists() {
                self.allHazards = getCompleteHazardsFromDisk()
                // show warning
                let alert = UIAlertController(title: "No Connection", message: "Using cached hazards.", preferredStyle: .alert)
                let okayAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
                alert.addAction(okayAction)
                self.present(alert, animated: true, completion: nil)
            }
            else {
                // show warning
                let alert = UIAlertController(title: "No Connection", message: "No Internet connection and cached hazards are not available.", preferredStyle: .alert)
                let okayAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
                alert.addAction(okayAction)
                self.present(alert, animated: true, completion: nil)
            }
            filterAllHazardsAndReloadTable()
        }
    }
    
    
    func loadHazardsFromApi() {
        let urlString = UserDefaults.standard.string(forKey: "selectedURL")! + "/api/?"
        let privateKey = UserDefaults.standard.string(forKey: "userPassword")!
        let queryString = "user=" + UserDefaults.standard.string(forKey: "userName")! + "&function=search_public_collections&param1=&param2=theme&param3=DESC&param4=0&param5=0"
        let signature = "&sign=" + (privateKey + queryString).sha256()!
        let completeURL = urlString + queryString + signature
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
                    // parse and filter JSON results
                    self.allHazards = resourceSpaceData.filter({
                        $0.theme == "Geologic Hazards" && $0.theme2 != ""
                    })
                    // save to disk in case of connectivity lost
                    saveCompleteHazardsToDisk(hazards: self.allHazards)
                    self.filterAllHazardsAndReloadTable()
                    
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.isHidden = true
                    if let viewWithTag = self.view.viewWithTag(99) {
                        viewWithTag.removeFromSuperview()
                    }
                    self.toggleHazardPickerView()
                }
            } catch let jsonError {
                print(jsonError)
            }
        }.resume()
    }
    
    
    func filterAllHazardsAndReloadTable() {
        self.hazardsDictionary = self.allHazards.reduce([String: [Hazard]]()) {
            (dict, hazard) in
            var tempDict = dict
            if var array = tempDict[hazard.theme2] {
                if array.contains(where: { (insideHazard: Hazard) -> Bool in
                    insideHazard.name == hazard.name
                }) {
                    
                }
                else {
                    array.append(hazard)
                    tempDict.updateValue(array, forKey: hazard.theme2)
                }
            }
            else {
                let newArray: [Hazard] = [hazard]
                tempDict[hazard.theme2] = newArray
            }
            return tempDict
        }
        
        self.hazardTitles.removeAll()
        
        for (key, _) in self.hazardsDictionary {
            if self.hazardTitles.contains(where: { (insideName: String) -> Bool in
                insideName == key
            }) {
                
            }
            else {
                self.hazardTitles.append(key)
            }
        }
        
        self.hazardTitles = self.hazardTitles.sorted(by: { $0 < $1 })
        self.hazardTitles.insert("Please select an item", at: 0)
    }
    
    // MARK: - Table view
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let localEntry = self.localEntry {
            print(localEntry.name!)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = UIColor(white: 0.97, alpha: 1)
        self.hazardPicker.alpha = 0.0
        self.hazardPicker.backgroundColor = UIColor(white: 0.97, alpha: 1)
        self.subcategoryPicker.alpha = 0.0
        self.subcategoryPicker.backgroundColor = UIColor(white: 0.97, alpha: 1)
        self.collectionPicker.alpha = 0.0
        self.collectionPicker.backgroundColor = UIColor(white: 0.97, alpha: 1)
        
        tableView.keyboardDismissMode = .onDrag
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        imagePickerController.delegate = self
        
        navigationItem.title = "New Local Entry"
        navigationController?.navigationBar.prefersLargeTitles = false
        self.tableView.register(LocalEntryTableViewCell.self, forCellReuseIdentifier: infoCellId)
        self.tableView.register(LocalResourceTableViewCell.self, forCellReuseIdentifier: resourceCellId)
        self.tableView.register(HazardTableViewCell.self, forCellReuseIdentifier: hazardCellId)
        self.tableView.register(SubcategoryTableViewCell.self, forCellReuseIdentifier: subcategoryCellId)
        self.tableView.register(CollectionTableViewCell.self, forCellReuseIdentifier: collectionCellId)
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: additionalButtonCellId)
        self.tableView.register(AlternativeTableViewCell.self, forCellReuseIdentifier: alternativeFileCellId)
        self.tableView.tableFooterView = UIView(frame: .zero)
        
        let saveBarButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveCheckAndUpload))
        let uploadBarButton = UIBarButtonItem(title: "Upload", style: .done, target: self, action: #selector(saveCheckAndUpload))
        
        
        navigationItem.setRightBarButtonItems([uploadBarButton, saveBarButton], animated: true)
//        navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveAndUpload)), animated: true)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let size = textView.bounds.size
        let newSize = textView.sizeThatFits(CGSize(width: size.width, height: CGFloat.greatestFiniteMagnitude))
        
        if size.height != newSize.height {
            UIView.setAnimationsEnabled(false)
            tableView?.beginUpdates()
            tableView?.endUpdates()
            UIView.setAnimationsEnabled(true)
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if !hazardSelected && !subcategorySelected && !collectionSelected {
                return 2
            }
            else if subcategoryTitles.count - 1 > 0 && collectionTitles.count - 1 > 0 {
                return 4
            }
            else if subcategoryTitles.count - 1 == 0 && collectionTitles.count - 1 > 0 {
                return 3
            }
            else {
                // tableView: numberOfRowsInSection: should not happen
                return 4
            }
        }
        else if section == 1 {
            return 3
        }
        else if section == 2 {
            return 1
        }
        else {
            return self.altFiles.count
        }
    }
    
//    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
//        return nil
//    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let title: String
        if section == 0 {
            title = "Resource Info"
        }
        else if section == 1 {
            title = "Entry Info"
        }
        else if section == 2 {
            title = "Alternative Files"
        }
        else {
            title = " "
        }
        return title
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: resourceCellId, for: indexPath) as! LocalResourceTableViewCell
                cell.insertButton.addTarget(self, action: #selector(selectingMainImage), for: .touchUpInside)
                self.resourceType = .PHOTO
                cell.cellLabel.becomeFirstResponder()
                cell.selectionStyle = .none
                cell.cellLabel.text = "Resource"
                if (previewImage != nil)
                {
                    cell.resourceSet = true
                    cell.insertButton.imageView?.contentMode = .scaleAspectFill
                    cell.insertButton.setImage(previewImage, for: .normal)
                    cell.layoutSubviews()
                }
                return cell
            }
            if indexPath.row == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: hazardCellId, for: indexPath) as! HazardTableViewCell
                cell.button.addTarget(self, action: #selector(collectAndShowHazards), for: .touchUpInside)
                cell.selectionStyle = .none
                cell.cellLabel.text = "Hazard"
                
                if self.hazardSelected {
                    if let title = self.selectedHazard {
                        cell.button.setTitle(title, for: .normal)
                    }
                } else {
                    cell.button.setTitle("Tap to select hazard...", for: .normal)
                }
                return cell
            }
            if indexPath.row == 2 {
                if collectionOnly {
                    let cell = tableView.dequeueReusableCell(withIdentifier: collectionCellId, for: indexPath) as! CollectionTableViewCell
                    cell.button.addTarget(self, action: #selector(collectAndShowCollections), for: .touchUpInside)
                    cell.selectionStyle = .none
                    cell.cellLabel.text = "Collection"
                    
                    if self.collectionSelected {
                        if let title = self.selectedCollection {
                            cell.button.setTitle(title, for: .normal)
                        }
                    } else {
                        cell.button.setTitle("Tap to select collection...", for: .normal)
                    }
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: subcategoryCellId, for: indexPath) as! SubcategoryTableViewCell
                    cell.button.addTarget(self, action: #selector(collectAndShowCategories), for: .touchUpInside)
                    cell.selectionStyle = .none
                    cell.cellLabel.text = "Subcategory"
                    
                    if self.subcategorySelected {
                        if let title = self.selectedSubcategory {
                            cell.button.setTitle(title, for: .normal)
                        }
                    } else {
                        cell.button.setTitle("Tap to select subcategory...", for: .normal)
                    }
                    return cell
                }
            }
            else {
                let cell = tableView.dequeueReusableCell(withIdentifier: collectionCellId, for: indexPath) as! CollectionTableViewCell
                cell.button.addTarget(self, action: #selector(collectAndShowCollections), for: .touchUpInside)
                cell.selectionStyle = .none
                cell.cellLabel.text = "Collection"
                
                if self.collectionSelected {
                    if let title = self.selectedCollection {
                        cell.button.setTitle(title, for: .normal)
                    }
                } else {
                    cell.button.setTitle("Tap to select collection...", for: .normal)
                }
                return cell
            }
        }
        else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: infoCellId, for: indexPath) as! LocalEntryTableViewCell
            
            
            if indexPath.row == 0 {
                cell.cellLabel.text = "Title"
                cell.selectionStyle = .none
                cell.textView.delegate = self
                return cell
            }
            if indexPath.row == 1 {
                cell.cellLabel.text = "Description"
                cell.selectionStyle = .none
                cell.textView.delegate = self
                return cell
            }
            else {
                cell.cellLabel.text = "Notes"
                cell.selectionStyle = .none
                cell.textView.delegate = self
                return cell
            }
        }
        else if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: additionalButtonCellId, for: indexPath)
            cell.textLabel?.textColor = view.tintColor
            cell.textLabel?.text = "Add alternative file..."
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: alternativeFileCellId, for: indexPath) as! AlternativeTableViewCell
            var altFile = self.altFiles[indexPath.row]
            cell.separatorInset = .zero
            
            cell.cellLabel.text = altFile.name
            cell.fileLabel.text = altFile.type

            if altFile.type == FileType.PHOTO.rawValue || altFile.type == FileType.VIDEO.rawValue {
                cell.altImageView.image = getImageFromDocumentDirectory(imageName: altFile.name + ".jpeg")
            } else if altFile.type == FileType.AUDIO.rawValue {
                cell.altImageView.image = UIImage(named: "audio")
            } else {
                let pdfImage = getImageFromDocumentDirectory(imageName: altFile.name + ".jpeg")
                cell.altImageView.image = pdfImage
            }
            
            return cell
        }
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 2 {
            tableView.deselectRow(at: indexPath, animated: true)
            showResourceTypeActionSheet()
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if indexPath.section == 3 {
            if editingStyle == .delete {
                let altFile = self.altFiles[indexPath.row]
                deleteAltFile(with: altFile)
                self.altFiles.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .left)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 3 {
            return 75
        }
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }

    // MARK: - Navigation

    private func displayErrorMessage(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Okay", style: .default, handler: {
            (action) in alert.dismiss(animated: true, completion: nil)
        })
        alert.addAction(dismissAction)
        present(alert, animated: true, completion: nil)
    }
}
