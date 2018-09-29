//
//  SideMenuLauncher.swift
//  USS-Mobile-Response-iOS
//
//  Created by Andrew Tsai on 6/5/18.
//  Copyright © 2018 Andrew Tsai. All rights reserved.
//

import UIKit

class Setting: NSObject {
    let name: String
    let imageName: String
    
    init(name: String, imageName: String) {
        self.name = name
        self.imageName = imageName
    }
}

class SideMenuLauncher: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    let cellId = "cellId"
    let greyView = UIView()
    
    var mainTabBarController: MainTabBarController?
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.white
        return cv
    }()
    
    var settings: [Setting] = {
        return [Setting(name: "Profile", imageName: "human"),
                Setting(name: "About", imageName: "about"),
                Setting(name: "Logout", imageName: "logout")]
    }()
    
    override init() {
        super.init()
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(SettingCell.self, forCellWithReuseIdentifier: cellId)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return settings.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! SettingCell
        let setting = settings[indexPath.row]
        cell.setting = setting
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width * 0.9, height: collectionView.frame.height * 0.075)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.greyView.alpha = 0
            self.collectionView.frame = CGRect(x: -self.collectionView.frame.width, y: 0, width: self.collectionView.frame.width, height: self.collectionView.frame.height)
        }) { (completed: Bool) in
            let setting = self.settings[indexPath.item]
            if setting.name != "Logout" {
                self.mainTabBarController?.showControllerFor(setting: setting)
            }
            else {
                let alertController = UIAlertController(title: "Logout confirmation", message: "Are you sure about logging out?", preferredStyle: .alert)
                
                let confirmAction = UIAlertAction(title: "Logout", style: .default, handler: { (action: UIAlertAction) in
                    // perform logout
                    UserDefaults.standard.set(false, forKey: "isLoggedIn")
                    UserDefaults.standard.synchronize()
                    // navigate to login page
                    DispatchQueue.main.asyncAfter(deadline: .now(), execute: { self.navigateToLoginInterface() })
                })
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction) in
                    
                })
                alertController.addAction(confirmAction)
                alertController.addAction(cancelAction)
                self.mainTabBarController?.present(alertController, animated: true, completion: nil)
            }
        }
        
    }
    
    private func navigateToLoginInterface() {
        // Referencing storyboard to change the window's rootViewController
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        guard let loginViewController =
            mainStoryboard.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController else {
                return
        }
        guard let window = UIApplication.shared.keyWindow else {
            return
        }
        loginViewController.plistController = PlistController()
        UIView.transition(with: window, duration: 0.3, options: .transitionFlipFromRight, animations: { window.rootViewController = loginViewController }, completion: nil)
    }
    
    // TODO: Add menu options for collectionView.
    func showSideMenu() {
        if let window = UIApplication.shared.keyWindow {
            window.addSubview(greyView)
            window.addSubview(collectionView)
            
            greyView.backgroundColor = UIColor(white: 0, alpha: 0.5)
            greyView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismiss)))
            
            collectionView.contentInset = UIEdgeInsetsMake(100, 0, 0, 0)
            let cvWidth = 260
            collectionView.frame = CGRect(x: -cvWidth, y: 0, width: cvWidth, height: Int(window.frame.height))
            greyView.frame = window.frame
            greyView.alpha = 0
            
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.greyView.alpha = 1
                self.collectionView.frame = CGRect(x: 0, y: 0, width: self.collectionView.frame.width, height: self.collectionView.frame.height)
            }, completion: nil)
        }
    }
    
    @objc func handleDismiss() {
        UIView.animate(withDuration: 0.3, animations: {
            self.greyView.alpha = 0
            self.collectionView.frame = CGRect(x: -self.collectionView.frame.width, y: 0, width: self.collectionView.frame.width, height: self.collectionView.frame.height)
        })
    }
    
}
