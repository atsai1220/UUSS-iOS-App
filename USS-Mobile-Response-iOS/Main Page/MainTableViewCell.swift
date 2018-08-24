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
    let imageName: String
    
    init(name: String, imageName: String) {
        self.name = name
        self.imageName = imageName
    }
}

class MainTableViewCell: UITableViewCell {
    
    var setting: MainCellSetting? {
        didSet {
            let localImage = getImageFromDocumentDirectory(imageName: (setting?.imageName)!)
            self.iconImageView.image = localImage
            self.nameLabel.text = setting?.name
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
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 5
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
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
//        self.iconImageView.frame = CGRect(origin: CGPoint(x: 0, y: self.frame.midY), size: CGSize(width: 100, height: 100))
        addConstraintsWithFormat(format: "H:|-8-[v0(150)]-16-[v1]|", views: self.iconImageView, self.nameLabel)
        addConstraintsWithFormat(format: "V:|[v0]|", views: self.nameLabel)
        addConstraintsWithFormat(format: "V:|-[v0]-|", views: self.iconImageView)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    
    

}
