//
//  PresentationAnimator.swift
//  USS-Mobile-Response-iOS
//
//  Created by Charlie Barber on 10/19/18.
//  Copyright © 2018 Andrew Tsai. All rights reserved.
//

import UIKit

class PresentationAnimator: NSObject
{
    // MARK: - Properties
    let type: PresentationType
    let isPresentation: Bool
    
    // MARK: - Initializers
    init(type: PresentationType, isPresentation: Bool)
    {
        self.type = type
        self.isPresentation = isPresentation
        super.init()
    }
}

extension PresentationAnimator: UIViewControllerAnimatedTransitioning
{
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval
    {
        return 0.3
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning)
    {
        let key = isPresentation ? UITransitionContextViewControllerKey.to : UITransitionContextViewControllerKey.from
        let controller = transitionContext.viewController(forKey: key)!
        
        if isPresentation
        {
            transitionContext.containerView.addSubview(controller.view)
        }
        
        let presentedFrame = transitionContext.finalFrame(for: controller)
        var dismissedFrame = presentedFrame
        switch type
        {
            case .save, .settings:
                dismissedFrame.origin.y = transitionContext.containerView.frame.size.height
        }
        
        let initialFrame = isPresentation ? dismissedFrame : presentedFrame
        let finalFrame = isPresentation ? presentedFrame : dismissedFrame
        
        let animationDuration = transitionDuration(using: transitionContext)
        controller.view.frame = initialFrame
        UIView.animate(withDuration: animationDuration, animations:
        {
            controller.view.frame = finalFrame
        })
        { finished in
            transitionContext.completeTransition(finished)
        }
    }
}

