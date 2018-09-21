//
//  MainNavigationController.swift
//  USS-Mobile-Response-iOS
//
//  Andrew Tsai

import Foundation
import UIKit


class MainNavigationController: UINavigationController {
    var menuButton = UIImageView(image: UIImage(named: "menu_button"))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
        self.menuButton.layer.shadowColor = UIColor.black.cgColor
        self.menuButton.layer.shadowOffset = CGSize(width: 5, height: 5)
        self.menuButton.layer.shadowRadius = 5
        self.menuButton.layer.shadowOpacity = 0.5
        self.view.addSubview(self.menuButton)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        NSLayoutConstraint.activate([
            self.menuButton.centerXAnchor.constraint(equalTo: self.view.rightAnchor, constant: -self.menuButton.layer.frame.size.width),
            self.menuButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -self.menuButton.layer.frame.size.height * 1.25),
            self.menuButton.widthAnchor.constraint(equalToConstant: 60),
            self.menuButton.heightAnchor.constraint(equalToConstant: 60)
            ])
        self.menuButton.layer.cornerRadius = self.menuButton.layer.frame.size.width / 2
        self.menuButton.backgroundColor = UIColor.white
        self.menuButton.layer.masksToBounds = false
        self.menuButton.translatesAutoresizingMaskIntoConstraints = false
    }

}
