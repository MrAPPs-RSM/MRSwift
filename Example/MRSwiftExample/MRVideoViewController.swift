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
}

public class MRVideoViewController: MRMediaViewController, MRMediaPlayerViewControllerDelegate {
    
    // MARK: - Xibs
    
    @IBOutlet weak var imgPlaceholder: UIImageView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    // MARK: - Constants & Variables
    
    private var media: MRMedia!
    
    internal var player = AVPlayer()
    internal var playerLayer: AVPlayerLayer!
    
    internal var videoAspect: VideoAspect = .resizeAspectFill
    
    private var didFirstLoad: Bool = false
    public var autoPlay: Bool = false
    
    public var videoDelegate: MRVideoViewControllerDelegate?
    
    // MARK: - Initialization
    
    public convenience init(media: MRMedia, autoPlay: Bool, delegate: MRVideoViewControllerDelegate?) {
        self.init()
        
        self.media = media
        self.autoPlay = autoPlay
        self.videoDelegate = delegate
    }
    
    deinit {
        player.removeObserver(self, forKeyPath: "status")
    }
    
    // MARK: - UIViewController Methods

    override public func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .clear
        
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = view.frame
        view.layer.addSublayer(playerLayer)
        
        spinner.hidesWhenStopped = true
        
        self.initialize()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if autoPlay && !didFirstLoad {
            self.play()
        }
        
        didFirstLoad = true
    }
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        playerLayer.frame = view.frame
        
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.playerDidFinishPlay(notification:)),
                                               name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem)
        player.addObserver(self, forKeyPath: "status", options: [], context: nil)
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
    
    // MARK: - Other Methods
    
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if (object as? AVPlayer) == player {
            
            if keyPath == "status" {
                if player.status == .readyToPlay {
                    spinner.stopAnimating()
                    videoDelegate?.videoReadyToPlay()
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
