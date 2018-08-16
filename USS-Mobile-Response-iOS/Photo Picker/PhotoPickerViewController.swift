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
    var imageName: UIImage?
    
    init(name: String) {
        self.name = name
    }
}

class PhotoPickerViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var collectionReference: String = ""
    let cellId = "photoCell"
    var selectedIndexPath: IndexPath?
    var mainImageChosen: Bool = true
    var imageURL: URL?
    
    lazy var collectionViewLayout: UICollectionViewLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 10, right: 10)
        layout.itemSize = CGSize(width: 300, height: 300)
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
        let item = PhotoObj(name: "main")
        return item
    }()
    
    var altPhotos: [PhotoObj] = {
        return [PhotoObj(name: "new")]
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveAndUpload)), animated: true)
    }
    
    @objc
    func saveAndUpload() {
        print("4-1: Create local device entry")
        createLocalEntry()
        print("4-2: HTTP uploading with custom plugin")
        httpUpload()
        print("4-3: Create resource on resource space")
        createResourceSpaceEntry()
        print("4-4: Add resource to selected collection")
        addResourceToCollection()
        print("4-4: Confirmation and update local history")
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func createLocalEntry() {
        do {
            var newEntry = LocalEntry()
            let savedImagePath = saveImageAtDocumentDirectory(url: self.imageURL!)
            newEntry.collectionRef = self.collectionReference
            newEntry.localURL = savedImagePath.path
            // TODO: store newEntry into local storage
            var oldEntries = getEntriesFromDisk()
            oldEntries.append(newEntry)
            saveEntriesToDisk(entries: oldEntries)
        }

        catch {
            
        }
    }
    
    func httpUpload() {
        
    }
    
    func createResourceSpaceEntry() {
        let urlString = "https://geodata.geology.utah.gov/api/?"
        let privateKey = "7d510414a826c1af09d864e70c3656964839664786b8e774bafb7c10adc5fea1"
        let imageURL = self.imageURL?.absoluteString
        print("URL GOES HERE??")
        print(imageURL!)
        let queryString = "user=atsai-uuss&function=create_resource&param1=1&param2=0&param3=\(imageURL!)&param4=&param5=&param6=&param7="
        let signature = "&sign=" + (privateKey + queryString).sha256()!
        let completeURL = urlString + queryString + signature
        print(completeURL)
        guard let url = URL(string: completeURL) else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            }
            guard let data = data else { return }
            // JSON decodign and parsing
            do {
                // decode retrieved data with JSONDecoder
                let resourceSpaceData = try JSONDecoder().decode([Hazard].self, from: data)
                // return to main queue
                DispatchQueue.main.async {
                    
                    print(type(of: resourceSpaceData[0]))
                    // reload tableview or something
                    
                }
            } catch let jsonError {
                print(jsonError)
            }
            }.resume()
        print("done...?")
        print(completeURL)
    }
    
    func addResourceToCollection() {
        
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
//            return altPhotos.count
            return 0
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let myCell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath as IndexPath) as! PhotoCell
        if indexPath.section == 0 {
            let setting = mainPhoto
            myCell.setting = setting
            myCell.backgroundColor = UIColor.white
            myCell.layer.borderWidth = 1
            myCell.layer.borderColor = UIColor.black.cgColor
            return myCell
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
        // select new photo to main
        if indexPath.section == 0 {
            mainImageChosen = true

            showActionSheet(indexPath: indexPath)
        }
        else {
            // last item
            mainImageChosen = false
            if indexPath.item == altPhotos.count-1{
                altPhotos.append(PhotoObj(name: "new"))
                photoCollectionView.insertItems(at: [indexPath])
            }
            // any other collectionview cell is alt
            else {
                
            }
        }
    }
    
    func showActionSheet(indexPath: IndexPath) {
        
        self.selectedIndexPath = indexPath
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        
        // Create and modify an UIAlertController.actionSheet to allow option between Camera or Photo Library.
        let actionSheet = UIAlertController(title: "Photo Source", message: "Please choose a source for image upload.", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action: UIAlertAction) in
            
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                imagePickerController.sourceType = .camera
                self.present(imagePickerController, animated: true, completion: nil)
            }
        }))
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (action: UIAlertAction) in
            imagePickerController.sourceType = .photoLibrary
            self.present(imagePickerController, animated: true, completion: nil)
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(actionSheet, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        if mainImageChosen {
            mainPhoto.imageName = image
            photoCollectionView.reloadData()
            self.imageURL = info[UIImagePickerControllerImageURL] as? URL
            picker.dismiss(animated: true, completion: nil)
        }
        else {
            
        }
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
