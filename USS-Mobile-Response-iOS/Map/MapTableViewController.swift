//
//  MapTableViewController.swift
//  USS-Mobile-Response-iOS
//
//  Created by Charlie Barber on 8/10/18.
//  Copyright © 2018 Andrew Tsai. All rights reserved.
//
import UIKit
import CoreData
import MapKit

protocol MoveToSelectionDelegate: class
{
    func moveToSelectedPlace(with name: String, and coordinates: CLLocationCoordinate2D)
}

protocol FavoritesDelegate: class
{
    func favoriteCellChosen(_:Bool)
}

class MapTableViewController: UITableViewController
{
    var tableData: [CellData] = []
    var managedContext: NSManagedObjectContext?
    weak var moveToSelectedPlaceDelegate: MoveToSelectionDelegate?
    weak var favoriteDelegate: FavoritesDelegate?
    
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
        
        initFooterData()
        tableView.register(TableCell.self, forCellReuseIdentifier: "cell")
        tableView.rowHeight = 90.0
        NotificationCenter.default.addObserver(self, selector: #selector(loadTableData), name: Notification.Name("New Search"), object: nil)
    }
        
    override func viewWillAppear(_ animated: Bool)
    {
        loadTableData()
        self.tableView.reloadData()
    }
    
    func initFooterData()
    {
        tableData.append(CellData(name: "Favorites", address: "0 places", city: "", latitude: 0, longitude: 0))
    }
    
    @objc func loadTableData()
    {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate

            managedContext = appDelegate.persistentContainer.viewContext

            let entity = NSEntityDescription.entity(forEntityName: "Placemark", in: managedContext!)
            
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
                        if(tableData.count == 10)
                        {
                            removeSearchFromData(name: tableData[tableData.count - 2].cellName!)
                            tableData.remove(at: tableData.count - 2)
                            tableData.insert((CellData(name: name, address: address, city: city, latitude: latitude, longitude: longitude)), at: 0)
                        }
                        else
                        {
                            tableData.insert((CellData(name: name, address: address, city: city, latitude: latitude, longitude: longitude)), at: 0)
                        }
                    }
                }
                tableView.reloadData()
            }
            catch
            {
                print("Fetch failed")
            }
    }
    
    
    override func viewWillDisappear(_ animated: Bool)
    {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.saveContext()
    }
    
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
        return false
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
        
        let cellData: CellData = tableData[indexPath.row]
        
        if(cellData.cellName == "Favorites")
        {
            cell.nameLabel.text = cellData.cellName
            cell.descriptionLabel.text = cellData.cellAddress
            cell.icon.image = UIImage(named: "heart")
        }
        else
        {
            cell.nameLabel.text = cellData.cellName
            cell.descriptionLabel.text = "\(String(describing: cellData.cellAddress!)), \(String(describing: cellData.cellCity!))"
            cell.icon.image = UIImage(named: "pin")
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let cell: CellData = tableData[indexPath.row]
        
        if cell.cellName != "Favorites"
        {
            let point: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: cell.cellLatitude!, longitude: cell.cellLongitude!)
            moveToSelectedPlaceDelegate?.moveToSelectedPlace(with: cell.cellName!, and: point)
        }
        else if cell.cellName == "Favorites"
        {
            favoriteDelegate?.favoriteCellChosen(true)
        }
    }
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
    
    let icon: RoundedImageView =
    {
        let image: RoundedImageView = RoundedImageView(image: UIImage(named: "video"))
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .center
        image.backgroundColor = .red

        return image
    }()
    
    let nameLabel: UILabel =
    {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 25)
        label.text = ""
        return label
    }()
    
    let descriptionLabel: UILabel =
    {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = UIColor.black.withAlphaComponent(0.4)
        label.text = ""
        return label
    }()
    
    func setUpViews()
    {
        addSubview(nameLabel)
        addSubview(icon)
        addSubview(descriptionLabel)
        
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: icon.topAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 15.0),
            descriptionLabel.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 15.0),
            descriptionLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 2.0),
            icon.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 25.0),
            icon.heightAnchor.constraint(equalToConstant: 40.0),
            icon.widthAnchor.constraint(equalToConstant: 40.0),
            icon.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            ])
    }
}

class CellData: NSObject
{
    var cellName: String?
    var cellAddress: String?
    var cellCity: String?
    var cellLatitude: Double?
    var cellLongitude: Double?

    
    init(name: String?, address: String?, city: String?, latitude: Double?, longitude: Double?)
    {
        cellName = name
        cellAddress = address
        cellCity = city
        cellLatitude = latitude
        cellLongitude = longitude
    }
}
