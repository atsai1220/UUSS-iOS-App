//
//  MainLocalTableViewController.swift
//  USS-Mobile-Response-iOS
//
//  Created by Andrew Tsai on 8/2/18.
//  Copyright © 2018 Andrew Tsai. All rights reserved.
//

import UIKit

class MainLocalTableViewController: UITableViewController {
    
    let cellId = "cellId"
    var localEntries: [LocalEntry] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(MainTableViewCell.self, forCellReuseIdentifier: cellId)
        self.tableView.tableFooterView = UIView(frame: .zero)
        
      
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

    }

    override func viewWillAppear(_ animated: Bool) {
        self.localEntries = getLocalEntriesFromDisk()
        self.tableView.reloadData()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        if localEntries.count > 0 {
            self.tableView.separatorStyle = .singleLine
            self.tableView.backgroundView = UIView()
            return 1
        }
        else {
            let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
            messageLabel.numberOfLines = 0
            messageLabel.text = "No local entries."
            messageLabel.textColor = UIColor.black
            messageLabel.textAlignment = .center
            messageLabel.sizeToFit()
            self.tableView.backgroundView = messageLabel
            self.tableView.separatorStyle = .none
            return 1
        }
    }

//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
//    {
//        <#code#>
//    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return localEntries.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! MainTableViewCell


        let item = self.localEntries[indexPath.row]
        let setting = MainCellSetting(name: item.collectionRef!, imageName: item.localFileName!, fileType: item.fileType!, videoURL: item.videoURL ?? "", submissionStatus: item.submissionStatus ?? "")
        cell.setting = setting
        cell.separatorInset = .zero
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            var trashEntries = getTrashEntriesFromDisk()
            trashEntries.append(self.localEntries[indexPath.row])
            saveTrashEntriesToDisk(entries: trashEntries)
            
            self.localEntries.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .left)
            saveLocalEntriesToDisk(entries: self.localEntries)
        }
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
