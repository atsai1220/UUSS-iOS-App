//
//  MapView.swift
//  USS-Mobile-Response-iOS
//
//  Created by Charlie Barber on 8/8/18.
//  Copyright © 2018 Andrew Tsai. All rights reserved.
//

import MapKit
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate
{
    var currentLocation: MKCoordinateRegion?
    var mapView: MKMapView?
    private var latitude: Double?
    private var longitude: Double?
    private var annotations: [NSObject] = []
    
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
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?
    {
        return mapView.view(for: annotation)
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let managedContext: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "Map", in: managedContext)
        
        do
        {
            annotations = try managedContext.fetch(NSFetchRequest.init(entityName: (entity?.name)!)) as! [NSObject]
            
        }
        catch
        {
            print("Fetch failed")
        }
        
    }
}
