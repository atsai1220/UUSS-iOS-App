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
