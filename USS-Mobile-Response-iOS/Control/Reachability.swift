//
//  Reachability.swift
//  USS-Mobile-Response-iOS
//
//  Created by Andrew Tsai on 8/23/18.
//  Copyright © 2018 Andrew Tsai. All rights reserved.
//

import Foundation
import SystemConfiguration

class Reachability {
    // object to read network information
    let reachability = SCNetworkReachabilityCreateWithName(nil, "www.google.com")
    var flags = SCNetworkReachabilityFlags()
    
    init() {
        // setting flags the correct data set
        SCNetworkReachabilityGetFlags(reachability!, &flags)
    }
    
    func hasInternet() -> Bool {
        if !isNetworkReachable(with: flags) {
            return false
        }
        if flags.contains(.isWWAN) {
            return true
        }
        return true
    }
    
    func isNetworkReachable(with flags: SCNetworkReachabilityFlags) -> Bool {
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        let canConnectAutomatically = flags.contains(.connectionOnDemand) || flags.contains(.connectionOnTraffic)
        let canConnectWithoutUserInteraction = canConnectAutomatically && !flags.contains(.interventionRequired)
        return isReachable && (!needsConnection || canConnectWithoutUserInteraction)
    }
}
