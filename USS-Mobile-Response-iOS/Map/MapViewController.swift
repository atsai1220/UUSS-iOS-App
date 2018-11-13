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

class MapViewController: UIViewController, CLLocationManagerDelegate, UISearchBarDelegate, MKMapViewDelegate, CloseSettingsDelegate, SelectorDelegate, CloseSaveToFavoritesDelegate, SaveDelegate, MoveToSelectionDelegate, FavoritesDelegate, FavoriteSelectedDelegate
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
    var photoAnnotationId: String = "photo"
    var videoAnnotationId: String = "video"
    var audioAnnotationId: String = "audio"
    var documentationAnnotationId: String = "document"
    var searchAnnotation: MapAnnotation?
    var segmentedControl: UISegmentedControl?
    var currentLocation: CLLocation?
    var compass: MKCompassButton?
    var transitionDelegate: PresentationManager = PresentationManager()
    var mapSettingsViewController: MapSettingsViewController?
    var saveToFavoritesViewController: SaveToFavoritesViewController?
    var placemark: CLPlacemark?
    var mapTableViewController: MapTableViewController?
    var mapTableStartPointConstraint: NSLayoutConstraint?
    var mapTableTopConstraint: NSLayoutConstraint?
    var mapTableBottomConstraint: NSLayoutConstraint?
    var tableStartingPoint: CGFloat?
//    var startingPointofTable: CGFloat?
//    var posOfTableAtTop: CGFloat?
//    var posOfTableAtBottom: CGFloat?
    var tablePosition: String = "start"
    var swipeUpGestureRecognizer: UISwipeGestureRecognizer? = nil
    var swipeDownGestureRecognizer: UISwipeGestureRecognizer? = nil
    var searchBarSwipeUp: UISwipeGestureRecognizer?
    var searchBarSwipeDown: UISwipeGestureRecognizer?
    var searchBarAnchorToMapTable: NSLayoutConstraint?
    var searchBarAnchorToFavoriteTable: NSLayoutConstraint?
    var favoritesTableViewController: MapFavoritesTableViewController?
    var searchImage: UIImage?
    var entity: NSEntityDescription?
    var managedContext: NSManagedObjectContext?
    var placemarkObject: NSManagedObject?
    
    var favoriteSearchBarView: UIView =
    {
        let favView: UIView = UIView()
        favView.translatesAutoresizingMaskIntoConstraints = false
        favView.backgroundColor = UIColor.darkGray.withAlphaComponent(0.75)
        favView.layer.cornerRadius = 5
        let favLabel: UILabel = UILabel()
        favLabel.translatesAutoresizingMaskIntoConstraints = false
        favLabel.font = .systemFont(ofSize: 15.0)
        favLabel.text = "Favorites"
        favLabel.textColor = .white
        let favImage: UIImageView = UIImageView(image: UIImage(named: "heart"))
        favImage.translatesAutoresizingMaskIntoConstraints = false
        favView.addSubview(favImage)
        favView.addSubview(favLabel)
        
        NSLayoutConstraint.activate([
            favLabel.heightAnchor.constraint(equalToConstant: 25.0),
            favLabel.widthAnchor.constraint(equalToConstant: 75.0),
            favLabel.leadingAnchor.constraint(equalTo: favImage.trailingAnchor, constant: 5.0),
            favImage.heightAnchor.constraint(equalToConstant: 10.0),
            favImage.widthAnchor.constraint(equalToConstant: 10.0),
            favImage.centerYAnchor.constraint(equalTo: favLabel.centerYAnchor),
            favImage.leadingAnchor.constraint(equalTo: favView.leadingAnchor, constant: 5.0)
            ])
        
        return favView
    }()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.lightGray
        

        swipeUpGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        swipeUpGestureRecognizer!.direction = .up
        swipeDownGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        swipeDownGestureRecognizer!.direction = .down
        
        searchBarSwipeUp = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        searchBarSwipeUp!.direction = .up
        searchBarSwipeDown = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        searchBarSwipeDown!.direction = .down
        
        mapView = MKMapView()
        mapView!.delegate = self
        mapView!.translatesAutoresizingMaskIntoConstraints = false
        mapView!.showsUserLocation = true
        mapView!.showsCompass = false
        mapView!.showsScale = true
        view.addSubview(mapView!)
        loadAnnotations()
        
        
        searchBar = UISearchBar()
        searchBar!.translatesAutoresizingMaskIntoConstraints = false
        searchBar!.placeholder = "Search for a place or address"
        searchBar!.barTintColor = .white
