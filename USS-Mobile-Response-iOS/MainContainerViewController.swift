//
//  MainContainerViewController.swift
//  USS-Mobile-Response-iOS
//
//  Andrew Tsai

import Foundation
import UIKit

class MainContainerViewController: UIViewController {
    
    @IBOutlet weak var sideMenuConstraint: NSLayoutConstraint!
    
    var sideMenuOpen = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Adding observer (notification center)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(toggleSideMenu),
                                               name: NSNotification.Name("ToggleSideMenu"),
                                               object: nil)
    }
    
    @objc func toggleSideMenu() {
        if sideMenuOpen {
            sideMenuConstraint.constant = -260
        }
        else {
            // TODO: Disable MainViewController while side menu is shown.
            sideMenuConstraint.constant = 0
        }
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        sideMenuOpen = !sideMenuOpen
    }
}
