//
//  PdfCollectionViewController.swift
//  USS-Mobile-Response-iOS
//
//  Created by Charlie Barber on 10/11/18.
//  Copyright © 2018 Andrew Tsai. All rights reserved.
//

import UIKit
import PDFKit

class PdfCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout
{
    var dataSource: [URL] = []
    let importDir: URL = getDocumentsURL().appendingPathComponent("import")
    
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
        collectionView?.backgroundColor = .white
        collectionView?.register(CollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        NotificationCenter.default.addObserver(self, selector: #selector(loadData), name: Notification.Name("Import Data"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        loadData()
    }
    
    @objc func loadData()
    {
        //Check the Documents/import folder and load all the data into the dataSource
        let importEnum = FileManager.default.enumerator(atPath: importDir.relativePath)
        
        if(importEnum != nil)
        {
            while let file = importEnum!.nextObject()
            {
                if(!dataSource.contains(getDocumentsURL().appendingPathComponent("import").appendingPathComponent(file as! String)))
                {
                    dataSource.append(importDir.appendingPathComponent(file as! String))
                }
            }
        }
        self.collectionView?.reloadData()
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat
    {
        return 20.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        return CGSize(width: collectionView.frame.size.width / 2 - 20, height: 200)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
        
        cell.pdfImage.document = PDFDocument(url: dataSource[indexPath.row])
        cell.pdfTitle.text = dataSource[indexPath.row].lastPathComponent
        
        return cell
    }
}

class CollectionViewCell: UICollectionViewCell
{
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        self.backgroundColor = .white
        self.layer.cornerRadius = 5.0
        self.layer.shadowRadius = 3.0
        self.layer.shadowOffset = CGSize(width: 0.0, height: 5.0)
        self.layer.shadowRadius = 5.0
        self.layer.shadowOpacity = 1.0
        self.layer.shadowColor = UIColor.black.cgColor
        setUpView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var pdfImage: PDFView =
    {
        var pdf: PDFView = PDFView()
        pdf.isUserInteractionEnabled = false
        pdf.translatesAutoresizingMaskIntoConstraints = false
        pdf.autoScales = true
        pdf.displayMode = .singlePage
        pdf.layer.borderWidth = 0.2
        pdf.layer.borderColor = UIColor.black.cgColor
        
        return pdf
    }()

    var pdfTitle: UILabel =
    {
        var label: UILabel = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "title"
        label.textAlignment = .center
        return label
    }()
    
    func setUpView()
    {
        addSubview(pdfImage)
        addSubview(pdfTitle)
        
        NSLayoutConstraint.activate([
            pdfImage.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.7),
            pdfImage.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.9),
            pdfImage.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            pdfImage.topAnchor.constraint(equalTo: self.topAnchor, constant: 10.0),
            pdfTitle.topAnchor.constraint(equalTo: pdfImage.bottomAnchor, constant: 5.0),
            pdfTitle.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.9),
            pdfTitle.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5.0),
            pdfTitle.centerXAnchor.constraint(equalTo: self.centerXAnchor)
            ])
    }
}
