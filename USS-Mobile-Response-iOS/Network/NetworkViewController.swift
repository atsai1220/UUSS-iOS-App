//
//  NetworkViewController.swift
//  USS-Mobile-Response-iOS
//
//  Created by Andrew Tsai on 10/15/18.
//  Copyright © 2018 Andrew Tsai. All rights reserved.
//

import UIKit

protocol NetworkViewControllerDelegate {
    func popToRootController()
}

class NetworkViewController: UIViewController, NetWorkManagerDelegate {

    var localEntry: LocalEntry?
    
    var delegate: NetworkViewControllerDelegate?
    
    var progressBackground = UIView()
    
    var progressText: UITextView = UITextView()
    
    var progressBar = UIProgressView()
    
    func uploadProgressWith(progress: Float) {
        progressBar.progress = progress
        view.layoutSubviews()
    }
    
    func dismissProgressBar() {
        progressBar.removeFromSuperview()
    }
    
    func showProgressBar() {
        view.addSubview(progressBar)
    }
    
    func dismissProgressController() {
//        self.dismiss(animated: true, completion: nil)
    }
    
    func popToRootController() {
        DispatchQueue.main.async {
            self.dismiss(animated: false, completion: {
                self.delegate?.popToRootController()
            })
        }
    }
    
    func updateProgress(with text: String) {
        DispatchQueue.main.async {
            self.progressText.text = text
            self.view.layoutSubviews()
        }
    }
    
    deinit {
        print("deallocate")
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
        
        progressText.text = ""
        progressText.textColor = UIColor.black
        progressText.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(progressBackground)
        progressBackground.addSubview(progressBar)
        progressBackground.addSubview(progressText)
        
        NSLayoutConstraint.activate([
            progressBackground.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.15),
            progressBackground.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85),
            progressBackground.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            progressBackground.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            ])
        
        NSLayoutConstraint.activate([
            progressBar.heightAnchor.constraint(equalTo: progressBackground.heightAnchor, multiplier: 0.2),
            progressBar.widthAnchor.constraint(equalTo: progressBackground.widthAnchor, multiplier: 0.85),
            progressBar.centerYAnchor.constraint(equalTo: progressBackground.centerYAnchor),
            progressBar.centerXAnchor.constraint(equalTo: progressBackground.centerXAnchor)
            ])
        
        NSLayoutConstraint.activate([
            progressText.heightAnchor.constraint(equalTo: progressBackground.heightAnchor, multiplier: 0.2),
            progressText.widthAnchor.constraint(equalTo: progressBackground.widthAnchor, multiplier: 0.85),
            progressText.topAnchor.constraint(equalTo: progressBar.bottomAnchor, constant: 5),
            progressText.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            ])
    }
    
}
