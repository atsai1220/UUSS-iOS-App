//
//  MapTableViewController.swift
//  USS-Mobile-Response-iOS
//
//  Created by Charlie Barber on 8/10/18.
//  Copyright © 2018 Andrew Tsai. All rights reserved.
//
//import Foundation
import UIKit
import CoreData

class MapTableViewController: UITableViewController
{
//    var tableData: [NSManagedObject] = []
    var tableData: [String] = ["hello"]
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.tableView.register(TableCell.self, forCellReuseIdentifier: "cell")
        tableView.rowHeight = 90.0
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        self.tableView.reloadData()
    }
//    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
//    {
//        var managedObjectArray: [NSManagedObject] = []
//        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//        let managedContext: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
//
//        let fetchRequest: NSFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Map")
//
//        do
//        {
//            try managedObjectArray = managedContext.fetch(fetchRequest)
//        }
//        catch let error as NSError
//        {
//            print("\(error). Could not complete fetch request")
//        }
//
//        var managedObject: NSManagedObject?
//        for object in managedObjectArray
//        {
//            if object.value(forKey: "name") as? String == tableData[indexPath.row].value(forKey: "name") as? String
//            {
//                managedObject = object
//            }
//        }
//
//        if editingStyle == .delete
//        {
//            self.tableData.remove(at: indexPath.row)
//            managedContext.delete(managedObject!)
//            tableView.deleteRows(at: [indexPath], with: .fade)
//
//        }
//    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return tableData.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableCell
////        cell.nameLabel.text = tableData[indexPath.row].value(forKey: "name") as? String
        cell.nameLabel.text = tableData[indexPath.row]
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
//        let mapObject: NSManagedObject = tableData[indexPath.row]
//        let lat: Double = (mapObject.value(forKey: "latitude") as? Double)!
//        let long: Double = (mapObject.value(forKey: "longitude") as? Double)!
        
//        let mapViewController: MapViewController = MapViewController()
//        mapViewController.mapLatitude = lat
//        mapViewController.mapLongitude = long
        
//        navigationController?.pushViewController(mapViewController, animated: true)
    }
//    @objc func addMap()
//    {
////        print("map button pressed in tableView!!!!")
//        delegate?.addMap(buttonPressed: true)
//    }
}

class TableCell: UITableViewCell
{
    override init(style: UITableViewCellStyle, reuseIdentifier: String?)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let nameLabel: UILabel =
    {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 25)
        label.text = ""
        return label
    }()
    
    func setUpViews()
    {
        addSubview(nameLabel)
        
        addConstraintsWithFormat(format: "H:|[v0]|", views: nameLabel)
        addConstraintsWithFormat(format: "V:|[v0]|", views: nameLabel)
    }
}
