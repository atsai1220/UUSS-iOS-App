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
}

class NetworkManager: NSObject, URLSessionDelegate, URLSessionTaskDelegate, URLSessionDataDelegate {
    
    var delegate: NetWorkManagerDelegate?

    func uploadResource(item: LocalEntry) {
        switch item.fileType {
        case FileType.PHOTO.rawValue:
            let image = getImageFromDocumentDirectory(imageName: item.localFileName!)
            let imageData = UIImageJPEGRepresentation(image!, 0.75)
            
            
            if (imageData == nil) { return }
            
            let urlString = UserDefaults.standard.string(forKey: "selectedURL")! + "/api/?"
            let privateKey = UserDefaults.standard.string(forKey: "userPassword")!
            let queryString = "user=" + UserDefaults.standard.string(forKey: "userName")! + "&function=http_upload"
            let signature = "&sign=" + (privateKey + queryString).sha256()!
            let completeURL = urlString + queryString + signature
        
            guard let url = URL(string: completeURL) else { return }
            let boundary = generateBoundaryString()
            let fullFormData = photoDataToFormData(data: imageData! as NSData, boundary: boundary, fileName: item.localFileName!)
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("Keep-Alive", forHTTPHeaderField: "Connection")
            request.setValue("multipart/form-data; boundary=" + boundary, forHTTPHeaderField: "Content-Type")
            
            request.setValue(String(fullFormData.length), forHTTPHeaderField: "Content-Length")
            request.httpBody = fullFormData as Data
            request.httpShouldHandleCookies = false
            
            let configuration = URLSessionConfiguration.default

            let session = URLSession(configuration: configuration, delegate: self, delegateQueue: OperationQueue.main)

            session.uploadTask(with: request, from: imageData!) { (responseData, response, responseError) in
                guard let data = responseData else { return }
                
                let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: [])
                if let jsonObject = jsonResponse as? [Any] {
                    print(jsonObject)
                }
            }.resume()
        case FileType.VIDEO.rawValue:
            print("uploading video")
        case FileType.AUDIO.rawValue:
            print("uploading audio")
        case FileType.DOCUMENT.rawValue:
            print("uploading document")
        default:
            print("NetworkManager: should never happen")
        }
    }
    func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().uuidString)"
    }
    
    func photoDataToFormData(data: NSData, boundary: String, fileName: String) -> NSData {
        let fullData = NSMutableData()
        
        let lineOne = "--" + boundary + "\r\n"
        fullData.append(lineOne.data(
            using: String.Encoding.utf8,
            allowLossyConversion: false)!)
        
        let lineTwo = "Content-Disposition: form-data; name=\"file\"; filename=\"" + fileName + "\"\r\n"
        NSLog(lineTwo)
        fullData.append(lineTwo.data(
            using: String.Encoding.utf8,
            allowLossyConversion: false)!)
        
        let lineThree = "Content-Type: image/jpg\r\n\r\n"
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
    
}
