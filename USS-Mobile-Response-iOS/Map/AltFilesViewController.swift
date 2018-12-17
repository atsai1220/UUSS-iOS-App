//
//  AltFilesViewController.swift
//  USS-Mobile-Response-iOS
//
//  Created by Charlie Barber on 11/19/18.
//  Copyright © 2018 Andrew Tsai. All rights reserved.
//

import UIKit

class AltFilesViewController: UIViewController
{
    var photoView: RoundedImageView =
    {
        var imageView: RoundedImageView = RoundedImageView(image: #imageLiteral(resourceName: "camera"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .center
        imageView.backgroundColor = UIColor.blue.withAlphaComponent(0.1)
        
        return imageView
    }()
    
    var videoView: RoundedImageView =
    {
        var imageView: RoundedImageView = RoundedImageView(image: #imageLiteral(resourceName: "video"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .center
        imageView.backgroundColor = UIColor.red.withAlphaComponent(0.1)
        
        return imageView
    }()
    
    var audioView: RoundedImageView =
    {
        var imageView: RoundedImageView = RoundedImageView(image: #imageLiteral(resourceName: "audio2"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .center
        imageView.backgroundColor = UIColor.orange.withAlphaComponent(0.1)

        return imageView
    }()
    
    var docView: RoundedImageView =
    {
        var imageView: RoundedImageView = RoundedImageView(image: #imageLiteral(resourceName: "document"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .center
        imageView.backgroundColor = UIColor.green.withAlphaComponent(0.1)
        
        return imageView
    }()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        layoutSubViews()
    }
    
    func layoutSubViews()
    {
        view.addSubview(photoView)
        view.addSubview(videoView)
        view.addSubview(audioView)
        view.addSubview(docView)
        
        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: 60.0),
            photoView.heightAnchor.constraint(equalToConstant: 50.0),
            photoView.widthAnchor.constraint(equalToConstant: 50.0),
            photoView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            photoView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10.0),
            videoView.heightAnchor.constraint(equalToConstant: 50.0),
            videoView.widthAnchor.constraint(equalToConstant: 50.0),
            videoView.leadingAnchor.constraint(equalTo: photoView.trailingAnchor, constant: 10.0),
            videoView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            audioView.heightAnchor.constraint(equalToConstant: 50.0),
            audioView.widthAnchor.constraint(equalToConstant: 50.0),
            audioView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            audioView.leadingAnchor.constraint(equalTo: videoView.trailingAnchor, constant: 10.0),
            docView.heightAnchor.constraint(equalToConstant: 50.0),
            docView.widthAnchor.constraint(equalToConstant: 50.0),
            docView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            docView.leadingAnchor.constraint(equalTo: audioView.trailingAnchor, constant: 10.0),
            view.leadingAnchor.constraint(equalTo: photoView.leadingAnchor, constant: 1.0),
            view.trailingAnchor.constraint(equalTo: docView.trailingAnchor, constant: 1.0)
            ])
    }
}
