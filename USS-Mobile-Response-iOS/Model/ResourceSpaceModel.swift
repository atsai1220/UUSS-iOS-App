//
//  ResourceSpaceModel.swift
//  USS-Mobile-Response-iOS
//
//  Created by Andrew Tsai on 6/8/18.
//  Copyright © 2018 Andrew Tsai. All rights reserved.
//

import Foundation

typealias PlistDictionary = [String: AnyObject]
protocol PlistKey: RawRepresentable {}
protocol PlistValue {}

extension Bool: PlistValue {}
extension String: PlistValue {}
extension Int: PlistValue {}
extension Date: PlistValue {}
extension Data: PlistValue {}
extension Dictionary: PlistValue {}
extension Array: PlistValue {}

struct ResourceSpace {
    let name: String
    let url: String
}

/*
 Converts data from plist to our ResourceSpace struct.
 This functionality is not part of the structure itself.
 */
extension ResourceSpace {
    init(plist: PlistDictionary) {
        name = plist.value(forKey: Keys.name)
        url = plist.value(forKey: Keys.url)
    }
    
    private enum Keys: String, PlistKey {
        case name
        case url
    }
}

extension Dictionary where Value: AnyObject {
    func value<V: PlistValue, K: PlistKey>(forKey key: K) -> V where K.RawValue == String {
        return self[key.rawValue as! Key] as! V
    }
}


