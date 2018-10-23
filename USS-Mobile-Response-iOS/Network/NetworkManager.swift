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
}

class NetworkManager: NSObject, URLSessionDelegate, URLSessionTaskDelegate, URLSessionDataDelegate {
    
    var delegate: NetWorkManagerDelegate?

    func uploadResource(item: LocalEntry) {
        switch item.fileType {
        case FileType.PHOTO.rawValue:
            let image = getImageFromDocumentDirectory(imageName: item.localFileName!)
            let imageData = UIImageJPEGRepresentation(image!, 0.9)
            if (imageData == nil) { return }
            let boundary = generateBoundaryString()
            let fullFormData = resourceDataToFormData(data: imageData! as NSData, boundary: boundary, fileName: item.localFileName!, type: item.fileType!)
            sendPostRequestWith(body: fullFormData, boundary: boundary)
        
        case FileType.VIDEO.rawValue:
            var movieData: Data?
            do {
                let path = URL(fileURLWithPath: item.videoURL!)
                movieData = try Data(contentsOf: path)
                let boundary = generateBoundaryString()
                let fullFormData = resourceDataToFormData(data: movieData! as NSData, boundary: boundary, fileName: item.localFileName!, type: item.fileType!)
                sendPostRequestWith(body: fullFormData, boundary: boundary)
            } catch {
                dismissProgressBar()
                displayErrorMessage(title: "Error", message: "Video upload error.")
            }
 
        case FileType.AUDIO.rawValue:
            print("uploading audio")
        case FileType.DOCUMENT.rawValue:
            print("uploading document")
        default:
            print("NetworkManager: should never happen")
        }
    }
    
    func sendPostRequestWith(body fullFormData: Data, boundary: String) {
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
            print(dataString ?? "Undecodable result")
            
            DispatchQueue.main.async {
                print("done")
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
    
}
