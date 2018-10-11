//
//  LocalResourceTypeTableViewCell.swift
//  USS-Mobile-Response-iOS
//
//  Created by Andrew Tsai on 10/8/18.
//  Copyright © 2018 Andrew Tsai. All rights reserved.
//

import UIKit

class LocalResourceTypeTableViewCell: UITableViewCell {
    
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
    
    var segmentController: UISegmentedControl = {
        let items = ["Photo", "Video", "Audio", "PDF"]
        let segments = UISegmentedControl(items: items)
        segments.selectedSegmentIndex = 0
        segments.translatesAutoresizingMaskIntoConstraints = false
        segments.addTarget(self, action: #selector(changeMode), for: .valueChanged)
        return segments
    }()
    
    @objc func changeMode(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 1:
            print("VideosInside")
        case 2:
            print("AudioInside")
        case 3:
            print("PDFInside")
        default:
            print("PhotosInside")
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        addSubview(cellLabel)
        addSubview(cellDivider)
        addSubview(segmentController)
        
        NSLayoutConstraint.activate([
            cellLabel.topAnchor.constraint(equalTo: self.topAnchor),
            cellLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            cellLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            cellLabel.widthAnchor.constraint(equalToConstant: 100),
            cellDivider.topAnchor.constraint(equalTo: self.topAnchor),
            cellDivider.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            cellDivider.leadingAnchor.constraint(equalTo: cellLabel.trailingAnchor, constant: 8),
            cellDivider.widthAnchor.constraint(equalToConstant: 1),
            segmentController.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            segmentController.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            segmentController.leadingAnchor.constraint(equalTo: cellDivider.trailingAnchor, constant: 8),
            segmentController.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
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
