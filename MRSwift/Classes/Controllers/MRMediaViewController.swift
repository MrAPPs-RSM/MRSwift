//
//  MRMediaViewController.swift
//  MRSwiftExample
//
//  Created by Nicola Innocenti on 11/01/18.
//  Copyright © 2018 Nicola Innocenti. All rights reserved.
//

import UIKit

protocol MRMediaViewControllerDelegate : class {
    func mediaDidTapView()
    func mediaDidDoubleTap()
}

open class MRMediaViewController: UIViewController {
    
    var index: Int = 0
    var delegate: MRMediaViewControllerDelegate?
    
    private var tap: UITapGestureRecognizer!
    private var doubleTap: UITapGestureRecognizer!
    
    // MARK: - UIViewController Methods
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        tap = UITapGestureRecognizer(target: self, action: #selector(self.didTap))
        tap.numberOfTapsRequired = 1
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        doubleTap = UITapGestureRecognizer(target: self, action: #selector(self.didDoubleTap))
        doubleTap.cancelsTouchesInView = true
        doubleTap.numberOfTapsRequired = 2
        view.addGestureRecognizer(doubleTap)
        
        tap.require(toFail: doubleTap)
    }
    
    // MARK: - Other Methods
    
    @objc public func didTap() {
        delegate?.mediaDidTapView()
    }
    
    @objc public func didDoubleTap() {
        delegate?.mediaDidDoubleTap()
    }
    
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
