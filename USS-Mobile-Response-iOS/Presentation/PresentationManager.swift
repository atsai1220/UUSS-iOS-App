//
//  PresentationManager.swift
//  USS-Mobile-Response-iOS
//
//  Created by Charlie Barber on 10/19/18.
//  Copyright © 2018 Andrew Tsai. All rights reserved.
//

import UIKit

enum PresentationType
{
    case save
    case settings
}

class PresentationManager: NSObject
{
    // MARK: - Properties
    var type = PresentationType.settings
}

extension PresentationManager: UIViewControllerTransitioningDelegate
{
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController?
    {
        return PresentationViewController(presentedViewController: presented, presenting: presenting, typeOfPresentation: type)
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning?
    {
        return PresentationAnimator(type: type, isPresentation: true)
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning?
    {
        return PresentationAnimator(type: type, isPresentation: false)
    }
}
