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
    
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
    var showPicker = false
    
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
    
    @objc func toggleCategoryPickerView() {
        if !subcategoryPicker.isDescendant(of: self.view) {
            print("show category ppicker")
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
            print("hide category picker")
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
                self.selectedCollection = self.collectionTitles[row]
                let rows = tableView.numberOfRows(inSection: 0)
                tableView.reloadRows(at: [IndexPath(row: rows - 1, section: 0)], with: .fade)
            }
        }
        
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
            tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - API Functions
    
    func filterForCategories() {
        
    }
    
    func loadCollectionAndCategoryArrays() {
        self.subcategoryTitles.removeAll()
        self.collectionTitles.removeAll()
        
//        self.allHazards.removeAll()
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
        removeAllPickerView()
        self.showPicker = true
        collectHazards()
    }
    
    @objc func collectAndShowCategories() {
        removeAllPickerView()
        self.showPicker = true
        // TODO: gather categories....?
        toggleCategoryPickerView()
    }
    
    @objc func collectAndShowCollections() {
        removeAllPickerView()
        self.showPicker = true
        // TODO: gather categories....?
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
                        self.toggleHazardPickerView()
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
        self.hazardPicker.backgroundColor = UIColor.lightGray
        self.subcategoryPicker.alpha = 0.0
        self.subcategoryPicker.backgroundColor = UIColor.lightGray
        self.collectionPicker.alpha = 0.0
        self.collectionPicker.backgroundColor = UIColor.lightGray
        
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
            else if subcategoryTitles.count - 1 > 0 && collectionTitles.count - 1 > 0 {
                return 4
            }
            else if subcategoryTitles.count - 1 == 0 && collectionTitles.count - 1 > 0 {
                return 3
            }
            else {
                //TODO: return 3 or 4 depending on hazard selection
                print("tableView: numberOfRowsInSection: should not happen")
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
                cell.cellLabel.becomeFirstResponder()
                cell.selectionStyle = .none
                cell.cellLabel.text = "Resource"
                if (previewImage != nil) {
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
