//
//  UploadImageOperation.swift
//  USS-Mobile-Response-iOS
//
//  Created by Andrew Tsai on 10/28/18.
//  Copyright © 2018 Andrew Tsai. All rights reserved.
//

import Foundation

class UploadAltFileOperation: NetworkOperation {
    let altFile: AltFile
    private let networkManager = NetworkManager()
    
    var onDidUpload: ((_ uploadResult: String?) -> Void)!
    var onProgress: (( _ progress: Float) -> Void)!
    
    init(altFile: AltFile) {
        self.altFile = altFile
    }
    
    override func execute() {
        uploadFile()
    }
    
    private func uploadFile() {
        print("upload alt")
        networkManager.uploadAltFile(altFile: altFile) {
            (httpResult) in
            self.onDidUpload(httpResult)
            self.finished(error: "upload alt")
        }
//        self.finished(error: "upload alt")
    }
}
