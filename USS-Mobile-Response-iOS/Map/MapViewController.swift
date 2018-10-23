//
//  NewMapFormViewController.swift
//  USS-Mobile-Response-iOS
//
//  Created by Charlie Barber on 8/11/18.
//  Copyright © 2018 Andrew Tsai. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import CoreData
import CoreGraphics

protocol AddMapDelegate: class
{
    func addMapToTable(map: MKMapView, withName name: String)
}

enum Segment: Int
{
    case INFO = 0
    case LOCATION = 1
}

class MapViewController: UIViewController, CLLocationManagerDelegate, UISearchBarDelegate, MKMapViewDelegate, CloseSettingsDelegate, SelectorDelegate, CloseSaveAnnotationDelegate, SaveDelegate
{
    var locationManager: CLLocationManager?
    var searchBar: UISearchBar?
    var mapView: MKMapView?
    var keyboardToolbar: UIToolbar?
    var doneButton: UIBarButtonItem?
    var geoCoder: CLGeocoder?
    let regionRadius: CLLocationDistance = 500
    let delta: CLLocationDegrees = 0.02
    var snapshotOptions: MKMapSnapshotOptions?
    var snapShotter: MKMapSnapshotter?
    var captureMap: UIButton?
    var mapCamera: MKMapCamera?
    var locLatandLong: CLLocationCoordinate2D?
    weak var addMapDelegate: AddMapDelegate?
    var searchId: String = "search"
    var searchAnnotation: MapAnnotation?
    var segmentedControl: UISegmentedControl?
    var currentLocation: CLLocation?
    var compass: MKCompassButton?
    var transitionDelegate: PresentationManager = PresentationManager()
    var mapSettingsViewController: MapSettingsViewController?
    var saveAnnotationViewController: SaveAnnotationViewController?
    var placemark: CLPlacemark?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.lightGray
        
        mapView = MKMapView()
        mapView!.delegate = self
        mapView!.translatesAutoresizingMaskIntoConstraints = false
        mapView!.showsUserLocation = true
        mapView!.showsCompass = false
        mapView!.showsScale = true
        view.addSubview(mapView!)
        
        searchBar = UISearchBar()
        searchBar!.translatesAutoresizingMaskIntoConstraints = false
        searchBar!.placeholder = "Search for a place or address"
        searchBar!.barTintColor = .white
//        searchBar!.layer.shadowOpacity = 0.5
//        searchBar!.layer.shadowColor = UIColor.black.cgColor
//        searchBar!.layer.shadowOffset = CGSize(width: 0.0, height: -10.0)
//        searchBar!.layer.shadowRadius = 3.0
        let searchField: UITextField = searchBar!.value(forKey: "searchField") as! UITextField
        searchField.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
        searchBar!.delegate = self
        
        view.addSubview(searchBar!)
        
        compass = MKCompassButton(mapView: mapView!)
        compass!.translatesAutoresizingMaskIntoConstraints = false
        compass!.compassVisibility = .visible

        view.addSubview(compass!)

