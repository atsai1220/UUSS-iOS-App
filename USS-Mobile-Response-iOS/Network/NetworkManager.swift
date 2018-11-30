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
    func popToRootController()
    func updateProgress(with text: String)
    func dismissAndDisplayError(message: String)
}

class NetworkManager: NSObject, URLSessionDelegate, URLSessionTaskDelegate, URLSessionDataDelegate {
    
    var delegate: NetWorkManagerDelegate?
    var remoteFileLocations: [(String, String)] = []
    var resourceId: Int?
    
    
    private lazy var queue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    func parseHttpResponse(result: Data) {
        do {
            let jsonResponse = try JSONSerialization.jsonObject(with: result, options: [])
            guard let jsonArray = jsonResponse as? [[String: Any]] else {
                return
            }
            guard let status = jsonArray[0]["Status"] as? String else { return }
            if status == "OK" {
                guard let location = jsonArray[0]["Location"] as? String else { return }
                guard var fileName = jsonArray[0]["Message"] as? String else { return }
                fileName.removeFirst(9)
                fileName.removeLast(19)
                self.remoteFileLocations.append((fileName, location))
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func uploadMainFile(item: LocalEntry, completionBlock: @escaping (_ httpResult: Data) -> Void) {
        // handle main image
        let internetTestObject = Reachability()
        if internetTestObject.hasInternet() {
            let imagePath = getDocumentsURL().appendingPathComponent("local-entries").appendingPathComponent(item.localFileName!).path
            let image = UIImage(contentsOfFile: imagePath)
            let imageData = UIImageJPEGRepresentation(image!, 0.9)
            if (imageData == nil) { return }
            let boundary = generateBoundaryString()
            delegate?.updateProgress(with: "Uploading main file...")
            let fullFormData = resourceDataToFormData(data: imageData! as NSData, boundary: boundary, fileName: item.localFileName!, type: item.fileType!)
            sendPostRequestWith(body: fullFormData, boundary: boundary) {
                (httpResult) in
                completionBlock(httpResult)
            }
        } else {
            delegate?.popToRootController()
            self.displayErrorMessage(title: "No network connection", message: "Please check your network connection")
        }

    }
    
    func uploadAltFile(altFile: AltFile, completionBlock: @escaping (_ httpResult: Data) -> Void) {
        let internetTestObject = Reachability()
        if internetTestObject.hasInternet() {
            do {
                let path = URL(fileURLWithPath: altFile.url, isDirectory: false)
                let fileData = try Data(contentsOf: path)
                let boundary = generateBoundaryString()
                let fileExtension = URL(fileURLWithPath: altFile.url).pathExtension
                delegate?.updateProgress(with: "Uploading alternative files...")
                let fullFormData = resourceDataToFormData(data: fileData as NSData, boundary: boundary, fileName: altFile.name + "." + fileExtension, type: altFile.type)
                sendPostRequestWith(body: fullFormData, boundary: boundary) {
                    (httpResult) in
                    completionBlock(httpResult)
                }
            } catch {
                dismissProgressController()
                displayErrorMessage(title: "Error", message: "Upload error.")
            }
        } else {
            delegate?.popToRootController()
            self.displayErrorMessage(title: "No network connection", message: "Please check your network connection")
        }
    }
    
    func uploadFiles(item: LocalEntry) {
        let mainOperation = UploadMainFileOperation(file: item)
        mainOperation.networkManager = self
        mainOperation.onDidUpload = { (uploadResult) in
            let outputStr  = String(data: uploadResult, encoding: String.Encoding.utf8) as String!
            if outputStr == "" {
                self.delegate?.dismissAndDisplayError(message: "500 Errorrrrrrrrr")
            }
            self.parseHttpResponse(result: uploadResult)
        }
        if let lastOp = queue.operations.last {
            mainOperation.addDependency(lastOp)
        }
        queue.addOperation(mainOperation)
        
        for altFile in item.altFiles ?? [] {
            let altOperation = UploadAltFileOperation(altFile: altFile)
            altOperation.networkManager = self
            altOperation.onDidUpload = { (uploadResult) in
                self.parseHttpResponse(result: uploadResult)

            }
            if let lastOp = queue.operations.last {
                altOperation.addDependency(lastOp)
            }
            queue.addOperation(altOperation)
        }
        
        // add operation for creating resource and adding alt files
        let createResourceOperation = CreateResourceOperation(item: item, resourceType: 1, archivalState: 0)
        createResourceOperation.networkManager = self
        createResourceOperation.onDidUpload = { (httpData) in
            let resourceId = String(data: httpData, encoding: .utf8)!
            self.resourceId = Int(resourceId)!
            
            // add_alternative_files
            for altFile in item.altFiles ?? [] {
                let addAlternativeFilesOperation = AddAlternativeFileOperation(resourceId: self.resourceId!, item: altFile, remoteFiles: self.remoteFileLocations)
                addAlternativeFilesOperation.networkManager = self
                addAlternativeFilesOperation.onDidUpload = { (uploadResult) in
                    let result = String(bytes: uploadResult, encoding: .utf8)!
                    print(result)
                }
                if let lastOp = self.queue.operations.last {
                    addAlternativeFilesOperation.addDependency(lastOp)
                }
                self.queue.addOperation(addAlternativeFilesOperation)
            }
            
            // add_resource_to_collection
            // TODO: remove this for the real deal (UGS ResourceSpace)
            let addResourceToCollectionOperation = AddResourceToCollectionOperation(resourceId: self.resourceId!, collectionId: 1)
            addResourceToCollectionOperation.networkManager = self
            addResourceToCollectionOperation.onDidUpload = { (uploadResult) in
                let result = String(bytes: uploadResult, encoding: .utf8)!
                // true or false depending on success
                print(result)
            }
            
            if let lastOp = self.queue.operations.last {
                addResourceToCollectionOperation.addDependency(lastOp)
            }
            
            self.queue.addOperation(addResourceToCollectionOperation)
            
            let finishOperation = BlockOperation { [unowned self] in
                self.delegate?.popToRootController()
            }
            if let lastOp = self.queue.operations.last {
                finishOperation.addDependency(lastOp)
            }
            self.queue.addOperation(finishOperation)
        }
        if let lastOp = self.queue.operations.last {
            createResourceOperation.addDependency(lastOp)
        }
        queue.addOperation(createResourceOperation)

        queue.isSuspended = false
    }
    
    // TODO: add JSON metadata
    func createResource(item: LocalEntry, resourceType: Int = 1, archivalState: Int = 4, completionBlock: @escaping (_ httpResult: Data) -> Void) {
//        let fileName = self.remoteFileLocations[0].0
//        let remoteLocation = self.remoteFileLocations[0].1
//        item.collectionRef
//        // METADATA
//        var metaArray = [Codable]()
//        let metaName = MetaName(name: fileName)
//        let metaDescription = MetaDescription(description: item.description!)
//        let metaNotes = MetaNotes(notes: item.notes!)
        
        let metaJSON = MetaThing(name: item.name!, description: item.description!, notes: item.notes!)
//        guard let jsonData = try? JSONEncoder().encode(metaJSON) else { return }
//        guard let jsonString = String(data: jsonData, encoding: .utf8) else { return }
//        metaJSON.encode(to: JSONEncoder)
//        print(jsonString)
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try! encoder.encode(metaJSON)
        let jsonString = String(data: data, encoding: .utf8)!
        print(jsonString)
        
//        metaArray.append(metaName)
//        metaArray.append(metaDescription)
//        metaArray.append(metaNotes)
//
//
//        if let jsonData = try? JSONEncoder().encode(metaArray),
//            guard let jsonString = String(data: jsonData, encoding: .utf8) { return }
//        print(jsonString)
        
//        guard let data = try? JSONSerialization.data(withJSONObject: metaData, options: []) else { return }
       
//        let jsonString = String(data: data, encoding: String.Encoding.utf8)!
//        let jsonString = String(data: data, encoding: .utf8)?.replacingOccurrences(of: "\\/", with: "/")
//        print(jsonString!)
        
        // Title
        // Hazard Type
        // Description
        // Notes
        
        delegate?.updateProgress(with: "Creating remote resource...")
        let urlString = UserDefaults.standard.string(forKey: "selectedURL")! + "/api/?"
        let privateKey = UserDefaults.standard.string(forKey: "userPassword")!
        let queryString = "user=" + UserDefaults.standard.string(forKey: "userName")! + "&function=create_resource" + "&param1=" + String(resourceType) + "&param2=" + String(archivalState) + "&param3=" + self.remoteFileLocations[0].1 + "&param4=" + "&param5=" + "&param6=1" + "&param7="
        let signature = "&sign=" + (privateKey + queryString).sha256()!
        let completeURL = urlString + queryString + signature
        guard let url = URL(string: completeURL) else { return }
        sendGetRequest(url: url, completionBlock: completionBlock)
    }
    
    struct MetaThing: Codable {
        let name: String
        let description: String
        let notes: String
    }
//
//    struct MetaName: Codable {
//        let name: String
//    }
//
//    struct MetaDescription: Codable {
//        let description: String
//    }
//
//    struct MetaNotes: Codable {
//        let notes: String
//    }
    
    func addAlternativeFile(resourceId: Int, name: String, description: String, fileName: String, fileExtension: String, fileSize: Int, fileURL: String, completionBlock: @escaping (_ httpResult: Data) -> Void) {
        delegate?.updateProgress(with: "Adding alternative files to remote resource...")
        let urlString = UserDefaults.standard.string(forKey: "selectedURL")! + "/api/?"
        let privateKey = UserDefaults.standard.string(forKey: "userPassword")!
        
        let queryString = "user=" + UserDefaults.standard.string(forKey: "userName")! + "&function=add_alternative_file" + "&param1=" + String(resourceId) + "&param2=" + name + "&param3=" + description + "&param4=" + fileName + "&param5=" + fileExtension + "&param6=" + String(fileSize) + "&param7=" + "&param8=" + fileURL
        let signature = "&sign=" + (privateKey + queryString).sha256()!
        let completeURL = urlString + queryString + signature
        guard let url = URL(string: completeURL) else { return }
        sendGetRequest(url: url, completionBlock: completionBlock)
    }
    
    func addResourceToCollection(resourceId: Int, collectionId: Int, completionBlock: @escaping (_ httpResult: Data) -> Void) {
        delegate?.updateProgress(with: "Adding resource to collection...")
        let urlString = UserDefaults.standard.string(forKey: "selectedURL")! + "/api/?"
        let privateKey = UserDefaults.standard.string(forKey: "userPassword")!
        
        let queryString = "user=" + UserDefaults.standard.string(forKey: "userName")! + "&function=add_resource_to_collection" + "&param1=" + String(resourceId) + "&param2=" + String(collectionId)
        let signature = "&sign=" + (privateKey + queryString).sha256()!
        let completeURL = urlString + queryString + signature
        guard let url = URL(string: completeURL) else { return }
        sendGetRequest(url: url, completionBlock: completionBlock)
    }
    
    func sendGetRequest(url: URL, completionBlock: @escaping(_ httpResult: Data) -> Void) {
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            guard let data = data else { return }
            let outputStr  = String(data: data, encoding: String.Encoding.utf8) as String!
            if let response = response as? HTTPURLResponse {
                switch response.statusCode {
                case 500...599:
                    DispatchQueue.main.async {
                        self.queue.isSuspended = true
                        self.delegate?.dismissAndDisplayError(message: "500 internal server")
                        return
                    }
                default:
                    print(response)
                    print(response.statusCode)
                    print("not a 500")
                }
            }
            completionBlock(data)
        }
        task.resume()
    }
    
    func sendPostRequestWith(body fullFormData: Data, boundary: String, completionBlock: @escaping (_ httpResult: Data) -> Void) {
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
        configuration.timeoutIntervalForRequest = 5.0
   
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        
        let task = session.dataTask(with: request) {
            (data, response, error) in
            guard let data = data, response != nil, error == nil else {
                self.displayErrorMessage(title: "Alert", message: "There was an error.")
                return
            }
            if error != nil {
                if error!._code == NSURLErrorTimedOut {
                    DispatchQueue.main.async {
                        self.displayErrorMessage(title: "Connection error", message: "Connection to server timed out.")
                        return
                    }
                }
            }
            if let response = response as? HTTPURLResponse {
                switch response.statusCode {
                case 500...599:
                    DispatchQueue.main.async {
                        self.queue.isSuspended = true
                        self.delegate?.dismissAndDisplayError(message: "500 internal server")
                        return
                    }
                default:
                    print("not a 500")
                }
            }
            DispatchQueue.main.async {
                completionBlock(data)
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
        DispatchQueue.main.async {
            let uploadProgress: Float = Float(totalBytesSent) / Float(totalBytesExpectedToSend)
           self.updateDelegateWith(progress: uploadProgress)
        }
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
