//
//  MapAnnotation.swift
//  USS-Mobile-Response-iOS
//
//  Created by Charlie Barber on 8/25/18.
//  Copyright © 2018 Andrew Tsai. All rights reserved.
//

import MapKit

class MapAnnotation: NSObject, MKAnnotation
{
    let coordinate: CLLocationCoordinate2D
    var title: String?
    var subTitle: String?
    var altFiles: [AltFile]?
    
    init(coordinate: CLLocationCoordinate2D, title: String, subTitle: String, altFileArray: [AltFile])
    {
        self.coordinate = coordinate
        self.title = title
        self.subTitle = subTitle
        self.altFiles = altFileArray
    }
}

