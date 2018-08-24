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
    func addMapToTable(map: MKMapView, withImage image: UIImage)
    {
        navigationController?.popViewController(animated: true)
        mapTableViewController?.insertCellData(with: UIImage(named: "appMap")!)
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

