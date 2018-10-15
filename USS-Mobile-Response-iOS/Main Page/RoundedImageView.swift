//
//  RoundedImageView.swift
//  USS-Mobile-Response-iOS
//
//  Created by Charlie Barber on 10/3/18.
//  Copyright © 2018 Andrew Tsai. All rights reserved.
//

import UIKit

class RoundedImageView: UIButton
{
    override func layoutSubviews()
    {
        super.layoutSubviews()
        self.layer.cornerRadius = self.frame.size.width / 2
        self.clipsToBounds = true
    }
}
