//
//  AudioTableView.swift
//  USS-Mobile-Response-iOS
//
//  Created by Charlie Barber on 8/30/18.
//  Copyright © 2018 Andrew Tsai. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CoreLocation

class AudioPlaybackViewController: UIViewController
{
    
    var progressBar: UIProgressView?
    var recordingTitle: UILabel?
    var recordLength: UILabel?
    var playButton: UIButton?
    var garbageButton: UIButton?
    var saveButton: UIButton?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.view.layer.cornerRadius = 15
        
            progressBar = UIProgressView(progressViewStyle: .default)
            progressBar!.translatesAutoresizingMaskIntoConstraints = false
            recordingTitle = UILabel()
            recordingTitle!.text = "Playback"
            recordingTitle!.translatesAutoresizingMaskIntoConstraints = false
            recordLength = UILabel()
            recordLength!.text = "00:00:00"
            recordLength!.translatesAutoresizingMaskIntoConstraints = false
            playButton = UIButton()
            playButton!.setImage(UIImage(named: "play"), for: .normal)
            playButton!.translatesAutoresizingMaskIntoConstraints = false
            garbageButton = UIButton()
            garbageButton!.setImage(UIImage(named: "trash"), for: .normal)
            garbageButton!.translatesAutoresizingMaskIntoConstraints = false
            saveButton = UIButton()
            saveButton!.setImage(UIImage(named: "save"), for: .normal)
            saveButton!.translatesAutoresizingMaskIntoConstraints = false
        
            self.view.addSubview(progressBar!)
            self.view.addSubview(recordingTitle!)
            self.view.addSubview(recordLength!)
            self.view.addSubview(playButton!)
            self.view.addSubview(garbageButton!)
            self.view.addSubview(saveButton!)
        
            let views: [String:Any] = ["progBar":progressBar!, "recTitle": recordingTitle!, "recLength": recordLength!, "playBtn": playButton!, "garbButton": garbageButton!, "saveBtn":saveButton!]
            self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-8-[progBar]-8-|", options: [], metrics: nil, views: views))
            self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[progBar]-25-[playBtn]", options: [], metrics: nil, views: views))
            self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[recTitle]-25-[progBar]-25-[garbButton]", options: [], metrics: nil, views: views))
            self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[recLength]-25-[progBar]-25-[saveBtn]", options: [], metrics: nil, views: views))
            self.view.addConstraint(NSLayoutConstraint.init(item: progressBar!, attribute: .right, relatedBy: .equal, toItem: garbageButton!, attribute: .right, multiplier: 1.0, constant: 0.0))
            self.view.addConstraint(NSLayoutConstraint.init(item: progressBar!, attribute: .left, relatedBy: .equal, toItem: saveButton!, attribute: .left, multiplier: 1.0, constant: 0.0))
            self.view.addConstraint(NSLayoutConstraint.init(item: progressBar!, attribute: .right, relatedBy: .equal, toItem: recordLength!, attribute: .right, multiplier: 1.0, constant: 0.0))
            self.view.addConstraint(NSLayoutConstraint.init(item: progressBar!, attribute: .left, relatedBy: .equal, toItem: recordingTitle!, attribute: .left, multiplier: 1.0, constant: 0.0))

        
            NSLayoutConstraint.activate([
                progressBar!.centerYAnchor.constraintEqualToSystemSpacingBelow(self.view.centerYAnchor, multiplier: 1.0),
                playButton!.centerXAnchor.constraintEqualToSystemSpacingAfter(self.view.centerXAnchor, multiplier: 1.0)])
        
    }
}
