//
//  MainLocalCollectionViewController.swift
//  USS-Mobile-Response-iOS
//
//  Created by Andrew Tsai on 9/29/18.
//  Copyright © 2018 Andrew Tsai. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class MainLocalCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var localEntries: [LocalEntry] = []
    
    var myCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 16
        layout.sectionInset = UIEdgeInsetsMake(16, 16, 16, 16)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.white
        return cv
    }()
    
    override init(collectionViewLayout layout: UICollectionViewLayout) {
        super.init(collectionViewLayout: layout)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Register cell classes
        myCollectionView.dataSource = self
        myCollectionView.delegate = self
        myCollectionView.register(MainCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView = myCollectionView
        // Do any additional setup after loading the view.
//        self.view.addSubview(self.collectionView!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.localEntries = getLocalEntriesFromDisk()
        self.collectionView?.reloadData()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if UIDevice.current.orientation.isLandscape {
            return CGSize(width: myCollectionView.frame.width * 0.3, height: myCollectionView.frame.height * 0.6)
            
        } else {
            return CGSize(width: myCollectionView.frame.width * 0.9, height: myCollectionView.frame.height * 0.30)
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    
//    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
//        if UIDevice.current.orientation.isLandscape,
//            let layout = myCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
//            let width = view.frame.height - 22
//            layout.itemSize = CGSize(width: 200, height: 300)
//            layout.invalidateLayout()
//        } else if UIDevice.current.orientation.isPortrait,
//            let layout = myCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
//            let width = view.frame.width - 22
//            layout.itemSize = CGSize(width: myCollectionView.frame.width * 0.9, height: myCollectionView.frame.height * 0.30)
//            layout.invalidateLayout()
//        }
//    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        if localEntries.count > 0 {
            self.collectionView?.backgroundView = UIView()
            return 1
        }
        else {
            let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
            messageLabel.numberOfLines = 0
            messageLabel.text = "No local entries."
            messageLabel.textColor = UIColor.black
            messageLabel.textAlignment = .center
            messageLabel.sizeToFit()
            self.collectionView?.backgroundView = messageLabel
            return 1
        }
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return localEntries.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! MainCollectionViewCell
    
        // Configure the cell
        let item = self.localEntries[indexPath.row]
        let setting = MainCellSetting(name: item.collectionRef!, imageName: item.localFileName!, fileType: item.fileType!, videoURL: item.videoURL ?? "", submissionStatus: item.submissionStatus!)
        cell.setting = setting
        return cell
    }
    

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
