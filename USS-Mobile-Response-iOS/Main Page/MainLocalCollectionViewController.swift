//
//  MainLocalCollectionViewController.swift
//  USS-Mobile-Response-iOS
//
//  Created by Andrew Tsai on 9/29/18.
//  Copyright © 2018 Andrew Tsai. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class MainLocalCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, PDFModalDoneDelegate, MainCellDelegate
{
    func deleteThis(cellIndexPath: IndexPath) {
        print("test")
        if self.localEntries.count > 0 {
            var trashEntries = getTrashEntriesFromDisk()
            trashEntries.append(self.localEntries[cellIndexPath.row])
            saveTrashEntriesToDisk(entries: trashEntries)
            self.localEntries.remove(at: cellIndexPath.row)
            collectionView?.deleteItems(at: [cellIndexPath])
            saveLocalEntriesToDisk(entries: self.localEntries)
        }
    }
    
    
    var editMode = false
    
    @objc func handleDelete(sender: UIButton) {
        
    }
    
//    func deleteThis(cellIndexPath: IndexPath) {
//
//    }
    
//    func deleteThis(cell: MainCollectionViewCell) {
//        print("test")
//        let indexPath = collectionView?.indexPath(for: cell)
//        if let indexPath = collectionView?.indexPath(for: cell) {
//            var trashEntries = getTrashEntriesFromDisk()
//            trashEntries.append(self.localEntries[indexPath.row])
//            saveTrashEntriesToDisk(entries: trashEntries)
//            self.localEntries.remove(at: indexPath.row)
//            collectionView?.deleteItems(at: [indexPath])
//            saveLocalEntriesToDisk(entries: self.localEntries)
//
//        } else {
//            print("could not find indexpath")
//        }
//    }
    
    func headerDoneButtonPressed(_: Bool)
    {
        pdfModalViewController?.dismiss(animated: true, completion: nil)
    }
    
    var localEntries: [LocalEntry] = []
    var pdfModalViewController: PdfFileModalViewController?
    
    var myCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 16
        layout.sectionInset = UIEdgeInsetsMake(16, 16, 16, 16)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.white
        return cv
    }()
    
