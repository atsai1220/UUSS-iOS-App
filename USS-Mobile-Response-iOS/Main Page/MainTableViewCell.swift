//
//  MainTableViewCell.swift
//  USS-Mobile-Response-iOS
//
//  Created by Andrew Tsai on 8/16/18.
//  Copyright © 2018 Andrew Tsai. All rights reserved.
//

import UIKit

class MainCellSetting: NSObject {
    let name: String
    let imageURL: String
    
    init(name: String, imageName: String) {
        self.name = name
        self.imageURL = imageName
    }
}

class MainTableViewCell: UITableViewCell {
    
    var setting: MainCellSetting? {
        didSet {
            self.nameLabel.text = setting?.name
            self.iconImageView.image = UIImage(named: (setting?.imageURL)!)
        }
    }
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        return label
    }()
    
    let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setupViews() {
        addSubview(self.nameLabel)
        addSubview(self.iconImageView)
        
        addConstraintsWithFormat(format: "H:|-8-[v0(30)]-16-[v1]|", views: self.iconImageView, self.nameLabel)
        addConstraintsWithFormat(format: "V:|[v0]|", views: self.nameLabel)
        addConstraintsWithFormat(format: "V:[v0(30)]", views: self.iconImageView)
        addConstraint(NSLayoutConstraint(item: iconImageView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    

}
