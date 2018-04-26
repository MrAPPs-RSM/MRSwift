//
//  MRHud.swift
//  MRSwiftExample
//
//  Created by Nicola Innocenti on 25/04/18.
//  Copyright © 2018 Nicola Innocenti. All rights reserved.
//

import UIKit
import PureLayout

public protocol MRLabelDelegate : class {
    func labelDidChangeText(text: String?)
}

open class MRLabel : UILabel {
    
    weak var delegate: MRLabelDelegate?
    
    override open var text: String? {
        
        didSet {
            delegate?.labelDidChangeText(text: text)
        }
    }
}

public enum MRHudTheme {
    case light
    case dark
    case custom(hudColor: UIColor, textColor: UIColor)
}

public enum MRHudStyle {
    case indeterminate
    case linearProgress
    case rotationInside(image: UIImage, duration: TimeInterval)
    case rotationOnly(image: UIImage, duration: TimeInterval)
}

open class MRHud: UIView, MRLabelDelegate {
    
    // MARK: - Views
    
    open var hudView: UIView!
    private var progressView: UIView!
    private var progressBar: UIProgressView!
    private var imageView: UIImageView!
    open var textLabel: MRLabel?
    
    // MARK: - Constraints
    
    var cntTextLabelTop: NSLayoutConstraint!
    
    // MARK: - Constants & Variables
    
    private var theme = MRHudTheme.dark
    private var style = MRHudStyle.indeterminate
    var progress: Float = 0
    private var contentOffset: CGFloat = 16
    private var shadowColor: UIColor = .black
    private var shadowOffset: CGSize = .zero
    private var shadowRadius: CGFloat = 3
    private var shadowOpacity: Float = 0.3
    
    // MARK: - Initialization

    public convenience init(theme: MRHudTheme, style: MRHudStyle) {
        self.init()
        
        backgroundColor = .clear
        clipsToBounds = true
        
        self.theme = theme
        self.style = style
        
        set(style: style)
    }
    
    // MARK: - MRLabel Delegate
    
    public func labelDidChangeText(text: String?) {
        
        fixLabelPosition()
        if superview != nil {
            UIView.animate(withDuration: 0.1) {
                self.layoutIfNeeded()
            }
        }
    }
    
    private func fixLabelPosition() {
        
        if textLabel != nil {
            let validText = textLabel?.text != nil && textLabel?.text?.isEmpty == false
            let offset: CGFloat = validText ? contentOffset : 0
            if cntTextLabelTop == nil {
                cntTextLabelTop = textLabel?.autoPinEdge(.top, to: .bottom, of: progressView, withOffset: offset)
            } else {
                cntTextLabelTop.constant = offset
            }
        }
    }
    
    // MARK: - Linear Progress Handlers
    
    open func set(progress: Float) {
        
        if progressBar != nil {
            progressBar.setProgress(progress, animated: true)
        }
    }
    
    open func setProgressColors(emptyColor: UIColor, filledColor: UIColor) {
        
        if progressBar != nil {
            progressBar.trackTintColor = emptyColor
            progressBar.progressTintColor = filledColor
        }
    }
    
    // MARK: - Shadow Handlers
    
    open func enableShadow(enable: Bool) {
        
        if hudView != nil {
            if enable {
                hudView.layer.shadowColor = shadowColor.cgColor
                hudView.layer.shadowOffset = shadowOffset
                hudView.layer.shadowRadius = shadowRadius
                hudView.layer.shadowOpacity = shadowOpacity
            } else {
                hudView.layer.shadowColor = UIColor.black.cgColor
                hudView.layer.shadowOffset = .zero
                hudView.layer.shadowRadius = 0
                hudView.layer.shadowOpacity = 0
            }
        }
    }
    
    open func setShadow(color: UIColor, offset: CGSize, radius: CGFloat, opacity: Float) {
        
        shadowColor = color
        shadowOffset = offset
        shadowRadius = radius
        shadowOpacity = opacity
        enableShadow(enable: true)
    }
    
    // MARK: - Hud Visibility Handlers
    
    open func set(style: MRHudStyle) {
        
        self.style = style
        if progressView != nil {
            progressView.removeSubviews()
        }
        
        switch style {
            
            case .indeterminate:
            
                setupHudView()
                
                progressView.removeSubviews()
                let spinner = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
                spinner.color = .lightGray
                
                progressView.addSubview(spinner)
                spinner.autoPinEdgesToSuperviewEdges()
                spinner.startAnimating()
            
            case .linearProgress:
            
                setupHudView()
                
                progressBar = UIProgressView(progressViewStyle: .default)
                progressBar.autoSetDimensions(to: CGSize(width: 200, height: 6))
                progressBar.clipsToBounds = true
                progressBar.layer.cornerRadius = 3
                
                progressView.addSubview(progressBar)
                progressBar.trackTintColor = UIColor(netHex: 0x999999)
                progressBar.progressTintColor = .green
                progressBar.progress = 0.5
                progressBar.autoAlignAxis(toSuperviewAxis: .vertical)
                progressBar.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16))
            
