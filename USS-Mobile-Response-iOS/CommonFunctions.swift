//
//  CommonFunctions.swift
//  USS-Mobile-Response-iOS
//
//  Created by Andrew Tsai on 7/27/18.
//  Copyright © 2018 Andrew Tsai. All rights reserved.
//

import UIKit

extension String {
    func sha256() -> String? {
        guard let messageData = self.data(using:String.Encoding.utf8) else { return nil }
        var digestData = Data(count: Int(CC_SHA256_DIGEST_LENGTH))
        
        _ = digestData.withUnsafeMutableBytes {digestBytes in
            messageData.withUnsafeBytes {messageBytes in
                CC_SHA256(messageBytes, CC_LONG(messageData.count), digestBytes)
            }
        }
        let shaHex = digestData.map { String(format: "%02hhx", $0) }.joined()
        return shaHex
    }
}

// Extension for String class to easily truncate string length
// TODO: Find better implementation for tablet screen size.
extension String {
    func truncated(length: Int) -> String {
        if self.count > length {
            return String(self.prefix(length)) + "..."
        }
        else {
            return self
        }
    }
}

// Easily adds constraints
extension UIView {
    func addConstraintsWithFormat(format: String, views: UIView...) {
        var viewsDictionary = [String: UIView]()
        for (index, view) in views.enumerated() {
            let key = "v\(index)"
            view.translatesAutoresizingMaskIntoConstraints = false
            viewsDictionary[key] = view
        }
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutFormatOptions(), metrics: nil, views: viewsDictionary))
    }
}

struct Hazard: Codable {
    let ref: String
    let name: String
    let user: String
    let created: String
    let `public`: String?
    let theme: String
    let theme2: String
    let theme3: String
    let theme4: String
    let theme5: String
    let allow_changes: String
    let cant_delete: String
    let keywords: String
    let savedsearch: String
    let home_page_publish: String
    let home_page_text: String
    let home_page_image: String
    let session_id: String
    let propose_changes: String
    let username: String
    let fullname: String
}

extension UIPageViewController {
    func goToNextPage() {
        guard let currentViewController = self.viewControllers?.first else { return }
        guard let nextViewController = dataSource?.pageViewController( self, viewControllerAfter: currentViewController ) else { return }
        setViewControllers([nextViewController], direction: .forward, animated: true, completion: nil)
    }

    func goToPreviousPage() {
        guard let currentViewController = self.viewControllers?.first else { return }
        guard let previousViewController = dataSource?.pageViewController( self, viewControllerBefore: currentViewController ) else { return }
        setViewControllers([previousViewController], direction: .reverse, animated: true, completion: nil)
    }
}

func getDocumentsURL() -> URL {
    if let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
        return url
    }
    else {
        fatalError("Could not retrieve documents directory.")
    }
}

func saveLocalEntriesToDisk(entries: [LocalEntry]) {
    // create url for documents directory
    let url = getDocumentsURL().appendingPathComponent("entries.json")
    let encoder = JSONEncoder()
    
    do {
        let data = try encoder.encode(entries)
//        let test = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
        try data.write(to: url, options: [])
    } catch {
        fatalError(error.localizedDescription)
    }
}

