//
//  SideMenuLauncher.swift
//  USS-Mobile-Response-iOS
//
//  Created by Andrew Tsai on 6/5/18.
//  Copyright © 2018 Andrew Tsai. All rights reserved.
//

import UIKit

class SideMenuLauncher: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    let cellId = "cellId"
    let greyView = UIView()
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.white
        return cv
    }()

    
    override init() {
        super.init()
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: cellId)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath)
        cell.backgroundColor = UIColor.blue
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width * 0.9, height: collectionView.frame.height * 0.1)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
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
