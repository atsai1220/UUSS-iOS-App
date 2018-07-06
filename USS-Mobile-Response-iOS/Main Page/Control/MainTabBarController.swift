//
//  MainViewController.swift
//  USS-Mobile-Response-iOS
//
//  Andrew Tsai

import Foundation
import UIKit

class MainTabBarController: UITabBarController {
    
    let sideMenuLauncher = SideMenuLauncher()
    
    @IBAction func menuTapped(_ sender: Any) {
        // TODO: Delegate vs Notification Center here?
        
        // Cover and disable main view when hamburger button is tapped.
        sideMenuLauncher.showSideMenu()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        selectedIndex = 0
        
    }

    
}
