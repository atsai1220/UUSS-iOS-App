//
//  ProfileViewController.swift
//  USS-Mobile-Response-iOS
//
//  Created by Andrew Tsai on 6/1/18.
//  Copyright © 2018 Andrew Tsai. All rights reserved.
//

import Foundation
import UIKit

class ProfileViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white

    }
    @IBAction func doneTapped(_ sender: Any) {
        // TODO: Implement completion function to save changes.
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func cancelTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    

    
}
