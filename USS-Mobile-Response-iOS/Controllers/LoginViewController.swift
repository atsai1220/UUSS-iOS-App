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
        
        // Read values from text fields
        let userName = userNameField.text
        let userPassword = passwordField.text
        
        // Check if fields are empty
        if (userName?.isEmpty)! || (userPassword?.isEmpty)! {
            displayErrorMessage(title: "Empty fields.", message: "Please input user name and password.")
            return
        }
        
        // Create activity indicator
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
        activityIndicator.center = view.center
        let activityBackground = UIView(frame: view.frame)
        activityBackground.backgroundColor = UIColor(white: 0, alpha: 0.5)
        view.addSubview(activityBackground)
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        // Send request to API
        // TODO: Configure POST for user authentication
        let myURL = URL(string: "http://localhost:8080/authenticate")
        var request = URLRequest(url: myURL!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "content-type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let postString = ["user": userName!, "password": userPassword!] as [String: String]
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: postString, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
            displayErrorMessage(title: "Something went wrong...", message: "An error occurred while parsing login information.")
            return
        }
        
//        let task = URLSession.shared.dataTask(with: request) {
//            (data: Data?, response: URLResponse?, error: Error?) in
//
//            // Stop activity indicator
//            // TODO: Animate activity indicator indicator
//            DispatchQueue.main.async {
//                activityIndicator.stopAnimating()
//                activityIndicator.removeFromSuperview()
//                activityBackground.removeFromSuperview()
//            }
//
//            if error != nil {
//                self.displayErrorMessage(title: "Request error.", message: "An error occurred with the server. Please try again later.")
//                return
//            }
//
//            // Convert server response to NSDictionary object.
//            do {
//                let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
//                // Test if json is empty and read.
//                if let parseJSON = json {
//
//                } else {
//                    self.displayErrorMessage(title: "Response error.", message: "Server response has error. JSON empty.")
//                }
//            } catch {
//
//            }
//        }
//        task.resume()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: { self.navigateToMainInterface() })
      
        
    }
    
    private func displayErrorMessage(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Okay", style: .default, handler: {
            (action) in alert.dismiss(animated: true, completion: nil)
        })
        alert.addAction(dismissAction)
        present(alert, animated: true, completion: nil)
    }
    
    private func navigateToMainInterface() {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)

        guard let mainNavigationController = mainStoryboard.instantiateViewController(withIdentifier: "MainNavigationController") as? MainNavigationController else {
            return
        }
        guard let window = UIApplication.shared.keyWindow else {
            return
        }
        UIView.transition(with: window, duration: 0.3, options: .transitionFlipFromRight, animations: { window.rootViewController = mainNavigationController }, completion: nil)
    }
}
