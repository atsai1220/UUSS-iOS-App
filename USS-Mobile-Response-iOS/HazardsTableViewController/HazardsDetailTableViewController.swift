//
//  HazardsDetailTableViewController.swift
//  USS-Mobile-Response-iOS
//
//  Created by Andrew Tsai on 8/2/18.
//  Copyright © 2018 Andrew Tsai. All rights reserved.
//

import UIKit

class HazardsDetailTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let cellId = "cellId"
    var selectedHazards: [Hazard] = []
    var hazardCollections: [Hazard] = []
    var categoryDictionary: [String: [Hazard]] = [:]
    var filteredCategoryTitles: [String] = []
    var subCategoryArray: [Hazard] = []
    var subCategoryNameArray: [String] = []
    var categoryName: String = ""
    var collectionName: String = ""
    var collectionsOnly = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
 
        if collectionsOnly {
            loadOnlyCollectionArray()
        }
        else {
            loadCollectionAndCategoryArrays()
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if collectionsOnly {
            return "Collections"
        }
        else {
            if section == 0 && filteredCategoryTitles.count > 0 {
                return "Subcategory"
            }
            else if section == 1 {
                return "Collections"
            }
            else {
                return ""
            }
        }

    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 75
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        if collectionsOnly {
            return 1
        }
        else {
            return 2
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if collectionsOnly {
            return hazardCollections.count
        }
        else {
            if section == 0 {
                return filteredCategoryTitles.count
            }
            else {
                return hazardCollections.count
            }
        }

    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        if collectionsOnly {
            let name = self.hazardCollections[indexPath.row].name
            cell.textLabel?.text = name
        }
        else {
            if indexPath.section == 0 {
                let name = self.filteredCategoryTitles[indexPath.row]
                cell.textLabel?.text = name
            }
            else {
                let name = self.hazardCollections[indexPath.row].name
                cell.textLabel?.text = name
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 && !collectionsOnly {
            // category
            let selectedCategory = self.filteredCategoryTitles[indexPath.row]
            let hazardsDetailTableVC = HazardsDetailTableViewController()
            hazardsDetailTableVC.title = selectedCategory
            hazardsDetailTableVC.selectedHazards = self.categoryDictionary[selectedCategory]!
            hazardsDetailTableVC.collectionsOnly = true
            navigationController?.pushViewController(hazardsDetailTableVC, animated: true)
        }
        else {
            // collection
            showActionSheet(indexPath: indexPath)
        }
    }
    
    func showActionSheet(indexPath: IndexPath) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        let actionSheet = UIAlertController(title: "Resource type", message: "Please choose a resource type.", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Photo (.JPEG and .TIF)", style: .default, handler: { (action: UIAlertAction) in
            let photoPickerVC = PhotoPickerViewController()
            photoPickerVC.collectionReference = self.hazardCollections[indexPath.row].ref
            self.navigationController?.pushViewController(photoPickerVC, animated: true)
        }))
        actionSheet.addAction(UIAlertAction(title: "Documents (.PDF)", style: .default, handler: { (action: UIAlertAction) in
            
        }))
        actionSheet.addAction(UIAlertAction(title: "Video (.MOV and .MP4)", style: .default, handler: { (action: UIAlertAction) in
            
        }))
        actionSheet.addAction(UIAlertAction(title: "Audio (.MP3)", style: .default, handler: { (action: UIAlertAction) in
            
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func loadCollectionAndCategoryArrays() {
        for hazard in self.selectedHazards {
            // is collection
            if hazard.theme3 == "" {
                if self.hazardCollections.contains(where: { (target: Hazard) -> Bool in
                    target.name == hazard.name
                }) {
                }
                else {
                    self.hazardCollections.append(hazard)
                }
            }
        }

        self.categoryDictionary = self.selectedHazards.reduce([String: [Hazard]]()) {
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
            if self.filteredCategoryTitles.contains(where: { (insideName) -> Bool in
                insideName == key
            }) {
                
            }
            else {
                self.filteredCategoryTitles.append(key)
            }
        }
        self.filteredCategoryTitles = self.filteredCategoryTitles.sorted(by: { $0 < $1 })
        self.hazardCollections = self.hazardCollections.sorted(by: { $0.name < $1.name })
    }
    
    func loadOnlyCollectionArray() {
        for hazard in self.selectedHazards {
            self.hazardCollections.append(hazard)
        }
        self.hazardCollections = self.hazardCollections.sorted(by: { $0.name < $1.name })
    }
}
