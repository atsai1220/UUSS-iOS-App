//
//  PdfCollectionViewController.swift
//  USS-Mobile-Response-iOS
//
//  Created by Charlie Barber on 10/11/18.
//  Copyright © 2018 Andrew Tsai. All rights reserved.
//

import UIKit
import PDFKit


protocol PDFDelegate: class
{
    func returnPDF(with pdfURL: URL)
}

class PdfCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, CellHoldDelegate, DeleteCellDelegate {
    
    var dataSource: [URL] = []
    let importDir: URL = getDocumentsURL().appendingPathComponent("pdf-import")
//    var pdfImage: PDFView = PDFView()
    weak var pdfDelegate: PDFDelegate?
    static var showDelete: Bool = false
    static var inDeleteMode: Bool = false
    
    // MARK: - Delegate functions
    func deleteCell(indexPath: IndexPath)
    {
        //Get url to delete from imports folder
        print(indexPath.row)
        let url: URL = dataSource[indexPath.row]
        //Delete from data source
        dataSource.remove(at: indexPath.row)
        //Delete from collection view
        collectionView?.deleteItems(at: [indexPath])
        //Delete from imports folder
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
                if(!dataSource.contains(getDocumentsURL().appendingPathComponent("pdf-import").appendingPathComponent(file as! String)))
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
            (cell as! PdfCollectionViewCell).showDeleteButton = true
            (cell as! PdfCollectionViewCell).setUpView()
        }
    }
    
    func toggleDoneButton()
    {
        if(PdfCollectionViewController.inDeleteMode)
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
        PdfCollectionViewController.inDeleteMode = false
        toggleDoneButton()
        let cells = collectionView?.visibleCells
        
        for cell in cells!
        {
            (cell as! PdfCollectionViewCell).showDeleteButton = false
            (cell as! PdfCollectionViewCell).setUpView()
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
        collectionView?.register(PdfCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! PdfCollectionViewCell
        
        cell.cellHoldDelegate = self
        cell.deleteCellDelegate = self
        cell.pdfImage.document = PDFDocument(url: dataSource[indexPath.row])
        cell.pdfTitle.text = dataSource[indexPath.row].lastPathComponent
        cell.indexPath = indexPath
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        let document: PDFDocument = PDFDocument(url: dataSource[indexPath.row])!
        // TODO: not sure what this is for
        // pdfImage.document = document
        pdfDelegate?.returnPDF(with: dataSource[indexPath.row])
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat
    {
        return 20.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        return CGSize(width: collectionView.frame.size.width / 2 - 20, height: 200)
    }
}