////        searchBar!.layer.shadowOpacity = 0.5
////        searchBar!.layer.shadowColor = UIColor.black.cgColor
////        searchBar!.layer.shadowOffset = CGSize(width: 0.0, height: -10.0)
////        searchBar!.layer.shadowRadius = 3.0
        let searchField: UITextField = searchBar!.value(forKey: "searchField") as! UITextField
        searchField.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
        searchBar!.delegate = self
        searchBar!.addGestureRecognizer(searchBarSwipeUp!)
        searchBar!.addGestureRecognizer(searchBarSwipeDown!)
        
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
        
        
        mapTableViewController = MapTableViewController(style: .plain)
        mapTableViewController!.view.translatesAutoresizingMaskIntoConstraints = false
        mapTableViewController!.moveToSelectedPlaceDelegate = self
        mapTableViewController!.favoriteDelegate = self
        mapTableViewController!.view.isUserInteractionEnabled = true
        mapTableViewController!.view.addGestureRecognizer(swipeUpGestureRecognizer!)
        mapTableViewController!.view.addGestureRecognizer(swipeDownGestureRecognizer!)
        mapTableViewController!.tableView.isScrollEnabled = false
        
        favoritesTableViewController = MapFavoritesTableViewController(style: .plain)
        favoritesTableViewController!.view.translatesAutoresizingMaskIntoConstraints = false
        favoritesTableViewController!.view.isUserInteractionEnabled = true
        favoritesTableViewController!.selectedFavoriteDelegate = self
        view.addSubview(favoritesTableViewController!.view)
        
        self.addChildViewController(mapTableViewController!)
        view.addSubview(searchBar!)
        view.addSubview(mapTableViewController!.view)
        
        NSLayoutConstraint.activate([
            mapView!.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mapView!.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 1.0),
            mapView!.widthAnchor.constraint(equalTo: view.widthAnchor),
            segmentedControl!.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15.0),
            segmentedControl!.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10.0),
            segmentedControl!.heightAnchor.constraint(equalToConstant: 35.0),
            segmentedControl!.widthAnchor.constraint(equalToConstant: 100.0),
            compass!.topAnchor.constraint(equalTo: segmentedControl!.bottomAnchor, constant: 10.0),
            compass!.trailingAnchor.constraint(equalTo: segmentedControl!.trailingAnchor),
            mapTableViewController!.view.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1.0),
            mapTableViewController!.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            searchBar!.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1.0),
            favoritesTableViewController!.view.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1.0),
            favoritesTableViewController!.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
