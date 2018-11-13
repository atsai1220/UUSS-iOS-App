//
//  PresentationViewController.swift
//  USS-Mobile-Response-iOS
//
//  Created by Charlie Barber on 10/19/18.
//  Copyright © 2018 Andrew Tsai. All rights reserved.
//

import UIKit

class PresentationViewController: UIPresentationController
{
    let type: PresentationType
    var dimmingView: UIView?
    
    init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?, typeOfPresentation: PresentationType)
    {
        type = typeOfPresentation
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
    }
    
    override var frameOfPresentedViewInContainerView: CGRect
    {
        var frame: CGRect = .zero
        
        print("container view size \(containerView!.bounds.size)")
        frame.size = size(forChildContentContainer: presentedViewController, withParentContainerSize: containerView!.bounds.size)
        
        switch type
        {
            case .save:
                frame.origin.y = containerView!.frame.height * (0.65)
            case .settings:
                frame.origin.y = containerView!.frame.height * (3/4)
        }
        
        return frame
    }

    
    override func size(forChildContentContainer container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize
    {
       return CGSize(width: parentSize.width, height: parentSize.height * (1/3))
    }
    
    //Use this method to add views to the view hierarchy and set up any animations related to those views
    override func presentationTransitionWillBegin()
    {
        if(type != .save)
        {
            dimmingView = setUpDimmingView()
            containerView!.addSubview(dimmingView!)
            dimmingView!.addSubview(presentedViewController.view)
            
            NSLayoutConstraint.activate([
                dimmingView!.heightAnchor.constraint(equalTo: containerView!.heightAnchor, multiplier: 1.0),
                dimmingView!.widthAnchor.constraint(equalTo: containerView!.widthAnchor, multiplier: 1.0)
                ])
            
            let transitionCoordinator: UIViewControllerTransitionCoordinator = presentingViewController.transitionCoordinator!
            
            //Fade in the dimming view during the transition
            transitionCoordinator.animate(alongsideTransition: { (context: UIViewControllerTransitionCoordinatorContext) in
                
                self.dimmingView!.alpha = 1.0
            
            }, completion: nil)
        }
        
    }
   
    override func dismissalTransitionWillBegin()
    {
        guard let coordinator = presentedViewController.transitionCoordinator else {
            dimmingView!.alpha = 0.0
            return
        }
        
        if(self.dimmingView != nil)
        {
            coordinator.animate(alongsideTransition: { _ in
                self.dimmingView!.alpha = 0.0
            })
        }
    }
    
    override func containerViewWillLayoutSubviews()
    {
        presentedView?.frame = frameOfPresentedViewInContainerView
    }
    
    func setUpDimmingView() -> UIView
    {
        let dimmingView = UIView()
        dimmingView.translatesAutoresizingMaskIntoConstraints = false
        dimmingView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        return dimmingView
    }
}
