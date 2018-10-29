//
//  NetworkManager.swift
//  USS-Mobile-Response-iOS
//
//  Created by Andrew Tsai on 10/15/18.
//  Copyright © 2018 Andrew Tsai. All rights reserved.
//

import Foundation
import UIKit

protocol NetWorkManagerDelegate {
    func uploadProgressWith(progress: Float)
    func dismissProgressBar()
    func showProgressBar()
    func dismissProgressController()
}

class NetworkManager: NSObject, URLSessionDelegate, URLSessionTaskDelegate, URLSessionDataDelegate {
    
    var delegate: NetWorkManagerDelegate?
    var result: [String] = []
    
    private lazy var queue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    func uploadMainFile(item: LocalEntry, completionBlock: @escaping (_ httpResult: String?) -> Void) {
        // handle main image
        let imagePath = getDocumentsURL().appendingPathComponent("local-entries").appendingPathComponent(item.localFileName!).path
        let image = UIImage(contentsOfFile: imagePath)
        let imageData = UIImageJPEGRepresentation(image!, 0.9)
        if (imageData == nil) { return }
        let boundary = generateBoundaryString()
        let fullFormData = resourceDataToFormData(data: imageData! as NSData, boundary: boundary, fileName: item.localFileName!, type: item.fileType!)
        sendPostRequestWith(body: fullFormData, boundary: boundary) {
            (httpResult) in
            completionBlock(httpResult)
        }
    }
    
    func uploadAltFile(altFile: AltFile, completionBlock: @escaping (_ httpResult: String?) -> Void) {
        do {
            let path = URL(fileURLWithPath: altFile.url)
            let fileData = try Data(contentsOf: path)
            let boundary = generateBoundaryString()
            let fileExtension = URL(fileURLWithPath: altFile.url).pathExtension
            let fullFormData = resourceDataToFormData(data: fileData as NSData, boundary: boundary, fileName: altFile.name + "." + fileExtension, type: altFile.type)
            sendPostRequestWith(body: fullFormData, boundary: boundary) {
                (httpResult) in
                completionBlock(httpResult)
            }
        } catch {
            dismissProgressController()
            displayErrorMessage(title: "Error", message: "Upload error.")
        }
    }
    
    func uploadFiles(item: LocalEntry) {
        let mainOperation = UploadMainFileOperation(file: item)
        mainOperation.onProgress = { (progress) in
            self.updateDelegateWith(progress: progress)
        }
        mainOperation.onDidUpload = { (uploadResult) in
            if let result = uploadResult {
                self.result.append(result)
            }
        }
        if let lastOp = queue.operations.last {
            mainOperation.addDependency(lastOp)
        }
        queue.addOperation(mainOperation)
        
        if let altFiles = item.altFiles {
            for altFile in altFiles {
                let altOperation = UploadAltFileOperation(altFile: altFile)
                altOperation.onProgress = { (progress) in
                    self.updateDelegateWith(progress: progress)
                }
                altOperation.onDidUpload = { (uploadResult) in
                    if let result = uploadResult {
                            
                        self.result.append(result)
                    }
                }
                if let lastOp = queue.operations.last {
                    altOperation.addDependency(lastOp)
                }
                queue.addOperation(altOperation)
            }
        } else {
            print("no alt files")
        }
        
        let finishOperation = BlockOperation { [unowned self] in
            self.dismissProgressController()
            print(self.result)
            print("OMG OMG OMG OMG OMG OMG OMG OMG OMG OMG OMG OMG OMG OMG OMG OMG OMG OMG OMG OMG OMG OMG OMG OMG OMG OMG OMG OMG OMG OMG OMG OMG OMG OMG OMG OMG OMG OMG OMG OMG OMG OMG OMG OMG OMG OMG OMG OMG OMG OMG OMG OMG OMG OMG ")
        }
        if let lastOp = queue.operations.last {
            finishOperation.addDependency(lastOp)
        }
        queue.addOperation(finishOperation)
        queue.isSuspended = false
    }
    
    func uploadAlternativeFiles(altFiles: [AltFile]) {
        
    }
    
    // TODO: add JSON metadata
    func createResource(resourceType: Int = 1, archivalState: Int = 0, serverFileURL: String) {
        
    }
    
