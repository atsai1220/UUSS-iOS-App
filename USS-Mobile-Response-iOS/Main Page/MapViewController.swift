//
//  MapView.swift
//  USS-Mobile-Response-iOS
//
//  Created by Charlie Barber on 8/8/18.
//  Copyright © 2018 Andrew Tsai. All rights reserved.
//

import MapKit

class MapViewController: UIViewController
{
    var currentLocation: MKCoordinateRegion?
    var mapView: MKMapView?
    private var latitude: Double?
    private var longitude: Double?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        mapView = MKMapView()
        mapView!.translatesAutoresizingMaskIntoConstraints = false
        currentLocation = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!), span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02) )
        mapView!.setRegion(currentLocation!, animated: true)
        
        self.view.addSubview(mapView!)
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[map]|", options: [], metrics: nil, views: ["map":mapView! as MKMapView]))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[map]|", options: [], metrics: nil, views: ["map":mapView! as MKMapView]))
    }
    
    var mapLatitude: Double
    {
        get
        {
            return latitude!
        }
        set
        {
            latitude = newValue
        }
    }
    var mapLongitude: Double
    {
        get
        {
            return longitude!
        }
        set
        {
            longitude = newValue
        }
    }
}
