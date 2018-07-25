//
//  ServerTableViewController.swift
//  USS-Mobile-Response-iOS
//
//  Created by Andrew Tsai on 6/15/18.
//  Copyright © 2018 Andrew Tsai. All rights reserved.
//

import Foundation
import UIKit

protocol PassSelectedServerBackwardsProtocol {
    func setResultOfTableRowSelect(name: String, url: String)
}

class ServerTableViewController: UITableViewController {
    /*
     Class variables
    */
    var plistController: PlistController!
    var plistSource = [ResourceSpace]()
    let cellId = "cellId"
    var protocolDelegate: PassSelectedServerBackwardsProtocol?
    
    @IBAction func addTapped(_ sender: Any) {
        showAddNewServer()
    }
    @IBAction func cancelTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Server List"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        plistController.loadPlist()
        plistSource = plistController.resources
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return plistSource.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        let name = plistSource[indexPath.row].name
        cell.textLabel?.text = name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let name = plistSource[indexPath.row].name
        let url = plistSource[indexPath.row].url
        protocolDelegate?.setResultOfTableRowSelect(name: name, url: url)
        self.dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            plistSource.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .left)
            plistController.remove(at: indexPath.row)
        }
    }
    
    // Passing plistController with dependency injection for sharing state.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddServerSegue" {
            if let addServerVC = segue.destination as? AddServerViewController {
                addServerVC.plistController = plistController
            }
        }
    }
    
    private func showAddNewServer() {
        performSegue(withIdentifier: "AddServerSegue", sender: nil)
    }
}