//            searchBar!.bottomAnchor.constraint(equalTo: mapTableViewController!.view.topAnchor)
            ])
        
        searchBarAnchorToMapTable = NSLayoutConstraint(item: self.searchBar!, attribute: .bottom, relatedBy: .equal, toItem: self.mapTableViewController!.view, attribute: .top, multiplier: 1.0, constant: 0.0)
        searchBarAnchorToMapTable!.isActive = true
        searchBarAnchorToFavoriteTable = NSLayoutConstraint(item: self.searchBar!, attribute: .bottom, relatedBy: .equal, toItem: self.favoritesTableViewController!.view, attribute: .top, multiplier: 1.0, constant: 0.0)
        searchBarAnchorToFavoriteTable!.isActive = false
        
        
        mapTableTopConstraint = NSLayoutConstraint(item: self.searchBar!, attribute: .top, relatedBy: .equal, toItem: self.mapView!, attribute: .top, multiplier: 1.0, constant: 0.0)
        mapTableTopConstraint!.isActive = false
        mapTableStartPointConstraint = NSLayoutConstraint(item: self.searchBar!, attribute: .top, relatedBy: .equal, toItem: self.mapView!, attribute: .bottom, multiplier: 0.75, constant: 0.0)
        mapTableStartPointConstraint!.isActive = true
        mapTableBottomConstraint = NSLayoutConstraint(item: self.searchBar!, attribute: .top, relatedBy: .equal, toItem: self.mapView!, attribute: .bottom, multiplier: 0.94, constant: 0.0)
        mapTableBottomConstraint!.isActive = false
        
        
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
        saveToFavoritesViewController?.dismiss(animated: true, completion: nil)
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
                transitionDelegate.type = .settings
                mapSettingsViewController!.transitioningDelegate = transitionDelegate
                mapSettingsViewController!.modalPresentationStyle = .custom
                present(mapSettingsViewController!, animated: true, completion: nil)
            
            case Segment.LOCATION.rawValue:
                if(self.searchAnnotation != nil)
                {
                    mapView!.removeAnnotation(self.searchAnnotation!)
                }
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
        if index == 0
        {
            mapView!.mapType = .standard
        }
        else if index == 1
        {
            mapView!.mapType = .satellite
        }
    }
    
   
    func moveToSelectedPlace(with name: String, and coordinates: CLLocationCoordinate2D)
    {
        if tablePosition == "top"
        {
            animateSearchTableToStartPosition()
        }
        mapView!.register(AnnotationView.self, forAnnotationViewWithReuseIdentifier: self.searchId)
        searchAnnotation = MapAnnotation(coordinate: coordinates, title: name, subTitle: "", type: "search")
        mapView!.addAnnotation(self.searchAnnotation!)
        let region = MKCoordinateRegionMakeWithDistance(coordinates, self.regionRadius, self.regionRadius)
        mapView!.setRegion(region, animated: true)
    }
   
    
    func savePlacemarkToTableView()
    {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        managedContext = appDelegate.persistentContainer.viewContext
        entity = NSEntityDescription.entity(forEntityName: "Placemark", in: managedContext!)
        placemarkObject = NSManagedObject(entity: entity!, insertInto: managedContext)
        
        placemarkObject!.setValue(self.placemark!.name, forKey: "name")
        if placemark?.thoroughfare != nil
        {
            placemarkObject!.setValue(self.placemark!.thoroughfare!, forKey: "thoroughfare")
        }
        if placemark?.locality != nil
        {
            placemarkObject!.setValue(self.placemark!.locality!, forKey: "city")
        }
        placemarkObject!.setValue(self.placemark!.location!.coordinate.latitude, forKey: "latitude")
        placemarkObject!.setValue(self.placemark!.location!.coordinate.longitude, forKey: "longitude")
    
        do
        {
            try managedContext!.save()
            NotificationCenter.default.post(name: Notification.Name("New Search"), object: nil)
        }
        catch let error as NSError
        {
            print("There was an error saving. \(error)")
        }
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(deleteAnnotation), name: Notification.Name("Local Entry Deleted"), object: nil)
        loadAnnotations()
    }
    
    
    @objc func deleteAnnotation(notification: Notification)
    {
        let userInfo: [AnyHashable: Any] = notification.userInfo!
        let annotations: [MKAnnotation] = mapView!.annotations
        let key = userInfo.keys.first as! String

        for annotation in annotations
        {
            if(!(annotation is MKUserLocation))
            {
                if(key == annotation.title)
                {
                    mapView!.removeAnnotation(annotation)
                }
            }

        }
    }
