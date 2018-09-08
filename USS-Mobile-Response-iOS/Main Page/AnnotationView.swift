//
//  AnnotationView.swift
//  USS-Mobile-Response-iOS
//
//  Created by Charlie Barber on 9/7/18.
//  Copyright © 2018 Andrew Tsai. All rights reserved.
//

import MapKit

class AnnotationView: MKMarkerAnnotationView
{
    override init(annotation: MKAnnotation?, reuseIdentifier: String?)
    {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
