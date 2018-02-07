//
//  MRMediaViewController.swift
//  MRSwiftExample
//
//  Created by Nicola Innocenti on 11/01/18.
//  Copyright © 2018 Nicola Innocenti. All rights reserved.
//

import UIKit
import SDWebImage

class MRImageViewController: MRMediaViewController, UIScrollViewDelegate {
    
    // MARK: - Xibs
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imgImage: UIImageView!
    
    // MARK: - Constants & Variables
    
    private var media: MRMedia!
    var maxZoomScale: CGFloat = 4.0
    
    // MARK: - Initialization
    
    convenience init(media: MRMedia) {
        self.init()
        
        self.media = media
    }
    
    // MARK: - UIViewController Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .clear
        
        scrollView.delegate = self
        scrollView.backgroundColor = .clear
        
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
    
    // MARK: - Image Methods
    
    func showImage() {
        imgImage.setImage(with: media.url, placeholder: nil, completion: nil)
    }

    // MARK: - UIScrollView Delegate
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imgImage
    }
    
    // MARK: - Other Methods
    
    public func setup() {
        
        if media.type == .image {
            self.showImage()
        }
    }
    
    override func didDoubleTap() {
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