func getLocalEntriesFromDisk() -> [LocalEntry] {
    if FileManager.default.fileExists(atPath: getDocumentsURL().appendingPathComponent("entries.json").path) {
        let url = getDocumentsURL().appendingPathComponent("entries.json")
        let decoder = JSONDecoder()
        do {
            let data = try Data(contentsOf: url, options: [])
            let entries = try decoder.decode([LocalEntry].self, from: data)
            return entries
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    else {
        saveLocalEntriesToDisk(entries: [])
        return getLocalEntriesFromDisk()
    }
}

func saveTrashEntriesToDisk(entries: [LocalEntry]) {
    // create url for documents directory
    let url = getDocumentsURL().appendingPathComponent("trash.json")
    let encoder = JSONEncoder()
    
    do {
        let data = try encoder.encode(entries)
//        let object = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
        try data.write(to: url, options: [])
    } catch {
        fatalError(error.localizedDescription)
    }
}

func getTrashEntriesFromDisk() -> [LocalEntry] {
    if FileManager.default.fileExists(atPath: getDocumentsURL().appendingPathComponent("trash.json").path) {
        let url = getDocumentsURL().appendingPathComponent("trash.json")
        let decoder = JSONDecoder()
        do {
            let data = try Data(contentsOf: url, options: [])
            let entries = try decoder.decode([LocalEntry].self, from: data)
            return entries
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    else {
        saveTrashEntriesToDisk(entries: [])
        return getTrashEntriesFromDisk()
    }
}

func saveCompleteHazardsToDisk(hazards: [Hazard]) {
    // create url for documents directory
    let url = getDocumentsURL().appendingPathComponent("allHazards.json")
    let encoder = JSONEncoder()
    
    do {
        let data = try encoder.encode(hazards)
        //        let object = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
        try data.write(to: url, options: [])
    } catch {
        fatalError(error.localizedDescription)
    }
}

func getCompleteHazardsFromDisk() -> [Hazard] {
    if FileManager.default.fileExists(atPath: getDocumentsURL().appendingPathComponent("allHazards.json").path) {
        let url = getDocumentsURL().appendingPathComponent("allHazards.json")
        let decoder = JSONDecoder()
        do {
            let data = try Data(contentsOf: url, options: [])
            let entries = try decoder.decode([Hazard].self, from: data)
            return entries
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    else {
        saveCompleteHazardsToDisk(hazards: [])
        return getCompleteHazardsFromDisk()
    }
}

func localHazardsFromDiskExists() -> Bool {
    if FileManager.default.fileExists(atPath: getDocumentsURL().appendingPathComponent("allHazards.json").path) {
        return true
    }
    else {
        return false
    }
}

func saveImageAtDocumentDirectory(url: URL) -> String {

    let userName = UserDefaults.standard.string(forKey: "userName")
    let imageName = userName! + getTimeStampString() + ".jpeg"
    let path = getDocumentsURL().appendingPathComponent(imageName)
    let image = UIImage(contentsOfFile: url.path)
    let imageData = UIImageJPEGRepresentation(image!, 0.5)
    FileManager.default.createFile(atPath: path.path, contents: imageData, attributes: [:])
    return imageName
}

func saveExistingImageAtDocumentDirectory(image: UIImage) -> String {
    let userName = UserDefaults.standard.string(forKey: "userName")
    let imageName = userName! + getTimeStampString() + ".jpeg"
    let path = getDocumentsURL().appendingPathComponent(imageName)
    let imageData = UIImageJPEGRepresentation(image, 0.5)
    FileManager.default.createFile(atPath: path.path, contents: imageData, attributes: [:])
    return imageName
}

func getTimeStampString() -> String {
    let date = Date()
    let calendar = Calendar.current
    let components = calendar.dateComponents([.year,.month,.day,.hour,.minute,.second], from: date)
    let year = components.year
    let month = components.month
    let day = components.day
    let hour = components.hour
    let minute = components.minute
    let second = components.second
    let today_string = String(year!) + String(month!) + String(day!) + String(month!) + String(day!) + String(hour!) + String(minute!) + String(second!)
    return today_string
}

func getImageFromDocumentDirectory(imageName: String) -> UIImage? {
    /*
     let pathComponent = "pack\(self.packID)-\(selectRow + 1).mp4"
     let directoryURL: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
     let folderPath: URL = directoryURL.appendingPathComponent("Downloads", isDirectory: true)
     let fileURL: URL = folderPath.appendingPathComponent(pathComponent)
     */
    let imagePath = getDocumentsURL().appendingPathComponent(imageName).path
    if FileManager.default.fileExists(atPath: imagePath) {
        return UIImage(contentsOfFile: imagePath)
    }
    else {
        return nil
    }
}
