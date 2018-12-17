//
//  LocalEntry.swift
//  USS-Mobile-Response-iOS
//
//  Created by Andrew Tsai on 8/15/18.
//  Copyright © 2018 Andrew Tsai. All rights reserved.
//

import Foundation

struct LocalEntry: Codable {
    var name: String?
    var resourceRef: String?
    var collectionRef: String?
    var description: String?
    var notes: String?
    var resourceType: String?
    var localFileName: String?
    var fileType: String?
    var metadata: metadataJSON?
    var videoURL: String?
    var submissionStatus: String?
    var pdfDocURL: String?
    var audioURL: String?
    var altFiles: [AltFile]?
    var dataLat: Double?
    var dataLong: Double?
    var hazardName: String?
    var subcategoryName: String?
    var collectionName: String?
}

// field ID to value string pairs.
struct metadataJSON: Codable {
    var foo: String?
}

struct AltFile: Codable {
    var name: String
    var url: String
    var type: String
}
