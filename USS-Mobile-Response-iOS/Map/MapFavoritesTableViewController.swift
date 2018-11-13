//
//  MapFavoritesTableViewController.swift
//  USS-Mobile-Response-iOS
//
//  Created by Charlie Barber on 10/31/18.
//  Copyright © 2018 Andrew Tsai. All rights reserved.
//

import UIKit
import CoreData
import MapKit


protocol FavoriteSelectedDelegate: class
{
    func moveToFavoriteSelected(with name:String, and point:CLLocationCoordinate2D)
}

class MapFavoritesTableViewController: UITableViewController
{
    var tableData: [CellData] = []
    var managedContext: NSManagedObjectContext?
    weak var selectedFavoriteDelegate: FavoriteSelectedDelegate?
    
    override init(style: UITableViewStyle)
    {
        super.init(style: style)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        loadTableData()
        tableView.register(TableCell.self, forCellReuseIdentifier: "cell")
        tableView.rowHeight = 90.0
        NotificationCenter.default.addObserver(self, selector: #selector(loadTableData), name: Notification.Name("Favorite Saved"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        loadTableData()
    }
    
    @objc func loadTableData()
    {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate

        managedContext = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "Favorite", in: managedContext!)
        
        do
        {
            let placeMarkArray = try managedContext!.fetch(NSFetchRequest.init(entityName: (entity?.name)!)) as! [NSObject]
            
            for placemark in placeMarkArray
            {
                let name: String  = placemark.value(forKey: "name") as! String
                let address: String = (placemark.value(forKey: "thoroughfare") != nil) ? placemark.value(forKey: "thoroughfare") as! String : ""
                let city: String? = (placemark.value(forKey: "city") != nil) ? placemark.value(forKey: "city") as! String : ""
                let latitude: Double? = placemark.value(forKey: "latitude") as? Double
                let longitude: Double? = placemark.value(forKey: "longitude") as? Double
                
                if(!isNameInTable(name: name))
                {
                    tableData.insert((CellData(name: name, address: address, city: city, latitude: latitude, longitude: longitude)), at: 0)
                }
            }
            tableView.reloadData()
            appDelegate.saveContext()
        }
        catch
        {
            print("Fetch failed")
        }
    }
    
    
//    override func viewWillDisappear(_ animated: Bool)
//    {
//        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//    }
    
    func removeSearchFromData(name: String)
    {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        let entity: NSEntityDescription = NSEntityDescription.entity(forEntityName: "Placemark", in: managedContext)!
        
        do
        {
            let placeMarkArray = try managedContext.fetch(NSFetchRequest.init(entityName: (entity.name)!)) as! [NSObject]
            
            for placemark in placeMarkArray
            {
                if(tableData[tableData.count - 2].cellName == name)
                {
                    managedContext.delete(placemark as! NSManagedObject)
                }
            }
        }
        catch
        {
            print("Fetch failed")
        }
        
        appDelegate.saveContext()
    }
    
    func isNameInTable(name: String?) -> Bool
    {
        for cell in tableData
        {
            if(name == cell.cellName)
            {
                return true
            }
        }
    
        
        let alert = UIAlertController(title: "Already Favorited", message: "You have already saved this map in your favorites", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: "default"), style: .default, handler: {_ in NSLog("The \"Ok\" alert occured")}))
        self.present(alert, animated: true, completion: nil)
        
        return false
    }
    
        override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
        {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            var managedObjectArray: [NSManagedObject] = []
            let managedContext: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
    
            let fetchRequest: NSFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Favorite")
    
            do
            {
                try managedObjectArray = managedContext.fetch(fetchRequest)
            }
            catch let error as NSError
            {
                print("\(error). Could not complete fetch request")
            }
    
            var managedObject: NSManagedObject?

            for object in managedObjectArray
            {
                if object.value(forKey: "name") as! String == tableData[indexPath.row].cellName!
                {
                    managedObject = object
                }
            }
    
            if editingStyle == .delete
            {
                tableData.remove(at: indexPath.row)
                managedContext.delete(managedObject!)
                tableView.deleteRows(at: [indexPath], with: .fade)
    
            }
        }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return tableData.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableCell
        
        let cellData: CellData = tableData[indexPath.row]
        
        cell.nameLabel.text = cellData.cellName
        cell.descriptionLabel.text = descriptionForPlacemark(address: cellData.cellAddress!, city: cellData.cellCity!)
//        cell.descriptionLabel.text = "\(String(describing: cellData.cellAddress!)), \(String(describing: cellData.cellCity!))"
        cell.icon.image = UIImage(named: "pin")
        
        return cell
    }
    
    func descriptionForPlacemark(address: String, city: String) -> String
    {
        var description: String?
        
        if address != "" && city != ""
        {
            description = "\(String(describing: address)), \(String(describing: city))"
        }
        else if address == "" && city != ""
        {
            description = "\(String(describing: city))"
        }
        else if address != "" && city == ""
        {
            description = "\(String(describing: address))"
        }
        else if address == "" && city == ""
        {
            description = ""
        }
        
        return description!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let cell: CellData = tableData[indexPath.row]
        
        let point: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: cell.cellLatitude!, longitude: cell.cellLongitude!)
        
        tableView.deselectRow(at: indexPath, animated: true)
        selectedFavoriteDelegate?.moveToFavoriteSelected(with: cell.cellName!, and: point)
    }
}
