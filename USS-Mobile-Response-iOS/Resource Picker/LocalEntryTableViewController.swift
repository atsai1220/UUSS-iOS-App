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

class LocalEntryTableViewController: UITableViewController, UITextViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, CLLocationManagerDelegate {
    
    enum ActionSheetMode: String {
        case PHOTOS = "PHOTOS"
        case VIDEOS = "VIDEOS"
        case AUDIOS = "AUDIOS"
        case PDFS = "PDFS"
    }
    
    let infoCellId = "infoCellId"
    let resourceCellId = "resourceCellId"
    let resourceTypeCellId = "resourceTypeCellId"
    let locationManager = CLLocationManager()
    let imagePickerController = UIImagePickerController()
    
    var previewImage: UIImage?
    var submissionStatus: SubmissionStatus = SubmissionStatus.LocalOnly
    var resourceType: ActionSheetMode = ActionSheetMode.PHOTOS
    
    @objc private func showActionSheet(sender: UIButton) {
        switch resourceType {
        case .PHOTOS:
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
                actionSheet.dismiss(animated: true, completion: nil)
            })
            cancelAction.setValue(UIColor.red, forKey: "titleTextColor")
            actionSheet.addAction(cancelAction)
            
            self.present(actionSheet, animated: true, completion: nil)
            
        case .VIDEOS:
            let imagePickerController = UIImagePickerController()
            let actionSheet: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            actionSheet.addAction(UIAlertAction(title: "Take Video", style: .default, handler: {(alert: UIAlertAction) -> Void in
                if(UIImagePickerController.isSourceTypeAvailable(.camera)) {
                    imagePickerController.sourceType = .camera
                    if(self.videoFormatIsAvailable(for: imagePickerController.sourceType)) {
                        imagePickerController.mediaTypes = [kUTTypeMovie as String]
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
                actionSheet.dismiss(animated: true, completion: nil)
            })
            cancelAction.setValue(UIColor.red, forKey: "titleTextColor")
            actionSheet.addAction(cancelAction)
            
            self.present(actionSheet, animated: true, completion: nil)
            
        case .AUDIOS:
            let audioViewController = AudioViewController()
            self.navigationController?.pushViewController(audioViewController, animated: true)
        case .PDFS:
            print("add select from pdf")
        }
 
    }
    
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
    
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            print("did get image")
            previewImage = pickedImage
            let set = IndexSet(arrayLiteral: 0)
            tableView.reloadSections(set, with: .automatic)
        }
        picker.dismiss(animated: true, completion: nil)
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
    
    private func displayErrorMessage(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Okay", style: .default, handler: {
            (action) in alert.dismiss(animated: true, completion: nil)
        })
        alert.addAction(dismissAction)
        present(alert, animated: true, completion: nil)
    }
    
    @objc func saveAndUpload() {
        print("saveing and uploading...")
        //TODO: check for empty fields
        //TODO: Create local device entry
        //TODO: HTTP uploadig with custom plugin
        //TODO: Create resource on resource space
        //TODO: Add resource to selected collection
        //TODO: Confirmation and update local history

//        self.navigationController?.popToRootViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        imagePickerController.delegate = self
        
        navigationItem.title = "New Local Entry"
        navigationController?.navigationBar.prefersLargeTitles = false
        self.tableView.register(LocalEntryTableViewCell.self, forCellReuseIdentifier: infoCellId)
        self.tableView.register(LocalResourceTableViewCell.self, forCellReuseIdentifier: resourceCellId)
        self.tableView.tableFooterView = UIView(frame: .zero)
        
        navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveAndUpload)), animated: true)
    }

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 4
        }
        else {
            return 3
        }
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let title: String
        if section == 0 {
            title = "Resource Info"
        }
        else {
            title = "Entry Info"
        }
        return title
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: resourceCellId, for: indexPath) as! LocalResourceTableViewCell
                //                cell.contentView.isUserInteractionEnabled = true
                cell.insertButton.addTarget(self, action: #selector(showActionSheet), for: .touchUpInside)
                cell.selectionStyle = .none
                cell.cellLabel.text = "Resource"
                if (previewImage != nil) {
                    cell.resourceSet = true
                    cell.insertButton.imageView?.contentMode = .scaleAspectFill
                    cell.insertButton.setImage(previewImage, for: .normal)
                    cell.layoutIfNeeded()
                }
                
                return cell
            }
            if indexPath.row == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: infoCellId, for: indexPath) as! LocalEntryTableViewCell
                cell.textView.delegate = self
                cell.cellLabel.text = "Hazard"
                return cell
            }
            if indexPath.row == 2 {
                let cell = tableView.dequeueReusableCell(withIdentifier: infoCellId, for: indexPath) as! LocalEntryTableViewCell
                cell.textView.delegate = self
                cell.cellLabel.text = "Subcategory"
                return cell
            }
            else {
                let cell = tableView.dequeueReusableCell(withIdentifier: infoCellId, for: indexPath) as! LocalEntryTableViewCell
                cell.textView.delegate = self
                cell.cellLabel.text = "Collection"
                return cell
            }
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: infoCellId, for: indexPath) as! LocalEntryTableViewCell
            cell.textView.delegate = self
            
            if indexPath.row == 0 {
                cell.cellLabel.text = "Title"
                return cell
            }
            if indexPath.row == 1 {
                cell.cellLabel.text = "Description"
                return cell
            }
            else {
                cell.cellLabel.text = "Notes"
                return cell
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }


    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
