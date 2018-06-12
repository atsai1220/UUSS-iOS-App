//
//  LoginViewController.swift
//  USS-Mobile-Response-iOS
//
//  Andrew Tsai

import Foundation
import UIKit

extension String {
    func truncated(length: Int) -> String {
        if self.count > length {
            return String(self.prefix(length)) + "..."
        }
        else {
            return self
        }
    }
}

class LoginViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet weak var userNameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var serverField: UITextField!
    
    @IBOutlet weak var serverButton: UIButton!
    
    @IBAction func serverButtonTapped(_ sender: Any) {
        serverField.becomeFirstResponder()
    }
    

    var pickerView = UIPickerView()
    var plistController = PlistController()
    var plistSource = [ResourceSpace]()
    

    // returns the number of 'columns' to display.
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    // returns the # of rows in each component..
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return plistSource.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return plistSource[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        serverButton.setTitle(plistSource[row].name.truncated(length: 20), for: .normal)
        if row == pickerView.numberOfRows(inComponent: 0) - 1 {
            self.showAddNewServer()
        }
        serverField.resignFirstResponder()
//        serverButton.titleLabel?.text = plistSource[row].name.truncated(length: 20)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.backgroundColor = UIColor(white: 1, alpha: 0)
        serverField.inputView = pickerView
        plistSource = plistController.resources
//        serverButton.titleLabel?.textAlignment = .center
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        pickerView.selectRow(0, inComponent: 0, animated: true)
//        serverButton.titleLabel?.text = plistSource[0].name
//        serverButton.setTitle(plistSource[0].name, for: .normal)
//        serverField.text = plistSource[0].name
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
        // Referencing storyboard to change the window's rootViewController
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        guard let mainNavigationController = mainStoryboard.instantiateViewController(withIdentifier: "MainNavigationController") as? MainNavigationController else {
            return
        }
        guard let window = UIApplication.shared.keyWindow else {
            return
        }
        UIView.transition(with: window, duration: 0.3, options: .transitionFlipFromRight, animations: { window.rootViewController = mainNavigationController }, completion: nil)
    }
    
    private func showAddNewServer() {
        performSegue(withIdentifier: "AddServerSegue", sender: nil)
    }
}
