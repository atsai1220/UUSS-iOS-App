//
//  SettingsViewController.swift
//  USS-Mobile-Response-iOS
//
//  Created by Andrew Tsai on 6/1/18.
//  Copyright © 2018 Andrew Tsai. All rights reserved.
//

import Foundation
import UIKit

class SettingsViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func doneTapped(_ sender: Any) {
        // TODO: Save settings to device.
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
