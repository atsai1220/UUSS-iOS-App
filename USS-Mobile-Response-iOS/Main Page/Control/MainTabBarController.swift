//
//  MainViewController.swift
//  USS-Mobile-Response-iOS
//
//  Andrew Tsai

import Foundation
import UIKit

class MainTabBarController: UITabBarController, UITabBarControllerDelegate
{
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
//        performSegue(withIdentifier: "formSegue", sender: self)
        performSegue(withIdentifier: "hazardSegue", sender: self)
    }
    
    func showControllerFor(setting: Setting) {
        let dummyViewController = UIViewController()
        dummyViewController.navigationItem.title = setting.name
        navigationController?.pushViewController(dummyViewController, animated: true)
    }
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.delegate = self
        selectedIndex = 0
        navigationItem.title = "Main"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let localViewCotnroller: MainLocalTableViewController = MainLocalTableViewController()
        
        let trashViewController: MainTrashTableViewController = MainTrashTableViewController()
        
        let mapsViewController: MapTableViewController = MapTableViewController()
        mapsViewController.title = "Maps"
        
        localViewCotnroller.tabBarItem = UITabBarItem(title: "Local", image: UIImage(named: "baggage"), tag: 0)
        mapsViewController.tabBarItem = UITabBarItem(title: "Maps", image: UIImage(named: "map"), tag: 1)
        trashViewController.tabBarItem = UITabBarItem(title: "Trash", image: UIImage(named: "bin"), tag: 2)
        
        self.setViewControllers([localViewCotnroller, mapsViewController, trashViewController], animated: true)
        
        
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