        let info: UIImage = UIImage(named: "info")!
        let arrow: UIImage = UIImage(named: "arrow")!
        let segmentImages: [UIImage] = [info, arrow]
        segmentedControl = UISegmentedControl(items: segmentImages)
        segmentedControl!.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl!.backgroundColor = UIColor(red: 245, green: 245, blue: 245, alpha: 0.9)
        segmentedControl!.layer.cornerRadius = 5
        segmentedControl!.isMomentary = true
        segmentedControl?.addTarget(self, action: #selector(handleSelection), for: .valueChanged)
        view.addSubview(segmentedControl!)
        
        
        let mapTableViewController: MapTableViewController = MapTableViewController()
        mapTableViewController.view.translatesAutoresizingMaskIntoConstraints = false
        self.addChildViewController(mapTableViewController)
        view.addSubview(mapTableViewController.view)
        
        NSLayoutConstraint.activate([
            mapView!.heightAnchor.constraint(equalTo: view.heightAnchor),
            mapView!.widthAnchor.constraint(equalTo: view.widthAnchor),
            segmentedControl!.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15.0),
            segmentedControl!.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10.0),
            segmentedControl!.heightAnchor.constraint(equalToConstant: 35.0),
            segmentedControl!.widthAnchor.constraint(equalToConstant: 100.0),
            compass!.topAnchor.constraint(equalTo: segmentedControl!.bottomAnchor, constant: 10.0),
            compass!.trailingAnchor.constraint(equalTo: segmentedControl!.trailingAnchor),
            mapTableViewController.view.bottomAnchor.constraint(equalTo: view!.bottomAnchor, constant: 1.0),
//            mapTableViewController.view.heightAnchor.constraint(equalToConstant: 100.0),
//            mapTableViewController.view.heightAnchor.constraint(equalTo: view!.heightAnchor, multiplier: 0.32),
            mapTableViewController.view.heightAnchor.constraint(equalTo: view!.heightAnchor, multiplier: 1.0),
            mapTableViewController.view.widthAnchor.constraint(equalTo: mapView!.widthAnchor, constant: 1.0),
            searchBar!.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1.0),
            searchBar!.bottomAnchor.constraint(equalTo: mapTableViewController.view.topAnchor)
//            searchBar!.centerYAnchor.constraint(equalTo: view.centerYAnchor),
//            searchBar!.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            ])
        
        
//        captureMap = UIButton(type: .system)
//        captureMap!.layer.cornerRadius = 15
//        captureMap!.layer.borderWidth = 2
//        captureMap!.backgroundColor = UIColor.white
//        captureMap!.layer.shadowOpacity = 0.5
//        captureMap!.layer.shadowColor = UIColor.black.cgColor
//        captureMap!.layer.shadowOffset = CGSize(width: 0.0, height:5.0)
//        captureMap!.layer.shadowRadius = 3.0
//        captureMap!.setTitle("Add Map", for: .normal)
//        captureMap!.translatesAutoresizingMaskIntoConstraints = false
//        captureMap!.addTarget(self, action: #selector(saveMap), for: .touchUpInside)
//        self.view.addSubview(captureMap!)
//
//        let capViewAndSbar: [String: UIView] = ["cMap":captureMap!, "sBar":searchBar!]
//        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "[cMap(>=100,<=150)]", options: [], metrics: nil, views: capViewAndSbar))
//        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[sBar]-20-[cMap]", options: [], metrics: nil, views: capViewAndSbar))
//
//        NSLayoutConstraint.activate([
//            captureMap!.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
//            captureMap!.topAnchor.constraintGreaterThanOrEqualToSystemSpacingBelow(searchBar!.bottomAnchor, multiplier: 1.0)])
        
        locationManager = CLLocationManager()
        locationManager!.delegate = self
        requestLocationPermision()
        checkForLocationServices()
    }
    
    override func viewDidLayoutSubviews()
    {
        searchBar!.roundedSearchBar()

    }
    
    func closeView(_: Bool)
    {
        saveAnnotationViewController?.dismiss(animated: true, completion: nil)
        //TODO: need to do some saving of the annotaion and add the stuff to the tableview
    }
    
    func closeSettings(_: Bool)
    {
        mapSettingsViewController?.dismiss(animated: true, completion: nil)
    }
    
    @objc func handleSelection()
    {
        switch segmentedControl!.selectedSegmentIndex
        {
            case Segment.INFO.rawValue:
                mapSettingsViewController = MapSettingsViewController()
                mapSettingsViewController!.closeSettingsDelegate = self
                mapSettingsViewController!.selectorDelegate = self
                transitionDelegate.direction = .bottom
                transitionDelegate.type = ""
                mapSettingsViewController!.transitioningDelegate = transitionDelegate
                mapSettingsViewController!.modalPresentationStyle = .custom
                present(mapSettingsViewController!, animated: true, completion: nil)
            
            case Segment.LOCATION.rawValue:
                var region: MKCoordinateRegion = mapView!.region
                region.center = CLLocationCoordinate2D(latitude: currentLocation!.coordinate.latitude, longitude: currentLocation!.coordinate.longitude)
                region.span = MKCoordinateSpan(latitudeDelta: delta, longitudeDelta: delta)
                MKMapView.animate(withDuration: 1.0, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 10, options: .curveEaseInOut, animations: {
                    self.mapView!.setRegion(region, animated: true)
                }, completion: nil)
            default:
                break
        }
    }
    
    
    func itemSelected(with index: Int)
    {
        if(index == 0)
        {
            mapView!.mapType = .standard
        }
        else if(index == 1)
        {
            mapView!.mapType = .satellite
        }
    }
    
    func saveAnnotations()
    {
        let annotationArray: [MKAnnotation] = self.mapView!.annotations
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        let entity: NSEntityDescription = NSEntityDescription.entity(forEntityName: "Annotation", in: managedContext)!
        let mapObject: NSManagedObject = NSManagedObject(entity: entity, insertInto: managedContext)

        for annotation in annotationArray
        {
            mapObject.setValue(annotation.coordinate.latitude, forKey: "annotationLatitude")
            mapObject.setValue(annotation.coordinate.longitude, forKey: "annotationLongitude")
            mapObject.setValue(annotation.title!, forKey: "annotationTitle")
            mapObject.setValue(searchId, forKey: "annotationId")
        }

        do
        {
            try managedContext.save()
        }
        catch let error as NSError
        {
            print("There was an error saving. \(error)")
        }
    }
    
    @objc func saveMap()
    {
        self.mapView!.register(AnnotationView.self, forAnnotationViewWithReuseIdentifier: self.searchId)
        self.mapView!.addAnnotation(self.searchAnnotation!)
        self.mapView!.delegate = self
        saveAnnotations()
        let mapNameAlert: UIAlertController = UIAlertController(title: "Map Name", message: "", preferredStyle: .alert)
        mapNameAlert.addTextField(configurationHandler: {( textfeild: UITextField )-> Void in
            textfeild.placeholder = "Please enter a name for the map"
            
            mapNameAlert.addAction(UIAlertAction(title: "Save", style: .default, handler: { _ in
                let mapName: String = textfeild.text!
                self.addMapDelegate?.addMapToTable(map: self.mapView!, withName: mapName)
            }))
        })
        
        self.present(mapNameAlert, animated: true, completion: nil)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar)
    {
        searchBar.showsCancelButton = true
    }
   
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar)
    {
        searchBar.endEditing(true)
    }
    
    func saveAnnotationToFavorites(_: Bool)
    {
        //TODO: Save to favorites in the table
    }
    
