//
//  LocalEntryPickerView.swift
//  USS-Mobile-Response-iOS
//
//  Created by Andrew Tsai on 11/11/18.
//  Copyright © 2018 Andrew Tsai. All rights reserved.
//

import UIKit

class LocalEntryPickerView: UIPickerView {

    func togglePickerView(of view: UIView, controller: LocalEntryTableViewController) {
        if self.isDescendant(of: view) {
            view.addSubview(self)
            UIView.animate(withDuration: 0.3) {
                self.alpha = 1.0
            }
            self.delegate = controller
            self.dataSource = controller
            self.translatesAutoresizingMaskIntoConstraints = false
            controller.showPicker = true
            
            self.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
            self.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
            self.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
            
        } else {
            UIView.animate(withDuration: 0.3, animations: {
                self.alpha = 0.0
            }) { (done) in
                if done {
                    self.removeFromSuperview()
                }
            }
            controller.showPicker = false
        }
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
