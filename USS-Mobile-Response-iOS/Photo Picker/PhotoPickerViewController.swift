//
//  PhotoPickerViewController.swift
//  USS-Mobile-Response-iOS
//
//  Created by Andrew Tsai on 8/2/18.
//  Copyright © 2018 Andrew Tsai. All rights reserved.
//

import UIKit

class PhotoObj: NSObject {
    let name: String
    let imageName: String
    
    init(name: String, imageName: String) {
        self.name = name
        self.imageName = imageName
    }
}

class PhotoPickerViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let cellId = "photoCell"
    
    lazy var collectionViewLayout: UICollectionViewLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 10, right: 10)
        layout.itemSize = CGSize(width: 100, height: 100)
        return layout
    }()
    
    lazy var photoCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: self.collectionViewLayout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.backgroundColor = UIColor.white
        return collectionView
    }()
    
    var mainPhoto: PhotoObj = {
        let item = PhotoObj(name: "main", imageName: "new")
        return item
    }()
    
    var altPhotos: [PhotoObj] = {
        return [PhotoObj(name: "new", imageName: "new")]
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.addSubview(self.photoCollectionView)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        else {
            return altPhotos.count
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let myCell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath as IndexPath) as! PhotoCell
        if indexPath.section == 0 {
            let setting = mainPhoto
        }
        else {
            let setting = altPhotos[indexPath.row]
            myCell.setting = setting
            myCell.backgroundColor = UIColor.white
            myCell.layer.borderWidth = 1
            myCell.layer.borderColor = UIColor.black.cgColor
            return myCell
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        // add new photo to select
        if indexPath.section == 0 {
            print("main")
        }
        else {
            if indexPath.row == indexPath.last {
                print("last")
//                photoCells.append(PhotoObj(name: "new", imageName: "new"))
                photoCollectionView.insertItems(at: [indexPath])
            }
            else {
                print("alt")
            }
        }
//        photoCollectionView.insert
//        photoCollectionView.reloadData()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        photoCollectionView.frame = self.view.frame
        
    }
    
}
