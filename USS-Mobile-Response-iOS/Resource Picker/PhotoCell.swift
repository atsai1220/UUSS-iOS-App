//
//  PhotoCell.swift
//  USS-Mobile-Response-iOS
//
//  Created by Andrew Tsai on 8/2/18.
//  Copyright © 2018 Andrew Tsai. All rights reserved.
//

import UIKit

class PhotoCell: UICollectionViewCell {
    
    var iconImageView: UIImageView = {
       let imageView = UIImageView()
        imageView.image = UIImage(named: "item_add")
        imageView.contentMode = .center
        imageView.clipsToBounds = true
        return imageView
    }()
    
//    var setting: PhotoObj? {
//        didSet {
//            if let image = setting?.imageName {
//                iconImageView.image = image
//            }
//        }
//    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        addSubview(iconImageView)
        addConstraintsWithFormat(format: "H:|[v0]|", views: iconImageView)
        addConstraintsWithFormat(format: "V:|[v0]|", views: iconImageView)
        addConstraint(NSLayoutConstraint(item: iconImageView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
    }
}
