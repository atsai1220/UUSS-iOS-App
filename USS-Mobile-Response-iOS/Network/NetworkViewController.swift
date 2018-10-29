//
//  NetworkViewController.swift
//  USS-Mobile-Response-iOS
//
//  Created by Andrew Tsai on 10/15/18.
//  Copyright © 2018 Andrew Tsai. All rights reserved.
//

import UIKit

class NetworkViewController: UIViewController, NetWorkManagerDelegate {

    var localEntry: LocalEntry?
    
    var progressBackground = UIView()
    
    var progressBar = UIProgressView()
    
    func uploadProgressWith(progress: Float) {
        print("updating progress barrrr")
        if let altFiles = localEntry?.altFiles {
            progressBar.progress = progress / Float(altFiles.count)
        } else {
            progressBar.progress = progress
        }
        view.layoutSubviews()
        if progressBar.progress == 1 {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func dismissProgressBar() {
        progressBar.removeFromSuperview()
//        self.dismiss(animated: true, completion: nil)
    }
    
    func showProgressBar() {
        view.addSubview(progressBar)
    }
    
    func dismissProgressController() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func popToRootController() {
        print("popping")
//        if let navigationController = self.window?.rootViewController as? UINavigationController {
//            navigationController.popToRootViewController(animated: true)
//        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let networkManager = NetworkManager()
        networkManager.delegate = self
        networkManager.uploadFiles(item: self.localEntry!)
        
        view.backgroundColor = UIColor.gray.withAlphaComponent(0.75)
        view.isOpaque = false
        
        progressBackground.backgroundColor = UIColor.white
        progressBackground.layer.cornerRadius = 15
        progressBackground.layer.masksToBounds = true
        progressBackground.translatesAutoresizingMaskIntoConstraints = false
        
        progressBar.progressTintColor = UIColor.cyan
        progressBar.trackTintColor = UIColor.lightGray
        progressBar.layer.cornerRadius = 5
        progressBar.layer.masksToBounds = true
        progressBar.progress = 0
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(progressBackground)
        progressBackground.addSubview(progressBar)
        
        NSLayoutConstraint.activate([
            progressBackground.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.15),
            progressBackground.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85),
            progressBackground.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            progressBackground.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ])
        
        NSLayoutConstraint.activate([
            progressBar.heightAnchor.constraint(equalTo: progressBackground.heightAnchor, multiplier: 0.2),
            progressBar.widthAnchor.constraint(equalTo: progressBackground.widthAnchor, multiplier: 0.85),
            progressBar.centerYAnchor.constraint(equalTo: progressBackground.centerYAnchor),
            progressBar.centerXAnchor.constraint(equalTo: progressBackground.centerXAnchor)
            ])
    }
    
}
