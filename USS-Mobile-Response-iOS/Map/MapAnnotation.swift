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
    
    init(coordinate: CLLocationCoordinate2D, title: String, subTitle: String)
    {
        self.coordinate = coordinate
        self.title = title
        self.subTitle = subTitle
    }
}

