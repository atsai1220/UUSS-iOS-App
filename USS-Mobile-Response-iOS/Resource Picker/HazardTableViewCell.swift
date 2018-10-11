//
//  HazardTableViewCell.swift
//  USS-Mobile-Response-iOS
//
//  Created by Andrew Tsai on 10/9/18.
//  Copyright © 2018 Andrew Tsai. All rights reserved.
//

import UIKit

class HazardTableViewCell: UITableViewCell {
    
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
    
    var hazardButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.lightGray
        button.layer.cornerRadius = 5
        button.clipsToBounds = true
        button.setTitle("Tap to select hazard...", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.invalidateIntrinsicContentSize()
        return button
    }()
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        addSubview(cellLabel)
        addSubview(cellDivider)
        addSubview(hazardButton)
        
        NSLayoutConstraint.activate([
            cellLabel.topAnchor.constraint(equalTo: self.topAnchor),
            cellLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            cellLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            cellLabel.widthAnchor.constraint(equalToConstant: 100),
            cellDivider.topAnchor.constraint(equalTo: self.topAnchor),
            cellDivider.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            cellDivider.leadingAnchor.constraint(equalTo: cellLabel.trailingAnchor, constant: 8),
            cellDivider.widthAnchor.constraint(equalToConstant: 1),
            hazardButton.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            hazardButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            hazardButton.leadingAnchor.constraint(equalTo: cellDivider.trailingAnchor, constant: 8),
            hazardButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            ])
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
