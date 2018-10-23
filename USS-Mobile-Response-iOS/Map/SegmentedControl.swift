//
//  SegmentedControl.swift
//  USS-Mobile-Response-iOS
//
//  Created by Charlie Barber on 10/18/18.
//  Copyright © 2018 Andrew Tsai. All rights reserved.
//

import UIKit

extension UISegmentedControl
{
    func goVertical()
    {
        self.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2))
        for segment in self.subviews {
            for segmentSubview in segment.subviews {
                if segmentSubview is UILabel {
                    (segmentSubview as! UILabel).transform = CGAffineTransform(rotationAngle: CGFloat(-(Double.pi / 2)))
                }
            }
        }
    }

}
