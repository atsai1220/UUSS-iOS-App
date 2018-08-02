//
//  ResourceTypeForm.swift
//  USS-Mobile-Response-iOS
//
//  Created by Andrew Tsai on 8/1/18.
//  Copyright © 2018 Andrew Tsai. All rights reserved.
//

import UIKit

class ResourceTypeForm: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    var hintLabel: UILabel = {
       let label = UILabel()
        label.text = "Choose a resource type:"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        return label
    }()
    
    var photoButton: UIButton = {
        let button = UIButton()
        button.setTitle("Photo", for: .normal)
        button.layer.borderColor = UIColor.blue.cgColor
        button.setTitleColor(UIColor.black, for: .normal)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 5
        return button
    }()
    
    var documentsButton: UIButton = {
        let button = UIButton()
        button.setTitle("Documents", for: .normal)
        button.layer.borderColor = UIColor.blue.cgColor
        button.setTitleColor(UIColor.black, for: .normal)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 5
        return button
    }()
    
    var videoButton: UIButton = {
        let button = UIButton()
        button.setTitle("Video", for: .normal)
        button.layer.borderColor = UIColor.blue.cgColor
        button.setTitleColor(UIColor.black, for: .normal)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 5
        return button
    }()
    
    var audioButton: UIButton = {
        let button = UIButton()
        button.setTitle("Audio", for: .normal)
        button.layer.borderColor = UIColor.blue.cgColor
        button.setTitleColor(UIColor.black, for: .normal)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 5
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
        backgroundColor = UIColor.white
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        
        addSubview(hintLabel)
        addSubview(photoButton)
        addSubview(documentsButton)
        addSubview(videoButton)
        addSubview(audioButton)
        
        addConstraintsWithFormat(format: "H:|-[v0]-|", views: hintLabel)
        addConstraintsWithFormat(format: "H:|-[v0]-|", views: photoButton)
        addConstraintsWithFormat(format: "H:|-[v0]-|", views: documentsButton)
        addConstraintsWithFormat(format: "H:|-[v0]-|", views: videoButton)
        addConstraintsWithFormat(format: "H:|-[v0]-|", views: audioButton)
        
        addConstraintsWithFormat(format: "V:|-[v0(<=80)]-[v1(==v4)]-[v2(==v4)]-[v3(==v4)]-[v4(>=50)]-|", views: hintLabel, photoButton, documentsButton, videoButton, audioButton)
        
        
        
//        addConstraintsWithFormat(format: "H:|-8-[v0(30)]-16-[v1]|", views: iconImageView, nameLabel)
//        addConstraintsWithFormat(format: "V:|[v0]|", views: nameLabel)
//        addConstraintsWithFormat(format: "V:[v0(30)]", views: iconImageView)
        let photoButtonXConstraint = NSLayoutConstraint(item: photoButton, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0)
        photoButtonXConstraint.isActive = true
    }
    

}
