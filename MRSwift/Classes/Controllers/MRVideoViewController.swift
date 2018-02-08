//
//  MRVideoViewController.swift
//  MRSwiftExample
//
//  Created by Nicola Innocenti on 12/01/18.
//  Copyright © 2018 Nicola Innocenti. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

public enum VideoAspect: Int {
    case resizeAspectFill = 1
    case resizeAspect = 2
    case resize = 3
}

public protocol MRVideoViewControllerDelegate : class {
    func videoReadyToPlay()
    func videoDidFinishPlay()
    func videoDidFailLoad()
    func videoDidUpdateProgress(currentTime: TimeInterval, duration: TimeInterval)
}

public class MRVideoViewController: MRMediaViewController, MRMediaPlayerViewControllerDelegate {
    
    // MARK: - Xibs
    
    private var videoView: UIView!
    private var imgPlaceholder: UIImageView!
    private var spinner: UIActivityIndicatorView!
    
    // MARK: - Constants & Variables
    
    private var media: MRMedia!
    
    internal var player: AVPlayer!
    internal var playerLayer: AVPlayerLayer!
    
    private var videoAspect: VideoAspect = .resizeAspectFill
    
    private var didFirstLoad: Bool = false
    public var autoPlay: Bool = false
    
    public var videoDelegate: MRVideoViewControllerDelegate?
    
    private var timeObserver: Any?
    
    // MARK: - Initialization
    
    public convenience init(media: MRMedia, autoPlay: Bool, delegate: MRVideoViewControllerDelegate?) {
        self.init()
        
        self.media = media
        self.autoPlay = autoPlay
        self.videoDelegate = delegate
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem)
        player.removeObserver(self, forKeyPath: "status")
        if let timeObserver = timeObserver {
            player.removeTimeObserver(timeObserver)
        }
    }
    
    // MARK: - UIViewController Methods

    override public func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .clear
        
        videoView = UIView(frame: view.frame)
        view.addSubview(videoView)
        
        imgPlaceholder = UIImageView(frame: videoView.frame)
        videoView.addSubview(imgPlaceholder)
        
        spinner = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        spinner.color = .lightGray
        spinner.center = videoView.center
        videoView.addSubview(imgPlaceholder)
        
        spinner.hidesWhenStopped = true
        
        self.initialize()
    }
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        videoView.frame = view.frame
        imgPlaceholder.frame = videoView.frame
        spinner.center = videoView.center
        playerLayer.frame = videoView.frame
        
        if UIDevice.isPortrait {
            videoAspect = .resizeAspect
        } else {
            videoAspect = .resizeAspectFill
        }
        
        switch(videoAspect){
            case .resizeAspectFill: playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
            case .resizeAspect: playerLayer.videoGravity = AVLayerVideoGravityResizeAspect
            case .resize: playerLayer.videoGravity = AVLayerVideoGravityResize
        }
    }
    
    // MARK: - Player Methods
    
    public var isReadyToPlay : Bool {
        return player.status == .readyToPlay
    }
    
    public var isPlaying : Bool {
        return player.rate != 0
    }
    
    public var duration : TimeInterval {
        if let item = player.currentItem {
            return item.duration.seconds
        }
        return 0.0
    }
    
    public var currentTime : TimeInterval {
        if let item = player.currentItem {
            return item.currentTime().seconds
        }
        return 0.0
    }
    
    public var remainingTime : TimeInterval {
        return (self.duration - self.currentTime)
    }
    
    public func initialize() {
        
        guard let url = media.url else {
            return
        }
        
        player = AVPlayer(url: url)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = videoView.frame
        videoView.layer.addSublayer(playerLayer)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.playerDidFinishPlay(notification:)),
                                               name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem)
        player.addObserver(self, forKeyPath: "status", options: [], context: nil)
        player.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1.0, 10), queue: DispatchQueue.main) { (time) in
            self.videoDelegate?.videoDidUpdateProgress(currentTime: time.seconds, duration: self.duration)
        }
        
        self.loadThumbnail()
    }
    
    public func loadThumbnail() {
        
        guard let asset = player.currentItem?.asset else {
            imgPlaceholder.image = nil
            return
        }
        
        let assetImgGenerate = AVAssetImageGenerator(asset: asset)
        assetImgGenerate.appliesPreferredTrackTransform = true
        let time = CMTimeMakeWithSeconds(Float64(1), 100)
        do {
            let img = try assetImgGenerate.copyCGImage(at: time, actualTime: nil)
            let thumbnail = UIImage(cgImage: img)
            imgPlaceholder.image = thumbnail
        } catch {
            imgPlaceholder.image = nil
        }
    }
    
    public func play() {
        player.play()
    }
    
    public func play(from seconds: TimeInterval) {
        player.seek(to: CMTime(seconds: seconds, preferredTimescale: 1000), toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
        self.play()
    }
    
    public func pause() {
        player.pause()
    }
    
    public func stop() {
        player.pause()
        player.seek(to: kCMTimeZero)
    }
    
    public func playerDidFinishPlay(notification: Notification) {
        self.stop()
        videoDelegate?.videoDidFinishPlay()
    }
    
    // MARK: - MRMediaPlayerViewController Delegate
    
    public func mediaPlayerDidTapPlay() {
        
        if isPlaying {
            self.pause()
        } else {
            self.play()
        }
    }
    
    public func mediaPlayerDidTapPause() {
        self.pause()
    }
    
    public func mediaPlayerDidTapStop() {
        self.stop()
    }
    
    public func mediaPlayerDidChangeTime(seconds: TimeInterval) {
        self.play(from: seconds)
    }
    
    // MARK: - Other Methods
    
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if (object as? AVPlayer) == player {
            
            if keyPath == "status" {
                if player.status == .readyToPlay {
                    spinner.stopAnimating()
                    imgPlaceholder.isHidden = true
                    videoDelegate?.videoReadyToPlay()
                    if autoPlay && !didFirstLoad {
                        self.play()
                        didFirstLoad = true
                    }
                } else {
                    videoDelegate?.videoDidFailLoad()
                }
            }
        }
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
