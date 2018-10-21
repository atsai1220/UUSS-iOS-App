//
//  AlternativeTableViewCell.swift
//  USS-Mobile-Response-iOS
//
//  Created by Andrew Tsai on 10/19/18.
//  Copyright © 2018 Andrew Tsai. All rights reserved.
//

import UIKit

class AlternativeTableViewCell: UITableViewCell {
    
    var cellLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textColor = UIColor.black
        label.translatesAutoresizingMaskIntoConstraints = false
        label.lineBreakMode = .byTruncatingTail
        label.textAlignment = .left
        return label
    }()
    
    var altImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 5
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    var fileLabel: UILabel = {
       let label = UILabel()
        label.textColor = UIColor.gray
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        return label
    }()
    
    var infoButton: UIButton = {
       let button = UIButton(type: UIButtonType.infoLight)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        addSubview(altImageView)
        addSubview(fileLabel)
        addSubview(infoButton)
        
        NSLayoutConstraint.activate([
            altImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
            altImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            altImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10),
            altImageView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.20),
            altImageView.trailingAnchor.constraint(equalTo: cellLabel.leadingAnchor, constant: -10),
            altImageView.trailingAnchor.constraint(equalTo: fileLabel.leadingAnchor, constant: -10),
            cellLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
            cellLabel.trailingAnchor.constraint(equalTo: infoButton.leadingAnchor, constant: -10),
            fileLabel.topAnchor.constraint(equalTo: cellLabel.bottomAnchor, constant: 5),
            infoButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            infoButton.centerYAnchor.constraint(equalTo: self.centerYAnchor)])


    }

}
