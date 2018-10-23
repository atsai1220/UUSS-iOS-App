//
//  LocalPlaybackViewController.swift
//  USS-Mobile-Response-iOS
//
//  Created by Charlie Barber on 10/15/18.
//  Copyright © 2018 Andrew Tsai. All rights reserved.
//

import UIKit

class LocalPlaybackViewController: UIViewController
{
    var audioTitle: UILabel?
    var progressBar: UIProgressView?
    var recordingTitle: UILabel?
    var recordLength: UILabel?
    var playButton: UIButton?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 15
        view.layer.shadowRadius = 3.0
        view.layer.shadowOffset = CGSize(width: 0.0, height: 5.0)
        view.layer.shadowOpacity = 1.0
        view.layer.shadowColor = UIColor.black.cgColor
       
        
        audioTitle = UILabel()
        audioTitle!.translatesAutoresizingMaskIntoConstraints = false
        audioTitle!.font = UIFont.systemFont(ofSize: 25.0)
        audioTitle!.textAlignment = .center
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
        
        view.addSubview(audioTitle!)
        view.addSubview(progressBar!)
        view.addSubview(recordingTitle!)
        view.addSubview(recordLength!)
        view.addSubview(playButton!)
        
        let views: [String:Any] = ["progBar":progressBar!, "recTitle": recordingTitle!, "recLength": recordLength!, "playBtn": playButton!]
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-8-[progBar]-8-|", options: [], metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[progBar]-25-[playBtn]", options: [], metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[recTitle]-25-[progBar]", options: [], metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[recLength]-25-[progBar]", options: [], metrics: nil, views: views))
        view.addConstraint(NSLayoutConstraint.init(item: progressBar!, attribute: .right, relatedBy: .equal, toItem: recordLength!, attribute: .right, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint.init(item: progressBar!, attribute: .left, relatedBy: .equal, toItem: recordingTitle!, attribute: .left, multiplier: 1.0, constant: 0.0))
        
        
        NSLayoutConstraint.activate([
            progressBar!.centerYAnchor.constraintEqualToSystemSpacingBelow(view.centerYAnchor, multiplier: 1.0),
            playButton!.centerXAnchor.constraintEqualToSystemSpacingAfter(view.centerXAnchor, multiplier: 1.0),
            audioTitle!.topAnchor.constraint(equalTo: view.topAnchor, constant: 5.0),
            audioTitle!.heightAnchor.constraint(equalToConstant: 50.0),
            audioTitle!.widthAnchor.constraint(equalToConstant: 150.0),
            audioTitle!.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            ])
        
    }
}
