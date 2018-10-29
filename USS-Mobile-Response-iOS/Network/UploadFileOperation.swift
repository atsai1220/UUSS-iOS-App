//
//  UploadImageOperation.swift
//  USS-Mobile-Response-iOS
//
//  Created by Andrew Tsai on 10/28/18.
//  Copyright © 2018 Andrew Tsai. All rights reserved.
//

import Foundation

class UploadFileOperation: NetworkOperation {
    let altFile: AltFile
    private let networkManager = NetworkManager()
    
    var onDidUpload: ((_ url: String?) -> Void)!
    var onProgress: (( _ progress: Float) -> Void)!
    
    init(altFile: AltFile) {
        self.altFile = altFile
    }
    
    override func execute() {
        uploadFile()
    }
    
    private func uploadFile() {
//        networkManager.uploadFile(fileURL, progressBlock: onProgress) { [unowned self] (url, error) in
//            self.onDidUpload(url)
//            self.finished(error: error)
//
//        }
    }
}
