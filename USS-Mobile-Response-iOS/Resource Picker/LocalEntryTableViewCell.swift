//
//  LocalEntryTableViewCell.swift
//  USS-Mobile-Response-iOS
//
//  Created by Andrew Tsai on 10/5/18.
//  Copyright © 2018 Andrew Tsai. All rights reserved.
//

import UIKit

//class LocalEntryCellSetting: NSObject {
//    let labelName: String
//    let width: CGFloat
//
//    init(labelName: String, width: CGFloat) {
//        self.labelName = labelName
//        self.width = width
//    }
//}

class LocalEntryTableViewCell: UITableViewCell, UITextViewDelegate {
    
//    var setting: LocalEntryCellSetting? {
//        didSet {
//
//        }
//    }
    
    var cellLabel: UILabel = {
        let label = UILabel()
        label.text = ""
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
    
    var textView: UITextView = {
        let text = UITextView()
        text.translatesAutoresizingMaskIntoConstraints = false
        text.isScrollEnabled = false
        text.layer.borderWidth = 0
        return text
    }()
    
    var tableView: UITableView? {
        get {
            var table: UIView? = superview
            while !(table is UITableView) && table != nil {
                table = table?.superview
            }
            return table as? UITableView
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        addSubview(cellLabel)
        addSubview(cellDivider)
        addSubview(textView)
        
        NSLayoutConstraint.activate([
            cellLabel.topAnchor.constraint(equalTo: self.topAnchor),
            cellLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            cellLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            cellLabel.widthAnchor.constraint(equalToConstant: 100),
            cellDivider.topAnchor.constraint(equalTo: self.topAnchor),
            cellDivider.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            cellDivider.leadingAnchor.constraint(equalTo: cellLabel.trailingAnchor, constant: 8),
            cellDivider.widthAnchor.constraint(equalToConstant: 1),
            textView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            textView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            textView.leadingAnchor.constraint(equalTo: cellDivider.trailingAnchor, constant: 8),
            textView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8)
            ])
    }

}
