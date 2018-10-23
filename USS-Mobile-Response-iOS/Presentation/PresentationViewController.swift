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
    private var type: String?
    
    init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?, typeOfView: String)
    {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        type = typeOfView
    }
    
    override var frameOfPresentedViewInContainerView: CGRect
    {
        switch type
        {
            case "save":
                return CGRect(x: 0, y: containerView!.bounds.height * 0.60, width: containerView!.bounds.width, height: containerView!.bounds.height)
            default:
                return CGRect(x: 0, y: containerView!.bounds.height * 0.80, width: containerView!.bounds.width, height: containerView!.bounds.height)
        }
        
    }

    //Use this method to add views to the view hierarchy and set up any animations related to those views
    override func presentationTransitionWillBegin()
    {
        if(type != "save")
        {
            let dimmingView: UIView = setUpDimmingView()
            containerView!.addSubview(dimmingView)
            dimmingView.addSubview(presentedViewController.view)
            
            NSLayoutConstraint.activate([
                dimmingView.heightAnchor.constraint(equalTo: containerView!.heightAnchor, multiplier: 1.0),
                dimmingView.widthAnchor.constraint(equalTo: containerView!.widthAnchor, multiplier: 1.0)
                ])
            
            let transitionCoordinator: UIViewControllerTransitionCoordinator = presentingViewController.transitionCoordinator!
            
            //Fade in the dimming view during the transition
            transitionCoordinator.animate(alongsideTransition: { (context: UIViewControllerTransitionCoordinatorContext) in
                
                dimmingView.alpha = 1.0
            
            }, completion: nil)
        }
        
    }
   
//    override func dismissalTransitionWillBegin()
//    {
//        <#code#>
//    }
//    
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
