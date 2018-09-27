//
//  FloatingButton.swift
//  USS-Mobile-Response-iOS
//
//  Created by Andrew Tsai on 9/26/18.
//  Copyright © 2018 Andrew Tsai. All rights reserved.
//

import UIKit

class FloatingButton: UIButton {
    
    var shadowLayer: CAShapeLayer!
    
    var menuIsExpanded: Bool = false {
        didSet {
            UIView.animate(withDuration: 0.25, delay: 0, options: .allowUserInteraction, animations: {
                if self.menuIsExpanded {
                    self.transform = self.transform.rotated(by: CGFloat(Double.pi / 4))
                } else {
                    self.transform = self.transform.rotated(by: -CGFloat(Double.pi / 4))
                }
            }, completion: nil)
        }
    }
    private struct Constants {
        static let plusLineWidth: CGFloat = 1.5
        static let plusButtonScale: CGFloat = 0.6
        static let halfPointShift: CGFloat = 0.5
    }
    
    private var halfWidth: CGFloat {
        return bounds.width / 2
    }
    
    private var halfHeight: CGFloat {
        return bounds.height / 2
    }

    override func draw(_ rect: CGRect) {
        let plusWidth: CGFloat = min(bounds.width, bounds.height) * Constants.plusButtonScale
        let halfPlusWidth = plusWidth / 2
        
        let plusPath = UIBezierPath()
        
        plusPath.lineWidth = Constants.plusLineWidth
        
        plusPath.move(to: CGPoint(x: halfWidth - halfPlusWidth + Constants.halfPointShift, y: halfHeight + Constants.halfPointShift))
        
        plusPath.addLine(to: CGPoint(x: halfWidth + halfPlusWidth + Constants.halfPointShift, y: halfHeight + Constants.halfPointShift))
        
        plusPath.move(to: CGPoint(
            x: halfWidth + Constants.halfPointShift,
            y: halfHeight - halfPlusWidth + Constants.halfPointShift))
        
        plusPath.addLine(to: CGPoint(
            x: halfWidth + Constants.halfPointShift,
            y: halfHeight + halfPlusWidth + Constants.halfPointShift))
        
        UIColor.blue.setStroke()
        
        plusPath.stroke()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setup()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        self.layer.cornerRadius = self.layer.frame.size.width / 2
        self.backgroundColor = UIColor.white
        self.layer.borderColor = UIColor.gray.cgColor
        self.layer.borderWidth = 2.0
        self.clipsToBounds = true
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.menuIsExpanded = !self.menuIsExpanded
    }
}

    

