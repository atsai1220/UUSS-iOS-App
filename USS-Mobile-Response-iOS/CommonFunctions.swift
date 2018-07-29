//
//  CommonFunctions.swift
//  USS-Mobile-Response-iOS
//
//  Created by Andrew Tsai on 7/27/18.
//  Copyright © 2018 Andrew Tsai. All rights reserved.
//

import Foundation

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

struct Hazard: Codable {
    let ref: String
    let name: String
    let user: String
    let created: String
    let publicKey: String?
    let theme: String
    let theme2: String
    let theme3: String
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
