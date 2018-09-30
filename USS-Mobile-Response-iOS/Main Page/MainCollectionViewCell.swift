//
//  MainCollectionViewCell.swift
//  USS-Mobile-Response-iOS
//
//  Created by Andrew Tsai on 9/29/18.
//  Copyright © 2018 Andrew Tsai. All rights reserved.
//

import UIKit

class MainCellSetting: NSObject
{
    let name: String
    let imageName: String
    let fileType: String
    let submissionStatus: String
    let videoURL: String?
    
    init(name: String, imageName: String, fileType: String, videoURL: String, submissionStatus: String)
    {
        self.name = name
        self.imageName = imageName
        self.fileType = fileType
        self.videoURL = videoURL
        self.submissionStatus = submissionStatus
    }
}

class MainCollectionViewCell: UICollectionViewCell {
    var setting: MainCellSetting?
    {
        didSet
        {
            switch setting?.fileType
            {
            case FileType.PHOTO.rawValue:
                let localImage = getImageFromDocumentDirectory(imageName: (setting?.imageName)!)
                self.iconImageView.image = localImage
                self.nameLabel.text = setting?.name
            case FileType.AUDIO.rawValue:
                self.iconImageView.image = UIImage(named: "audio")
                self.iconImageView.contentMode = .scaleAspectFit
                self.nameLabel.text = setting?.name
            case FileType.VIDEO.rawValue:
                //                    self.iconImageView.image = UIImage(named: "video")
//                self.iconImageView.image = createVideoThumbnail(from: setting!.videoURL!)
                self.nameLabel.text = setting?.name
            default:
                self.iconImageView.image = nil
                self.nameLabel.text = ""
            }
            
            switch setting?.submissionStatus {
            case SubmissionStatus.LocalOnly.rawValue:
                self.statusView.backgroundColor = UIColor(red: 0, green: 0.5, blue: 0.7, alpha: 0.5)
            case SubmissionStatus.SuccessfulUpload.rawValue:
                self.statusView.backgroundColor = UIColor(red: 0, green: 0.7, blue: 0, alpha: 0.5)
            case SubmissionStatus.ErrorUpload.rawValue:
                self.statusView.backgroundColor = UIColor(red: 0.7, green: 0, blue: 0, alpha: 0.5)
            default:
                print("should never happen")
            }
        }
    }
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage()
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 5
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    var statusView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.blue
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.white
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        addSubview(nameLabel)
        addSubview(iconImageView)
        addSubview(statusView)
        
        NSLayoutConstraint.activate([
            iconImageView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            iconImageView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.6),
            iconImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            iconImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            nameLabel.topAnchor.constraintLessThanOrEqualToSystemSpacingBelow(iconImageView.bottomAnchor, multiplier: 1.0),
            nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            nameLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            statusView.topAnchor.constraintLessThanOrEqualToSystemSpacingBelow(iconImageView.bottomAnchor, multiplier: 1.0),
            statusView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            statusView.trailingAnchor.constraint(equalTo: nameLabel.leadingAnchor, constant: -10),
            statusView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            statusView.widthAnchor.constraint(equalToConstant: 10)
            ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.layer.cornerRadius = 5.0
        contentView.layer.borderWidth = 1.0
        contentView.layer.borderColor = UIColor.clear.cgColor
        contentView.layer.masksToBounds = false
        layer.shadowColor = UIColor.lightGray.cgColor
        layer.shadowOffset = CGSize(width: 5, height: 5)
        layer.shadowRadius = 4.0
        layer.shadowOpacity = 0.8
        layer.masksToBounds = false
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: contentView.layer.cornerRadius).cgPath
    }
}
