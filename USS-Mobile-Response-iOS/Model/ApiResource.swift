//
//  ApiResource.swift
//  USS-Mobile-Response-iOS
//
//  Created by Andrew Tsai on 7/26/18.
//  Copyright © 2018 Andrew Tsai. All rights reserved.
//

import Foundation

typealias Serialization = [String: Any]

struct ApiWrapper {
    let items: [Serialization]
}
struct CreateResourceResponse {
    let resourceId: String
}

protocol SerializationKey {
    var stringValue: String { get }
}

extension RawRepresentable where RawValue == String {
    var stringValue: String {
        return rawValue
    }
}

protocol SerializationValue {}

extension Bool: SerializationValue {}
extension String: SerializationValue {}
extension Int: SerializationValue {}
extension Dictionary: SerializationValue {}
extension Array: SerializationValue {}

extension Dictionary where Key == String, Value: Any {
    func value<V: SerializationValue>(forKey key: SerializationKey) -> V? {
        return self[key.stringValue] as? V
    }
}

