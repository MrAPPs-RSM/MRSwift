//
//  MRMediaViewController.swift
//  MRSwiftExample
//
//  Created by Nicola Innocenti on 11/01/18.
//  Copyright © 2018 Nicola Innocenti. All rights reserved.
//

import UIKit
import SDWebImage

open class MRImageViewController: MRMediaViewController, UIScrollViewDelegate {
    
    // MARK: - Xibs
    
    private var scrollView: UIScrollView!
    private var imgImage: UIImageView!
    
    // MARK: - Constants & Variables

    var maxZoomScale: CGFloat = 4.0
    
    // MARK: - UIViewController Methods
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .clear
        
        scrollView = UIScrollView(frame: view.frame)
        scrollView.delegate = self
        scrollView.backgroundColor = .clear
        view.addSubview(scrollView)
        
        imgImage = UIImageView(frame: scrollView.frame)
        imgImage.center = scrollView.center
        scrollView.addSubview(imgImage)
        
        if maxZoomScale > 4.0 {
            print("[Image] Error: Max zoom scale is 5.0")
        }
        
        scrollView.maximumZoomScale = maxZoomScale > 4.0 ? 4.0 : maxZoomScale
        scrollView.minimumZoomScale = 1.0
        
        imgImage.isUserInteractionEnabled = true
        imgImage.clipsToBounds = true
        imgImage.contentMode = .scaleAspectFit
        
        self.setup()
    }
    
    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        scrollView.frame = view.frame
        imgImage.frame = scrollView.frame
    }
    
    // MARK: - Image Methods
    
    func showImage() {
        imgImage.setImage(with: media.url, placeholder: nil, completion: nil)
    }
    
    // MARK: - UIScrollView Delegate
    
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imgImage
    }
    
    // MARK: - Other Methods
    
    public func setup() {
        
        if media.type == .image {
            self.showImage()
        }
    }
    
    override public func didDoubleTap() {
        super.didDoubleTap()
        
        let zoomScale = scrollView.zoomScale
        
        if zoomScale >= maxZoomScale {
            scrollView.setZoomScale(1.0, animated: true)
            return
        }
        
        if zoomScale >= 1.0 && zoomScale < 2.5 {
            scrollView.setZoomScale(2.5, animated: true)
        } else if zoomScale >= 2.5 && zoomScale < 4.0 {
            scrollView.setZoomScale(4.0, animated: true)
        }
    }
    
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

