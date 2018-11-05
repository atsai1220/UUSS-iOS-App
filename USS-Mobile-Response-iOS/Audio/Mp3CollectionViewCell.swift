//
//  Mp3CCollectionViewCell.swift
//  USS-Mobile-Response-iOS
//
//  Created by Andrew Tsai on 10/24/18.
//  Copyright © 2018 Andrew Tsai. All rights reserved.
//

import UIKit



class Mp3CollectionViewCell: UICollectionViewCell {
    weak var cellHoldDelegate: CellHoldDelegate?
    weak var deleteCellDelegate: DeleteCellDelegate?
    var showDeleteButton: Bool = false
    var indexPath: IndexPath?
    
    var mp3ImageView: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.image = UIImage(named: "audio")
        return image
    }()
    
    var mp3Title: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        return label
    }()
    
    var deleteButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.clipsToBounds = true
        button.layer.cornerRadius = 15
        button.alpha = 0.0
        button.backgroundColor = .red
        button.setImage(UIImage(named: "minus"), for: .normal)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        self.layer.cornerRadius = 5.0
        self.layer.shadowRadius = 3.0
        self.layer.shadowOffset = CGSize(width: 5.0, height: 5.0)
        self.layer.shadowRadius = 5.0
        self.layer.shadowOpacity = 0.8
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.masksToBounds = false
        setupView()
        
        let holdGestureRecognizer: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(cellTouched))
        holdGestureRecognizer.minimumPressDuration = 1.0
        addGestureRecognizer(holdGestureRecognizer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        addSubview(mp3ImageView)
        addSubview(mp3Title)
        
        if showDeleteButton {
            addSubview(deleteButton)
            
            UIView.animate(withDuration: 0.2, animations: {
                self.deleteButton.alpha = 1.0
            })
            
            NSLayoutConstraint.activate([
                deleteButton.topAnchor.constraint(equalTo: self.topAnchor, constant: -10),
                deleteButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: -10),
                deleteButton.heightAnchor.constraint(equalToConstant: 30),
                deleteButton.widthAnchor.constraint(equalToConstant: 30)
                ])
            
            deleteButton.addTarget(self, action: #selector(deleteCell), for: .touchUpInside)
        }
        else {
            UIView.animate(withDuration: 0.2, animations: { self.deleteButton.alpha = 0.0 })
            deleteButton.removeFromSuperview()
        }
        
        NSLayoutConstraint.activate([
            mp3ImageView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.9),
            mp3ImageView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.1),
            mp3ImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
            mp3Title.topAnchor.constraint(equalTo: self.topAnchor, constant: 5),
            mp3Title.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5),
            mp3Title.leadingAnchor.constraint(equalTo: mp3ImageView.trailingAnchor, constant: 10),
            mp3Title.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10)
            ])
    }
    
    @objc func cellTouched() {
        Mp3CollectionViewController.inDeleteMode = true
        cellHoldDelegate!.reloadTable()
    }
    
    @objc func deleteCell() {
        deleteCellDelegate!.deleteCell(indexPath: self.indexPath!)
    }
}
