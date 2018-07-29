//
//  HazardsTableViewController.swift
//  USS-Mobile-Response-iOS
//
//  Created by Andrew Tsai on 7/28/18.
//  Copyright © 2018 Andrew Tsai. All rights reserved.
//

import UIKit

class HazardsTableViewController: UITableViewController {
    
    var hazards: [Hazard] = []
    let cellId = "cellId"

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Hazards"
        navigationController?.navigationBar.prefersLargeTitles = true
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(loadHazardsFromApi), for: .valueChanged)
        
        loadHazardsFromApi()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        if hazards.count > 0 {
            return 1
        }
        else {
            let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
            messageLabel.text = "Acquiring hazards from API. Pull down to refresh."
            messageLabel.textColor = UIColor.black
            messageLabel.textAlignment = .center
            messageLabel.sizeToFit()
            self.tableView.backgroundView = messageLabel
            self.tableView.separatorStyle = .none
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return hazards.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        if self.hazards.count > 0 {
            let name = self.hazards[indexPath.row].name
            cell.textLabel?.text = name
        }
        return cell
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
            
                    // reload tableview or something
                    self.hazards = resourceSpaceData.filter({
                        $0.theme == "Geologic Hazards"
                    })
                    self.hazards = self.hazards.sorted(by: { $0.name < $1.name })
                    self.tableView.reloadData()
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
