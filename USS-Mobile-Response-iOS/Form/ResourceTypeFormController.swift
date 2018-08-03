//
//  ResourceTypeFormController.swift
//  USS-Mobile-Response-iOS
//
//  Created by Andrew Tsai on 8/2/18.
//  Copyright © 2018 Andrew Tsai. All rights reserved.
//

import UIKit

class ResourceTypeFormController: UIViewController {
    
    lazy var page: ResourceTypeForm = {
        let view = ResourceTypeForm()
        return view
    }()
    
    override func loadView() {
        super.loadView()
        navigationItem.title = "Resource Type"
        self.view.addSubview(self.page)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        setupButtons()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupButtons() {
        page.photoButton.addTarget(self, action: #selector(photoTapped), for: .touchUpInside)
    }
    
    @objc
    func photoTapped(sender: UIButton!) {
//        performSegue(withIdentifier: "imagePickerSegue", sender: self)
        let photoPickerVC = PhotoPickerViewController()
        navigationController?.pushViewController(photoPickerVC, animated: true)
//        let parentVC = self.parent as! FormViewController
//        parentVC.goToNextPage()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        page.frame = CGRect(origin: .zero, size: view.frame.size)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
