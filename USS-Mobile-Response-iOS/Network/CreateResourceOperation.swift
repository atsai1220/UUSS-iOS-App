//
//  CreateResourceOperation.swift
//  USS-Mobile-Response-iOS
//
//  Created by Andrew Tsai on 11/11/18.
//  Copyright © 2018 Andrew Tsai. All rights reserved.
//

import Foundation

class CreateResourceOperation: NetworkOperation {
    
    let resourceType: Int
    let archivalState: Int
    
    var networkManager: NetworkManager?
    
    var onDidUpload: ((_ uploadResult: Data) -> Void)!
    
    init(resourceType: Int, archivalState: Int) {
        self.resourceType = resourceType
        self.archivalState = archivalState
    }
    
    override func execute() {
        createResource()
    }
    
    private func createResource() {
        networkManager?.createResource(resourceType: self.resourceType, archivalState: self.archivalState) {
            (httpResult) in
            self.onDidUpload(httpResult)
            self.finished(error: "create resource")
        }
    }
}
