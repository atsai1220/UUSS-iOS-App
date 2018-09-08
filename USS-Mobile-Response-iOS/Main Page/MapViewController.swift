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
    private var annotations: [MapAnnotation] = []
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        mapView = MKMapView()
        mapView!.delegate = self
        mapView!.register(AnnotationView.self, forAnnotationViewWithReuseIdentifier: "search")
        mapView!.translatesAutoresizingMaskIntoConstraints = false
        currentLocation = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!), span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02) )
        mapView!.setRegion(currentLocation!, animated: true)
        
        self.view.addSubview(mapView!)
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[map]|", options: [], metrics: nil, views: ["map":mapView! as MKMapView]))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[map]|", options: [], metrics: nil, views: ["map":mapView! as MKMapView]))
        
        loadAnnotations()
        mapView!.addAnnotations(annotations)
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
        let annotation: MKAnnotationView = self.mapView!.dequeueReusableAnnotationView(withIdentifier: "search", for: annotation)
        
        return annotation
    }
    
    func loadAnnotations()
    {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let managedContext: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "Annotation", in: managedContext)
        
        do
        {
            let annotationsArray = try managedContext.fetch(NSFetchRequest.init(entityName: (entity?.name)!)) as! [NSObject]
            for annotation in annotationsArray
            {
                
                let lat: Double  = annotation.value(forKey: "annotationLatitude") as! Double
                let long: Double = annotation.value(forKey: "annotationLongitude") as! Double
                let title: String = annotation.value(forKey: "annotationTitle") as! String
                
                let mapAnnotation: MapAnnotation = MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: lat, longitude: long), title: title, subTitle: "")
                
                self.annotations.append(mapAnnotation)
            }
            
        }
        catch
        {
            print("Fetch failed")
        }
        
    }
}
