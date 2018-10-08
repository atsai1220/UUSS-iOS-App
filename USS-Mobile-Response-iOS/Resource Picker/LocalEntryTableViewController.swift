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

class LocalEntryTableViewController: UITableViewController, UITextViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, CLLocationManagerDelegate {
    
    let infoCellId = "infoCellId"
    let resourceCellId = "resourceCellId"
    let resourceTypeCellId = "resourceTypeCellId"
    let locationManager = CLLocationManager()
    let imagePickerController = UIImagePickerController()
    
    var testImage: UIImage?
    
    @objc private func showActionSheet(sender: UIButton) {
        checkPhotoPermission()
        // Create and modify an UIAlertController.actionSheet to allow option between Camera or Photo Library.
        let actionSheet = UIAlertController(title: "Photo Source", message: "Please choose a source for image upload.", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action: UIAlertAction) in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                self.imagePickerController.sourceType = .camera
                self.present(self.imagePickerController, animated: true, completion: nil)
            }
        }))
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (action: UIAlertAction) in
            self.imagePickerController.sourceType = .photoLibrary
            self.present(self.imagePickerController, animated: true, completion: nil)
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            print("did get image")
            testImage = pickedImage
            let set = IndexSet(arrayLiteral: 0)
            tableView.reloadSections(set, with: .automatic)
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    private func textViewDidChange(_ textView: UITextView) {
        
        let size = textView.bounds.size
        let newSize = textView.sizeThatFits(CGSize(width: size.width, height: CGFloat.greatestFiniteMagnitude))

        if size.height != newSize.height {
            tableView?.beginUpdates()
            tableView?.endUpdates()
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
    
    func checkPhotoPermission() {
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        switch photoAuthorizationStatus {
        case .authorized:
            print("Access is granted by user")
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({
                (newStatus) in
                print("status is \(newStatus)")
                if newStatus ==  PHAuthorizationStatus.authorized {
                    /* do stuff here */
                    print("success")
                }
            })
            print("It is not determined until now")
        case .restricted:
            // same same
            print("User do not have access to photo album.")
        case .denied:
            // same same
            print("User has denied the permission.")
        }
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
        self.tableView.register(LocalResourceTypeTableViewCell.self, forCellReuseIdentifier: resourceTypeCellId)
        self.tableView.tableFooterView = UIView(frame: .zero)
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
                
                cell.contentView.isUserInteractionEnabled = true
                cell.insertButton.addTarget(self, action: #selector(showActionSheet), for: .touchUpInside)
                cell.tag = indexPath.row
                cell.selectionStyle = .none
                cell.cellLabel.text = "Resource"
                if (testImage != nil) {
                    cell.insertButton.setImage(testImage, for: .normal)
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
            if indexPath.row == 3 {
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
            if indexPath.row == 2 {
                cell.cellLabel.text = "Notes"
                return cell
            }
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: infoCellId, for: indexPath) as! LocalEntryTableViewCell
        cell.textView.delegate = self
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
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
