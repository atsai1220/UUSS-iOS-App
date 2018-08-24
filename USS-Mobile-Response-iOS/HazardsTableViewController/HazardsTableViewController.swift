//
//  HazardsTableViewController.swift
//  USS-Mobile-Response-iOS
//
//  Created by Andrew Tsai on 7/28/18.
//  Copyright © 2018 Andrew Tsai. All rights reserved.
//

import UIKit

class HazardsTableViewController: UITableViewController {
    
    var allHazards: [Hazard] = []
    var hazardsDictionary: [String: [Hazard]] = [:]
    var filteredHazardsTitles: [String] = []
    let cellId = "cellId"
    var selectedHazards: [Hazard] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Hazards"
        navigationController?.navigationBar.prefersLargeTitles = false
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(loadHazardsFromApi), for: .valueChanged)
        
        // check Internet connection
        let internetTestObject = Reachability()
        if internetTestObject.hasInternet() {
            print("true")
        }
        else {
            print("false")
        }
//        if localHazardsFromDiskExists() {
//            // check Internet connection
//        }
//        else {
//            // must retrieve from Internet
//            loadHazardsFromApi()
//        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        if self.filteredHazardsTitles.count > 0 {
            self.tableView.separatorStyle = .singleLine
            return 1
        }
        else {
            let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
            messageLabel.text = "Acquiring hazards from API.\n\nPull down to refresh."
            messageLabel.numberOfLines = 0
            messageLabel.textColor = UIColor.black
            messageLabel.textAlignment = .center
            messageLabel.sizeToFit()
            self.tableView.backgroundView = messageLabel
            self.tableView.separatorStyle = .none
            return 1
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return filteredHazardsTitles.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        if self.filteredHazardsTitles.count > 0 {
            let name = self.filteredHazardsTitles[indexPath.row]
            cell.textLabel?.text = name
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        showActionSheet(indexPat: indexPath)
        
        let itemTitle = self.filteredHazardsTitles[indexPath.row]
        self.selectedHazards = self.hazardsDictionary[itemTitle]!
        let hazardsDetailTableVC = HazardsDetailTableViewController()
        hazardsDetailTableVC.navigationItem.title = itemTitle
        hazardsDetailTableVC.selectedHazards = self.selectedHazards
        navigationController?.pushViewController(hazardsDetailTableVC, animated: true)
    }
    
    
    @objc
    func loadHazardsFromApi() {
        let urlString = "https://geodata.geology.utah.gov/api/?"
        let privateKey = "7d510414a826c1af09d864e70c3656964839664786b8e774bafb7c10adc5fea1"
        let queryString = "user=atsai-uuss&function=search_public_collections&param1=&param2=theme&param3=DESC&param4=0&param5=0"
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
                    
                    var indexPathsToReload = [IndexPath]()
                    for index in self.filteredHazardsTitles.indices {
                        let indexPath = IndexPath(row: index, section: 0)
                        indexPathsToReload.append(indexPath)
                    }
                    self.tableView.reloadData()
                    self.tableView.reloadRows(at: indexPathsToReload, with: .left)
                    
                    if self.refreshControl?.isRefreshing == true {
                        self.refreshControl?.endRefreshing()
                    }
                }
            } catch let jsonError {
                print(jsonError)
            }
            }.resume()
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

    

 

}
