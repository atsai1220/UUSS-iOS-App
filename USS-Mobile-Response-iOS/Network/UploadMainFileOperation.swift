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
    private let networkManager = NetworkManager()
    
    var onDidUpload: ((_ uploadResult: String?) -> Void)!
    var onProgress: (( _ progress: Float) -> Void)!
    
    init(file: LocalEntry) {
        self.file = file
    }
    
    override func execute() {
        uploadFile()
    }
    
    private func uploadFile() {
        print("uploading main")
        networkManager.uploadMainFile(item: file) {
            (httpResult) in
            self.onDidUpload(httpResult)
            self.finished(error: "upload main")
        }
    }
}
