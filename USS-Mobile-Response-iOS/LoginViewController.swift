//
//  LoginViewController.swift
//  USS-Mobile-Response-iOS
//
//  Andrew Tsai

import Foundation
import UIKit

class LoginViewController: UIViewController {
    @IBOutlet weak var userNameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func loginTapped(_ sender: Any) {
        navigateToMainInterface()
    }
    
    private func navigateToMainInterface() {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)

        guard let mainContainerVC = mainStoryboard.instantiateViewController(withIdentifier: "MainContainerViewController") as? MainContainerViewController else {
            return
        }
        
        // Present
        present(mainContainerVC, animated: true, completion: nil)
        
    }
}
