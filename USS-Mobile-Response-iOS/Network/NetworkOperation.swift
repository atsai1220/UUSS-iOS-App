//
//  NetworkOperation.swift
//  USS-Mobile-Response-iOS
//
//  Created by Andrew Tsai on 10/28/18.
//  Copyright © 2018 Andrew Tsai. All rights reserved.
//

import Foundation
import UIKit

class NetworkOperation: Operation {
    
    private var isStarted: Bool = false
    
    override var isAsynchronous: Bool {
        return true
    }
    
    var _executing : Bool = false {
        willSet {
            willChangeValue(forKey: "isExecuting")
        }
        didSet {
            didChangeValue(forKey: "isExecuting")
        }
    }
    
    override var isExecuting: Bool {
        return _executing
    }
    
    var _finished : Bool = false {
        willSet {
            willChangeValue(forKey: "isFinished")
        }
        didSet {
            didChangeValue(forKey: "isFinished")
        }
    }
    
    override var isFinished: Bool {
        return _finished
    }
    
    override func start() {
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        _executing = true
        _finished = false
        
        execute()
    }
    
    open func execute() {
        if !isCancelled {
            execute()
        } else {
            finished(error: nil)
        }
    }
    
    func finished(error: String?) {
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
        _finished = true
        _executing = false
    }
    
    override func cancel() {
        super.cancel()
        
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
        _executing = false
        _finished = true
    }
}
