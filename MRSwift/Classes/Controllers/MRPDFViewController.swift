//
//  PDFViewController.swift
//  MRSwiftExample
//
//  Created by Nicola Innocenti on 01/03/18.
//  Copyright © 2018 mrapps. All rights reserved.
//

import UIKit
import CoreGraphics
import Alamofire

extension CGPDFPage {
    /// original size of the PDF page.
    var originalPageRect: CGRect {
        switch rotationAngle {
        case 90, 270:
            let originalRect = getBoxRect(.mediaBox)
            let rotatedSize = CGSize(width: originalRect.height, height: originalRect.width)
            return CGRect(origin: originalRect.origin, size: rotatedSize)
        default:
            return getBoxRect(.mediaBox)
        }
    }
}

extension FloatingPoint {
    var degreesToRadians: Self { return self * .pi / 180 }
    var radiansToDegrees: Self { return self * 180 / .pi }
}

public protocol MRPDFViewControllerDelegate : class {
    func pdfDidLoad(page: Int, totalPages: Int)
}

open class MRPDFViewController: MRMediaViewController, MRMediaViewControllerDelegate, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    // MARK: - Xibs
    
    private var pageContainer: UIView!
    private var pageController: UIPageViewController!
    private var spinner: UIActivityIndicatorView!
    
    // MARK: - Constants & Variables
    
    private var pages = [MRMedia]()
    private var nextIndex: Int = 0
    private var selectedIndex: Int = 0
    private var document: CGPDFDocument?
    public var pdfDelegate: MRPDFViewControllerDelegate?
    
    // MARK: - Initialization
    
    public convenience init(media: MRMedia, delegate: MRPDFViewControllerDelegate?) {
        self.init(media: media)
        
        self.pdfDelegate = delegate
    }
    
    // MARK: - UIViewController Methods
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(netHex: 0xdddddd)
        
        pageContainer = UIView(frame: view.frame)
        pageContainer.backgroundColor = .clear
        view.insertSubview(pageContainer, at: 0)
        
        pageController = UIPageViewController(transitionStyle: .pageCurl, navigationOrientation: .horizontal, options: nil)
        pageController.dataSource = self
        pageController.delegate = self
        pageController.view.frame = CGRect(origin: CGPoint(x: 0.0, y: 0.0), size: pageContainer.frame.size)
        pageController.view.backgroundColor = .clear
        
        let blankController = UIViewController()
        blankController.view.backgroundColor = .clear
        pageController.setViewControllers([blankController], direction: .forward, animated: true, completion: nil)
        
        pageContainer.addSubview(pageController.view)
        addChildViewController(pageController)
        
        spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        spinner.color = .lightGray
        spinner.center = view.center
        spinner.hidesWhenStopped = true
        view.addSubview(spinner)
        spinner.startAnimating()
        
        setupPDF()
    }
    
    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        pageContainer.frame = view.frame
        pageController.view.frame = CGRect(origin: CGPoint(x: 0.0, y: 0.0), size: pageContainer.frame.size)
        
        spinner.center = view.center
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
            }
        }
    }
    
    // MARK: - MRMediaViewController Delegate
    
    func mediaDidTapView() {
        delegate?.mediaDidTapView()
    }
    
    func mediaDidDoubleTap() {
        delegate?.mediaDidDoubleTap()
    }
    
    func mediaDidFailLoad(media: MRMedia) {
        
    }
    
    // MARK: - PDF Methods
    
    private func setupPDF() {
        
        if let localUrl = media.localUrl, localUrl.fileExists {
            initializePDF(with: localUrl)
        } else if let remoteUrl = media.remoteUrl {
            initializePDF(with: remoteUrl)
        }
    }
    
    private func initializePDF(with url: URL) {
        
        DispatchQueue.global(qos: .background).async {
            
            if let data = Cache.shared.object(ofType: Data.self, forKey: url.absoluteString) {
                self.loadPdf(fromData: data)
            } else {
                Alamofire.request(url).responseData(completionHandler: { (response) in
                    
                    guard let data = response.data, data.count > 0 else {
                        self.delegate?.mediaDidFailLoad(media: self.media)
                        return
                    }
                    Cache.shared.setObject(data, forKey: url.absoluteString)
                    self.loadPdf(fromData: data)
                })
            }
        }
    }
    
    private func loadPdf(fromData data: Data) {
        
        if let provider = CGDataProvider(data: data as CFData) {
            self.document = CGPDFDocument(provider)
            if let document = self.document {
                for _ in 0..<document.numberOfPages {
                    self.pages.append(MRMedia())
                }
                self.getImagesFromPDF(at: 0, completion: {
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.1, execute: {
                        self.spinner.stopAnimating()
                        if let viewController = self.viewController(at: self.selectedIndex) {
                            self.pageController.setViewControllers([viewController], direction: .forward, animated: false, completion: nil)
                        }
                    })
                })
            }
        }
    }
    
    private func getImagesFromPDF(completion: @escaping () -> Void) {
        
        var completedImages: Int = 0
        
        DispatchQueue.global(qos: .background).async {
            for i in 1..<(self.pages.count+1) {
                self.imageFromPDFPage(at: i, thumbnail: false, completion: { (image) in
                    self.pages[i-1].image = image
                    completedImages += 1
                    if completedImages == self.pages.count {
                        completion()
                    }
                })
            }
        }
    }
    
    private func getImagesFromPDF(at index: Int, completion: @escaping () -> Void) {
        
        var indexes = [Int]()
        /*if index > 0 {
         if pages[index-1].image == nil {
         indexes.append(index-1)
         }
         }*/
        if pages[index].image == nil {
            indexes.append(index)
        }
        if index < (pages.count-2) {
            if pages[index+1].image == nil {
                indexes.append(index+1)
            }
            if pages[index+2].image == nil {
                indexes.append(index+2)
            }
        } else if index < (pages.count-1) {
            if pages[index+1].image == nil {
                indexes.append(index+1)
            }
        }
        
        if indexes.count == 0 {
            completion()
            return
        }
        
        var completedImages: Int = 0
        
        DispatchQueue.global(qos: .background).async {
            
            for index in indexes {
                self.imageFromPDFPage(at: index+1, thumbnail: false, completion: { (image) in
                    self.pages[index].image = image
                    completedImages += 1
                    if completedImages == indexes.count {
                        DispatchQueue.main.sync {
                            completion()
                        }
                    }
                })
            }
        }
    }
    
    private func imageFromPDFPage(at index: Int, thumbnail: Bool, completion: (UIImage?) -> Void) {
        
        guard let page = document?.page(at: index) else {
            completion(nil)
            return
        }
        
        var originalPagerect: CGFloat = 0.0
        var scalingConstant: CGFloat = 0.0
        var pdfScale: CGFloat = 0.0
        var scaledPageSize: CGSize = .zero
        var scaledPageRect: CGRect = .zero
        
        let originalPageRect = page.originalPageRect
        
        if thumbnail {
            
            scalingConstant = 240
            pdfScale = min(scalingConstant/originalPageRect.width, scalingConstant/originalPageRect.height)
            scaledPageSize = CGSize(width: originalPageRect.width * pdfScale, height: originalPageRect.height * pdfScale)
            scaledPageRect = CGRect(origin: originalPageRect.origin, size: scaledPageSize)
            
        } else {
            
            scalingConstant = originalPageRect.size.width
            pdfScale = min(scalingConstant/originalPageRect.width, scalingConstant/originalPageRect.height)
            scaledPageSize = CGSize(width: originalPageRect.width * pdfScale, height: originalPageRect.height * pdfScale)
            scaledPageRect = CGRect(origin: originalPageRect.origin, size: scaledPageSize)
        }
        
        // Create a low resolution image representation of the PDF page to display before the TiledPDFView renders its content.
        UIGraphicsBeginImageContextWithOptions(scaledPageSize, true, 1)
        guard let context = UIGraphicsGetCurrentContext() else {
            completion(nil)
            return
        }
        
        // First fill the background with white.
        context.setFillColor(red: 1, green: 1, blue: 1, alpha: 1)
        context.fill(scaledPageRect)
        
        context.saveGState()
        
        // Flip the context so that the PDF page is rendered right side up.
        let rotationAngle: CGFloat
        switch page.rotationAngle {
        case 90:
            rotationAngle = 270
            //context.translateBy(x: scaledPageSize.width, y: scaledPageSize.height)
        case 180:
            rotationAngle = 180
            context.translateBy(x: 0, y: scaledPageSize.height)
        case 270:
            rotationAngle = 90
            context.translateBy(x: scaledPageSize.width, y: scaledPageSize.height)
        default:
            rotationAngle = 0
            context.translateBy(x: 0, y: scaledPageSize.height)
        }
        
        context.scaleBy(x: 1, y: -1)
        context.rotate(by: rotationAngle.degreesToRadians)
        
        // Scale the context so that the PDF page is rendered at the correct size for the zoom level.
        context.scaleBy(x: pdfScale, y: pdfScale)
        context.drawPDFPage(page)
        context.restoreGState()
        
        defer { UIGraphicsEndImageContext() }
        guard let backgroundImage = UIGraphicsGetImageFromCurrentImageContext() else {
            completion(nil)
            return
        }
        
        completion(backgroundImage)
    }
    
    // MARK: - Other Methods
    
    open func viewController(at index: Int) -> MRMediaViewController? {
        
        if index < 0 || index >= pages.count {
            return nil
        }
        
        let page = pages[index]
        var viewController: MRMediaViewController?
        viewController = MRImageViewController(media: page)
        viewController?.delegate = self
        viewController?.index = index
        
        getImagesFromPDF(at: index) {
            for viewController in self.pageController.viewControllers! {
                if let view = viewController as? MRImageViewController {
                    view.refresh(media: self.pages[view.index])
                }
            }
        }
        pdfDelegate?.pdfDidLoad(page: index+1, totalPages: pages.count)
        
        return viewController
    }
    
    override open var prefersStatusBarHidden: Bool {
        return true
    }
    
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}



