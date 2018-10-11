//
//  LoginViewController.swift
//  USS-Mobile-Response-iOS
//
//  Andrew Tsai

import Foundation
import UIKit

class LoginViewController: UIViewController, PassSelectedServerBackwardsProtocol, UITextViewDelegate {
    /*
     IBOutlets
     */
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var userNameField: UITextField!
    @IBOutlet weak var apiField: UITextView!
    @IBOutlet weak var serverField: UITextField!
    @IBOutlet weak var serverButton: UIButton!
    
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var publicButton: UIButton!
    
    var selectedServerName: String?
    var selectedServerURL: String?
    
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    /*
     IBActions
     */
    @IBAction func serverButtonTapped(_ sender: Any) {
        showServerTableVC()
    }
    
    @IBAction func backgroundTapped(_ sender: Any) {
        view.endEditing(true)
    }
    
    @IBAction func loginTapped(_ sender: Any) {
        view.endEditing(true)
        loginToAPI()
    }
    
    @IBAction func publicTapped(_ sender: Any) {
        // Create activity indicator
        view.endEditing(true)
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
        activityIndicator.center = view.center
        let activityBackground = UIView(frame: view.frame)
        activityBackground.backgroundColor = UIColor(white: 0, alpha: 0.5)
        view.addSubview(activityBackground)
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: { self.navigateToMainInterface() })
    }
    
    /*
     Class variables
     */
    var plistController: PlistController!
    var plistSource = [ResourceSpace]()
    let shadowColor = UIColor.black.cgColor
    let shadowOpacity: Float = 0.5
    let shadowOffset = CGSize(width: 2, height: 2)
    let shadowRadius = 10
    override func viewDidLoad() {
        super.viewDidLoad()
        
        logoImage.layer.masksToBounds = true
        logoImage.layer.cornerRadius = 5.0
        
        loginButton.setTitleColor(UIColor.white, for: .normal)
        publicButton.setTitleColor(UIColor.white, for: .normal)
        
        loginButton.backgroundColor = UIColor.lightGray
        loginButton.layer.masksToBounds = true
        loginButton.layer.cornerRadius = 5.0
        
        publicButton.backgroundColor = UIColor.lightGray
        publicButton.layer.masksToBounds = true
        publicButton.layer.cornerRadius = 5.0
        
        userNameField.layer.borderColor = UIColor.lightGray.cgColor
        userNameField.layer.borderWidth = 1.0
        userNameField.layer.cornerRadius = 5.0
        
        apiField.layer.masksToBounds = true
        apiField.layer.borderColor = UIColor.lightGray.cgColor
        apiField.layer.borderWidth = 1.0
        apiField.layer.cornerRadius = 5.0
        apiField.text = "Enter API key here..."
        apiField.textColor = .lightGray
        apiField.delegate = self
        
        selectedServerName = plistController.resources.first?.name
        selectedServerURL = plistController.resources.first?.url
        serverButton.setTitle(selectedServerName!.truncated(length: 19), for: .normal)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if apiField.textColor == UIColor.lightGray && apiField.isFirstResponder {
            apiField.text = nil
            apiField.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if apiField.text.isEmpty || apiField.text == "" {
            apiField.textColor = .lightGray
            apiField.text = "Enter API key here..."
        }
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    @objc
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0 {
                self.view.frame.origin.y += keyboardSize.height
            }
            self.view.frame.origin.y = 0
        }
    }
    
    fileprivate func isLoggedIn() -> Bool {
        return UserDefaults.standard.bool(forKey: "isLoggedIn")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if isLoggedIn() {
            DispatchQueue.main.asyncAfter(deadline: .now(), execute: { self.navigateToMainInterface() })
        }
        plistController.loadPlist()
        plistSource = plistController.resources
        if let serverName = selectedServerName {
            serverButton.setTitle(serverName.truncated(length: 30), for: .normal)
        }
    }
    
    func setResultOfTableRowSelect(name: String, url: String) {
        self.selectedServerName = name
        self.selectedServerURL = url
        UserDefaults.standard.set(self.selectedServerURL, forKey: "selectedURL")
        UserDefaults.standard.synchronize()
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
        
        UIView.transition(with: window, duration: 0.4, options: .transitionFlipFromRight, animations: { window.rootViewController = mainNavigationController }, completion: nil)
    }
    
    private func loginToAPI() {
        // Read values from text fields
        let userName = userNameField.text
        let userPassword = apiField.text
        
        // Check if fields are empty
        if (userName?.isEmpty)! || (userPassword?.isEmpty)! {
            displayErrorMessage(title: "Empty fields.", message: "Please input user name and password.")
            return
        }
        
        // Create activity indicator
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
        activityIndicator.center = view.center
        let activityBackground = UIView(frame: view.frame)
        activityBackground.tag = 99
        activityBackground.backgroundColor = UIColor(white: 0, alpha: 0.5)
        view.addSubview(activityBackground)
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        let urlString = selectedServerURL! + "/api/?"
        let privateKey = userPassword!
        let queryString = "user=" + userName!
        let signature = "&sign=" + (privateKey + queryString).sha256()!
        let completeURL = URL(string: (urlString + queryString + signature))
        if completeURL != nil {
                let task = URLSession.shared.dataTask(with: completeURL!) {(data, response, error) in
                    guard let data = data else { return }
                    if (String(data: data, encoding:. utf8)! != "Invalid signature") {
                        DispatchQueue.main.async {
                            // UserDefaults to save logged in state
                            UserDefaults.standard.set(userName!, forKey: "userName")
                            UserDefaults.standard.set(userPassword!, forKey: "userPassword")
                            UserDefaults.standard.set(true, forKey: "isLoggedIn")
                            UserDefaults.standard.set(self.selectedServerURL, forKey: "selectedURL")
                            UserDefaults.standard.synchronize()
                            print(String(data: data, encoding:. utf8)!)
                            self.navigateToMainInterface()
                        }
                    }
                    else {
                        DispatchQueue.main.async {
                            activityIndicator.stopAnimating()
                            activityIndicator.isHidden = true
                            if let viewWithTag = self.view.viewWithTag(99) {
                                viewWithTag.removeFromSuperview()
                            }
                            self.displayErrorMessage(title: "Bad login.", message: "Check user name or API key.")
                        }
                    }
                }
                task.resume()
        } else {
            activityIndicator.stopAnimating()
            activityIndicator.isHidden = true
            if let viewWithTag = self.view.viewWithTag(99) {
                viewWithTag.removeFromSuperview()
            }
            displayErrorMessage(title: "Bad login.", message: "Unable to parse for sha-256. Check user format.")
        }
    }
    
    
    // Passing plistController with dependency injection for sharing state.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ServerTableSegue" {
            if let serverTableNC = segue.destination as? ServerTableNavigationController {
                if let serverTableVC = serverTableNC.topViewController as? ServerTableViewController {
                    serverTableVC.plistController = plistController
                    serverTableVC.protocolDelegate = self
                }
            }
        }
    }
    
    private func showServerTableVC() {
        performSegue(withIdentifier: "ServerTableSegue", sender: nil)
    }
}
