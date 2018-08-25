//
//  MainViewController.swift
//  USS-Mobile-Response-iOS
//
//  Andrew Tsai

import Foundation
import UIKit
import MapKit
import CoreData


class MainTabBarController: UITabBarController, NewMapDelegate, AddMapDelegate
{
    func addMapToTable(map: MKMapView, withName name: String)
    {
        navigationController?.popViewController(animated: true)
        save(map: map, with: name)
    }
    
    func save(map: MKMapView, with name: String)
    {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
       
        let managedContext: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        
        let entity: NSEntityDescription = NSEntityDescription.entity(forEntityName: "Map", in: managedContext)!
        
        let mapObject: NSManagedObject = NSManagedObject(entity: entity, insertInto: managedContext)
        
        
        mapObject.setValue(map.region.center.latitude, forKey: "latitude")
        mapObject.setValue(map.region.center.longitude, forKey: "longitude")
        mapObject.setValue(name, forKey: "name")
        
        do
        {
            try managedContext.save()
            mapTableViewController?.insertCellData(with: mapObject)
            mapTableViewController?.tableData.append(mapObject)
        }
        catch let error as NSError
        {
            print("There was an error saving. \(error)")
        }
        
    }
    
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let managedContext: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Map")
        
        do {
            try
                mapTableViewController?.tableData = managedContext.fetch(fetchRequest)
            var x = 5
        }
        catch let error as NSError
        {
            print("\(error). Could not complete fetch request")
        }
    }
    
    func addMap(buttonPressed: Bool)
    {
        let newMapFormVC: NewMapFormViewController = NewMapFormViewController()
        newMapFormVC.addMapDelegate = self
        navigationController?.pushViewController(newMapFormVC, animated: true)
    }
    
    var mapView: MapView?
    var mapTableViewController: MapTableViewController?
    
    lazy var sideMenuLauncher: SideMenuLauncher =
        {
        let launcher = SideMenuLauncher()
        launcher.mainTabBarController = self
        return launcher
    }()
    
    @IBAction func menuTapped(_ sender: Any) {
        // TODO: Delegate vs Notification Center here?
        
        // Cover and disable main view when hamburger button is tapped.
        sideMenuLauncher.showSideMenu()
    }
    
    @IBAction func newTapped(_ sender: Any) {
        performSegue(withIdentifier: "hazardSegue", sender: self)
        
//        let resourceTypeVC = ResourceTypeFormController()
//        resourceTypeVC.collectionReference = "Test Entry"
//        navigationController?.pushViewController(resourceTypeVC, animated: true)
    }
    
    func showControllerFor(setting: Setting) {
        let pageVC: UIViewController
        if setting.name == "Profile" {
            pageVC = ProfileViewController()
        }
        else if setting.name == "Settings" {
            pageVC = SettingsViewController()
        }
        else {
            pageVC = AboutViewController()
        }
        pageVC.navigationItem.title = setting.name
        navigationController?.pushViewController(pageVC, animated: true)
    }
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        selectedIndex = 0
        navigationItem.title = "Main"
        navigationController?.navigationBar.prefersLargeTitles = false
        
        let localViewCotnroller: MainLocalTableViewController = MainLocalTableViewController()
        
        let trashViewController: MainTrashTableViewController = MainTrashTableViewController()
        
        mapTableViewController = MapTableViewController()
        mapTableViewController!.delegate = self
        mapTableViewController!.title = "Maps"
        
        localViewCotnroller.tabBarItem = UITabBarItem(title: "Local", image: UIImage(named: "baggage"), tag: 0)
        mapTableViewController!.tabBarItem = UITabBarItem(title: "Maps", image: UIImage(named: "map"), tag: 1)
        trashViewController.tabBarItem = UITabBarItem(title: "Trash", image: UIImage(named: "bin"), tag: 2)
        
        self.setViewControllers([localViewCotnroller, mapTableViewController!, trashViewController], animated: true)
        
    }
    
    override func viewWillLayoutSubviews()
    {
        if let window = UIApplication.shared.keyWindow
        {
            let cvWidth = 260
            let oldRect = sideMenuLauncher.collectionView.frame
            sideMenuLauncher.collectionView.frame = CGRect(x: Int(oldRect.origin.x), y: Int(oldRect.origin.y), width: cvWidth, height: Int(window.frame.height))
            sideMenuLauncher.greyView.frame = window.frame
        }
    }
}

