//
//  AudioViewController.swift
//  USS-Mobile-Response-iOS
//
//  Created by Charlie Barber on 8/28/18.
//  Copyright © 2018 Andrew Tsai. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class AudioViewController: UIViewController, AVAudioRecorderDelegate
{
    private var recordButton: UIButton?
    private var pauseButton: UIButton?
    private var progressBar: UIProgressView?
    private var timeLabel: UILabel?
    private var timer: Timer?
    var seconds: TimeInterval = 0.0
    private var audioRecorder: AVAudioRecorder?
    private var recordingTime: String?
    private var fileManager: FileManager?
    private var urlPath: [URL]?
    private var soundFileURL: URL?
    private var audioPlaybackViewController: AudioPlaybackViewController?
    private var audioPlayer: AVAudioPlayer?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black
        
        audioPlaybackViewController = AudioPlaybackViewController()
        audioPlaybackViewController!.view.translatesAutoresizingMaskIntoConstraints = false
        audioPlaybackViewController!.playButton!.addTarget(self, action: #selector(playAudio), for: .touchUpInside)
        audioPlaybackViewController!.garbageButton!.addTarget(self, action: #selector(deleteAudio), for: .touchUpInside)
        self.view.addSubview(audioPlaybackViewController!.view)

        recordButton = UIButton()
        recordButton!.layer.cornerRadius = 25
        recordButton!.layer.borderWidth = 2
        recordButton!.backgroundColor = UIColor.red
        recordButton!.layer.borderColor = UIColor.white.cgColor
        recordButton!.translatesAutoresizingMaskIntoConstraints = false
        recordButton!.setTitle("Record", for: .normal)
        recordButton!.titleLabel!.font = UIFont(name: "Times", size: 25)
        recordButton!.titleLabel!.textColor = UIColor.white
        recordButton!.addTarget(self, action: #selector(toggleRecording), for: .touchUpInside)
        self.view.addSubview(recordButton!)
        
        
        progressBar = UIProgressView(progressViewStyle: .default)
        progressBar!.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(progressBar!)
        
        timeLabel = UILabel()
        timeLabel!.translatesAutoresizingMaskIntoConstraints = false
        timeLabel!.textColor = UIColor.white
        timeLabel!.text = "00:00:00"
        timeLabel!.font = UIFont(name: "Times", size: 100.0)
        timeLabel!.adjustsFontSizeToFitWidth = true
        self.view.addSubview(timeLabel!)
        
        
        let views: [String: Any] = ["recBtn":recordButton!, "progBar":progressBar!, "time":timeLabel!, "playView":audioPlaybackViewController!.view]
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[recBtn(250)]", options: [], metrics: nil, views: views))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[time]-|", options: [], metrics: nil, views: views))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[playView]-|", options: [], metrics: nil, views: views))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[time]-50-[recBtn(>=50,<=100)]", options: [], metrics: nil, views: views))
//        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[progBar]-|", options: [], metrics: nil, views: views))
        self.view.addConstraint(NSLayoutConstraint.init(item: self.view, attribute: .bottom, relatedBy: .equal, toItem: recordButton!, attribute: .bottom, multiplier: 1.0, constant: 95.0))
        
        let guide = self.view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            recordButton!.centerXAnchor.constraintEqualToSystemSpacingAfter(self.view.centerXAnchor, multiplier: 1.0),
            timeLabel!.centerXAnchor.constraintEqualToSystemSpacingAfter(self.view.centerXAnchor, multiplier: 1.0),
            audioPlaybackViewController!.view.topAnchor.constraintEqualToSystemSpacingBelow(guide.topAnchor, multiplier: 1.0),
            audioPlaybackViewController!.view.bottomAnchor.constraintEqualToSystemSpacingBelow(timeLabel!.topAnchor, multiplier: 1.0)
            ])
        
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.audioSession!.requestRecordPermission({(granted: Bool) -> Void in
            if(granted)
            {
                self.fileManager = FileManager.default
                self.urlPath = self.fileManager!.urls(for: .documentDirectory, in: .userDomainMask)
                self.soundFileURL = self.urlPath![0].appendingPathComponent("sound.caf")
                let recordSettings =  [AVEncoderAudioQualityKey: AVAudioQuality.min.rawValue,
                                       AVEncoderBitRateKey: 16,
                                       AVNumberOfChannelsKey: 2,
                                       AVSampleRateKey: 44100.0] as [String : Any]
                
                do
                {
                    try self.audioRecorder = AVAudioRecorder(url: self.soundFileURL!, settings: recordSettings)

                }
                catch let error as NSError
                {
                    let alert: UIAlertController = UIAlertController(title: "Error", message: "\(error.localizedDescription)", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
            else
            {
                self.recordButton!.isEnabled = false
                self.recordButton!.backgroundColor = UIColor.gray
                let alert: UIAlertController = UIAlertController(title: "Permission Denied", message: "You must enable microphone usage to record.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        })
    }
    
    @objc func deleteAudio()
    {
        do
        {
            try self.fileManager!.removeItem(at: self.soundFileURL!)
            self.recordButton!.isEnabled = true
            self.recordButton!.backgroundColor = UIColor.red
            let alert: UIAlertController = UIAlertController(title: "File Deleted", message: "You have successfully deleted your audio file", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        catch
        {
            let alert: UIAlertController = UIAlertController(title: "Error", message: "There was a problem deleting the audio file. Did you record audio", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @objc func playAudio()
    {
        do
        {
            try audioPlayer = AVAudioPlayer(contentsOf: self.soundFileURL!)
            audioPlayer!.volume = 1.0
            audioPlayer!.play()
        }
        catch
        {
            let alert: UIAlertController = UIAlertController(title: "Playback Error", message: "There was a problem with playback. Did you record audio?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    @objc func toggleRecording()
    {
        
        if(recordButton!.titleLabel!.text == "Record" && self.recordButton!.isEnabled)
        {
            recordButton!.setTitle("Stop", for: .normal)
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
            audioRecorder!.record()
        }
        else
        {
            recordingTime = timeLabel!.text
            audioPlaybackViewController!.recordLength!.text = recordingTime
            audioRecorder!.stop()
            timer!.invalidate()
            timeLabel!.text =  "00:00:00"
            seconds = 0
            recordButton!.setTitle("Record", for: .normal)
            recordButton!.backgroundColor = UIColor.gray
            self.recordButton!.isEnabled = false
        }
    }
    
    @objc func updateTimer() -> Void
    {
        seconds = seconds + 1
        timeLabel!.text = updateString(time: seconds)
    }
    
    func updateString(time:TimeInterval) -> String
    {
       let hours = Int(time) / 3600
       let minutes = Int(time) / 60 % 60
       let seconds = Int(time) % 60
       return String(format: "%02i:%02i:%02i", hours, minutes, seconds)
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        AppDelegate.AppUtility.lockOrientation(.all)
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        AppDelegate.AppUtility.lockOrientation(.portrait)
    }
    
    override func viewDidDisappear(_ animated: Bool)
    {
        super.viewDidDisappear(animated)
        
        do
        {
            try self.fileManager!.removeItem(at: self.soundFileURL!)
        }
        catch
        {
            let alert: UIAlertController = UIAlertController(title: "Error", message: "There was a problem deleting the audio file", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
    }
}

