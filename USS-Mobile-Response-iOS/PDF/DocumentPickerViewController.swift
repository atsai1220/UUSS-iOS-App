//
//  DocumentPickerViewController.swift
//  USS-Mobile-Response-iOS
//
//  Created by Charlie Barber on 10/4/18.
//  Copyright © 2018 Andrew Tsai. All rights reserved.
//

import UIKit

class DocumentPickerViewController: UIDocumentPickerViewController
{
    var collectionRef: String = ""
    var url: URL?
    
    override init(url: URL, in mode: UIDocumentPickerMode)
    {
        super.init(url: url, in: mode)
        
        self.url = url
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
}
