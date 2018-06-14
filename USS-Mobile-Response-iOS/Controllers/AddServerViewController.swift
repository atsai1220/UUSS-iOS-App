//
//  AddServerViewController.swift
//  USS-Mobile-Response-iOS
//
//  Created by Andrew Tsai on 6/12/18.
//  Copyright © 2018 Andrew Tsai. All rights reserved.
//

import Foundation
import UIKit

class AddServerViewController: UIViewController {
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var urlField: UITextField!
    
    var plistController: PlistController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func cancelTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveTapped(_ sender: Any) {
        saveToPlist()
    }
    
    private func saveToPlist() {
        if (nameField.text?.isEmpty)! || (urlField.text?.isEmpty)! {
            displayErrorMessage(title: "Empty fields.", message: "Please input name and URL.")
            return
        }
        let plistDictionary: PlistDictionary = ["name" : nameField.text! as AnyObject, "url" : urlField.text! as AnyObject]
        plistController!.updatePlist(with: plistDictionary)
        self.dismiss(animated: true, completion: nil)
    }
    
    private func displayErrorMessage(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Okay", style: .default, handler: {
            (action) in alert.dismiss(animated: true, completion: nil)
        })
        alert.addAction(dismissAction)
        present(alert, animated: true, completion: nil)
    }
}
