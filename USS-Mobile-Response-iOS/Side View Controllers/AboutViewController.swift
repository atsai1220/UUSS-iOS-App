//
//  AboutViewController.swift
//  USS-Mobile-Response-iOS
//
//  Created by Andrew Tsai on 8/16/18.
//  Copyright © 2018 Andrew Tsai. All rights reserved.
//

import Foundation
import UIKit

class AboutViewController: UIViewController {
    
    var titleText: UILabel = {
        let label = UILabel()
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        let text =
"""
This application enhances field data collection and reporting capabilities by allowing reports on hazard features in the field using a simple form-based app and pushing that data to a specific ResourceSpace website.

This application was developed by:
Andrew Tsai
andrewtsai1220@gmail.com

Charlie Barber
cbarb2747@gmail.com

This project was developed under University of Utah Seismograph Stations.

Version: 1.0 2018/08/17
"""
        label.text = text
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        setupViews()
    }
    func setupViews() {
        let scrollView = UIScrollView()
        scrollView.addSubview(titleText)
        
        self.view.addSubview(scrollView)

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        titleText.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 8),
            scrollView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 8),
            scrollView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 0),
            scrollView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: 0),
            titleText.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
//            titleText.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
            titleText.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.9, constant: 0),
            titleText.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            titleText.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -8),
            ])
/*
         
 */
        
    }
    
}
