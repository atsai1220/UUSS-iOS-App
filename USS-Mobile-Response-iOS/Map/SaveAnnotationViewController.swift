//
//  SaveAnnotationViewController.swift
//  USS-Mobile-Response-iOS
//
//  Created by Charlie Barber on 10/22/18.
//  Copyright © 2018 Andrew Tsai. All rights reserved.
//

import UIKit

protocol CloseSaveAnnotationDelegate: class
{
    func closeView(_: Bool)
}

protocol SaveDelegate: class
{
    func saveAnnotationToFavorites(_: Bool)
}

class SaveAnnotationViewController: UIViewController
{
    weak var closeSaveAnnotationDelegate: CloseSaveAnnotationDelegate?
    weak var saveDelegate: SaveDelegate?
    
    var titleLabel: UILabel =
    {
        var label: UILabel = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Place Title"
        label.font = UIFont.systemFont(ofSize: 20.0, weight: .bold)
        
        return label
    }()
    
    var addressLabel: UILabel =
    {
        var label: UILabel = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Address"
        label.font = UIFont.systemFont(ofSize: 15.0, weight: .bold)
        
        return label
    }()
    
    var streetLabel: UILabel =
    {
        var label: UILabel = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "4119 N. Edgewood Dr"
        label.font = UIFont.systemFont(ofSize: 15.0)
        
        return label
    }()
    
    var cityLabel: UILabel =
    {
        var label: UILabel = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Provo, Utah 84604"
        label.font = UIFont.systemFont(ofSize: 15.0)
        
        return label
    }()
    
    var countryLabel: UILabel =
    {
        var label: UILabel = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "United States"
        label.font = UIFont.systemFont(ofSize: 15.0)
        
        return label
    }()
    
    var distanceLabel: UILabel =
    {
        var label: UILabel = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "1.2 mi"
        label.font = UIFont.systemFont(ofSize: 15.0)
        
        return label
    }()
    
    var closeButton: UIButton =
    {
        var button: UIButton = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "close"), for: .normal)
        button.layer.cornerRadius = button.frame.width / 2
        
        return button
    }()
    
    var saveToFavoritesButton: UIButton =
    {
        var button: UIButton = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1.0)
        button.tintColor = .white
        button.setTitle("Save to Favorites", for: .normal)
        button.titleLabel!.font = UIFont.systemFont(ofSize: 15.0, weight: .bold)
        button.layer.cornerRadius = 10
        
        return button
    }()
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.layer.cornerRadius = 15
        
        closeButton.addTarget(self, action: #selector(closeView), for: .touchUpInside)
        
        view.addSubview(titleLabel)
        view.addSubview(closeButton)
        view.addSubview(distanceLabel)
        view.addSubview(saveToFavoritesButton)
        view.addSubview(addressLabel)
        view.addSubview(streetLabel)
        view.addSubview(cityLabel)
        view.addSubview(countryLabel)
        
        saveToFavoritesButton.addTarget(self, action: #selector(saveMap), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 25.0),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15.0),
            titleLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 150.0),
            closeButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 22.0),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15.0),
            closeButton.heightAnchor.constraint(equalToConstant: 27.0),
            closeButton.widthAnchor.constraint(equalToConstant: 27.0),
            distanceLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2.0),
            distanceLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            distanceLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 100.0),
            saveToFavoritesButton.topAnchor.constraint(equalTo: distanceLabel.bottomAnchor, constant: 20.0),
            saveToFavoritesButton.heightAnchor.constraint(equalToConstant: 50.0),
            saveToFavoritesButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            saveToFavoritesButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addressLabel.topAnchor.constraint(equalTo: saveToFavoritesButton.bottomAnchor, constant: 20.0),
            addressLabel.leadingAnchor.constraint(equalTo: saveToFavoritesButton.leadingAnchor, constant: 1.0),
            addressLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 100.0),
            streetLabel.topAnchor.constraint(equalTo: addressLabel.bottomAnchor, constant: 2.0),
            streetLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 100.0),
            streetLabel.leadingAnchor.constraint(equalTo: addressLabel.leadingAnchor, constant: 1.0),
            cityLabel.topAnchor.constraint(equalTo: streetLabel.bottomAnchor, constant: 2.0),
            cityLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 100.0),
            cityLabel.leadingAnchor.constraint(equalTo: streetLabel.leadingAnchor, constant: 1.0),
            countryLabel.topAnchor.constraint(equalTo: cityLabel.bottomAnchor, constant: 2.0),
            countryLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 100.0),
            countryLabel.leadingAnchor.constraint(equalTo: cityLabel.leadingAnchor, constant: 1.0)
            ])
    }
    
    @objc func closeView()
    {
        closeSaveAnnotationDelegate!.closeView(true)
    }
    
    @objc func saveMap()
    {
        saveDelegate!.saveAnnotationToFavorites(true)
    }
}
