//
//  MapTableViewController.swift
//  USS-Mobile-Response-iOS
//
//  Created by Charlie Barber on 8/10/18.
//  Copyright © 2018 Andrew Tsai. All rights reserved.
//

import UIKit

class MapTableViewController: UITableViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        tableView.register(TableCell.self, forCellReuseIdentifier: "cellId")
        tableView.register(TableHeader.self, forHeaderFooterViewReuseIdentifier: "headerId")
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
        return tableView.dequeueReusableHeaderFooterView(withIdentifier: "headerId")
    }
}

class TableHeader: UITableViewHeaderFooterView
{
    override init(reuseIdentifier: String?)
    {
        super.init(reuseIdentifier: reuseIdentifier)
        setUpViews()
    }

    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        var button: UIButton = UIButton(type: .system)
        button.setTitle("Add Map", for: UIControlState.normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    func setUpViews()
    {
        addSubview(nameLabel)
        addSubview(newMapButton)
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[v0]-8-[v1(80)]-8-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0": nameLabel, "v1": newMapButton]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0": nameLabel]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0": newMapButton]))
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
