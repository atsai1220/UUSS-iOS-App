//
//  SideMenuLauncher.swift
//  USS-Mobile-Response-iOS
//
//  Created by Andrew Tsai on 6/5/18.
//  Copyright © 2018 Andrew Tsai. All rights reserved.
//

import UIKit

class SideMenuLauncher: NSObject {
    
    let greyView = UIView()
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.white
        return cv
    }()
    
    override init() {
        super.init()
    }
    
    // TODO: Add menu options for collectionView.
    func showSideMenu() {
        if let window = UIApplication.shared.keyWindow {
            greyView.backgroundColor = UIColor(white: 0, alpha: 0.5)
            greyView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismiss)))
            window.addSubview(greyView)
            window.addSubview(collectionView)
            
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
