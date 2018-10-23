//
//  LocalAudioViewController.swift
//  USS-Mobile-Response-iOS
//
//  Created by Charlie Barber on 10/15/18.
//  Copyright © 2018 Andrew Tsai. All rights reserved.
//

import UIKit
import AVFoundation

class LocalAudioViewController: UIViewController, AVAudioPlayerDelegate
{
    private var audioPlayer: AVAudioPlayer?
    private var fileName: URL?
    private var fileTitle: String?
    private var timer: Timer?
    private var localPlaybackVC: LocalPlaybackViewController?
    private var seconds: Double = 0
    
    var audioUrl: URL
    {
        get
        {
            return fileName!
        }
        set
        {
            fileName = newValue
        }
    }
    var audioTitle: String
    {
        get
        {
            return fileTitle!
        }
        set
        {
            fileTitle = newValue
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        view.backgroundColor = .lightGray
        
        setUpNotifications()
        setUpPlayer()
        
        localPlaybackVC = LocalPlaybackViewController()
        localPlaybackVC!.view.translatesAutoresizingMaskIntoConstraints = false
        localPlaybackVC!.audioTitle!.text = audioTitle
        localPlaybackVC!.playButton?.addTarget(self, action: #selector(playAudio), for: .touchUpInside)
        localPlaybackVC!.recordLength?.text = String(getAudioFileDuration())
        view.addSubview(localPlaybackVC!.view)
    
        NSLayoutConstraint.activate([
            localPlaybackVC!.view.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.25),
            localPlaybackVC!.view.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            localPlaybackVC!.view.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            localPlaybackVC!.view.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            ])
    }
    
    func setUpPlayer()
    {
        do
        {
            try audioPlayer = AVAudioPlayer(contentsOf: audioUrl)
            audioPlayer!.setVolume(1.0, fadeDuration: 0.0)
            audioPlayer!.delegate = self
            timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updateProgressBar), userInfo: nil, repeats: true)
        }
        catch
        {
            let alert: UIAlertController = UIAlertController(title: "Playback Error", message: "There was a problem with playback. Did you record audio?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func getAudioFileDuration() -> String
    {
        let audioAsset: AVURLAsset = AVURLAsset(url: audioUrl)
        let audioDuration: CMTime = audioAsset.duration
        let audioDurationSeconds: Float64 = CMTimeGetSeconds(audioDuration)
        seconds = audioDurationSeconds
        let time: String = updateString(time: audioDurationSeconds)
    
        return time
    }
    
    @objc func decreaseTime()
    {
        seconds = seconds - 1
        localPlaybackVC?.recordLength?.text = updateString(time: seconds)        
    }
    
    func updateString(time:TimeInterval) -> String
    {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format: "-%02i:%02i:%02i", hours, minutes, seconds)
    }
    
    @objc func playAudio()
    {
        if(!audioPlayer!.isPlaying)
        {
            localPlaybackVC!.playButton!.setImage(UIImage(named: "pause"), for: .normal)
            audioPlayer!.play()
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(decreaseTime), userInfo: nil, repeats: true)
        }
        else if(audioPlayer!.isPlaying)
        {
            localPlaybackVC!.playButton!.setImage(UIImage(named: "play"), for: .normal)
            audioPlayer!.pause()
            timer?.invalidate()
        }
    }
    
    @objc func updateProgressBar()
    {
        if(audioPlayer!.isPlaying)
        {
            localPlaybackVC!.progressBar!.setProgress(Float(audioPlayer!.currentTime / audioPlayer!.duration), animated: true)
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool)
    {
        timer?.invalidate()
        localPlaybackVC!.recordLength?.text = String(getAudioFileDuration())
        localPlaybackVC?.progressBar?.setProgress(0.0, animated: false)
        localPlaybackVC?.playButton?.setImage(UIImage(named: "play"), for: .normal)
    }
    
    func setUpNotifications()
    {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self,
                                       selector: #selector(handleInterruption),
                                       name: .AVAudioSessionInterruption,
                                       object: nil)
    }
    
    @objc func handleInterruption(notification: Notification)
    {
        guard let userInfo = notification.userInfo,
            let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
            let type = AVAudioSessionInterruptionType(rawValue: typeValue) else {
                return
        }
        if type == .began
        {
            timer!.invalidate()
            
            if(audioPlayer!.isPlaying)
            {
                self.localPlaybackVC?.playButton?.setImage(UIImage(named: "play"), for: .normal)
                audioPlayer!.pause()
            }
        }
    }
}
