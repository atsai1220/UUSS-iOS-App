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
        loadImageForData(type: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadImageForData(type: String?)
    {
        switch reuseIdentifier
        {
    
        case "photo":
            annotationImage = UIImage(named: "camera")
            self.glyphImage = annotationImage
            self.markerTintColor = .red
        case "video":
            annotationImage = UIImage(named: "video")
            self.glyphImage = annotationImage
            self.markerTintColor = .blue
        case "audio":
            annotationImage = UIImage(named: "audio")
            self.glyphImage = annotationImage
            self.markerTintColor = .green
        case "document":
            annotationImage = UIImage(named: "document")
            self.glyphImage = annotationImage
            self.markerTintColor = .orange
        default:
            break
        }
    }
}
