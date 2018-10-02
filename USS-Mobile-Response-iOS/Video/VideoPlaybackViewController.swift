//
//  VideoPlaybackViewController.swift
//  USS-Mobile-Response-iOS
//
//  Created by Charlie Barber on 9/30/18.
//  Copyright © 2018 Andrew Tsai. All rights reserved.
//

import Foundation
import AVKit
import AVFoundation
import UIKit


class VideoPlaybackViewController: UIViewController, AVPlayerViewControllerDelegate
{
    var playerViewController: AVPlayerViewController!
    var player: AVPlayer!
    var playerItem: AVPlayerItem!
    private var url: URL!
    
    var videoUrl: URL
    {
        get
        {
            return url!
        }
        set
        {
            url = newValue
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        
        let asset: AVAsset = AVAsset(url: videoUrl)
        
        playerItem = AVPlayerItem(asset: asset)
        
        player = AVPlayer(playerItem: playerItem)
        
        playerViewController = AVPlayerViewController()
        playerViewController.player = player
        playerViewController.delegate = self
        playerViewController.showsPlaybackControls = true
        
        self.view.backgroundColor = UIColor.white
        self.addChildViewController(playerViewController)
        self.view.addSubview(playerViewController.view)
        playerViewController.view.frame = self.view.frame
    }
}