    func addAlternativeFile(resourceId: Int, name: String, description: String, fileName: String, fileExtension: String, fileSize: Int, fileURL: String) {
        
    }
    
    func addResourceToCollection(resourceId: Int, collectionId: Int) {
        
    }
    
    func sendPostRequestWith(body fullFormData: Data, boundary: String, completionBlock: @escaping (_ httpResult: String?) -> Void) {
        let urlString = UserDefaults.standard.string(forKey: "selectedURL")! + "/api/?"
        let privateKey = UserDefaults.standard.string(forKey: "userPassword")!
        let queryString = "user=" + UserDefaults.standard.string(forKey: "userName")! + "&function=http_upload"
        let signature = "&sign=" + (privateKey + queryString).sha256()!
        let completeURL = urlString + queryString + signature
        guard let url = URL(string: completeURL) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Keep-Alive", forHTTPHeaderField: "Connection")
        request.setValue("multipart/form-data; boundary=" + boundary, forHTTPHeaderField: "Content-Type")
        
        request.setValue(String(fullFormData.count), forHTTPHeaderField: "Content-Length")
        request.httpBody = fullFormData
        request.httpShouldHandleCookies = false
        
        let configuration = URLSessionConfiguration.default
        
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: OperationQueue.main)
        
        let task = session.dataTask(with: request) {
            (data, response, error) in
            guard let data = data, response != nil, error == nil else {
                self.displayErrorMessage(title: "Alert", message: "There was an error.")
                return
            }
            let dataString = String(data: data, encoding: .utf8)
            completionBlock(dataString!)
//            print(dataString!)
            DispatchQueue.main.async {
            }
            
        }
        task.resume()
    }
    
    
    func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().uuidString)"
    }
    

    func resourceDataToFormData(data: NSData, boundary: String, fileName: String, type: String) -> Data {
        var fullData = Data()
        var mimeType = ""
        switch type {
        case FileType.PHOTO.rawValue:
            mimeType = "image/jpg"
        case FileType.VIDEO.rawValue:
            mimeType = "video/mov"
        case FileType.AUDIO.rawValue:
            mimeType = "video/mp4"
        case FileType.DOCUMENT.rawValue:
            mimeType = "application/pdf"
        default:
            print("Should not happen")
        }
        
        let lineOne = "--" + boundary + "\r\n"
        fullData.append(lineOne.data(
            using: String.Encoding.utf8,
            allowLossyConversion: false)!)
        
        let lineTwo = "Content-Disposition: form-data; name=\"file\"; filename=\"" + fileName + "\"\r\n"
        fullData.append(lineTwo.data(
            using: String.Encoding.utf8,
            allowLossyConversion: false)!)
        
        let lineThree = "Content-Type: " + mimeType + "\r\n\r\n"
        fullData.append(lineThree.data(
            using: String.Encoding.utf8,
            allowLossyConversion: false)!)
        
        fullData.append(data as Data)
        
        let lineFive = "\r\n"
        fullData.append(lineFive.data(
            using: String.Encoding.utf8,
            allowLossyConversion: false)!)
        
        let lineSix = "--" + boundary + "--\r\n"
        fullData.append(lineSix.data(
            using: String.Encoding.utf8,
            allowLossyConversion: false)!)
        
        return fullData
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        displayErrorMessage(title: "Alert", message: (error?.localizedDescription)!)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        let uploadProgress: Float = Float(totalBytesSent) / Float(totalBytesExpectedToSend)
        updateDelegateWith(progress: uploadProgress)
    }
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
//        print(response)
    }
    
    func displayErrorMessage(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Okay", style: .default, handler: {
            (action) in alert.dismiss(animated: true, completion: nil)
        })
        alert.addAction(dismissAction)
        let topController = UIApplication.shared.keyWindow?.rootViewController
        topController!.present(alert, animated: true, completion: nil)
    }
    
    func updateDelegateWith(progress: Float) {
        delegate?.uploadProgressWith(progress: progress)
    }
    
    func dismissProgressBar() {
        delegate?.dismissProgressBar()
    }
    
    func showProgressBar() {
        delegate?.showProgressBar()
    }
    
    func dismissProgressController() {
        delegate?.dismissProgressController()
    }
    
}
