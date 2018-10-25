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

protocol MainCellDelegate {
    func deleteThis(cellIndexPath: IndexPath)
}

class MainCollectionViewCell: UICollectionViewCell {
    
    var delegate: MainCellDelegate?
    var cellIndexPath: IndexPath?
    var isEditing = false
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
                var imageName = NSURL(fileURLWithPath: (setting?.imageName)!).deletingPathExtension?.lastPathComponent ?? ""
                imageName += ".jpeg"
                let localImage = getImageFromDocumentDirectory(imageName: imageName)
                self.iconImageView.image = localImage
                self.nameLabel.text = setting?.name
            default:
                self.iconImageView.image = nil
                self.nameLabel.text = ""
            }
            
            switch setting?.submissionStatus
            {
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
    
    var deleteViewButton: UIButton = {
       let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.clipsToBounds = true
        button.layer.cornerRadius = 15
        button.alpha = 0.0
        button.backgroundColor = UIColor.red
        button.setImage(UIImage(named: "minus"), for: .normal)
        return button
    }()
    
//    let deleteViewIcon: RoundedImageView =
//    {
//        let icon: RoundedImageView = RoundedImageView()
//        icon.translatesAutoresizingMaskIntoConstraints = false
//        icon.layer.cornerRadius = self.frame.size.width / 2
//        icon.backgroundColor = UIColor.red
//        icon.alpha = 0.0
//        icon.image = UIImage(named: "minus")
//        return icon
//    }()
    
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
    
    var editView: UIImageView =
    {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "edit")
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(editTapped))
        imageView.addGestureRecognizer(tapGesture)
        return imageView
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
//        addSubview(editView)
        
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
        layer.shadowRadius = 3.0
        layer.shadowOpacity = 0.8
        layer.masksToBounds = false
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: contentView.layer.cornerRadius).cgPath
    }
    
    @objc func editTapped()
    {
        print("edit tapped")
    }
    
    func showDeleteButton() {
        if let superView = self.superview {
            if !deleteViewButton.isDescendant(of: superView) {
                
                addSubview(deleteViewButton)
                UIView.animate(withDuration: 0.3) {
                    self.deleteViewButton.alpha = 1.0
                }
                deleteViewButton.topAnchor.constraint(equalTo: topAnchor, constant: -10.0).isActive = true
                deleteViewButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: -10.0).isActive = true
                deleteViewButton.heightAnchor.constraint(equalToConstant: 30.0).isActive = true
                deleteViewButton.widthAnchor.constraint(equalToConstant: 30.0).isActive = true
                deleteViewButton.addTarget(self, action: #selector(deleteThis), for: .touchUpInside)
            }
        }

    }
    
    func hideDeleteButton() {
        if let superView = self.superview {
            if deleteViewButton.isDescendant(of: superView) {
                UIView.animate(withDuration: 0.3, animations: { self.deleteViewButton.alpha = 0.0 })
                deleteViewButton.removeFromSuperview()
            }
        }
    }
    
    func toggleDeleteButtion() {
        if !deleteViewButton.isDescendant(of: self.superview!) {
//            let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(deleteThis))
//            deleteViewIcon.addGestureRecognizer(tapGesture)
            
            addSubview(deleteViewButton)
            UIView.animate(withDuration: 0.3) {
                self.deleteViewButton.alpha = 1.0
            }
            deleteViewButton.topAnchor.constraint(equalTo: topAnchor, constant: -10.0).isActive = true
            deleteViewButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: -10.0).isActive = true
            deleteViewButton.heightAnchor.constraint(equalToConstant: 30.0).isActive = true
            deleteViewButton.widthAnchor.constraint(equalToConstant: 30.0).isActive = true
            deleteViewButton.addTarget(self, action: #selector(deleteThis), for: .touchUpInside)
        } else {
            UIView.animate(withDuration: 0.3, animations: {
                self.deleteViewButton.alpha = 0.0
            }) { (done) in
                if done {
                    self.deleteViewButton.removeFromSuperview()
                }
            }
        }
    }
    
    @objc func deleteThis() {
        print("delete this")
        delegate?.deleteThis(cellIndexPath: self.cellIndexPath!)
    }
}
