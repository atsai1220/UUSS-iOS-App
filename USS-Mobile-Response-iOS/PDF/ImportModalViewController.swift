//
//  PdfFileModalViewController.swift
//  USS-Mobile-Response-iOS
//
//  Created by Charlie Barber on 10/7/18.
//  Copyright © 2018 Andrew Tsai. All rights reserved.
//

import UIKit

protocol ImportModalDoneDelegate
{
    func headerDoneButtonPressed(_:Bool)
}

class ImportModalViewController: UIViewController, TableViewControllerDelegate
{
    func tableViewDone(_: Bool)
    {
        modalDoneDelegate?.headerDoneButtonPressed(true)
    }
    
    var importTableView: ImportTableViewController?
    var modalDoneDelegate: ImportModalDoneDelegate?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.gray.withAlphaComponent(0.9)
        self.view.isOpaque = false
        
        importTableView = ImportTableViewController()
        importTableView!.tableVCDelegate = self
        importTableView!.view.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(importTableView!.view)
        
        NSLayoutConstraint.activate([
            importTableView!.view.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.75),
            importTableView!.view.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.85),
            importTableView!.view.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            importTableView!.view.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
            ])
    }
}