//    func showSaveAnnotationView()
//    {
//        saveAnnotationViewController = SaveAnnotationViewController()
//        saveAnnotationViewController!.titleLabel.text = placemark!.name
//        saveAnnotationViewController!.distanceLabel.text = String(format: "%.2f", placemark!.location!.distance(from: currentLocation!) / 1609.344) + " mi"
//        saveAnnotationViewController!.streetLabel.text = placemark!.thoroughfare
//        saveAnnotationViewController!.cityLabel.text = placemark!.locality! + ", " + placemark!.administrativeArea! + " " + placemark!.postalCode!
//        saveAnnotationViewController!.countryLabel.text = placemark!.country
//        saveAnnotationViewController!.saveDelegate = self
//        saveAnnotationViewController!.closeSaveAnnotationDelegate = self
//        transitionDelegate.direction = .bottom
//        transitionDelegate.type = "save"
//        saveAnnotationViewController!.transitioningDelegate = transitionDelegate
//        saveAnnotationViewController!.modalPresentationStyle = .custom
//        present(saveAnnotationViewController!, animated: true, completion: nil)
//    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        
        searchBar.endEditing(true)
        
        let searchBarString: String = searchBar.text!
        geoCoder = CLGeocoder()
//        var placeMarks: [CLPlacemark]?
//        var error: NSError?
       
        locLatandLong = CLLocationCoordinate2DMake(locationManager!.location!.coordinate.latitude, locationManager!.location!.coordinate.longitude)
        
        let locationArea: CLCircularRegion = CLCircularRegion(center: locLatandLong!, radius: regionRadius, identifier: "circle")
    
        geoCoder!.geocodeAddressString(searchBarString, in: locationArea, completionHandler: {(placeMarks, error) in
            
                if(error != nil)
                {
                    let alert = UIAlertController(title: "Error Locating", message: "Could not find your location. Please try again", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: "default"), style: .default, handler: {_ in NSLog("The \"Ok\" alert occured")}))
                    self.present(alert, animated: true, completion: nil)
                }
                else
                {
                    self.placemark = placeMarks![0]
                    
                    let coord: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: self.placemark!.location!.coordinate.latitude, longitude: self.placemark!.location!.coordinate.longitude)
                    let region = MKCoordinateRegionMakeWithDistance(coord, self.regionRadius, self.regionRadius)
                    self.mapView!.setRegion(region, animated: true)
                    
                    if (self.searchAnnotation == nil)
                    {
                        self.mapView!.register(AnnotationView.self, forAnnotationViewWithReuseIdentifier: self.searchId)
                        self.searchAnnotation = MapAnnotation(coordinate: coord, title: self.placemark!.name!, subTitle: "")
                        self.mapView!.addAnnotation(self.searchAnnotation!)
                    }
                    else
                    {
                        self.mapView!.removeAnnotation(self.searchAnnotation!)
                        self.mapView!.register(AnnotationView.self, forAnnotationViewWithReuseIdentifier: self.searchId)
                        self.searchAnnotation = MapAnnotation(coordinate: coord, title: self.placemark!.name!, subTitle: "")
                        self.mapView!.addAnnotation(self.searchAnnotation!)
                    }
                    
