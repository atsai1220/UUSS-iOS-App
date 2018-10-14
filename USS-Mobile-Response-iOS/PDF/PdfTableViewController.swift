//
//  PdfTableViewController.swift
//  USS-Mobile-Response-iOS
//
//  Created by Charlie Barber on 10/9/18.
//  Copyright © 2018 Andrew Tsai. All rights reserved.
//

import UIKit

protocol TableViewControllerDelegate: class
{
    func tableViewDone(_: Bool)
}

class PdfTableViewController: UITableViewController, DoneWithPDFDelegate, ClearDataDelegate, ImportAllDelegate
{
    func importAll()
    {
        for i in 0..<tableData.count
        {
            let file: Data = fileManager.contents(atPath: tableData[i].relativePath)!
            let fileName: String = tableData[i].lastPathComponent
            fileManager.createFile(atPath: (getDocumentsURL().appendingPathComponent("import").appendingPathComponent(fileName)).relativePath, contents: file, attributes: nil)
        }
        
        NotificationCenter.default.post(name: Notification.Name("Import Data"), object: nil)
        clearData()
       
        let alert: UIAlertController = UIAlertController(title: "Files Imported", message: "Your files were imported to your documents library", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: {(alert: UIAlertAction) -> Void in
            self.dismissPDFForm(true)
        }))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func clearData()
    {
        for i in 0..<tableData.count
        {            
            do
            {
                try fileManager.removeItem(at: tableData[i])
                if(!fileManager.fileExists(atPath: tableData[i].relativePath))
                {
                    print("file removed")
                }
            }
            catch
            {
                print(error)
            }
        }
        tableData.removeAll()
        tableView.reloadData()
    }
    
    func dismissPDFForm(_: Bool)
    {
        tableVCDelegate?.tableViewDone(true)
    }
    
