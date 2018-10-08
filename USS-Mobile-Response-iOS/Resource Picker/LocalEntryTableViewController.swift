//
//  LocalEntryTableViewController.swift
//  USS-Mobile-Response-iOS
//
//  Created by Andrew Tsai on 10/5/18.
//  Copyright © 2018 Andrew Tsai. All rights reserved.
//

import UIKit

class LocalEntryTableViewController: UITableViewController, UITextViewDelegate {
    
    let cellId = "cellId"
    
    var resourceLabel: UILabel = {
       let label = UILabel()
        label.text = "Resource"
        return label
    }()
    var hazardLabel: UILabel = {
        let label = UILabel()
        label.text = "Hazard"
        return label
    }()
    var subcategoryLabel: UILabel = {
        let label = UILabel()
        label.text = "Subcategory"
        return label
    }()
    var collectionLabel: UILabel = {
        let label = UILabel()
        label.text = "Collection"
        return label
    }()
    
    var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Title"
        return label
    }()
    var descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Description"
        return label
    }()
    var notesLabel: UILabel = {
        let label = UILabel()
        label.text = "Notes"
        return label
    }()
    
    var allLabels: [UILabel]!
    var entryLabels: [UILabel]!
    var infoLabels: [UILabel]!
    
    private func calculateLabelWidth(label: UILabel) -> CGFloat {
        let labelSize = label.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: label.frame.height))
        return labelSize.width
    }
    
    private func calculateMaxLabelWidth(labels: [UILabel]) -> CGFloat {
        let fittedLabels = labels.map { calculateLabelWidth(label: $0) }
        let maxLabelWidth = fittedLabels.reduce(0, { max($0, $1) })
        return maxLabelWidth
    }
    
    private func updateWidthForLabels(labels: [UILabel]) {
        let maxLabelWidth = calculateMaxLabelWidth(labels: labels)
        for label in labels {
            let constraint = NSLayoutConstraint(item: label, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: maxLabelWidth)
            label.addConstraint(constraint)
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        let size = textView.bounds.size
        let newSize = textView.sizeThatFits(CGSize(width: size.width, height: CGFloat.greatestFiniteMagnitude))

        if size.height != newSize.height {
            tableView?.beginUpdates()
            tableView?.endUpdates()
            
            
//
//            if let thisIndexPath = tableView.indexPath(for: self) {
//                tableView?.scrollToRow(at: thisIndexPath, at: .bottom, animated: false)
//            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.allLabels = [resourceLabel, hazardLabel, subcategoryLabel, collectionLabel, titleLabel, descriptionLabel, notesLabel]
        self.entryLabels = [resourceLabel, hazardLabel, subcategoryLabel, collectionLabel]
        self.infoLabels = [titleLabel, descriptionLabel, notesLabel]
        
        updateWidthForLabels(labels: self.allLabels)
        navigationItem.title = "New Local Entry"
        navigationController?.navigationBar.prefersLargeTitles = false
        self.tableView.register(LocalEntryTableViewCell.self, forCellReuseIdentifier: cellId)
        self.tableView.tableFooterView = UIView(frame: .zero)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.entryLabels.count
        }
        else {
            return self.infoLabels.count
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
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! LocalEntryTableViewCell
        cell.textView.delegate = self
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                cell.cellLabel.text = "Resource"
            }
            if indexPath.row == 1 {
                cell.cellLabel.text = "Hazard"
            }
            if indexPath.row == 2 {
                cell.cellLabel.text = "Subcategory"
            }
            if indexPath.row == 3 {
                cell.cellLabel.text = "Collection"
            }
        }
        else {
            if indexPath.row == 0 {
                cell.cellLabel.text = "Title"
            }
            if indexPath.row == 1 {
                cell.cellLabel.text = "Description"
            }
            if indexPath.row == 2 {
                cell.cellLabel.text = "Notes"
            }
        }
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