//                    self.showSaveAnnotationView()
                }
        })
        
//          let annotation: MapAnnotation = MapAnnotation(coordinate: coord, title: place.name!, subTitle: "")
//        geoCoder!.geocodeAddressString(searchBarString) { (placeMarks, error) in
//            let place = placeMarks![0]
//            print(place.location!.coordinate.latitude)
//            print(place.location!.coordinate.longitude)
//
//            var region: MKCoordinateRegion = self.mapView!.region
//            region.center = CLLocationCoordinate2D(latitude: place.location!.coordinate.latitude, longitude: place.location!.coordinate.longitude)
//            self.mapView!.setRegion(region, animated: true)
//            self.mapView!.showsUserLocation = true
//        }
    }
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?
    {
        let annotationView: MKAnnotationView? = mapView.dequeueReusableAnnotationView(withIdentifier: searchId)
        return annotationView
    }
    
    func requestLocationPermision()
    {

        switch CLLocationManager.authorizationStatus()
        {
            case .notDetermined:
                // Request when-in-use authorization initially
                locationManager?.requestWhenInUseAuthorization()
                break

            case .restricted, .denied:
                // Disable location features
                let alert = UIAlertController(title: "Location Services Disabled", message: "Location services must be enabled to use maps. Please check your settings", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: "default"), style: .default, handler: {_ in NSLog("The \"Ok\" alert occured")}))
                self.present(alert, animated: true, completion: nil)
                break

            case .authorizedWhenInUse, .authorizedAlways:
                // Enable location features
                CLLocationManager.locationServicesEnabled()
                break
        }
    
    }
    
    func checkForLocationServices()
    {
        if CLLocationManager.locationServicesEnabled()
        {
            startReceivingLocationChanges()
        }
        else
        {
            let alert = UIAlertController(title: "Error", message: "Location services are unavailable at this time. Please check your settings", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: "default"), style: .default, handler: {_ in NSLog("The \"Ok\" alert occured")}))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func startReceivingLocationChanges()
    {
        let authroizationStatus = CLLocationManager.authorizationStatus()
        
        if authroizationStatus != .authorizedWhenInUse
        {
            let alert = UIAlertController(title: "Error", message: "Location services must be anabled to use maps. Please check your settings", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: "default"), style: .default, handler: {_ in NSLog("The \"Ok\" alert occured")}))
            self.present(alert, animated: true, completion: nil)
            return
        }
        if !CLLocationManager.locationServicesEnabled()
        {
            let alert = UIAlertController(title: "Error", message: "Location services are unavailable at this time. Please check your settings", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: "default"), style: .default, handler: {_ in NSLog("The \"Ok\" alert occured")}))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        //Configure and start the device
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.distanceFilter = 100.0 //Meters
        locationManager?.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        currentLocation = locations.last!
        
        let now = Date()
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "HH:mm:ss"
        let timeStamp = formatter.string(from: now)
        let locationTimestamp = formatter.string(from: currentLocation!.timestamp)
        
        if(locationTimestamp == timeStamp)
        {
            var region: MKCoordinateRegion = mapView!.region
            region.center = CLLocationCoordinate2D(latitude: currentLocation!.coordinate.latitude, longitude: currentLocation!.coordinate.longitude)
            region.span = MKCoordinateSpan(latitudeDelta: delta, longitudeDelta: delta)
            mapView!.setRegion(region, animated: true)
        }
        
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print(error)
    }
}

extension UISearchBar
{
    func roundedSearchBar()
    {
        let maskPath1 = UIBezierPath(roundedRect: bounds,
                                     byRoundingCorners: [.topLeft , .topRight],
                                     cornerRadii: CGSize(width: 10, height: 10))
        let maskLayer1 = CAShapeLayer()
        maskLayer1.frame = bounds
        maskLayer1.path = maskPath1.cgPath
        layer.mask = maskLayer1
    }
}
