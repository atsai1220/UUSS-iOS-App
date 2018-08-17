//
//  MapView.swift
//  USS-Mobile-Response-iOS
//
//  Created by Charlie Barber on 8/8/18.
//  Copyright © 2018 Andrew Tsai. All rights reserved.
//

import MapKit

class MapView: MKMapView
{
    var currentLocation: MKCoordinateRegion?
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        currentLocation = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 39.419220, longitude: -111.950684), span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10))
        self.setRegion(currentLocation!, animated: true)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
