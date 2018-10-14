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
    var pdfView: PDFView?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        pdfView = PDFView()
    }
}
