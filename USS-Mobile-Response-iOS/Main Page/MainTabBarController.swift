//
//  MainViewController.swift
//  USS-Mobile-Response-iOS
//
//  Andrew Tsai

import Foundation
import UIKit
import MapKit
import CoreData


class MainTabBarController: UITabBarController
{
    @IBOutlet weak var rightBarButton: UIBarButtonItem!
    var isEditMode: Bool = false
    
    let doneEditingButton: UIButton =
    {
        let button: UIButton = UIButton(type: .system)
        button.backgroundColor = UIColor.white
        button.titleLabel!.text = "Done"
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.layer.borderWidth = 1.0
        button.layer.cornerRadius = 5.0
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowRadius = 3.0
        return button
    }()
    
//    func addMap(buttonPressed: Bool)
//    {
//        let newMapFormVC: NewMapFormViewController = NewMapFormViewController()
//        newMapFormVC.addMapDelegate = self
//        navigationController?.pushViewController(newMapFormVC, animated: true)
//    }

    lazy var sideMenuLauncher: SideMenuLauncher =
        {
        let launcher = SideMenuLauncher()
        launcher.mainTabBarController = self
        return launcher
    }()
    
    
    @IBAction func menuTapped(_ sender: Any) {
        // Cover and disable main view when hamburger button is tapped.
        sideMenuLauncher.showSideMenu()
    }
    
    @IBAction func newTapped(_ sender: Any) {
        let localEntryVC = LocalEntryTableViewController()
        self.navigationController?.pushViewController(localEntryVC, animated: true)
//        showResourceTypeActionSheet()
//        let ew = HazardsTableViewController()
//        self.navigationController?.pushViewController(ew, animated: true)
    }
    
    @objc func doneTapped(_ sender: Any) {
        print("turn into done")
    }
    
    func toggleRightBarButton() {
        if isEditMode {
            rightBarButton.action = #selector(newTapped)
            rightBarButton.target = self
        } else {
            rightBarButton.action = #selector(doneTapped)
            rightBarButton.target = self
        }
    }
    
    
    func showControllerFor(setting: Setting) {
        let pageVC: UIViewController
        if setting.name == "Profile" {
            pageVC = ProfileViewController()
        }
        else {
            pageVC = AboutViewController()
        }
        pageVC.navigationItem.title = setting.name
        navigationController?.pushViewController(pageVC, animated: true)
    }
    
//    func addMapToTable(map: MKMapView, withName name: String)
//    {
//        navigationController?.popViewController(animated: true)
//        save(map: map, with: name)
//    }
    
//    func save(map: MKMapView, with name: String)
//    {
//        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//
//        let managedContext: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
//
//        let entity: NSEntityDescription = NSEntityDescription.entity(forEntityName: "Map", in: managedContext)!
//
//        let mapObject: NSManagedObject = NSManagedObject(entity: entity, insertInto: managedContext)
//
//        mapObject.setValue(map.region.center.latitude, forKey: "latitude")
//        mapObject.setValue(map.region.center.longitude, forKey: "longitude")
//        mapObject.setValue(name, forKey: "name")
//
//        do
//        {
//            try managedContext.save()
//            mapTableViewController?.insertCellData(with: mapObject)
//            mapTableViewController?.tableData.append(mapObject)
//        }
//        catch let error as NSError
//        {
//            print("There was an error saving. \(error)")
//        }
//
//    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
//        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//
//        let managedContext: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
//
//        let fetchRequest: NSFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Map")
//
//        do
//        {
//            try
//                mapTableViewController?.tableData = managedContext.fetch(fetchRequest)
//        }
//        catch let error as NSError
//        {
//            print("\(error). Could not complete fetch request")
//        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        rightBarButton.action = #selector(newTapped)
        rightBarButton.target = self
        
        selectedIndex = 0
        navigationItem.title = "Main"
        navigationController?.navigationBar.prefersLargeTitles = false
        
        let localViewCotnroller: MainLocalCollectionViewController = MainLocalCollectionViewController(collectionViewLayout: UICollectionViewLayout())
        
        let trashViewController: MainTrashTableViewController = MainTrashTableViewController()
        
        let mapViewController: MapViewController = MapViewController()
        
//        let tableVC = MapTableViewController()
        
        localViewCotnroller.tabBarItem = UITabBarItem(title: "Local", image: UIImage(named: "baggage"), tag: 0)
        mapViewController.tabBarItem = UITabBarItem(title: "Maps", image: UIImage(named: "map"), tag: 1)
        trashViewController.tabBarItem = UITabBarItem(title: "Trash", image: UIImage(named: "bin"), tag: 2)
        
        self.setViewControllers([localViewCotnroller, mapViewController, trashViewController], animated: true)
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
        
        self.navigationController?.navigationBar.layer.masksToBounds = false
        self.navigationController?.navigationBar.layer.shadowColor = UIColor.lightGray.cgColor
        self.navigationController?.navigationBar.layer.shadowOpacity = 0.8
        self.navigationController?.navigationBar.layer.shadowOffset = CGSize(width: 0, height: 3)
        self.navigationController?.navigationBar.layer.shadowRadius = 2

    }
}

