//
//  ProfileViewController.swift
//  USS-Mobile-Response-iOS
//
//  Created by Andrew Tsai on 6/1/18.
//  Copyright © 2018 Andrew Tsai. All rights reserved.
//

import Foundation
import UIKit

class ProfileViewController: UIViewController {
    
    let accountLabel: UILabel = {
        let label = UILabel()
        label.text = "Account: "
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        return label
    }()
    
    let keyLabel: UILabel = {
        let label = UILabel()
        label.text = "Key: "
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        return label
    }()
    
    let accountField: UITextField = {
        let field = UITextField()
        field.text = UserDefaults.standard.string(forKey: "userName")
        field.translatesAutoresizingMaskIntoConstraints = false
        field.isUserInteractionEnabled = false
        return field
    }()
    
    let keyField: UITextView = {
        let field = UITextView()
        field.text = UserDefaults.standard.string(forKey: "userPassword")
        field.translatesAutoresizingMaskIntoConstraints = false
        field.isUserInteractionEnabled = false
        field.textContainer.lineBreakMode = .byWordWrapping
        return field
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        
        view.addSubview(accountLabel)
        view.addSubview(keyLabel)
        view.addSubview(accountField)
        view.addSubview(keyField)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        NSLayoutConstraint.activate([
            accountLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -75),
            accountLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            accountField.topAnchor.constraint(equalTo: accountLabel.bottomAnchor, constant: 8),
            accountField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            keyLabel.topAnchor.constraint(equalTo: accountField.bottomAnchor, constant: 32),
            keyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            keyField.topAnchor.constraint(equalTo: keyLabel.bottomAnchor, constant: 8),
            keyField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            keyField.widthAnchor.constraint(equalToConstant: 250),
            keyField.heightAnchor.constraint(equalToConstant: 75)
            ])
    }
}
