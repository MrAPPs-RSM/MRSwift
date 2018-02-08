//
//  MediaPlayerViewController.swift
//  MRSwiftExample
//
//  Created by Nicola Innocenti on 11/01/18.
//  Copyright © 2018 Nicola Innocenti. All rights reserved.
//

import UIKit

public enum MediaType : Int {
    case image = 1
    case video = 2
    case audio = 3
}

public class MRMedia : NSObject {
    
    var id: String?
    var title: String?
    var mediaDescription: String?
    var url: URL?
    var type: MediaType = .image
    
    public convenience init(id: String?, title: String?, description: String?, url: URL?, type: MediaType) {
        self.init()
        
        self.id = id
        self.title = title
        self.mediaDescription = description
        self.url = url
        self.type = type
    }
}

public protocol MRMediaPlayerViewControllerDelegate : class {
    func mediaPlayerDidTapPlay()
    func mediaPlayerDidTapPause()
    func mediaPlayerDidTapStop()
    func mediaPlayerDidChangeTime(seconds: TimeInterval)
}

public class MRMediaPlayerViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate, MRMediaViewControllerDelegate, MRVideoViewControllerDelegate {

    // MARK: - Xibs
    
    private var pageContainer: UIView!
    private var pageController: UIPageViewController!
    
    // MARK: - Constants & Variables
    
    public var backgroundColor: UIColor = .black
    public var topViewBackgroundColor: UIColor = UIColor.black.withAlphaComponent(0.5)
    public var bottomViewBackgroundColor: UIColor = UIColor.black.withAlphaComponent(0.5)
    public var videoAutoPlay: Bool = false
    
    private var medias = [MRMedia]()
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
    
    override public func viewDidLoad() {
        super.viewDidLoad()

        videoAutoPlay = true
        
        view.backgroundColor = backgroundColor
        
        pageContainer = UIView(frame: view.frame)
        pageContainer.backgroundColor = .clear
        view.addSubview(pageContainer)

        pageController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageController.dataSource = self
        pageController.delegate = self
        pageController.view.frame = CGRect(origin: CGPoint(x: 0.0, y: 0.0), size: pageContainer.frame.size)
        pageController.view.backgroundColor = .clear
        
        if let viewController = self.viewController(at: selectedIndex) {
            pageController.setViewControllers([viewController], direction: .forward, animated: false, completion: nil)
        }
        
        pageContainer.addSubview(pageController.view)
        self.addChildViewController(pageController)
    }
    
    override public func viewDidLayoutSubviews() {
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
    
    // MARK: - MRMediaViewController Delegate
    
    public func mediaDidTapView() {
        
    }
    
    public func mediaDidDoubleTap() {
        
    }
    
    // MARK: - MRVideoViewController Delegate
    
    public func videoReadyToPlay() {
        
    }
    
    public func videoDidFailLoad() {
        
    }
    
    public func videoDidFinishPlay() {
        
    }
    
    public func videoDidUpdateProgress(currentTime: TimeInterval, duration: TimeInterval) {

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
    
    public func viewController(at index: Int) -> MRMediaViewController? {
        
        if index < 0 || index > medias.count {
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
        }
        
        viewController?.delegate = self
        
        return viewController
    }
    
    public func close() {
        self.dismiss(animated: true, completion: nil)
    }
    
    override public var prefersStatusBarHidden: Bool {
        return true
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
