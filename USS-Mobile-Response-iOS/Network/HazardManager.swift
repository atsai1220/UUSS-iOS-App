//
//  HazardManager.swift
//  USS-Mobile-Response-iOS
//
//  Created by Andrew Tsai on 10/19/18.
//  Copyright © 2018 Andrew Tsai. All rights reserved.
//

import Foundation

protocol HazardManagerDelegate {
    func startActivityIndicator()
    func stopActivityIndicator()
    func showErrorFromHazardManager(title: String, message: String)
    
}

class HazardManager: NSObject {
    
    var delegate: HazardManagerDelegate?
    var allHazards: [Hazard] = []
    var allCategories: [Hazard] = []
    var allCollections: [Hazard] = []
    var hazardTitles: [String] = []
    var subcategoryTitles: [String] = []
    var collectionTitles: [String] = []
    var hazardsDictionary: [String: [Hazard]] = [:]
    var categoryDictionary: [String: [Hazard]] = [:]
    var collectionDictionary: [String: [Hazard]] = [:]
    
    func collectHazardsFromAPI() {
        delegate?.startActivityIndicator()
        let internetTestObject = Reachability()
        if internetTestObject.hasInternet() {
            loadHazardsFromAPI()
        }
        else {
            if localHazardsFromDiskExists() {
                self.allHazards = getCompleteHazardsFromDisk()
                delegate?.showErrorFromHazardManager(title: "No connection", message: "Using cached hazards.")
            }
            else {
                delegate?.showErrorFromHazardManager(title: "No connection", message: "Internet connection and cached hazards unavailable.")
            }
            
        }
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
    
    func loadHazardsFromAPI() {
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
                    
                    self.delegate?.stopActivityIndicator()
//                    self.activityIndicator.stopAnimating()
//                    self.activityIndicator.isHidden = true
//                    if let viewWithTag = self.view.viewWithTag(99) {
//                        viewWithTag.removeFromSuperview()
//                    }
                    
//                    if self.showPicker {
//                        self.toggleHazardPickerView()
//                        self.showPicker = false
//                    }
                    
                }
            } catch let jsonError {
                print(jsonError)
            }
            }.resume()
    }
}
