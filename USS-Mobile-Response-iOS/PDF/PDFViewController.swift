//
//  PDFViewController.swift
//  USS-Mobile-Response-iOS
//
//  Created by Charlie Barber on 10/4/18.
//  Copyright © 2018 Andrew Tsai. All rights reserved.
//

import UIKit
import PDFKit

class PDFViewController: UIViewController
{
    var collectionRef: String = ""
    private var document: PDFDocument?
    var pdfView: PDFView?
    var pdfDoc: PDFDocument
    {
        get
        {
            if(document != nil)
            {
                return document!
            }
            return PDFDocument()
        }
        set
        {
            document = newValue
        }
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        pdfView = PDFView()
        pdfView?.translatesAutoresizingMaskIntoConstraints = false
        pdfView?.document = pdfDoc
        pdfView?.displayMode = .singlePageContinuous
        pdfView?.autoScales = true
    
        let pdfPage = pdfView!.document?.page(at: 0)
        pdfView!.go(to: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height), on: pdfPage!)
        
        self.view.addSubview(pdfView!)
        
        NSLayoutConstraint.activate([
            pdfView!.heightAnchor.constraint(equalTo: self.view.heightAnchor),
            pdfView!.widthAnchor.constraint(equalTo: self.view.widthAnchor)
            ])
    }
}
