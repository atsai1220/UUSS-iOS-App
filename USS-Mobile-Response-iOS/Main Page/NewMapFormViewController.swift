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

protocol AddMapDelegate: class
{
    func addMapToTable(map: MKMapView, withName name: String)
}

class NewMapFormViewController: UIViewController, CLLocationManagerDelegate, UISearchBarDelegate, MKMapViewDelegate
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
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        searchBar = UISearchBar()
        searchBar!.placeholder = "Search"
        searchBar!.showsCancelButton = true
        searchBar!.translatesAutoresizingMaskIntoConstraints = false
        searchBar!.delegate = self
        self.view.addSubview(searchBar!)
        
        self.view.backgroundColor = UIColor.lightGray
        
        let views: [String: UIView] = ["sBar":searchBar!]
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[sBar]|", options: [], metrics: nil, views: views))
        
        let guide = view.safeAreaLayoutGuide
            NSLayoutConstraint.activate([
                (searchBar!.topAnchor.constraintEqualToSystemSpacingBelow(guide.topAnchor, multiplier: 1.0)),
                (searchBar!.bottomAnchor.constraintLessThanOrEqualToSystemSpacingBelow(guide.bottomAnchor, multiplier: 0.5))])
        
        
        mapView = MKMapView()
        mapView!.translatesAutoresizingMaskIntoConstraints = false
//        let currentLocation: MKCoordinateRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
//        mapView!.setRegion(currentLocation, animated: true)

        self.view.addSubview(mapView!)
        
        let mView: [String: UIView] = ["mapV":mapView!]
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[mapV]|", options: [], metrics: nil, views: mView))
        
        NSLayoutConstraint.activate([
            mapView!.topAnchor.constraintEqualToSystemSpacingBelow(searchBar!.bottomAnchor, multiplier: 1.0),
            mapView!.bottomAnchor.constraintEqualToSystemSpacingBelow(guide.bottomAnchor, multiplier: 1.0)])
        
        
        captureMap = UIButton(type: .system)
        captureMap!.layer.cornerRadius = 15
        captureMap!.layer.borderWidth = 2
        captureMap!.backgroundColor = UIColor.white
        captureMap!.layer.shadowOpacity = 1.0
        captureMap!.layer.shadowColor = UIColor.black.cgColor
        captureMap!.layer.shadowOffset = CGSize(width: 0.0, height:5.0)
        captureMap!.layer.shadowRadius = 3.0
        captureMap!.setTitle("Add Map", for: .normal)
        captureMap!.translatesAutoresizingMaskIntoConstraints = false
        captureMap!.addTarget(self, action: #selector(saveMap), for: .touchUpInside)
        self.view.addSubview(captureMap!)
        
        let capViewAndSbar: [String: UIView] = ["cMap":captureMap!, "sBar":searchBar!]
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "[cMap(>=100,<=150)]", options: [], metrics: nil, views: capViewAndSbar))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[sBar]-20-[cMap]", options: [], metrics: nil, views: capViewAndSbar))
        
        NSLayoutConstraint.activate([
            captureMap!.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            captureMap!.topAnchor.constraintGreaterThanOrEqualToSystemSpacingBelow(searchBar!.bottomAnchor, multiplier: 1.0)])
        
        locationManager = CLLocationManager()
        locationManager!.delegate = self
        requestLocationPermision()
        checkForLocationServices()
    }
    
    @objc func saveMap()
    {
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
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar)
    {
        searchBar.endEditing(true)
    }
    
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
                    let place = placeMarks![0]
                    
                    let coord: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: place.location!.coordinate.latitude, longitude: place.location!.coordinate.longitude)
                    let region = MKCoordinateRegionMakeWithDistance(coord, self.regionRadius, self.regionRadius)
                    self.mapView!.setRegion(region, animated: true)
                    
                    let annotation: MapAnnotation = MapAnnotation(coordinate: coord, title: place.name!, subTitle: "")
                    self.mapView!.addAnnotation(annotation)
                    self.mapView!.delegate = self
                }
        })
        
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
        let view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "mapCenter")
        return view
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
        let location: CLLocation = locations.last!
        
        let now = Date()
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "HH:mm:ss"
        let timeStamp = formatter.string(from: now)
        let locationTimestamp = formatter.string(from: location.timestamp)
        
        if(locationTimestamp == timeStamp)
        {
            var region: MKCoordinateRegion = mapView!.region
            region.center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            region.span = MKCoordinateSpan(latitudeDelta: delta, longitudeDelta: delta)
            mapView!.setRegion(region, animated: true)
            mapView!.showsUserLocation = true
        }
        
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print(error)
    }
}
