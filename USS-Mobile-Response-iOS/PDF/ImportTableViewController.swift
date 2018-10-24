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

class ImportTableViewController: UITableViewController, DoneWithImportDelegate, ClearDataDelegate, ImportAllDelegate
{
    func importAll()
    {
        for i in 0..<tableData.count
        {
            let file: Data = fileManager.contents(atPath: tableData[i].relativePath)!
            let fileName: String = tableData[i].lastPathComponent
            let fileExtension: String = tableData[i].pathExtension
            if fileExtension == "pdf" {
                fileManager.createFile(atPath: (getDocumentsURL().appendingPathComponent("pdf-import").appendingPathComponent(fileName)).relativePath, contents: file, attributes: nil)
            } else {
                fileManager.createFile(atPath: (getDocumentsURL().appendingPathComponent("mp3-import").appendingPathComponent(fileName)).relativePath, contents: file, attributes: nil)
            }
            printImportDir()
        }
        
        NotificationCenter.default.post(name: Notification.Name("Import Data"), object: nil)
        clearData()
       
        let alert: UIAlertController = UIAlertController(title: "Files Imported", message: "Your files were imported to your documents library", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: {(alert: UIAlertAction) -> Void in
            self.dismissImportForm(true)
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
                let dirURL = getDocumentsURL()
                let inboxDirURL = dirURL.appendingPathComponent("Inbox", isDirectory: true)
                let filePaths = try fileManager.contentsOfDirectory(atPath: inboxDirURL.path)
                for path in filePaths {
                    let filePath = inboxDirURL.appendingPathComponent(path)
                    try fileManager.removeItem(at: filePath)
                }
            }
            catch
            {
                print(error.localizedDescription)
            }
        }
        tableData.removeAll()
        tableView.reloadData()
    }
    
    func dismissImportForm(_: Bool)
    {
        tableVCDelegate?.tableViewDone(true)
    }
    
    var tableData: [URL] = []
    weak var tableVCDelegate: TableViewControllerDelegate?
    let fileManager: FileManager = FileManager.default
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        makeImportDir()
        checkforImportFilesAndLoad()
        tableView.layer.cornerRadius = 15.0
        tableView.register(ImportTableCell.self, forCellReuseIdentifier: "cell")
        tableView.register(ImportTableHeader.self, forHeaderFooterViewReuseIdentifier: "header")
    }
    
    
    func makeImportDir()
    {
        let pdfImportDir: URL = getDocumentsURL().appendingPathComponent("pdf-import")
        let mp3ImportDir: URL = getDocumentsURL().appendingPathComponent("mp3-import")
        do
        {
            try fileManager.createDirectory(at: pdfImportDir, withIntermediateDirectories: false, attributes: nil)
            try fileManager.createDirectory(at: mp3ImportDir, withIntermediateDirectories: false, attributes: nil)
        }
        catch
        {
            print(error)
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(checkforImportFilesAndLoad), name: Notification.Name("New data"), object: nil)
    }
    
    @objc func checkforImportFilesAndLoad()
    {
        let docDir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
        let tempDocDir = docDir!.appendingPathComponent("tmp")
        let filesEnumerator = fileManager.enumerator(atPath: tempDocDir.relativePath)
        
        while let file = filesEnumerator?.nextObject()
        {
            let fileURL = docDir!.appendingPathComponent("tmp").appendingPathComponent(file as! String)
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
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as! ImportTableHeader
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! ImportTableCell
        cell.importTitle.text = tableData[indexPath.row].lastPathComponent
        let fileExtension = tableData[indexPath.row].pathExtension
        if fileExtension == "pdf" {
            cell.fileImageView.image = UIImage(named: "pdf")
        } else {
            cell.fileImageView.image = UIImage(named: "mp3")
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
//        if(fileManager.fileExists(atPath: getDocumentsURL().appendingPathComponent("import").relativePath))
//        {
//            print("file exists")
//        }
        
        let file: Data = fileManager.contents(atPath: tableData[indexPath.row].relativePath)!
        let fileName: String = tableData[indexPath.row].lastPathComponent
        let fileExtension = tableData[indexPath.row].pathExtension
        if fileExtension == "pdf" {
            fileManager.createFile(atPath: (getDocumentsURL().appendingPathComponent("pdf-import").appendingPathComponent(fileName)).relativePath, contents: file, attributes: nil)
        } else {
            fileManager.createFile(atPath: (getDocumentsURL().appendingPathComponent("mp3-import").appendingPathComponent(fileName)).relativePath, contents: file, attributes: nil)
        }
        printImportDir()
        NotificationCenter.default.post(name: Notification.Name("Import Data"), object: nil)

        do
        {
            try fileManager.removeItem(at: tableData[indexPath.row])
        }
        catch
        {
            print(error.localizedDescription)
        }
        
        tableData.remove(at: indexPath.row)
        tableView.reloadData()
        
        
        
        let alert: UIAlertController = UIAlertController(title: "File Imported", message: "Your file was imported to your documents library", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: {(alert: UIAlertAction) -> Void in
            self.dismissImportForm(true)
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

class ImportTableCell: UITableViewCell
{
    override init(style: UITableViewCellStyle, reuseIdentifier: String?)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpViews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    let fileImageView: UIImageView =
    {
        var image: UIImageView = UIImageView(image: UIImage(named: "pdf"))
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()

    let importTitle: UILabel =
    {
        var label: UILabel = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 25)
        label.text = "Title"
        return label
    }()

    func setUpViews()
    {
        addSubview(fileImageView)
        addSubview(importTitle)

        NSLayoutConstraint.activate([
            fileImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10.0),
            fileImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 2.0),
            fileImageView.heightAnchor.constraint(equalToConstant: 40.0),
            fileImageView.widthAnchor.constraint(equalToConstant: 40.0),
            importTitle.leadingAnchor.constraint(equalTo: fileImageView.trailingAnchor, constant: 15.0),
            importTitle.centerYAnchor.constraint(equalTo: fileImageView.centerYAnchor),
            ])
    }
}

protocol DoneWithImportDelegate: class
{
    func dismissImportForm(_:Bool)
}
protocol ClearDataDelegate: class
{
    func clearData()
}
protocol ImportAllDelegate: class
{
    func importAll()
}

class ImportTableHeader: UITableViewHeaderFooterView
{
    weak var doneDelegate: DoneWithImportDelegate?
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
        button.addTarget(self, action: #selector(clearData), for: .touchUpInside)
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
    
    @objc func clearData()
    {
        clearDelegate?.clearData()
    }
    
    @objc func doneWithPdfForm()
    {
        doneDelegate?.dismissImportForm(true)
        
    }
    
    @objc func importAllPdfDocs()
    {
        //Write all the files to a documents/import/pdf
        do
        {
            if(!fileManager.fileExists(atPath: getDocumentsURL().appendingPathComponent("pdf-import").relativePath))
            {
                try fileManager.createDirectory(at: getDocumentsURL().appendingPathComponent("pdf-import"), withIntermediateDirectories: false, attributes: nil)
            }
            if(!fileManager.fileExists(atPath: getDocumentsURL().appendingPathComponent("mp3-import").relativePath))
            {
                try fileManager.createDirectory(at: getDocumentsURL().appendingPathComponent("mp3-import"), withIntermediateDirectories: false, attributes: nil)
            }
            importAllDelegate?.importAll()
        }
        catch
        {
            print(error)
        }
        
    }
}
