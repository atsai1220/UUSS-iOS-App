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
    var annotationImage: UIImage?
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?)
    {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        loadImageForView()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadImageForView()
    {
        switch reuseIdentifier
        {
            case "search":
                glyphImage = UIImage(named: "pin")
                markerTintColor = .red
            case "photo":
                glyphImage = UIImage(named: "camera")
                markerTintColor = .blue
            default:
                break
        }
        
    }
}
