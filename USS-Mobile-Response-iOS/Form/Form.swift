//
//  Form.swift
//  USS-Mobile-Response-iOS
//
//  Created by Charlie Barber on 7/25/18.
//  Copyright © 2018 Andrew Tsai. All rights reserved.
//

import Foundation
import UIKit

//protocol FormViewDelegate: class
//{
//    func viewSwiped(with direction: String)
//}

class FormView: UIView
{
    var page: UIView?
    var color: UIColor?
    var swipeLeftGestureRecognizer: UISwipeGestureRecognizer?
    var swipeRightGestureRecognizer: UISwipeGestureRecognizer?
//    weak var delegate: FormViewDelegate? = nil
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        page = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.frame.width, height: self.frame.height))
        
        //Create a gesture recognizer and add it to the view to recognize swiping left
        swipeLeftGestureRecognizer = UISwipeGestureRecognizer()
        swipeLeftGestureRecognizer!.direction = .left
        swipeLeftGestureRecognizer!.addTarget(self, action: #selector(viewSwipedLeft))
        self.addGestureRecognizer(swipeLeftGestureRecognizer!)
        
        //Create a gesture recognizer and add it to the view to recognize swiping right
        swipeRightGestureRecognizer = UISwipeGestureRecognizer()
        swipeRightGestureRecognizer!.direction = .right
        swipeRightGestureRecognizer!.addTarget(self, action: #selector(viewSwipedRight))
        self.addGestureRecognizer(swipeRightGestureRecognizer!)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect)
    {
        super.draw(rect)
        page?.backgroundColor = color
        addSubview(page!)
    }
    
    func setColor(newColor: UIColor)
    {
        self.color = newColor
    }
    
    @objc func viewSwipedLeft()
    {
        print("View Swiped Left!!")
//        delegate?.viewSwiped(with: "left")
    }
    
    @objc func viewSwipedRight()
    {
        print("View Swiped Right!")
//        delegate?.viewSwiped(with: "Right")
    }
}