    var tableData: [URL] = []
    weak var tableVCDelegate: TableViewControllerDelegate?
    let fileManager: FileManager = FileManager.default
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        checkForPdfFilesAndLoad()
        tableView.layer.cornerRadius = 15.0
        tableView.register(PdfTableCell.self, forCellReuseIdentifier: "cell")
        tableView.register(PdfTableHeader.self, forHeaderFooterViewReuseIdentifier: "header")
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(checkForPdfFilesAndLoad), name: Notification.Name("New data"), object: nil)
    }
    
    @objc func checkForPdfFilesAndLoad()
    {
        let docDir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
        let tempDocDir = docDir!.appendingPathComponent("tmp")
        let filesEnumerator = fileManager.enumerator(atPath: tempDocDir.relativePath)
        
        while let file = filesEnumerator?.nextObject()
        {
            let fileURL = docDir!.appendingPathComponent("tmp").appendingPathComponent(file as! String)
            print(fileURL)
            if(!tableData.contains(fileURL))
            {
                tableData.append(fileURL)
            }
        }
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return tableData.count
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as! PdfTableHeader
        header.doneDelegate = self
        header.clearDelegate = self
        header.importAllDelegate = self
        
        return header
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 50.0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! PdfTableCell
        
        cell.pdfTitle.text = tableData[indexPath.row].lastPathComponent
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        
        let file: Data = fileManager.contents(atPath: tableData[indexPath.row].relativePath)!
        let fileName: String = tableData[indexPath.row].lastPathComponent
        fileManager.createFile(atPath: (getDocumentsURL().appendingPathComponent("import").appendingPathComponent(fileName)).relativePath, contents: file, attributes: nil)

        do
        {
            try fileManager.removeItem(at: tableData[indexPath.row])
        }
        catch
        {
            print(error)
        }
        
        tableData.remove(at: indexPath.row)
        tableView.reloadData()
        
        
        NotificationCenter.default.post(name: Notification.Name("Import Data"), object: nil)
        
        let alert: UIAlertController = UIAlertController(title: "File Imported", message: "Your file was imported to your documents library", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: {(alert: UIAlertAction) -> Void in
            self.dismissPDFForm(true)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
    {
        if editingStyle == .delete
        {
            do
            {
                try fileManager.removeItem(at: tableData[indexPath.row])
            }
            catch
            {
                print(error)
            }
            
            tableData.remove(at: indexPath.row)
            tableView.reloadData()
        }
    }

}

class PdfTableCell: UITableViewCell
{
    override init(style: UITableViewCellStyle, reuseIdentifier: String?)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpViews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    let pdfLogo: UIImageView =
    {
        var image: UIImageView = UIImageView(image: UIImage(named: "pdf"))
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()

    let pdfTitle: UILabel =
    {
        var label: UILabel = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 25)
        label.text = "Title"
        return label
    }()

    func setUpViews()
    {
        addSubview(pdfLogo)
        addSubview(pdfTitle)

        NSLayoutConstraint.activate([
            pdfLogo.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10.0),
            pdfLogo.topAnchor.constraint(equalTo: self.topAnchor, constant: 2.0),
            pdfLogo.heightAnchor.constraint(equalToConstant: 40.0),
            pdfLogo.widthAnchor.constraint(equalToConstant: 40.0),
            pdfTitle.leadingAnchor.constraint(equalTo: pdfLogo.trailingAnchor, constant: 15.0),
            pdfTitle.centerYAnchor.constraint(equalTo: pdfLogo.centerYAnchor),
            ])
    }
}

protocol DoneWithPDFDelegate: class
{
    func dismissPDFForm(_:Bool)
}
protocol ClearDataDelegate: class
{
    func clearData()
}
protocol ImportAllDelegate: class
{
    func importAll()
}

class PdfTableHeader: UITableViewHeaderFooterView
{
    weak var doneDelegate: DoneWithPDFDelegate?
    weak var clearDelegate: ClearDataDelegate?
    weak var importAllDelegate: ImportAllDelegate?
    let fileManager: FileManager = FileManager.default
    
    override init(reuseIdentifier: String?)
    {
        super.init(reuseIdentifier: reuseIdentifier)
        setUpHeaderViews()
    }

    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }

    var clearButton: UIButton =
    {
        var button: UIButton = UIButton(type: .system)
        button.addTarget(self, action: #selector(clearPdf), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel!.font = .systemFont(ofSize: 20.0)
        button.titleLabel!.textColor = .blue
        button.setTitle("Clear", for: .normal)
        return button
    }()
    
    var doneButton: UIButton =
    {
        var button: UIButton = UIButton(type: .system)
        button.addTarget(self, action: #selector(doneWithPdfForm), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel!.font = .systemFont(ofSize: 20.0)
        button.titleLabel!.textColor = .blue
        button.setTitle("Done", for: .normal)
        return button
    }()

    var importButton: UIButton =
    {
        var button: UIButton = UIButton(type: .system)
        button.addTarget(self, action: #selector(importAllPdfDocs), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel!.font = .systemFont(ofSize: 20.0)
        button.titleLabel!.textColor = .blue
        button.setTitle("Import All", for: .normal)
        return button
    }()

    func setUpHeaderViews()
    {
        addSubview(clearButton)
        addSubview(doneButton)
        addSubview(importButton)

        NSLayoutConstraint.activate([
            clearButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 1.0),
            clearButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 1.0),
            clearButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20.0),
            doneButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 1.0),
            doneButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 1.0),
            doneButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20.0),
            importButton.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            importButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 5.0),
            importButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5.0),
            ])
    }
    
    @objc func clearPdf()
    {
        clearDelegate?.clearData()
    }
    
    @objc func doneWithPdfForm()
    {
        doneDelegate?.dismissPDFForm(true)
        
    }
    
    @objc func importAllPdfDocs()
    {
        //Write all the files to a documents/import/pdf
        do
        {
            if(!fileManager.fileExists(atPath: getDocumentsURL().appendingPathComponent("import").relativePath))
            {
                try fileManager.createDirectory(at: getDocumentsURL().appendingPathComponent("import"), withIntermediateDirectories: false, attributes: nil)
            }
            importAllDelegate?.importAll()
        }
        catch
        {
            print(error)
        }
        
    }
}