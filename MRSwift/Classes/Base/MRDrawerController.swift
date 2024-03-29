//
//  MRDrawerController.swift
//  MRSwiftExample
//
//  Created by Nicola Innocenti on 14/05/17.
//  Copyright © 2017 Nicola Innocenti. All rights reserved.
//

import UIKit

public extension UIViewController {
    
    @objc func openLeftDrawerView() {
        if let drawer = UIApplication.shared.windows.first?.rootViewController as? MRDrawerController {
            drawer.openLeftDrawer()
        }
    }
    
    @objc func closeLeftDrawerView() {
        if let drawer = UIApplication.shared.windows.first?.rootViewController as? MRDrawerController {
            drawer.closeLeftDrawer()
        }
    }
    
    @objc func openRightDrawerView() {
        if let drawer = UIApplication.shared.windows.first?.rootViewController as? MRDrawerController {
            drawer.openRightDrawer()
        }
    }
    
    @objc func closeRightDrawerView() {
        if let drawer = UIApplication.shared.windows.first?.rootViewController as? MRDrawerController {
            drawer.closeRightDrawer()
        }
    }
}

public enum DrawerType : Int {
    case overlay = 1
    case side = 2
}

open class MRDrawerController: UIViewController {
    
    // MARK: - Constants & Variables
    
    open var leftViewController : UIViewController?
    open var centerViewController : UIViewController?
    open var rightViewController : UIViewController?
    private var darkBackground : UIView!
    
    private var isLeftViewVisible : Bool = false
    private var isRightViewVisible : Bool = false
    private var drawerType : DrawerType = .overlay
    
    open var leftViewWidth : CGFloat = 275.0
    open var rightViewWidth : CGFloat = 275.0
    open var animationDuration : TimeInterval = 0.3
    open var backgroundOpacity : CGFloat = 0.5
    
    private var viewWidth : CGFloat {
        return self.view.frame.size.width
    }
    
    private var viewHeight : CGFloat {
        return self.view.frame.size.height
    }
    
    // MARK: - Initialization
    
    public convenience init(leftViewController: UIViewController?, centerViewController: UIViewController?, rightViewController: UIViewController?, drawerType: DrawerType) {
        self.init()
        self.leftViewController = leftViewController
        self.centerViewController = centerViewController
        self.rightViewController = rightViewController
        self.drawerType = drawerType
    }
    
    public convenience init(leftViewController: UIViewController?, centerViewController: UIViewController?, drawerType: DrawerType) {
        self.init()
        self.leftViewController = leftViewController
        self.centerViewController = centerViewController
        self.drawerType = drawerType
    }
    
    public convenience init(centerViewController: UIViewController?, rightViewController: UIViewController?, drawerType: DrawerType) {
        self.init()
        self.centerViewController = centerViewController
        self.rightViewController = rightViewController
        self.drawerType = drawerType
    }
    
    // MARK: - UIViewController Methods
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        //Center View
        
        if self.centerViewController != nil {
            self.centerViewController?.view.frame = CGRect(x: 0.0, y: 0.0, width: self.viewWidth, height: self.viewHeight)
            self.addChild(self.centerViewController!)
            self.view.addSubview(self.centerViewController!.view)
        }
        
        //Dark Background
        
