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

public enum MediaExtension : String {
    case none = ""
    case jpg = "jpg"
    case png = "png"
    case gif = "gif"
    case mp4 = "mp4"
    case mkv = "mkv"
    case avi = "avi"
}

open class MRMedia : NSObject {
    
    open var id: String?
    open var title: String?
    open var mediaDescription: String?
    open var remoteUrl: URL?
    open var localUrl: URL?
    open var shareUrl: URL?
    open var image: UIImage?
    open var thumbnail: UIImage?
    open var type: MediaType = .image
    open var fileExtension: MediaExtension = .none
    open var videoThumbnailSecond: Double = 1
    
    public convenience init(id: String?, title: String?, description: String?, remoteUrl: URL?, localUrl: URL?, type: MediaType, fileExtension: MediaExtension) {
        self.init()
        
        self.id = id
        self.title = title
        self.mediaDescription = description
        self.remoteUrl = remoteUrl
        self.localUrl = localUrl
        self.type = type
        self.fileExtension = fileExtension
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

open class MRMediaPlayerViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate, MRMediaViewControllerDelegate, MRVideoViewControllerDelegate, MRPDFViewControllerDelegate {
    
    // MARK: - Xibs
    
    private var pageContainer: UIView!
    public var pageController: UIPageViewController!
    
    // MARK: - Constants & Variables
    
    public var backgroundColor: UIColor = .black
    public var topViewBackgroundColor: UIColor = UIColor.black.withAlphaComponent(0.5)
    public var bottomViewBackgroundColor: UIColor = UIColor.black.withAlphaComponent(0.5)
    public var videoAutoPlay: Bool = false
    
    public var medias = [MRMedia]()
    private var nextIndex: Int = 0
    public var selectedIndex: Int = 0
    private weak var playerDelegate: MRMediaPlayerViewControllerDelegate?
    
    public var dragAnimation: Bool = false
    private var dragGesture: UIPanGestureRecognizer?
    private var dragYTranslation: CGFloat = 0.0
    
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
        self.addChild(pageController)
        
        if dragAnimation {
            dragGesture = UIPanGestureRecognizer(target: self, action: #selector(handleDrag(pan:)))
            view.addGestureRecognizer(dragGesture!)
        }
    }
    
    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        pageContainer.frame = view.frame
        pageController.view.frame = CGRect(origin: CGPoint(x: 0.0, y: 0.0), size: pageContainer.frame.size)
    }
    
    // MARK: - DragGesture Delegate
    
    @objc func handleDrag(pan: UIPanGestureRecognizer) {
        
        if pan.state == .began {
            
            dragYTranslation = 0.0
            
        } else if pan.state == .changed {
            
            let translation = pan.translation(in: view)
            dragYTranslation += translation.y
            pan.view!.center = CGPoint(x: pan.view!.center.x, y: pan.view!.center.y + translation.y)
            pan.setTranslation(CGPoint.zero, in: view)
            
        } else if pan.state == .ended || pan.state == .cancelled {
            
            if dragYTranslation > pan.view!.frame.size.height/2 {
                UIView.animate(withDuration: 0.3, animations: {
                    pan.view!.frame.origin.y = pan.view!.frame.size.height
                }, completion: { (completed) in
                    self.dismiss(animated: false, completion: nil)
                })
            } else {
                UIView.animate(withDuration: 0.3, animations: {
                    pan.view!.frame.origin.y = 0
                }, completion: { (completed) in
                    
                })
            }
        }
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
    
    open func mediaDidFailLoad(media: MRMedia) {
        
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
    
    // MARK: - MRPDFViewController Delegate
    
    open func pdfDidStartDownload() {
        
    }
    
    open func pdfDidFinishDownload() {
        
    }
    
    open func pdfDidUpdateDownload(progress: Float) {
        
    }
    
    open func pdfDidLoad(page: Int, totalPages: Int) {
        
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
            viewController = MRVideoViewController(media: media, autoPlay: videoAutoPlay, loop: media.fileExtension == .gif, delegate: self)
            playerDelegate = viewController as? MRVideoViewController
        } else if media.type == .pdf {
            viewController = MRPDFViewController(media: media, delegate: self)
        }
        
        viewController?.delegate = self
        viewController?.index = index
        
        return viewController
    }
    
    open func goToNext() {
        let newIndex = selectedIndex + 1
        if let viewController = viewController(at: newIndex) {
            pageController.setViewControllers([viewController], direction: .forward, animated: true) { completed in
                self.selectedIndex = newIndex
                self.didLoadNewMedia()
            }
        }
    }
    
    open func goToPrevious() {
        let newIndex = selectedIndex - 1
        if let viewController = viewController(at: newIndex) {
            pageController.setViewControllers([viewController], direction: .reverse, animated: true) { completed in
                self.selectedIndex = newIndex
                self.didLoadNewMedia()
            }
        }
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

