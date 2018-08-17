//
//  MapTableViewController.swift
//  USS-Mobile-Response-iOS
//
//  Created by Charlie Barber on 8/10/18.
//  Copyright © 2018 Andrew Tsai. All rights reserved.
//

import UIKit

protocol NewMapDelegate: class
{
    func addMap(buttonPressed: Bool)
}

class MapTableViewController: UITableViewController
{
    weak var delegate: NewMapDelegate?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        tableView.register(TableCell.self, forCellReuseIdentifier: "cellId")
//        tableView.register(TableHeader.self, forHeaderFooterViewReuseIdentifier: "headerId")
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 5
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        return tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        
//        let tView: UITableViewHeaderFooterView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "headerId")!
        let headerView: UIView = UIView()
        let nameLabel: UILabel =
        {
            let label = UILabel()
            label.text = "Maps"
            label.translatesAutoresizingMaskIntoConstraints = false
            label.font = UIFont.boldSystemFont(ofSize: 25)
            return label
        }()
        
        let newMapButton: UIButton =
        {
            let button: UIButton = UIButton(type: .roundedRect)
            button.layer.cornerRadius = 10
            button.layer.borderWidth = 2
            button.layer.shadowOffset = CGSize(width: 12.0, height: 12.0)
            button.layer.shadowColor = UIColor.black.cgColor
            button.layer.shadowOpacity = 0.8
            button.layer.shadowRadius = 12.0
            button.layer.borderColor = UIColor.black.cgColor
            button.setTitle("Add Map", for: UIControlState.normal)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.addTarget(self, action: #selector(addMap), for: .touchUpInside)
            
            return button
        }()
        
        
            headerView.addSubview(nameLabel)
            headerView.addSubview(newMapButton)
            headerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[v0]-8-[v1(80)]-8-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0": nameLabel, "v1": newMapButton]))
            headerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[v0]-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0": nameLabel]))
            headerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[v0]-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0": newMapButton]))
        
        return headerView
    }
    
    @objc func addMap()
    {
//        print("map button pressed in tableView!!!!")
        delegate?.addMap(buttonPressed: true)
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
    
    let nameLabel: UILabel =
    {
        let label = UILabel()
        label.text = "Sample Item"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 25)
        return label
    }()
    
    func setUpViews()
    {
        addSubview(nameLabel)
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[v0]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0": nameLabel]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0": nameLabel]))
    }
}
