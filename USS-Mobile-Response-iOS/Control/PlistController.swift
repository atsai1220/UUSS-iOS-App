//
//  PlistController.swift
//  USS-Mobile-Response-iOS
//
//  Created by Andrew Tsai on 6/8/18.
//  Copyright © 2018 Andrew Tsai. All rights reserved.
//

import Foundation

class PlistController {
    var resources: [ResourceSpace]
    let fileURL: URL
    
    init() {
        let documentsURL = getDocumentsURL().appendingPathComponent("servers.plist")
        
        if FileManager.default.fileExists(atPath: documentsURL.path) {
            let resourcePlist = NSArray(contentsOf: documentsURL) as! [PlistDictionary]
            fileURL = documentsURL
            resources = resourcePlist.map(ResourceSpace.init)
        }
        else {
            let bundleURL = Bundle.main.url(forResource: "ServerList", withExtension: "plist")!
            let resourcePlist = NSArray(contentsOf: bundleURL) as! [PlistDictionary]
            let plistData = try! PropertyListSerialization.data(fromPropertyList: resourcePlist, format: .xml, options: 0)
            try! plistData.write(to: documentsURL)
            fileURL = documentsURL
            resources = resourcePlist.map(ResourceSpace.init)
        }
    }
    
    func loadPlist() {
        let resourcePlist = NSArray(contentsOf: fileURL) as! [PlistDictionary]
        resources = resourcePlist.map(ResourceSpace.init)
    }
    
    func updatePlist(with newDictionaryEntry: PlistDictionary) {
        var resourcePlist = NSArray(contentsOf: fileURL) as! [PlistDictionary]
        resourcePlist.insert(newDictionaryEntry, at: resourcePlist.count)
        write(with: resourcePlist)
    }
    
    func remove(at index: Int) {
        // TODO: Test for appropriate index
        var resourcePlist = NSArray(contentsOf: fileURL) as! [PlistDictionary]
        resourcePlist.remove(at: index)
        write(with: resourcePlist)
    }
    
    private func write(with resourcePlist: [PlistDictionary]) {
        let plistData = try! PropertyListSerialization.data(fromPropertyList: resourcePlist, format: .xml, options: 0)
        try! plistData.write(to: fileURL)
    }
}
