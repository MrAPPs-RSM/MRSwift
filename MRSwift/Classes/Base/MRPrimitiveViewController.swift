//
//  MRPrimitiveViewController.swift
//  MRSwiftExample
//
//  Created by Nicola Innocenti on 01/05/17.
//  Copyright © 2017 Nicola Innocenti. All rights reserved.
//

import UIKit

open class KeyboardInfo : NSObject {
    public var beginFrame: CGRect = CGRect.zero
    public var endFrame: CGRect = CGRect.zero
    public var animationDuration: Double = 0.0
    public var animationCurve: UInt = 0
}

open class MRPrimitiveViewController: UIViewController {
    
    // MARK: - Initialization
    
    deinit {
        self.unregisterForKeyboardNotifications()
    }
    
    // MARK: - UIViewController Methods
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.registerForKeyboardNotifications()
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.unregisterForKeyboardNotifications()
    }
    
    // MARK: - Keyboard Handlers
    
    open func registerForKeyboardNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.internalKeyboardWillChangeFrame(notification:)), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.internalKeyboardWillShow(notification:)), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.internalKeyboardDidShow(notification:)), name: Notification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.internalKeyboardWillHide(notification:)), name: Notification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.internalKeyboardDidHide(notification:)), name: Notification.Name.UIKeyboardDidHide, object: nil)
    }
    
    open func unregisterForKeyboardNotifications() {
        
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIKeyboardDidHide, object: nil)
    }
    
    @objc private func internalKeyboardWillChangeFrame(notification: Notification) {
        self.keyboardWillChangeFrame(keyboardInfo: self.getKeyboardInfo(fromNotification: notification))
    }
    
    @objc private func internalKeyboardWillShow(notification: Notification) {
        self.keyboardWillShow(keyboardInfo: self.getKeyboardInfo(fromNotification: notification))
    }
    
    @objc private func internalKeyboardDidShow(notification: Notification) {
        self.keyboardDidShow(keyboardInfo: self.getKeyboardInfo(fromNotification: notification))
    }
    
    @objc private func internalKeyboardWillHide(notification: Notification) {
        self.keyboardWillHide(keyboardInfo: self.getKeyboardInfo(fromNotification: notification))
    }
    
    @objc private func internalKeyboardDidHide(notification: Notification) {
        self.keyboardDidHide(keyboardInfo: self.getKeyboardInfo(fromNotification: notification))
    }
    
    open func keyboardWillChangeFrame(keyboardInfo: KeyboardInfo) {
        
    }
    
    open func keyboardWillShow(keyboardInfo: KeyboardInfo) {
        
    }
    
    open func keyboardDidShow(keyboardInfo: KeyboardInfo) {
        
    }
    
    open func keyboardWillHide(keyboardInfo: KeyboardInfo) {
        
    }
    
    open func keyboardDidHide(keyboardInfo: KeyboardInfo) {
        
    }
    
    private func getKeyboardInfo(fromNotification: Notification) -> KeyboardInfo {
        
        let userInfo: NSDictionary = fromNotification.userInfo! as NSDictionary
        let beginFrame = (userInfo.value(forKey: UIKeyboardFrameBeginUserInfoKey) as! NSValue).cgRectValue
        let endFrame = (userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue).cgRectValue
        let animationDuration: Double = userInfo.value(forKey: UIKeyboardAnimationDurationUserInfoKey) as! Double
        let animationCurve: UInt = userInfo.value(forKey: UIKeyboardAnimationCurveUserInfoKey) as! UInt
        
        let keyboardInfo = KeyboardInfo()
        keyboardInfo.beginFrame = beginFrame
        keyboardInfo.endFrame = endFrame
        keyboardInfo.animationDuration = animationDuration
        keyboardInfo.animationCurve = animationCurve
        
        return keyboardInfo
    }
    
    // MARK: - Others Methods
    
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
