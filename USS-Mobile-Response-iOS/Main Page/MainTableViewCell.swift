//
//  MainTableViewCell.swift
//  USS-Mobile-Response-iOS
//
//  Created by Andrew Tsai on 8/16/18.
//  Copyright © 2018 Andrew Tsai. All rights reserved.
//

import UIKit
import Foundation
import Photos
import MobileCoreServices

//class MainCellSetting: NSObject
//{
//    let name: String
//    let imageName: String
//    let fileType: String
//    let submissionStatus: String
//    let videoURL: String?
//
//    init(name: String, imageName: String, fileType: String, videoURL: String, submissionStatus: String)
//    {
//        self.name = name
//        self.imageName = imageName
//        self.fileType = fileType
//        self.videoURL = videoURL
//        self.submissionStatus = submissionStatus
//    }
//}


class MainTableViewCell: UITableViewCell {
    
    var setting: MainCellSetting?
    {
        didSet
        {
            switch setting?.fileType
            {
                case FileType.PHOTO.rawValue:
                    let localImage = getImageFromLocalEntriesDirectory(imageName: (setting?.imageName)!)
                    self.iconImageView.image = localImage
                    self.nameLabel.text = setting?.name
                case FileType.AUDIO.rawValue:
                    self.iconImageView.image = UIImage(named: "audio")
                    self.iconImageView.contentMode = .scaleAspectFit
                    self.nameLabel.text = setting?.name
                case FileType.VIDEO.rawValue:
//                    self.iconImageView.image = UIImage(named: "video")
                    self.iconImageView.image = createVideoThumbnail(from: setting!.videoURL!)
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
    
    var statusView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.blue
        return view
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
    
    func setupViews()
    {
        addSubview(self.nameLabel)
        addSubview(self.iconImageView)
        addSubview(statusView)
//        self.iconImageView.frame = CGRect(origin: CGPoint(x: 0, y: self.frame.midY), size: CGSize(width: 100, height: 100))
        addConstraintsWithFormat(format: "H:|-8-[v0(150)]-16-[v1][v2(5)]|", views: self.iconImageView, self.nameLabel, self.statusView)
        addConstraintsWithFormat(format: "V:|[v0]|", views: self.nameLabel)
        addConstraintsWithFormat(format: "V:|[v0]|", views: self.statusView)
        addConstraintsWithFormat(format: "V:|-[v0]-|", views: self.iconImageView)
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func createVideoThumbnail(from url: String) -> UIImage
    {
        print(URL(string: url)!)
        let asset = AVAsset(url: URL(string: url)!)
        let assetImgGenerate = AVAssetImageGenerator(asset: asset)
        assetImgGenerate.appliesPreferredTrackTransform = true
        
        let time = CMTimeMakeWithSeconds(1.0, 600)
        do {
            let img = try assetImgGenerate.copyCGImage(at: time, actualTime: nil)
            let thumbnail = UIImage(cgImage: img)
            return thumbnail
        }
        catch
        {
            print(error.localizedDescription)
            return UIImage()
        }
    }

}