//    self.searchAnnotation = MapAnnotation(coordinate: coord, title: self.placemark!.name!, subTitle: "")
//    self.mapView!.addAnnotation(self.searchAnnotation!)
    
    func loadAnnotations()
    {
        let localEntries: [LocalEntry] = getLocalEntriesFromDisk()
        
        for entry in localEntries
        {
            switch entry.fileType
            {
                case FileType.PHOTO.rawValue:
                    mapView!.register(AnnotationView.self, forAnnotationViewWithReuseIdentifier: photoAnnotationId)
                    let photoAnnotation: MapAnnotation = MapAnnotation(
                        coordinate: CLLocationCoordinate2D(latitude: entry.dataLat!, longitude: entry.dataLong!),
                        title: entry.name!,
                        subTitle: "", type: entry.fileType)
                    mapView!.addAnnotation(photoAnnotation)
                
                case FileType.VIDEO.rawValue:
                    mapView!.register(AnnotationView.self, forAnnotationViewWithReuseIdentifier: videoAnnotationId)
                    let videoAnnotation: MapAnnotation = MapAnnotation(
                        coordinate: CLLocationCoordinate2D(latitude: entry.dataLat!, longitude: entry.dataLong!),
                        title: entry.name!,
                        subTitle: "", type: entry.fileType)
                    mapView!.addAnnotation(videoAnnotation)
                case FileType.AUDIO.rawValue:
                    mapView!.register(AnnotationView.self, forAnnotationViewWithReuseIdentifier: audioAnnotationId)
                    let audioAnnotation: MapAnnotation = MapAnnotation(
                        coordinate: CLLocationCoordinate2D(latitude: entry.dataLat!, longitude: entry.dataLong!),
                        title: entry.name!,
                        subTitle: "", type: entry.fileType)
                    mapView!.addAnnotation(audioAnnotation)
                case FileType.DOCUMENT.rawValue:
                    mapView!.register(AnnotationView.self, forAnnotationViewWithReuseIdentifier: documentationAnnotationId)
                    let documentAnnotation: MapAnnotation = MapAnnotation(
                        coordinate: CLLocationCoordinate2D(latitude: entry.dataLat!, longitude: entry.dataLong!),
                        title: entry.name!,
                        subTitle: "", type: entry.fileType)
                    mapView!.addAnnotation(documentAnnotation)
                default:
                    break
            }
        }
    }
    
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar)
    {
        mapTableViewController!.tableView.isScrollEnabled = true
        if(self.searchAnnotation != nil)
        {
            mapView!.removeAnnotation(searchAnnotation!)
        }
        
        animateSearchTableToTop()
        searchBar.showsCancelButton = true
    }
    
    func animateSearchTableToTop()
    {
        tablePosition = "top"
        mapTableStartPointConstraint!.isActive = false
        mapTableBottomConstraint!.isActive = false
        mapTableTopConstraint!.isActive = true
        
        UIView.animate(withDuration: 0.2, animations:
        {
                self.view.layoutIfNeeded()
        }, completion: nil)
        
        mapTableViewController!.tableView.isScrollEnabled = true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
        if searchBarAnchorToFavoriteTable!.isActive
        {
            favoriteSearchBarView.removeFromSuperview()
            searchBarAnchorToFavoriteTable!.isActive = false
            searchBarAnchorToMapTable!.isActive = true
            let textfield: UITextField = searchBar.value(forKey: "searchField") as! UITextField
            textfield.textColor = .black
            textfield.tintColor = .black
            
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar)
    {
        if(self.searchAnnotation != nil)
        {
            mapView!.removeAnnotation(self.searchAnnotation!)
        }
        
        if searchBarAnchorToFavoriteTable!.isActive
        {
            searchBar.setImage(searchImage, for: .search, state: .normal)
            let textfield: UITextField = searchBar.value(forKey: "searchField") as! UITextField
            textfield.textColor = .black
            textfield.tintColor = .black
            searchBarAnchorToFavoriteTable!.isActive = false
            searchBarAnchorToMapTable!.isActive = true
            searchBar.text = ""
            animateSearchTableToStartPosition()
            searchBar.endEditing(true)
            favoriteSearchBarView.removeFromSuperview()
        }
        else
        {
            searchBar.text = ""
            animateSearchTableToStartPosition()
            searchBar.endEditing(true)
        }
    }
    
    
    func animateSearchTableToStartPosition()
    {
        searchBar!.endEditing(true)
        tablePosition = "start"
        mapTableTopConstraint!.isActive = false
        mapTableBottomConstraint!.isActive = false
        mapTableStartPointConstraint!.isActive = true
        
        UIView.animate(withDuration: 0.2, animations:
            {
                self.view.layoutIfNeeded()
        }, completion: nil)
        
        mapTableViewController!.tableView.isScrollEnabled = false
    }
    
    func animateSearchTableToBottomPosition()
    {
        tablePosition = "bottom"
        mapTableStartPointConstraint!.isActive = false
        mapTableTopConstraint!.isActive = false
        mapTableBottomConstraint!.isActive = true
        
        UIView.animate(withDuration: 0.2, animations:
            {
                self.view.layoutIfNeeded()
        }, completion: nil)
        
        mapTableViewController!.tableView.isScrollEnabled = false
    }
    
    @objc func handleSwipe(gestureRecognizer: UISwipeGestureRecognizer)
    {
        if gestureRecognizer.state == .ended
        {
            
            switch tablePosition
            {
            case "start":
                
                if gestureRecognizer.direction == .up
                {
                    animateSearchTableToTop()
                }
                else if gestureRecognizer.direction == .down
                {
                    animateSearchTableToBottomPosition()
                }
                
            case "top":
                
                if gestureRecognizer.direction == .down
                {
                    animateSearchTableToStartPosition()
                }
                
            case "bottom":
                
                if gestureRecognizer.direction == .up
                {
                    animateSearchTableToStartPosition()
                }
            default:
                break
                
            }
        }
    }
    
    func moveToFavoriteSelected(with name: String, and point: CLLocationCoordinate2D)
    {
        animateSearchTableToStartPosition()
        searchBarAnchorToMapTable!.isActive = true
        searchBarAnchorToFavoriteTable!.isActive = false
        favoriteSearchBarView.removeFromSuperview()
        let textfield: UITextField = searchBar!.value(forKey: "searchField") as! UITextField
        textfield.text = ""
        textfield.textColor = .black
        textfield.tintColor = .black
        searchBar!.setImage(searchImage, for: .search, state: .normal)
        mapView!.register(AnnotationView.self, forAnnotationViewWithReuseIdentifier: self.searchId)
        searchAnnotation = MapAnnotation(coordinate: point, title: name, subTitle: "", type: "search")
        mapView!.addAnnotation(self.searchAnnotation!)
        let region = MKCoordinateRegionMakeWithDistance(point, self.regionRadius, self.regionRadius)
        mapView!.setRegion(region, animated: true)
        
    }
    
    func favoriteCellChosen(_: Bool)
    {
        searchBar!.becomeFirstResponder()
        searchBarAnchorToMapTable!.isActive = false
        searchBarAnchorToFavoriteTable!.isActive = true
        let textfield: UITextField = searchBar!.value(forKey: "searchField") as! UITextField
        textfield.text = "t"
        textfield.textColor = .clear
        textfield.tintColor = .clear
        searchImage = searchBar!.image(for: .search, state: .normal)
        searchBar!.setImage(UIImage(), for: .search, state: .normal)
        searchBar!.showsCancelButton = true
        searchBar!.addSubview(favoriteSearchBarView)
        NSLayoutConstraint.activate([
            favoriteSearchBarView.widthAnchor.constraint(equalToConstant: 90.0),
            favoriteSearchBarView.heightAnchor.constraint(equalToConstant: 25.0),
            favoriteSearchBarView.leadingAnchor.constraint(equalTo: searchBar!.leadingAnchor, constant: 15.0),
            favoriteSearchBarView.centerYAnchor.constraint(equalTo: searchBar!.centerYAnchor, constant: 1.0)
            ])
        
        
        transitionDelegate.type = .save
        animateSearchTableToTop()
    }
    
    func saveToFavoritesTable(_: Bool)
    {
        saveToFavoritesViewController!.dismiss(animated: true, completion: nil)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        managedContext = appDelegate.persistentContainer.viewContext
        entity = NSEntityDescription.entity(forEntityName: "Favorite", in: managedContext!)
        placemarkObject = NSManagedObject(entity: entity!, insertInto: managedContext)
        
        placemarkObject!.setValue(self.placemark!.name, forKey: "name")
        if placemark?.thoroughfare != nil
        {
            placemarkObject!.setValue(self.placemark!.thoroughfare!, forKey: "thoroughfare")
        }
        if placemark?.locality != nil
        {
            placemarkObject!.setValue(self.placemark!.locality!, forKey: "city")
        }
        placemarkObject!.setValue(self.placemark!.location!.coordinate.latitude, forKey: "latitude")
        placemarkObject!.setValue(self.placemark!.location!.coordinate.longitude, forKey: "longitude")
        
        do
        {
            try managedContext!.save()
        }
        catch let error as NSError
        {
            print("There was an error saving. \(error)")
        }
        
        let cellData: CellData = CellData(name: placemark!.name, address: "", city: "", latitude: placemark!.location!.coordinate.latitude, longitude: placemark!.location!.coordinate.longitude)
        
        favoritesTableViewController!.tableData.append(cellData)
        NotificationCenter.default.post(name: Notification.Name("Favorite Saved"), object: nil)
    }
    
    func showSaveToFavoritesView()
    {
//    if let newMark = placemark {
//        if let post = newMark.postalCode {
//                print(post)
//        }
//    }
        saveToFavoritesViewController = SaveToFavoritesViewController()
        saveToFavoritesViewController!.titleLabel.text = placemark!.name
        saveToFavoritesViewController!.distanceLabel.text = String(format: "%.2f", placemark!.location!.distance(from: currentLocation!) / 1609.344) + " mi"
//        saveToFavoritesViewController!.streetLabel.text = placemark!.thoroughfare
        saveToFavoritesViewController!.cityLabel.text = placemark!.locality! + ", " + placemark!.administrativeArea! /*+ " " + (placemark!.postalCode?)!*/
        saveToFavoritesViewController!.countryLabel.text = placemark!.country
        saveToFavoritesViewController!.saveDelegate = self
        saveToFavoritesViewController!.closeSaveToFavoritesDelegate = self
        transitionDelegate.type = .save
        saveToFavoritesViewController!.transitioningDelegate = transitionDelegate
        saveToFavoritesViewController!.modalPresentationStyle = .custom
        present(saveToFavoritesViewController!, animated: true, completion: nil)
    }
    
    
//    func cityLabelString() -> String
//    {
//        var cityLabel: String?
//
//        if placemark?.locality == nil
//        {
//
//        }
//
//        return cityLabel!
//    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        if(self.searchAnnotation != nil)
        {
            mapView!.removeAnnotation(self.searchAnnotation!)
        }
        
        searchBar.endEditing(true)
        animateSearchTableToStartPosition()
        
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

                    if(!self.isNameInTable())
                    {
                        self.savePlacemarkToTableView()
                    }
    
                    let coord: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: self.placemark!.location!.coordinate.latitude, longitude: self.placemark!.location!.coordinate.longitude)
                    let region = MKCoordinateRegionMakeWithDistance(coord, self.regionRadius, self.regionRadius)
                    self.mapView!.setRegion(region, animated: true)
                    
                    if (self.searchAnnotation == nil)
                    {
                        self.mapView!.register(AnnotationView.self, forAnnotationViewWithReuseIdentifier: self.searchId)
                        self.searchAnnotation = MapAnnotation(coordinate: coord, title: self.placemark!.name!, subTitle: "", type: "search")
                        self.mapView!.addAnnotation(self.searchAnnotation!)
                    }
                    else
                    {
                        self.mapView!.removeAnnotation(self.searchAnnotation!)
                        self.mapView!.register(AnnotationView.self, forAnnotationViewWithReuseIdentifier: self.searchId)
                        self.searchAnnotation = MapAnnotation(coordinate: coord, title: self.placemark!.name!, subTitle: "", type: "search")
                        self.mapView!.addAnnotation(self.searchAnnotation!)
                    }
                    
                    self.showSaveToFavoritesView()
                }
        })
    }
    
    
    func isNameInTable() -> Bool
    {
        for cell in mapTableViewController!.tableData
        {
            if(placemark?.name == cell.cellName)
            {
                return true
            }
        }
        return false
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?
    {
        if(annotation is MKUserLocation)
        {
            return nil
        }
        else
        {
            var annotationView: AnnotationView? = AnnotationView()
            print((annotation as! MapAnnotation).fileType!)
            switch (annotation as! MapAnnotation).fileType!
            {

                case "PHOTO":
                    annotationView = (mapView.dequeueReusableAnnotationView(withIdentifier: photoAnnotationId) as! AnnotationView)
                case "VIDEO":
                    annotationView = (mapView.dequeueReusableAnnotationView(withIdentifier: videoAnnotationId) as! AnnotationView)
                case "AUDIO":
                    annotationView = (mapView.dequeueReusableAnnotationView(withIdentifier: audioAnnotationId) as! AnnotationView)
                case "DOCUMENT":
                    annotationView = (mapView.dequeueReusableAnnotationView(withIdentifier: documentationAnnotationId) as! AnnotationView)
                default:
                    print("Should not happen")
            }
            
            return annotationView
        }
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
        if !CLLocationManager.locationServicesEnabled()
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
            let alert = UIAlertController(title: "Error", message: "Location services must be enabled to use maps. Please check your settings", preferredStyle: .alert)
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
        else if authroizationStatus == .authorizedWhenInUse && CLLocationManager.locationServicesEnabled()
        {
            //Configure and start the device
            locationManager?.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            locationManager?.distanceFilter = 10000.0 //Meters
            locationManager?.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus)
    {
        if(status != .notDetermined)
        {
            startReceivingLocationChanges()
        }
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