        self.darkBackground = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.viewWidth, height: self.viewHeight))
        self.darkBackground.backgroundColor = UIColor.clear
        self.darkBackground.isHidden = true
        self.view.addSubview(self.darkBackground)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.didTapDarkBackground))
        tap.numberOfTapsRequired = 1
        self.darkBackground.addGestureRecognizer(tap)
        
        //Left View
        
        if self.leftViewController != nil {
            self.leftViewController?.view.frame = CGRect(x: -self.leftViewWidth, y: 0.0, width: self.leftViewWidth, height: self.viewHeight)
            self.addChild(self.leftViewController!)
            self.view.addSubview(self.leftViewController!.view)
        }
        
        //Right View
        
        if self.rightViewController != nil {
            self.rightViewController?.view.frame = CGRect(x: self.viewWidth, y: 0.0, width: self.rightViewWidth, height: self.viewHeight)
            self.addChild(self.rightViewController!)
            self.view.addSubview(self.rightViewController!.view)
        }
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if self.centerViewController != nil {
            self.centerViewController?.view.frame = CGRect(x: 0.0, y: 0.0, width: self.viewWidth, height: self.viewHeight)
        }
        
        if self.leftViewController != nil {
            self.leftViewController?.view.frame = CGRect(x: self.isLeftViewVisible ? 0.0 : -self.leftViewWidth, y: 0.0, width: self.leftViewWidth, height: self.viewHeight)
        }
        
        if self.rightViewController != nil {
            self.rightViewController?.view.frame = CGRect(x: self.isRightViewVisible ? self.viewWidth-self.rightViewWidth : self.viewWidth, y: 0.0, width: self.rightViewWidth, height: self.viewHeight)
        }
        
        darkBackground.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height)
    }
    
    // MARK: - Drawer Methods
    
    public func openLeftDrawer() {
        
        if self.isLeftViewVisible == true {
            return
        }
        
        self.darkBackground.isHidden = false
        self.moveCenterViewLeft()
        UIView.animate(withDuration: self.animationDuration, animations: {
            self.darkBackground.backgroundColor = UIColor.black.withAlphaComponent(self.backgroundOpacity)
            self.leftViewController?.view.frame = CGRect(x: 0.0, y: 0.0, width: self.leftViewWidth, height: self.viewHeight)
        }) { (completed) in
            self.isLeftViewVisible = true
        }
    }
    
    public func closeLeftDrawer() {
        
        if self.isLeftViewVisible == false {
            return
        }
        
        self.resetCenterViewPosition()
        UIView.animate(withDuration: self.animationDuration, animations: {
            self.darkBackground.backgroundColor = UIColor.clear
            self.leftViewController?.view.frame = CGRect(x: -self.leftViewWidth, y: 0.0, width: self.leftViewWidth, height: self.viewHeight)
        }) { (completed) in
            self.darkBackground.isHidden = true
            self.isLeftViewVisible = false
        }
    }
    
    public func openRightDrawer() {
        
        if self.isRightViewVisible == true {
            return
        }
        
        self.darkBackground.isHidden = false
        self.moveCenterViewRight()
        UIView.animate(withDuration: self.animationDuration, animations: {
            self.darkBackground.backgroundColor = UIColor.black.withAlphaComponent(self.backgroundOpacity)
            self.rightViewController?.view.frame = CGRect(x: self.viewWidth-self.rightViewWidth, y: 0.0, width: self.rightViewWidth, height: self.viewHeight)
        }) { (completed) in
            self.isRightViewVisible = true
        }
    }
    
    public func closeRightDrawer() {
        
        if self.isRightViewVisible == false {
            return
        }
        
        self.resetCenterViewPosition()
        UIView.animate(withDuration: self.animationDuration, animations: {
            self.darkBackground.backgroundColor = UIColor.clear
            self.rightViewController?.view.frame = CGRect(x: self.viewWidth, y: 0.0, width: self.rightViewWidth, height: self.viewHeight)
        }) { (completed) in
            self.darkBackground.isHidden = true
            self.isRightViewVisible = false
        }
    }
    
    private func moveCenterViewLeft() {
        
        if self.drawerType == .side {
            UIView.animate(withDuration: self.animationDuration, animations: {
                self.centerViewController?.view.frame.origin.x = self.leftViewWidth
            })
        }
    }
    
    private func moveCenterViewRight() {
        
        if self.drawerType == .side {
            UIView.animate(withDuration: self.animationDuration, animations: {
                self.centerViewController?.view.frame.origin.x = -self.rightViewWidth
            })
        }
    }
    
    private func resetCenterViewPosition() {
        
        if self.drawerType == .side {
            UIView.animate(withDuration: self.animationDuration, animations: {
                self.centerViewController?.view.frame.origin.x = 0.0
            })
        }
    }
    
    // MARK: - Other Methods
    
    @objc func didTapDarkBackground() {
        
        if self.isLeftViewVisible == true {
            self.closeLeftDrawer()
        } else if self.isRightViewVisible == true {
            self.closeRightDrawer()
        }
    }
    
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
