//
//  PresentationManager.swift
//  USS-Mobile-Response-iOS
//
//  Created by Charlie Barber on 10/19/18.
//  Copyright © 2018 Andrew Tsai. All rights reserved.
//

import UIKit

enum PresentationDirection
{
    case bottom
}

class PresentationManager: NSObject
{
    // MARK: - Properties
    var direction = PresentationDirection.bottom
    var type: String = ""
}

extension PresentationManager: UIViewControllerTransitioningDelegate
{
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController?
    {
        return PresentationViewController(presentedViewController: presented, presenting: presenting, typeOfView: type)
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning?
    {
        return PresentationAnimator(direction: direction, isPresentation: true)
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning?
    {
        return PresentationAnimator(direction: direction, isPresentation: false)
    }
}
