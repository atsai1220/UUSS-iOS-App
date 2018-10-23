//
//  MapSettingsViewController.swift
//  USS-Mobile-Response-iOS
//
//  Created by Charlie Barber on 10/19/18.
//  Copyright © 2018 Andrew Tsai. All rights reserved.
//

import UIKit

protocol CloseSettingsDelegate: class
{
    func closeSettings(_: Bool)
}

protocol SelectorDelegate: class
{
    func itemSelected(with index: Int)
}
class MapSettingsViewController: UIViewController
{
    weak var closeSettingsDelegate: CloseSettingsDelegate?
    weak var selectorDelegate: SelectorDelegate?
    
    var titleLibel: UILabel =
    {
        var label: UILabel = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Maps Settings"
        label.font = UIFont.systemFont(ofSize: 20.0, weight: .bold)
        
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
    
    var segmentedControl: UISegmentedControl =
    {
        var control: UISegmentedControl = UISegmentedControl(items: ["Map", "Satellite"])
        control.translatesAutoresizingMaskIntoConstraints = false
        control.backgroundColor = UIColor(red: 245, green: 245, blue: 245, alpha: 0.9)
        control.layer.cornerRadius = 5
        
        return control
    }()
    
    let separator: UIView =
    {
        var view: UIView = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
        
        return view
    }()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.layer.cornerRadius = 15
        
        closeButton.addTarget(self, action: #selector(closeSettings), for: .touchUpInside)
        
        view.addSubview(titleLibel)
        view.addSubview(closeButton)
        view.addSubview(segmentedControl)
        segmentedControl.addTarget(self, action: #selector(handleSelection), for: .valueChanged)
        
        NSLayoutConstraint.activate([
            titleLibel.topAnchor.constraint(equalTo: view.topAnchor, constant: 25.0),
            titleLibel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15.0),
            titleLibel.widthAnchor.constraint(equalToConstant: 150.0),
            closeButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 22.0),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15.0),
            closeButton.heightAnchor.constraint(equalToConstant: 27.0),
            closeButton.widthAnchor.constraint(equalToConstant: 27.0),
            segmentedControl.topAnchor.constraint(equalTo: titleLibel.bottomAnchor, constant: 30.0),
            segmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            segmentedControl.leadingAnchor.constraint(equalTo: titleLibel.leadingAnchor),
            segmentedControl.trailingAnchor.constraint(equalTo: closeButton.trailingAnchor),
            ])
    }
    
    @objc func closeSettings()
    {
        closeSettingsDelegate?.closeSettings(true)
    }
    
    @objc func handleSelection()
    {
        selectorDelegate?.itemSelected(with: segmentedControl.selectedSegmentIndex)
    }
}
