//
//  AddAlternativeFileOperation.swift
//  USS-Mobile-Response-iOS
//
//  Created by Andrew Tsai on 11/11/18.
//  Copyright © 2018 Andrew Tsai. All rights reserved.
//

import Foundation

class AddAlternativeFileOperation: NetworkOperation {
    let resourceId: Int
    var item: AltFile
    let remoteFiles: [(String, String)]
    var networkManager: NetworkManager?
    
    var onDidUpload: ((_ uploadResult: Data) -> Void)!
    
    init(resourceId: Int, item: AltFile, remoteFiles: [(String, String)]) {
        self.resourceId = resourceId
        self.remoteFiles = remoteFiles
        self.item = item
    }
    
    override func execute() {
        addAlternativeFile()
    }
    
    private func addAlternativeFile() {
        let fileType: String
        if item.type == "PHOTO" {
            item.name.append(".jpeg")
            fileType = ".jpeg"
        } else if item.type == ".mp3" {
            item.name.append(".mp3")
            fileType = ".mp3"
        } else if item.type == ".pdf" {
            item.name.append("pdf")
            fileType = ".pdf"
        } else if item.type == ".mp4" {
            item.name.append(".mp4")
            fileType = ".mp4"
        } else {
            item.name.append(".mov")
            fileType = ".mov"
        }
        
        let remoteSet = self.remoteFiles.first { (arg0) -> Bool in
            let (remoteName, _) = arg0
            if item.name == remoteName {
                return true
            } else {
                return false
            }
        }
        var fileSize: UInt64
        do {
            let attr = try FileManager.default.attributesOfItem(atPath: getDocumentsURL().appendingPathComponent("local-entries").appendingPathComponent(item.name).path)
            fileSize = attr[FileAttributeKey.size] as! UInt64
            networkManager?.addAlternativeFile(resourceId: self.resourceId, name: item.name, description: "", fileName: remoteSet!.0, fileExtension: fileType, fileSize: Int(fileSize), fileURL: remoteSet!.1) {
                (httpResult) in
                self.onDidUpload(httpResult)
                self.finished(error: "add alt file to resource")
            }
        } catch {
            print("error while grabbing alt file size")
        }
        
 
    }
}
