//
//  MainViewController.swift
//  USS-Mobile-Response-iOS
//
//  Andrew Tsai

import Foundation
import UIKit

class MainViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    let sideMenuLauncher = SideMenuLauncher()
    
    @IBAction func menuTapped(_ sender: Any) {
        // TODO: Delegate vs Notification Center here?
        
        // Cover and disable main view when hamburger button is tapped.
        sideMenuLauncher.showSideMenu()
    }
    
}
