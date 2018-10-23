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

protocol SaveAudioDelegate: class
{
    func saveAudio(with url: URL)
}

class AudioViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate
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
    private var appDelegate: AppDelegate?
    private let notificationCenter: NotificationCenter = NotificationCenter.default
    private var audioFileName: String = "tempAudioFile"
    private var recordSettings: [String: Any]?
    var collectionReference: String = ""
    weak var saveAudioDelegate: SaveAudioDelegate?
    private var isLocal: Bool = false
    private var origLength: Double = 0
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.view.backgroundColor = .black
        
        setUpNotifications()
        
        audioPlaybackViewController = AudioPlaybackViewController()
        audioPlaybackViewController!.view.translatesAutoresizingMaskIntoConstraints = false
        audioPlaybackViewController!.playButton!.addTarget(self, action: #selector(playAudio), for: .touchUpInside)
        audioPlaybackViewController!.garbageButton!.addTarget(self, action: #selector(deleteAudio), for: .touchUpInside)
        audioPlaybackViewController!.saveButton!.addTarget(self, action: #selector(saveAudio), for: .touchUpInside)
        audioPlaybackViewController!.playButton!.isEnabled = false
        audioPlaybackViewController!.garbageButton!.isEnabled = false
        audioPlaybackViewController!.saveButton!.isEnabled = false
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
        
        
        appDelegate = (UIApplication.shared.delegate as! AppDelegate)
        appDelegate!.audioSession!.requestRecordPermission({(granted: Bool) -> Void in
            if(granted)
            {
                self.fileManager = FileManager.default
                self.urlPath = self.fileManager!.urls(for: .documentDirectory, in: .userDomainMask)
                self.soundFileURL = self.urlPath![0].appendingPathComponent("\(self.audioFileName).caf")
                self.recordSettings =  [AVEncoderAudioQualityKey: AVAudioQuality.min.rawValue,
                                        AVEncoderBitRateKey: 16,
                                        AVNumberOfChannelsKey: 2,
                                        AVSampleRateKey: 44100.0] as [String : Any]
                
                do
                {
                    try self.audioRecorder = AVAudioRecorder(url: self.soundFileURL!, settings: self.recordSettings!)
                    
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
    
    func setUpPlayer()
    {
        do
        {
            try audioPlayer = AVAudioPlayer(contentsOf: self.soundFileURL!)
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
    
    @objc func saveAudio()
    {
        timer!.invalidate()
        audioPlayer?.stop()
        let docDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        
        do
        {
            let data = try Data(contentsOf: soundFileURL!)
            soundFileURL = docDir?.appendingPathComponent("tempFile.caf")

            do
            {
               try data.write(to: soundFileURL!)
               printDocDir()
            }
            catch
            {
                print(error)
            }

        }
        catch
        {
            print(error)
        }

        saveAudioDelegate?.saveAudio(with: soundFileURL!)
        navigationController?.popViewController(animated: true)
    }
    
    func saveNewFile(origURL: URL, newURL: URL)
    {
        do
        {
            soundFileURL = try self.fileManager?.replaceItemAt(newURL, withItemAt: newURL)
        }
        catch
        {
            let alert: UIAlertController = UIAlertController(title: "Error", message: "There was a problem saving the file", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @objc func deleteAudio()
    {
        do
        {
            timer!.invalidate()
            seconds = 0
            audioPlaybackViewController!.progressBar?.setProgress(0.0, animated: false)
            audioPlaybackViewController?.playButton?.setImage(UIImage(named: "play"), for: .normal)
            audioPlaybackViewController!.playButton?.isEnabled = false
            audioPlaybackViewController!.garbageButton?.isEnabled = false
            audioPlaybackViewController!.saveButton?.isEnabled = false
            audioPlayer?.stop()
            audioPlaybackViewController!.recordLength!.text = "00:00:00"
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
        if(!audioPlayer!.isPlaying)
        {
            audioPlaybackViewController?.playButton?.setImage(UIImage(named: "pause"), for: .normal)
            audioPlayer!.play()
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(decreaseTime), userInfo: nil, repeats: true)
        }
        else if(audioPlayer!.isPlaying)
        {
            audioPlaybackViewController?.playButton?.setImage(UIImage(named: "play"), for: .normal)
            audioPlayer!.pause()
            timer!.invalidate()
        }
    }
    
    @objc func toggleRecording()
    {
        
        if(recordButton!.titleLabel!.text == "Record" && self.recordButton!.isEnabled)
        {
            audioPlaybackViewController!.playButton?.isEnabled = false
            audioPlaybackViewController!.garbageButton?.isEnabled = false
            recordButton!.setTitle("Stop", for: .normal)
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
            audioRecorder!.record()
        }
        else
        {
            audioPlaybackViewController!.playButton?.isEnabled = true
            audioPlaybackViewController!.garbageButton?.isEnabled = true
            audioPlaybackViewController!.saveButton?.isEnabled = true
            recordingTime = timeLabel!.text
            audioPlaybackViewController!.recordLength!.text = "-" + recordingTime!
            seconds = audioRecorder!.currentTime
            origLength = seconds
            audioRecorder!.stop()
            timer!.invalidate()
            timeLabel!.text =  "00:00:00"
            recordButton!.setTitle("Record", for: .normal)
            recordButton!.backgroundColor = UIColor.gray
            self.recordButton!.isEnabled = false
            setUpPlayer()
        }
    }
    
    @objc func updateProgressBar()
    {
        if(audioPlayer!.isPlaying)
        {
            audioPlaybackViewController!.progressBar!.setProgress(Float(audioPlayer!.currentTime / audioPlayer!.duration), animated: true)
        }
    }
    
    @objc func updateTimer() -> Void
    {
        if(recordButton!.isEnabled || audioPlayer!.isPlaying)
        {
            seconds = seconds + 1
            timeLabel!.text = updateString(time: seconds)
        }
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
    
    @objc func decreaseTime()
    {
        seconds = seconds - 1
        print("seconds" + String(seconds))
        audioPlaybackViewController?.recordLength?.text = updateDecreasedString(time: seconds)
    }
    
    func updateDecreasedString(time:TimeInterval) -> String
    {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        let time = String(format: "-%02i:%02i:%02i", hours, minutes, seconds)
        print("Time " + time)
        return String(format: "-%02i:%02i:%02i", hours, minutes, seconds)
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool)
    {
        timer!.invalidate()
        seconds = origLength
        audioPlaybackViewController!.recordLength!.text = "-" + recordingTime!
        audioPlaybackViewController?.progressBar?.setProgress(0.0, animated: false)
        audioPlaybackViewController?.playButton?.setImage(UIImage(named: "play"), for: .normal)
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
            
            if(audioRecorder!.isRecording)
            {
                audioRecorder!.pause()
            }
            else if(audioPlayer!.isPlaying)
            {
                self.audioPlaybackViewController?.playButton?.setImage(UIImage(named: "play"), for: .normal)
                audioPlayer!.pause()
            }
        }
        else if type == .ended
        {
            if let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt {
                let options = AVAudioSessionInterruptionOptions(rawValue: optionsValue)
                if options.contains(.shouldResume)
                {
                    if(recordButton!.titleLabel!.text == "Stop" && recordButton!.isEnabled)
                    {
                        audioRecorder!.record()
                        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
                    }
                }
            }
        }
    }
}

