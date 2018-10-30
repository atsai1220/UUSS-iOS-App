//
//  UploadMainFileOperation.swift
//  USS-Mobile-Response-iOS
//
//  Created by Andrew Tsai on 10/28/18.
//  Copyright © 2018 Andrew Tsai. All rights reserved.
//

import Foundation

class UploadMainFileOperation: NetworkOperation {
    let file: LocalEntry
    var networkManager: NetworkManager?
    
    var onDidUpload: ((_ uploadResult: String?) -> Void)!
    
    init(file: LocalEntry) {
        self.file = file
    }
    
    override func execute() {
        uploadFile()
    }
    
    private func uploadFile() {
  
        networkManager?.uploadMainFile(item: file) {
            (httpResult) in
            self.onDidUpload(httpResult)
            self.finished(error: "upload main")
        }
    }
}