//    let doneEditingButton: UIButton =
//    {
//        let button: UIButton = UIButton(type: .roundedRect)
//        button.translatesAutoresizingMaskIntoConstraints = false
//        button.layer.cornerRadius = 12
//        button.layer.borderWidth = 2
//        button.backgroundColor = UIColor.white
//        button.layer.shadowOpacity = 0.5
//        button.layer.shadowColor = UIColor.black.cgColor
//        button.layer.shadowOffset = CGSize(width: 0.0, height:3.0)
//        button.layer.shadowRadius = 3.0
//        button.layer.borderColor = UIColor.black.cgColor
//        button.setTitle("Done", for: .normal)
//
//        return button
//
//    }()
    
    override init(collectionViewLayout layout: UICollectionViewLayout)
    {
        super.init(collectionViewLayout: layout)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(newFilesAdded), name: Notification.Name("New data"), object: nil)
        
        let holdGesture: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(cellPressedAndHeld))
        holdGesture.minimumPressDuration = 1.0
        myCollectionView.addGestureRecognizer(holdGesture)
        
        // Register cell classes
        myCollectionView.dataSource = self
        myCollectionView.delegate = self
        myCollectionView.register(MainCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView = myCollectionView
        myCollectionView.backgroundColor = UIColor(red: 211/225, green: 211/225, blue: 211/225, alpha: 1)
        
//        view.addSubview(doneEditingButton)
//
//        NSLayoutConstraint.activate([
//            doneEditingButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10.0),
//            doneEditingButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10.0),
//            doneEditingButton.heightAnchor.constraint(equalToConstant: 25.0),
//            doneEditingButton.widthAnchor.constraint(equalToConstant: 70.0)
//            ])
        
        pdfModalViewController = PdfFileModalViewController()
        pdfModalViewController?.modalDoneDelegate = self
    }
    
    @objc func newFilesAdded()
    {
        if(pdfModalViewController!.isViewLoaded && (pdfModalViewController!.view!.window != nil))
        {
            return
        }
        else
        {
            pdfModalViewController!.modalPresentationStyle = .overCurrentContext
            navigationController!.present(pdfModalViewController!, animated: true, completion: nil)
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool)
    {
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

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! MainCollectionViewCell
    
        // Configure the cell
        let item = self.localEntries[indexPath.row]
        let setting = MainCellSetting(name: item.name!, imageName: item.localFileName!, fileType: item.fileType!, videoURL: item.videoURL ?? "", submissionStatus: item.submissionStatus!)
        cell.setting = setting
        cell.cellIndexPath = indexPath
        cell.delegate = self
//        cell.deleteViewButton.addTarget(self, action: #selector(handleDelete), for: .touchUpInside)
        if self.editMode {
            cell.showDeleteButton()
        } else {
            cell.hideDeleteButton()
        }
        return cell
    }
    
    @objc func cellPressed()
    {
        print("Cell pressed")
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
            super.viewWillTransition(to: size, with: coordinator)
            guard let flowLayout = myCollectionView.collectionViewLayout as? UICollectionViewLayout else {
                return
            }
            flowLayout.invalidateLayout()
    }


    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        let localMedia: LocalEntry = localEntries[indexPath.row]
        
        let holdGesture: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: collectionView, action: #selector(cellPressed))
        holdGesture.minimumPressDuration = TimeInterval(exactly: 2.0)!
        collectionView.addGestureRecognizer(holdGesture)
        
        
        
        switch localMedia.fileType
        {
            case FileType.PHOTO.rawValue:
                break
            case FileType.VIDEO.rawValue:
                
                let videoPlaybackController: VideoPlaybackViewController = VideoPlaybackViewController()
                videoPlaybackController.videoUrl = URL(fileURLWithPath: localMedia.videoURL!)
                navigationController?.pushViewController(videoPlaybackController, animated: true)
            
            case FileType.AUDIO.rawValue:
                break
            case FileType.DOCUMENT.rawValue:
                break
            default:
                break
        }
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

    
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    /*
    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: true)
//        var parentVC = self.parent as! MainTabBarController
//        parentVC
//        var indexPaths: [NSIndexPath] = []
//        for section in 0...collectionView!.numberOfSections {
//            for item in 0...collectionView!.numberOfItems(inSection: section) {
//                indexPaths.append(NSIndexPath(item: item, section: section))
//            }
//        }
//
//        for indexPath in indexPaths {
//            if let cell = collectionView?.cellForItem(at: indexPath as IndexPath) as? MainCollectionViewCell {
//                cell.setting?.isEditing = true
//            }
//        }
        
    }

    @objc func cellPressedAndHeld(gesture: UILongPressGestureRecognizer)
    {
        if(gesture.state != .began)
        {
            return
        }
//        var parentVC = self.parent as! MainTabBarController
//        parentVC.setEditing(true, animated: true)
//        setEditing(true, animated: true)
        self.editMode = !self.editMode
        collectionView?.reloadData()
//        var indexPaths: [NSIndexPath] = []
//        for item in 0...localEntries.count {
//            indexPaths.append(NSIndexPath(item: item, section: 0))
//        }
//
//        for indexPath in indexPaths {
//            if let cell = collectionView?.cellForItem(at: indexPath as IndexPath) as? MainCollectionViewCell {
//                cell.isEditing = !cell.isEditing
////                        cell.toggleDeleteButtion()
//            }
//        }
        
        
//        let locationPointInView: CGPoint = gesture.location(in: self.myCollectionView)
//        if let indexPath = (self.myCollectionView.indexPathForItem(at: locationPointInView)){
//            let cell = myCollectionView.cellForItem(at: indexPath) as! MainCollectionViewCell
//            cell.setting?.isEditing = true
//            cell.toggleDeleteButtion()
//        }
        
    }
}
