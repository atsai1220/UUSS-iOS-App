//
//  FormViewController.swift
//  USS-Mobile-Response-iOS
//
//  Created by Charlie Barber on 7/25/18.
//  Copyright © 2018 Andrew Tsai. All rights reserved.
//

import Foundation
import UIKit

class FormViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate
{
    var pageControl: UIPageControl? = UIPageControl()
    var viewControllersArray: [UIViewController] = [UIViewController]()
    var page1ViewController: UIViewController = UIViewController()
    var page2ViewController: UIViewController = UIViewController()
    var page3ViewController: UIViewController = UIViewController()
    var view1: FormView = FormView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.maxX, height: UIScreen.main.bounds.maxY))
    var view2: FormView = FormView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.maxX, height: UIScreen.main.bounds.maxY))
    var view3: FormView = FormView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.maxX, height: UIScreen.main.bounds.maxY))
    
    
    override init(transitionStyle style: UIPageViewControllerTransitionStyle, navigationOrientation: UIPageViewControllerNavigationOrientation, options: [String : Any]? = nil)
    {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }
    
//    var swipeDirection: String? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.navigationItem.title = "New form"
        self.navigationItem.largeTitleDisplayMode = .never
        self.delegate = self
        self.dataSource = self
//        view1.delegate = self
//        view2.delegate = self
//        view3.delegate = self

        //Create view controllers and view for the view controllers and put them in the viewcontrollerArray
        view1.setColor(newColor: UIColor.blue)
        page1ViewController.view.addSubview(view1)
        view2.setColor(newColor: UIColor.green)
        page2ViewController.view.addSubview(view2)
        view3.setColor(newColor: UIColor.purple)
        page3ViewController.view.addSubview(view3)
        viewControllersArray.append(page1ViewController)
        viewControllersArray.append(page2ViewController)
        viewControllersArray.append(page3ViewController)

        //Set the view controllers for the pagesViewController
        setViewControllers([viewControllersArray[0]], direction: .forward, animated: true, completion: nil)
        

        //Setting the UIPageControl View
        pageControl = UIPageControl(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.maxX, height: UIScreen.main.bounds.maxY))
        pageControl?.backgroundColor = UIColor.red
        pageControl!.numberOfPages = 3
        pageControl!.currentPage = 0
        pageControl!.pageIndicatorTintColor = UIColor.lightGray
        pageControl!.currentPageIndicatorTintColor = UIColor.darkGray
        self.view.addSubview(pageControl!)
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController?
    {
        print("controller: view swiped Left")
        if let viewControllerIndex = self.viewControllersArray.index(of: viewController)
        {
            if viewControllerIndex == 0
            {
                // wrap to last page in array
                return nil
            } else {
                // go to previous page in array
                return self.viewControllersArray[viewControllerIndex - 1]
            }
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController?
    {
        print("controller: view swiped Right")
        if let viewControllerIndex = self.viewControllersArray.index(of: viewController) {
            if viewControllerIndex < self.viewControllersArray.count - 1 {
                // go to next page in array
                return self.viewControllersArray[viewControllerIndex + 1]
            } else {
                // wrap to first page in array
                return nil
            }
        }
        return nil
    }
    
    override func viewDidLayoutSubviews()
    {
        var rect = CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.maxX, height: UIScreen.main.bounds.maxY)

        (pageControl!.frame, rect) = rect.divided(atDistance: rect.height * 0.1, from: CGRectEdge.maxYEdge)
    }
}