            case .rotationInside(image: let image, duration: let duration):
            
                setupHudView()
                
                imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
                imageView.image = image
                imageView.clipsToBounds = true
                imageView.contentMode = .scaleAspectFit
                imageView.autoSetDimensions(to: CGSize(width: 60, height: 60))
                
                progressView.addSubview(imageView)
                imageView.autoAlignAxis(toSuperviewAxis: .vertical)
                imageView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16))
            
                imageView.layer.transform = CATransform3DMakeScale(1.0, 1.0, 1.0)
                
                UIView.animateKeyframes(withDuration: duration, delay: 0, options:[.repeat, .autoreverse], animations: {
                        self.imageView.layer.transform = CATransform3DMakeScale(-1.0, 1.0, 1.0)
                }) { (completed) in
                    
                }
            
            case .rotationOnly(image: let image, duration: let duration):
                
                removeHudView()
            
                imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
                imageView.image = image
                imageView.clipsToBounds = true
                imageView.contentMode = .scaleAspectFit
                imageView.autoSetDimensions(to: CGSize(width: 80, height: 80))
            
                addSubview(imageView)
                imageView.autoCenterInSuperview()
            
                imageView.layer.transform = CATransform3DMakeScale(1.0, 1.0, 1.0)
                
                UIView.animateKeyframes(withDuration: duration, delay: 0, options:[.repeat, .autoreverse], animations: {
                    self.imageView.layer.transform = CATransform3DMakeScale(-1.0, 1.0, 1.0)
                }) { (completed) in
                    
                }
        }
    }
    
    private func setupHudView() {
        
        if imageView != nil {
            imageView.removeFromSuperview()
        }
        
        if hudView != nil {
            return
        }
        
        hudView = UIView()
        hudView.layer.cornerRadius = 8
        hudView.layer.borderWidth = 1/UIScreen.main.scale
        hudView.layer.borderColor = UIColor.lightGray.cgColor
        hudView.autoSetDimension(.width, toSize: 30, relation: .greaterThanOrEqual)
        hudView.autoSetDimension(.height, toSize: 30, relation: .greaterThanOrEqual)
        
        progressView = UIView()
        
        textLabel = MRLabel()
        textLabel?.delegate = self
        textLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        textLabel?.textAlignment = .center
        textLabel?.numberOfLines = 0
        
        switch theme {
            case .light:
                hudView.backgroundColor = UIColor(netHex: 0xffffff)
                textLabel?.textColor = .white
            case .dark:
                hudView.backgroundColor = UIColor(netHex: 0x555555)
                textLabel?.textColor = .black
            case .custom(hudColor: let hudColor, textColor: let textColor):
                hudView.backgroundColor = hudColor
                textLabel?.textColor = textColor
        }
        
        hudView.addSubview(progressView)
        progressView.autoAlignAxis(toSuperviewAxis: .vertical)
        progressView.autoPinEdge(toSuperviewEdge: .top, withInset: contentOffset)
        progressView.autoPinEdge(toSuperviewEdge: .left, withInset: contentOffset, relation: .greaterThanOrEqual)
        progressView.autoPinEdge(toSuperviewEdge: .right, withInset: contentOffset, relation: .greaterThanOrEqual)
        
        hudView.addSubview(textLabel!)
        fixLabelPosition()
        textLabel?.autoPinEdge(toSuperviewEdge: .bottom, withInset: contentOffset)
        textLabel?.autoPinEdge(toSuperviewEdge: .left, withInset: contentOffset)
        textLabel?.autoPinEdge(toSuperviewEdge: .right, withInset: contentOffset)

        addSubview(hudView)
        hudView.autoCenterInSuperview()
        hudView.autoPinEdge(toSuperviewEdge: .top, withInset: 32, relation: .greaterThanOrEqual)
        hudView.autoPinEdge(toSuperviewEdge: .bottom, withInset: 32, relation: .greaterThanOrEqual)
        hudView.autoPinEdge(toSuperviewEdge: .left, withInset: 32, relation: .greaterThanOrEqual)
        hudView.autoPinEdge(toSuperviewEdge: .right, withInset: 32, relation: .greaterThanOrEqual)
    }
    
    private func removeHudView() {
        
        if self.hudView != nil {
            self.hudView.removeFromSuperview()
        }
    }
    
    open func show(in view: UIView) {
        
        if superview == nil {
            view.addSubview(self)
            autoPinEdgesToSuperviewEdges()
        }
    }
    
    open func show(in view: UIView, animated: Bool) {
        
        if superview == nil {
            view.addSubview(self)
            autoPinEdgesToSuperviewEdges()
            if animated {
                alpha = 0.0
                UIView.animate(withDuration: 0.3) {
                    self.alpha = 1.0
                }
            }
        }
    }
    
    open func hide() {
        removeFromSuperview()
    }
    
    open func hide(animated: Bool) {
        
        if animated {
            UIView.animate(withDuration: 0.3, animations: {
                self.alpha = 1.0
            }) { (completed) in
                self.removeFromSuperview()
            }
        } else {
            removeFromSuperview()
        }
    }
}
