//
//  LocalResourceTableViewCell.swift
//  USS-Mobile-Response-iOS
//
//  Created by Andrew Tsai on 10/8/18.
//  Copyright © 2018 Andrew Tsai. All rights reserved.
//

import UIKit

class LocalResourceTableViewCell: UITableViewCell {
    
    var resourceSet: Bool = false

    var cellLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textColor = UIColor.blue
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.preferredFont(forTextStyle: .caption1)
        label.textAlignment = .right
        return label
    }()
    
    let cellDivider: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.gray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var insertButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.lightGray
        button.layer.cornerRadius = 5
        button.clipsToBounds = true
        button.setTitle("Tap to select resource...", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    var resourceView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .center
        view.backgroundColor = UIColor.blue
        view.clipsToBounds = true
        view.layer.cornerRadius = 5
        return view
    }()
    
//    @objc private func showActionSheet(_ sender: UIButton) {
//        print("tapped")
//        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//        let navigationController = storyBoard.instantiateViewController(withIdentifier: "MainNavigationController") as! MainNavigationController
//        navigationController.showActionSheet()
//    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        addSubview(cellLabel)
        addSubview(cellDivider)
        addSubview(insertButton)
        
        
        if !resourceSet {
            NSLayoutConstraint.activate([
                cellLabel.topAnchor.constraint(equalTo: self.topAnchor),
                cellLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor),
                cellLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                cellLabel.widthAnchor.constraint(equalToConstant: 100),
                cellDivider.topAnchor.constraint(equalTo: self.topAnchor),
                cellDivider.bottomAnchor.constraint(equalTo: self.bottomAnchor),
                cellDivider.leadingAnchor.constraint(equalTo: cellLabel.trailingAnchor, constant: 8),
                cellDivider.widthAnchor.constraint(equalToConstant: 1),
                insertButton.topAnchor.constraint(equalTo: topAnchor, constant: 8),
                insertButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
                insertButton.leadingAnchor.constraint(equalTo: cellDivider.trailingAnchor, constant: 8),
                insertButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8)
                ])
        }
        else {
            insertButton.removeFromSuperview()
            addSubview(resourceView)
            
            NSLayoutConstraint.activate([
            cellLabel.topAnchor.constraint(equalTo: self.topAnchor),
            cellLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            cellLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            cellLabel.widthAnchor.constraint(equalToConstant: 100),
            cellDivider.topAnchor.constraint(equalTo: self.topAnchor),
            cellDivider.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            cellDivider.leadingAnchor.constraint(equalTo: cellLabel.trailingAnchor, constant: 8),
            cellDivider.widthAnchor.constraint(equalToConstant: 1),
        
            resourceView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            resourceView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            resourceView.leadingAnchor.constraint(equalTo: cellDivider.trailingAnchor, constant: 8),
            resourceView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
//            resourceView.heightAnchor.constraint(equalToConstant: 200),
        ])
    }
}
}
