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

class PdfCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, CellHoldDelegate, DeleteCellDelegate
{
    func deleteCell(indexPath: IndexPath)
    {
        //Get url to delete from imports folder
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
    
    
//    @objc func deleteCell(sender: UIButton)
//    {
//        let index = sender.tag
//
//        //Get url to delete from imports folder
//        let url: URL = dataSource[index]
//        //Delete from data source
//        dataSource.remove(at: index)
//        //Delete from collection view
//        collectionView?.reloadItems(at: <#T##[IndexPath]#>)
//        //Delete from imports folder
//        dataSource.remove(at: index)
//        collectionView?.reloadData()
//
//
//    }
    
    
    
    
    func reloadTable()
    {
        toggleDoneButton()
        let cells: [UICollectionViewCell] = (collectionView?.visibleCells)!
        
        for cell in cells
        {
            (cell as! CollectionViewCell).showDeleteButton = true
            (cell as! CollectionViewCell).setUpView()
        }
    }
    
    var dataSource: [URL] = []
    let importDir: URL = getDocumentsURL().appendingPathComponent("import")
    var pdfImage: PDFView = PDFView()
    weak var pdfDelegate: PDFDelegate?
    static var showDelete: Bool = false
    static var inDeleteMode: Bool = false
    
    let doneEditingButton: UIButton =
    {
        let button: UIButton = UIButton(type: .roundedRect)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.alpha = 0.0
        button.layer.cornerRadius = 12
        button.layer.borderWidth = 2
        button.backgroundColor = UIColor.white
        button.layer.shadowOpacity = 0.5
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0.0, height:3.0)
        button.layer.shadowRadius = 3.0
        button.layer.borderColor = UIColor.black.cgColor
        button.setTitle("Done", for: .normal)
        button.addTarget(self, action: #selector(exitDeleteMode), for: .touchUpInside)

        return button

    }()

    @objc func exitDeleteMode()
    {
        PdfCollectionViewController.inDeleteMode = false
        toggleDoneButton()
        let cells: [UICollectionViewCell] = (collectionView?.visibleCells)!
        
        for cell in cells
        {
            (cell as! CollectionViewCell).showDeleteButton = false
            (cell as! CollectionViewCell).setUpView()
        }
    }
    
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
    
    func toggleDoneButton()
    {
        if(PdfCollectionViewController.inDeleteMode)
        {
            view.addSubview(doneEditingButton)
            
            UIView.animate(withDuration: 0.2, delay: 0.1, options: .curveEaseInOut, animations: { self.doneEditingButton.alpha = 1.0 }, completion: nil)
           
            NSLayoutConstraint.activate([
                doneEditingButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15.0),
                doneEditingButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -15.0),
                doneEditingButton.heightAnchor.constraint(equalToConstant: 25.0),
                doneEditingButton.widthAnchor.constraint(equalToConstant: 75.0)
                ])
        }
        else
        {
            UIView.animate(withDuration: 0.2, delay: 0.1, options: .curveEaseInOut, animations: { self.doneEditingButton.alpha = 0.0 }, completion: nil)
            doneEditingButton.removeFromSuperview()
        }
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
        pdfImage.document = document
        pdfDelegate?.returnPDF(with: dataSource[indexPath.row])
        navigationController?.popViewController(animated: true)
    }
}

protocol CellHoldDelegate: class
{
    func reloadTable()
}
protocol DeleteCellDelegate: class
{
    func deleteCell(indexPath: IndexPath)
}

class CollectionViewCell: UICollectionViewCell
{
    weak var cellHoldDelegate: CellHoldDelegate?
    weak var deleteCellDelegate: DeleteCellDelegate?
    var showDeleteButton: Bool = false
    var indexPath: IndexPath?
    
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
        
        let holdGestureRecognizer: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(cellTouched))
        holdGestureRecognizer.minimumPressDuration = 1.0
        addGestureRecognizer(holdGestureRecognizer)
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
    
    var deleteViewButton: UIButton =
    {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.clipsToBounds = true
        button.layer.cornerRadius = 15
        button.alpha = 0.0
        button.backgroundColor = .red
        button.setImage(UIImage(named: "minus"), for: .normal)
        return button
    }()
    
    func setUpView()
    {
        addSubview(pdfImage)
        addSubview(pdfTitle)
        if(showDeleteButton)
        {
            addSubview(deleteViewButton)
            
            UIView.animate(withDuration: 0.2, delay: 0.1, options: .curveEaseInOut, animations: { self.deleteViewButton.alpha = 1.0}, completion: nil)
            
            NSLayoutConstraint.activate([
                deleteViewButton.topAnchor.constraint(equalTo: self.topAnchor, constant: -10.0),
                deleteViewButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: -10.0),
                deleteViewButton.heightAnchor.constraint(equalToConstant: 30.0),
                deleteViewButton.widthAnchor.constraint(equalToConstant: 30.0)
                ])
            deleteViewButton.addTarget(self, action: #selector(deleteCell), for: .touchUpInside)
        }
        else
        {
            UIView.animate(withDuration: 0.2, delay: 0.1, options: .curveEaseInOut, animations: { self.deleteViewButton.alpha = 0.0}, completion: nil)
            deleteViewButton.removeFromSuperview()
        }
        
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
    
    @objc func cellTouched()
    {
        PdfCollectionViewController.inDeleteMode = true
        cellHoldDelegate!.reloadTable()
    }
    
    @objc func deleteCell()
    {
        deleteCellDelegate?.deleteCell(indexPath: self.indexPath!)
    }
}
