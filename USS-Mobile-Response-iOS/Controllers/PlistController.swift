//
//  PlistController.swift
//  USS-Mobile-Response-iOS
//
//  Created by Andrew Tsai on 6/8/18.
//  Copyright © 2018 Andrew Tsai. All rights reserved.
//

import Foundation

class PlistController {
    let resources: [ResourceSpace]
    
    init() {
        let fileURL = Bundle.main.url(forResource: "ServerList", withExtension: "plist")!
        let resourcePlists = NSArray(contentsOf: fileURL) as! [PlistDictionary]
        resources = resourcePlists.map(ResourceSpace.init)
    }
}
