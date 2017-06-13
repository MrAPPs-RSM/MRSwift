//
//  MRMediaPlayer.swift
//  MRSwift
//
//  Created by Nicola Innocenti on 05/04/17.
//  Copyright © 2017 Nicola Innocenti. All rights reserved.
//

import UIKit
import AVFoundation

public protocol MRMediaPlayerDelegate : class {
    
    func mediaPlayerReadyToPlay()
    func mediaPlayerDidUpdateProgress(currentTime: TimeInterval)
    func mediaPlayerDidFail(with error: Error?)
}

public class MRMediaPlayer: NSObject {
    
    // MARK: - Constants & Variables

    public static let shared = MRMediaPlayer()
    
    private var player: AVPlayer?
    public weak var delegate : MRMediaPlayerDelegate?
    
    deinit {
        if self.player != nil {
            self.removeObserver(self, forKeyPath: "status")
        }
    }
    
    public var duration : TimeInterval {
        if self.player == nil {
            return .nan
        }
        return (self.player!.currentItem?.duration.seconds)!
    }
    
    public var currentTime : TimeInterval {
        if self.player == nil {
            return .nan
        }
        return (self.player!.currentItem?.currentTime().seconds)!
    }
    
    public var remainingTime : TimeInterval {
        if self.player == nil {
            return .nan
        }
        return (self.duration - self.currentTime)
    }
    
    // MARK: - Playback handlers
    
    public var isPlaying : Bool {
        return (self.player != nil && self.player?.rate != 0)
    }
    
    public func setup(with url: URL) {
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            self.player = AVPlayer(url: url)
            if self.player != nil {
                self.addObserver(self, forKeyPath: "status", options: [], context: nil)
            }            
        } catch {
            self.delegate?.mediaPlayerDidFail(with: error)
        }
    }
    
    public func play() {
        self.player?.play()
    }
    
    public func play(from seconds: TimeInterval) {
        self.player?.seek(to: CMTime(seconds: seconds, preferredTimescale: 1000), toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
        self.play()
    }
    
    public func pause() {
        self.player?.pause()
    }
    
    public func stop() {
        self.player?.pause()
        self.player?.seek(to: kCMTimeZero)
    }
    
    // MARK: - Other Methods
    
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == "status" {
            if object is AVPlayer {
                if (object as! AVPlayer) == self.player {
                    if self.player?.status == .readyToPlay {
                        self.delegate?.mediaPlayerReadyToPlay()
                        self.player?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.01, preferredTimescale: 1000), queue: DispatchQueue.main, using: { (time) in
                            self.delegate?.mediaPlayerDidUpdateProgress(currentTime: self.currentTime)
                        })
                    } else if self.player?.status == .failed {
                        self.delegate?.mediaPlayerDidFail(with: nil)
                    }
                }
            }
        }
    }
}
