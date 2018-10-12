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

class LocalEntryTableViewController: UITableViewController, UITextViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, CLLocationManagerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    enum ActionSheetMode: String {
        case PHOTOS = "PHOTOS"
        case VIDEOS = "VIDEOS"
        case AUDIOS = "AUDIOS"
        case PDFS = "PDFS"
    }
    
    let infoCellId = "infoCellId"
    let resourceCellId = "resourceCellId"
    let hazardCellId = "hazardCellId"
    let subcategoryCellId = "subcategoryCellId"
    let collectionCellId = "collectionCellId"
    let locationManager = CLLocationManager()
    let imagePickerController = UIImagePickerController()
    
    // Resource Info section related
    var previewImage: UIImage?
    var submissionStatus: SubmissionStatus = SubmissionStatus.LocalOnly
    var resourceType: ActionSheetMode = ActionSheetMode.PHOTOS
    
    // Hazards related
    var hazardSelected = false
    var subcategorySelected = false
    var collectionSelected = false
    var allHazards: [Hazard] = []
    var hazardsDictionary: [String: [Hazard]] = [:]
    var filteredHazardsTitles: [String] = []
    let hazardPicker = UIPickerView()
    let subcategoryPicker = UIPickerView()
    let collectionPicker = UIPickerView()
    var subcategoryTitles: [String] = []
    var collectionTitles: [String] = []
    
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
    var showPicker = false
    
    // MARK: - Picker View
    
    func showHazardPickerView() {
        if !hazardPicker.isDescendant(of: self.view) {
            
            view.addSubview(hazardPicker)
            UIView.animate(withDuration: 0.3) {
                self.hazardPicker.alpha = 1.0
            }
            hazardPicker.delegate = self
            hazardPicker.dataSource = self
            hazardPicker.translatesAutoresizingMaskIntoConstraints = false
            
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
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.isEqual(hazardPicker) {
            return self.filteredHazardsTitles.count
        }
        else if pickerView.isEqual(subcategoryPicker) {
            return self.subcategoryTitles.count
        }
        else {
            return self.collectionTitles.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if self.filteredHazardsTitles.count > 0 {
            return self.filteredHazardsTitles[row]
        }
        return ""
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print(self.filteredHazardsTitles[row])
    }
    
    // MARK: - Action sheet
    
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
            let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
            layout.scrollDirection = .vertical
            layout.sectionInset = UIEdgeInsets(top: 25.0, left: 10.0, bottom: 2.0, right: 10.0)
            let pdfCollectionViewController: PdfCollectionViewController = PdfCollectionViewController(collectionViewLayout: layout)
            navigationController?.pushViewController(pdfCollectionViewController, animated: true)
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
            tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - API Functions
    
    @objc func collectAndShowHazards() {
        if !hazardPicker.isDescendant(of: self.view) {
            self.showPicker = true
            collectHazards()
        } else {
            UIView.animate(withDuration: 0.3, animations: {
                self.hazardPicker.alpha = 0.0
            }) { (done) in
                if done {
                    self.hazardPicker.removeFromSuperview()
                }
            }
        }
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
            if self.refreshControl?.isRefreshing == true {
                self.refreshControl?.endRefreshing()
            }

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
                    
                    if self.refreshControl?.isRefreshing == true {
                        self.refreshControl?.endRefreshing()
                    }
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.isHidden = true
                    if let viewWithTag = self.view.viewWithTag(99) {
                        viewWithTag.removeFromSuperview()
                    }
                    
                    if self.showPicker {
                        self.showHazardPickerView()
                        self.showPicker = false
                    }
                    
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
        
        for (key, _) in self.hazardsDictionary {
            if self.filteredHazardsTitles.contains(where: { (insideName: String) -> Bool in
                insideName == key
            }) {
                
            }
            else {
                self.filteredHazardsTitles.append(key)
            }
        }
        
        self.filteredHazardsTitles = self.filteredHazardsTitles.sorted(by: { $0 < $1 })
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
    
    // MARK: - Table view
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hazardPicker.alpha = 0.0
        self.hazardPicker.backgroundColor = UIColor.white
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        imagePickerController.delegate = self
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(collectHazards), for: .valueChanged)
        
        navigationItem.title = "New Local Entry"
        navigationController?.navigationBar.prefersLargeTitles = false
        self.tableView.register(LocalEntryTableViewCell.self, forCellReuseIdentifier: infoCellId)
        self.tableView.register(LocalResourceTableViewCell.self, forCellReuseIdentifier: resourceCellId)
        self.tableView.register(HazardTableViewCell.self, forCellReuseIdentifier: hazardCellId)
        self.tableView.register(SubcategoryTableViewCell.self, forCellReuseIdentifier: subcategoryCellId)
        self.tableView.register(CollectionTableViewCell.self, forCellReuseIdentifier: collectionCellId)
        self.tableView.tableFooterView = UIView(frame: .zero)
        
        navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveAndUpload)), animated: true)
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
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if !hazardSelected && !subcategorySelected && !collectionSelected {
                return 2
            }
            else {
                //TODO: return 3 or 4 depending on hazard selection
                return 4
            }
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
                cell.insertButton.addTarget(self, action: #selector(showActionSheet), for: .touchUpInside)
                cell.selectionStyle = .none
                cell.cellLabel.text = "Resource"
                if (previewImage != nil) {
                    
                    cell.resourceSet = true
                    cell.insertButton.imageView?.contentMode = .scaleAspectFill
                    cell.insertButton.setImage(previewImage, for: .normal)
                    cell.layoutSubviews()
//                    cell.layoutIfNeeded()
                }
                
                return cell
            }
            if indexPath.row == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: hazardCellId, for: indexPath) as! HazardTableViewCell
                cell.hazardButton.addTarget(self, action: #selector(collectAndShowHazards), for: .touchUpInside)
                cell.selectionStyle = .none
                cell.cellLabel.text = "Hazard"
                return cell
            }
            if indexPath.row == 2 {
                let cell = tableView.dequeueReusableCell(withIdentifier: subcategoryCellId, for: indexPath) as! SubcategoryTableViewCell
                cell.selectionStyle = .none
                cell.cellLabel.text = "Subcategory"
                return cell
            }
            else {
                let cell = tableView.dequeueReusableCell(withIdentifier: collectionCellId, for: indexPath) as! CollectionTableViewCell
                cell.selectionStyle = .none
                cell.cellLabel.text = "Collection"
                return cell
            }
        }
        else {
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

    // MARK: - Navigation


}
