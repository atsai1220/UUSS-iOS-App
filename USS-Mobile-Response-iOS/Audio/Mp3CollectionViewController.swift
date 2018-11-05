////
////  Mp3CollectionViewController.swift
////  USS-Mobile-Response-iOS
////
////  Created by Andrew Tsai on 10/24/18.
////  Copyright © 2018 Andrew Tsai. All rights reserved.
////

import UIKit
import PDFKit

protocol Mp3Delegate: class {
    func returnMp3(with mp3URL: URL)
}

class Mp3CollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, CellHoldDelegate, DeleteCellDelegate {
    
    var dataSource: [URL] = []
    let cellId = "mp3Cell"
    let importDir: URL = getDocumentsURL().appendingPathComponent("mp3-import")
    weak var mp3Delegate: Mp3Delegate?
    static var showDelete: Bool = false
    static var inDeleteMode: Bool = false
    
    // MARK: - Delegate functions
    func deleteCell(indexPath: IndexPath)
    {
        let url: URL = dataSource[indexPath.row]
        dataSource.remove(at: indexPath.row)
        collectionView?.deleteItems(at: [indexPath])
        do
        {
            try FileManager.default.removeItem(at: url)
            printImportDir()
        }
        catch
        {
            print(error)
        }
    }
    
    @objc func loadData()
    {
        //Check the Documents/import folder and load all the data into the dataSource
        let importEnum = FileManager.default.enumerator(atPath: importDir.relativePath)
        if(importEnum != nil)
        {
            while let file = importEnum!.nextObject()
            {
                if(!dataSource.contains(getDocumentsURL().appendingPathComponent("mp3-import").appendingPathComponent(file as! String)))
                {
                    dataSource.append(importDir.appendingPathComponent(file as! String))
                }
            }
        }
        self.collectionView?.reloadData()
    }
    
    func reloadTable()
    {
        toggleDoneButton()
        let cells = collectionView?.visibleCells
        
        for cell in cells!
        {
            (cell as! Mp3CollectionViewCell).showDeleteButton = true
            (cell as! Mp3CollectionViewCell).setupView()
        }
    }
    
    func toggleDoneButton()
    {
        if(Mp3CollectionViewController.inDeleteMode)
        {
    
            navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(exitDeleteMode)), animated: false)
            
        }
        else
        {
            navigationItem.setRightBarButtonItems(nil, animated: true)
        }
    }
    
    @objc func exitDeleteMode()
    {
        Mp3CollectionViewController.inDeleteMode = false
        toggleDoneButton()
        let cells = collectionView?.visibleCells
        
        for cell in cells!
        {
            (cell as! Mp3CollectionViewCell).showDeleteButton = false
            (cell as! Mp3CollectionViewCell).setupView()
        }
    }
    
    // MARK: - UICollectionViewController
    override init(collectionViewLayout layout: UICollectionViewLayout)
    {
        super.init(collectionViewLayout: layout)
        collectionView?.collectionViewLayout = layout
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        collectionView?.backgroundColor = UIColor(red: 211/225, green: 211/225, blue: 211/225, alpha: 1)
        collectionView?.register(Mp3CollectionViewCell.self, forCellWithReuseIdentifier: cellId)
        NotificationCenter.default.addObserver(self, selector: #selector(loadData), name: Notification.Name("Import Data"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        loadData()
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        AppDelegate.AppUtility.lockOrientation(.portrait)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return dataSource.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! Mp3CollectionViewCell
        
        cell.cellHoldDelegate = self
        cell.deleteCellDelegate = self
//        cell.pdfImage.document = PDFDocument(url: dataSource[indexPath.row])
        cell.mp3Title.text = dataSource[indexPath.row].lastPathComponent
        cell.indexPath = indexPath
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
//        let document: PDFDocument = PDFDocument(url: dataSource[indexPath.row])!
        mp3Delegate?.returnMp3(with: dataSource[indexPath.row])
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat
    {
        return 20.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        return CGSize(width: collectionView.frame.size.width - 50, height: 150)
    }
}



