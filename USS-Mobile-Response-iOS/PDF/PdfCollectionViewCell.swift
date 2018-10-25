//
//  PdfCollectionViewCell.swift
//  USS-Mobile-Response-iOS
//
//  Created by Andrew Tsai on 10/24/18.
//  Copyright © 2018 Andrew Tsai. All rights reserved.
//
import UIKit
import PDFKit

protocol CellHoldDelegate: class
{
    func reloadTable()
}
protocol DeleteCellDelegate: class
{
    func deleteCell(indexPath: IndexPath)
}

class PdfCollectionViewCell: UICollectionViewCell {
    weak var cellHoldDelegate: CellHoldDelegate?
    weak var deleteCellDelegate: DeleteCellDelegate?
    var showDeleteButton: Bool = false
    var indexPath: IndexPath?
    
    var pdfImage: PDFView =
    {
        var pdf: PDFView = PDFView()
        pdf.isUserInteractionEnabled = false
        pdf.translatesAutoresizingMaskIntoConstraints = false
        pdf.autoScales = true
        pdf.displayMode = .singlePage
        pdf.layer.borderWidth = 0.2
        pdf.layer.borderColor = UIColor.black.cgColor
        
        return pdf
    }()
    
    var pdfTitle: UILabel =
    {
        var label: UILabel = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "title"
        label.textAlignment = .center
        return label
    }()
    
    var deleteViewButton: UIButton =
    {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.clipsToBounds = true
        button.layer.cornerRadius = 15
        button.alpha = 0.0
        button.backgroundColor = .red
        button.setImage(UIImage(named: "minus"), for: .normal)
        return button
    }()
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        self.backgroundColor = .white
        self.layer.cornerRadius = 5.0
        self.layer.shadowRadius = 3.0
        self.layer.shadowOffset = CGSize(width: 5.0, height: 5.0)
        self.layer.shadowRadius = 5.0
        self.layer.shadowOpacity = 0.8
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.lightGray.cgColor
        setUpView()
        
        let holdGestureRecognizer: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(cellTouched))
        holdGestureRecognizer.minimumPressDuration = 1.0
        addGestureRecognizer(holdGestureRecognizer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpView()
    {
        addSubview(pdfImage)
        addSubview(pdfTitle)
        if(showDeleteButton)
        {
            addSubview(deleteViewButton)
            
            UIView.animate(withDuration: 0.2, delay: 0.1, options: .curveEaseInOut, animations: { self.deleteViewButton.alpha = 1.0}, completion: nil)
            
            NSLayoutConstraint.activate([
                deleteViewButton.topAnchor.constraint(equalTo: self.topAnchor, constant: -10.0),
                deleteViewButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: -10.0),
                deleteViewButton.heightAnchor.constraint(equalToConstant: 30.0),
                deleteViewButton.widthAnchor.constraint(equalToConstant: 30.0)
                ])
            deleteViewButton.addTarget(self, action: #selector(deleteCell), for: .touchUpInside)
        }
        else
        {
            UIView.animate(withDuration: 0.2, delay: 0.1, options: .curveEaseInOut, animations: { self.deleteViewButton.alpha = 0.0}, completion: nil)
            deleteViewButton.removeFromSuperview()
        }
        
        NSLayoutConstraint.activate([
            pdfImage.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.7),
            pdfImage.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.9),
            pdfImage.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            pdfImage.topAnchor.constraint(equalTo: self.topAnchor, constant: 10.0),
            pdfTitle.topAnchor.constraint(equalTo: pdfImage.bottomAnchor, constant: 5.0),
            pdfTitle.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.9),
            pdfTitle.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5.0),
            pdfTitle.centerXAnchor.constraint(equalTo: self.centerXAnchor)
            ])
    }
    
    @objc func cellTouched()
    {
        PdfCollectionViewController.inDeleteMode = true
        cellHoldDelegate!.reloadTable()
    }
    
    @objc func deleteCell()
    {
        deleteCellDelegate?.deleteCell(indexPath: self.indexPath!)
    }
}
