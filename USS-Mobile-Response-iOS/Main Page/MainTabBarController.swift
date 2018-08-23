//
//  MainViewController.swift
//  USS-Mobile-Response-iOS
//
//  Andrew Tsai

import Foundation
import UIKit
import MapKit


class MainTabBarController: UITabBarController, NewMapDelegate, AddMapToTableDelegate
{
    func addMapToTable(map: MKMapView)
    {
        navigationController?.popViewController(animated: true)
        var indexPaths: [IndexPath] = mapTableViewController!.tableView.indexPathsForVisibleRows!
        var cell: UITableViewCell = mapTableViewController!.tableView.cellForRow(at: indexPaths[0])!
        
//        var mapImage = makeSnapshotOfMap(map: map)
//        cell.imageView!.image = UIImage(named: "map")
        mapTableViewController?.insertCellData(image: UIImage(named: "map")!)
        
    }
    
    func makeSnapshotOfMap(map: MKMapView) -> UIImage
    {
        let regionRadius: CLLocationDistance = 500
           var mapCamera: MKMapCamera
            var snapshotOptions: MKMapSnapshotOptions
        var image: UIImage = UIImage()
        var snapShotter: MKMapSnapshotter
                mapCamera = MKMapCamera(lookingAtCenter: map.centerCoordinate, fromDistance: regionRadius, pitch: 0.0, heading: 0.0)
                snapshotOptions = MKMapSnapshotOptions()
                snapshotOptions.camera = mapCamera
        snapshotOptions.region = map.region
                snapshotOptions.size = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                snapshotOptions.scale = UIScreen.main.scale
                snapshotOptions.mapType = .standard
        
                snapShotter = MKMapSnapshotter(options: snapshotOptions)
                snapShotter.start(completionHandler: {(snapshot, error) in
                    if((error) != nil)
                    {
                        print("There was a problem taking the snapshot")
                    }
                    else
                    {
                        image = snapshot!.image
                    }
                })
        
        return image
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
//        navigationController?.navigationBar.prefersLargeTitles = false
        
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

