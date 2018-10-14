//
//  PdfFileModalViewController.swift
//  USS-Mobile-Response-iOS
//
//  Created by Charlie Barber on 10/7/18.
//  Copyright © 2018 Andrew Tsai. All rights reserved.
//

import UIKit

protocol PDFModalDoneDelegate
{
    func headerDoneButtonPressed(_:Bool)
}

class PdfFileModalViewController: UIViewController, TableViewControllerDelegate
{
    func tableViewDone(_: Bool)
    {
        modalDoneDelegate?.headerDoneButtonPressed(true)
    }
    
    var pdfTableView: PdfTableViewController?
    var modalDoneDelegate: PDFModalDoneDelegate?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.gray.withAlphaComponent(0.9)
        self.view.isOpaque = false
        
        pdfTableView = PdfTableViewController()
        pdfTableView!.tableVCDelegate = self
        pdfTableView!.view.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(pdfTableView!.view)
        
        NSLayoutConstraint.activate([
            pdfTableView!.view.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.75),
            pdfTableView!.view.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.85),
            pdfTableView!.view.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            pdfTableView!.view.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
            ])
    }
}
