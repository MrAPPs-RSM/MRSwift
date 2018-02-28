//
//  MediaPlayerViewController.swift
//  MRSwiftExample
//
//  Created by Nicola Innocenti on 11/01/18.
//  Copyright © 2018 Nicola Innocenti. All rights reserved.
//

import UIKit

public enum MediaType : Int {
    case none = 0
    case image = 1
    case video = 2
    case audio = 3
    case pdf = 4
}

open class MRMedia : NSObject {
    
    open var id: String?
    open var title: String?
    open var mediaDescription: String?
    open var remoteUrl: URL?
    open var localUrl: URL?
    open var type: MediaType = .image
    
    public convenience init(id: String?, title: String?, description: String?, remoteUrl: URL?, localUrl: URL?, type: MediaType) {
        self.init()
        
        self.id = id
        self.title = title
        self.mediaDescription = description
        self.remoteUrl = remoteUrl
        self.localUrl = localUrl
        self.type = type
    }
    
    open var url: URL? {
        
        if localUrl?.fileExists == true {
            return localUrl
        }
        return remoteUrl
    }
}

public protocol MRMediaPlayerViewControllerDelegate : class {
    func mediaPlayerDidTapPlay()
    func mediaPlayerDidTapPause()
    func mediaPlayerDidTapStop()
    func mediaPlayerDidChangeTime(seconds: TimeInterval)
}

open class MRMediaPlayerViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate, MRMediaViewControllerDelegate, MRVideoViewControllerDelegate {
    
    // MARK: - Xibs
    
    private var pageContainer: UIView!
    private var pageController: UIPageViewController!
    
    // MARK: - Constants & Variables
    
    public var backgroundColor: UIColor = .black
    public var topViewBackgroundColor: UIColor = UIColor.black.withAlphaComponent(0.5)
    public var bottomViewBackgroundColor: UIColor = UIColor.black.withAlphaComponent(0.5)
    public var videoAutoPlay: Bool = false
    
    private var medias = [MRMedia]()
    private var nextIndex: Int = 0
    private var selectedIndex: Int = 0
    private var playerDelegate: MRMediaPlayerViewControllerDelegate?
    
    // MARK: - Initialization
    
    public convenience init(medias: [MRMedia], selectedIndex: Int?) {
        self.init()
        
        self.medias = medias
        if let selectedIndex = selectedIndex {
            self.selectedIndex = selectedIndex
        }
    }
    
    // MARK: - UIViewController Methods
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = backgroundColor
        
        pageContainer = UIView(frame: view.frame)
        pageContainer.backgroundColor = .clear
        view.insertSubview(pageContainer, at: 0)
        
        pageController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageController.dataSource = self
        pageController.delegate = self
        pageController.view.frame = CGRect(origin: CGPoint(x: 0.0, y: 0.0), size: pageContainer.frame.size)
        pageController.view.backgroundColor = .clear
        
        if let viewController = self.viewController(at: selectedIndex) {
            pageController.setViewControllers([viewController], direction: .forward, animated: false, completion: nil)
            self.didLoadNewMedia()
        }
        
        pageContainer.addSubview(pageController.view)
        self.addChildViewController(pageController)
    }
    
    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        pageContainer.frame = view.frame
        pageController.view.frame = CGRect(origin: CGPoint(x: 0.0, y: 0.0), size: pageContainer.frame.size)
    }
    
    // MARK: - UIPageViewController DataSource & Delegate
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let preview = viewController as? MRMediaViewController else {
            return nil
        }
        
        return self.viewController(at: preview.index+1)
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let preview = viewController as? MRMediaViewController else {
            return nil
        }
        
        return self.viewController(at: preview.index-1)
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        if completed {
            if let viewController = pageViewController.viewControllers?.first as? MRMediaViewController {
                selectedIndex = viewController.index
                if viewController is MRVideoViewController {
                    playerDelegate = viewController as? MRVideoViewController
                }
                self.didLoadNewMedia()
            }
        }
    }
    
    // MARK: - MRMediaViewController Delegate
    
    open func mediaDidTapView() {
        
    }
    
    open func mediaDidDoubleTap() {
        
    }
    
    // MARK: - MRVideoViewController Delegate
    
    open func videoReadyToPlay() {
        
    }
    
    open func videoDidPlay() {
        
    }
    
    open func videoDidPause() {
        
    }
    
    open func videoDidStop() {
        
    }
    
    open func videoDidFailLoad() {
        
    }
    
    open func videoDidFinishPlay() {
        
    }
    
    open func videoDidUpdateProgress(currentTime: TimeInterval, duration: TimeInterval) {
        
    }
    
    // MARK: - Video Handlers
    
    public func play() {
        playerDelegate?.mediaPlayerDidTapPlay()
    }
    
    public func pause() {
        playerDelegate?.mediaPlayerDidTapPause()
    }
    
    public func stop() {
        playerDelegate?.mediaPlayerDidTapStop()
    }
    
    public func moveToSeconds(seconds: TimeInterval) {
        playerDelegate?.mediaPlayerDidChangeTime(seconds: seconds)
    }
    
    // MARK: - Other Methods
    
    open func viewController(at index: Int) -> MRMediaViewController? {
        
        if index < 0 || index >= medias.count {
            return nil
        }
        
        var viewController: MRMediaViewController?
        
        let media = medias[index]
        if media.type == .image {
            viewController = MRImageViewController(media: media)
            playerDelegate = nil
        } else if media.type == .video {
            viewController = MRVideoViewController(media: media, autoPlay: videoAutoPlay, delegate: self)
            playerDelegate = viewController as? MRVideoViewController
        } else if media.type == .pdf {
            viewController = MRPDFViewController(media: media)
        }
        
        viewController?.delegate = self
        viewController?.index = index
        
        return viewController
    }
    
    open func didLoadNewMedia() {
        
    }
    
    public func close() {
        self.dismiss(animated: true, completion: nil)
    }
    
    public var selectedMedia : MRMedia {
        return medias[selectedIndex]
    }
    
    public var videoDuration : TimeInterval {
        
        guard let viewController = pageController.viewControllers?.first else {
            return 0.0
        }
        
        if let videoViewController = viewController as? MRVideoViewController {
            return videoViewController.duration
        }
        return 0.0
    }
    
    override open var prefersStatusBarHidden: Bool {
        return true
    }
    
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

