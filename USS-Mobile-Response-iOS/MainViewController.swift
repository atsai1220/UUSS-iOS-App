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
        // Observers for each side menu item
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(pushProfileVC),
                                               name: NSNotification.Name("ShowProfile"),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(pushSettingsVC),
                                               name: NSNotification.Name("ShowSettings"),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(pushSignInVC),
                                               name: NSNotification.Name("ShowSignIn"),
                                               object: nil)
    }
    
    @objc func pushProfileVC() {
        performSegue(withIdentifier: "ShowProfileSegue", sender: nil)
    }
    
    @objc func pushSettingsVC() {
        performSegue(withIdentifier: "ShowSettingsSegue", sender: nil)
    }
    
    @objc func pushSignInVC() {
        performSegue(withIdentifier: "ShowSignInSegue", sender: nil)
    }
    
    @IBAction func menuTapped(_ sender: Any) {
        // Post notification
        NotificationCenter.default.post(name: NSNotification.Name("ToggleSideMenu"), object: nil)
    }
}
