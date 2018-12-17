//
//  AddResourceToCollectionOperation.swift
//  USS-Mobile-Response-iOS
//
//  Created by Andrew Tsai on 11/11/18.
//  Copyright © 2018 Andrew Tsai. All rights reserved.
//

import Foundation

class AddResourceToCollectionOperation: NetworkOperation {
    let resourceId: Int
    let collectionId: Int
    var networkManager: NetworkManager?
    
    var onDidUpload: ((_ uploadResult: Data) -> Void)!
    
    init(resourceId: Int, collectionId: Int) {
        self.resourceId = resourceId
        self.collectionId = collectionId
    }
    
    override func execute() {
        addResourceToCollection()
    }
    
    private func addResourceToCollection() {
        networkManager?.addResourceToCollection(resourceId: self.resourceId, collectionId: self.collectionId) {
            (httpResult) in
            self.onDidUpload(httpResult)
            self.finished(error: "add resouce to collection")
        }
    }
}
