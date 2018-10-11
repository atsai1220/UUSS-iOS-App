//
//  PDFViewController.swift
//  USS-Mobile-Response-iOS
//
//  Created by Charlie Barber on 10/4/18.
//  Copyright © 2018 Andrew Tsai. All rights reserved.
//

import UIKit
import PDFKit

class PDFViewController: UIViewController, UIDocumentInteractionControllerDelegate
{
    var collectionRef: String = ""
    var docInteractionController: UIDocumentInteractionController = UIDocumentInteractionController()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        docInteractionController.delegate = self
    }
    
    func documentInteractionControllerViewForPreview(_ controller: UIDocumentInteractionController) -> UIView?
    {
        var view = controller.url
        return UIView()
    }
}
