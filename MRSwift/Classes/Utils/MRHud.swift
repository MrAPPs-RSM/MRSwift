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
    case indefinite
    case linearProgress
}

open class MRHud: UIView, MRLabelDelegate {
    
    // MARK: - Views
    
    open var hudView: UIView!
    private var progressView: UIView!
    open var textLabel: MRLabel!
    
    // MARK: - Constraints
    
    var cntTextLabelTop: NSLayoutConstraint!
    
    // MARK: - Constants & Variables
    
    var progress: Float = 0
    private var contentOffset: CGFloat = 16
    
    // MARK: - Initialization

    public convenience init(theme: MRHudTheme, style: MRHudStyle) {
        self.init()
        
        backgroundColor = .clear
        clipsToBounds = true
        
        hudView = UIView()
        hudView.layer.cornerRadius = 8
        hudView.layer.borderWidth = 1/UIScreen.main.scale
        hudView.layer.borderColor = UIColor.lightGray.cgColor
        hudView.autoSetDimension(.width, toSize: 120, relation: .greaterThanOrEqual)
        hudView.autoSetDimension(.height, toSize: 80, relation: .greaterThanOrEqual)
        
        progressView = UIView()
        textLabel = MRLabel()
        textLabel.delegate = self
        textLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        textLabel.textAlignment = .center
        
        switch theme {
            case .light:
                hudView.backgroundColor = UIColor(netHex: 0xffffff)
                textLabel.textColor = .white
            case .dark:
                hudView.backgroundColor = UIColor(netHex: 0x555555)
                textLabel.textColor = .black
            case .custom(hudColor: let hudColor, textColor: let textColor):
                hudView.backgroundColor = hudColor
                textLabel.textColor = textColor
        }

        hudView.addSubview(progressView)
        progressView.autoAlignAxis(toSuperviewAxis: .vertical)
        progressView.autoPinEdge(toSuperviewEdge: .top, withInset: contentOffset)
        progressView.autoPinEdge(toSuperviewEdge: .left, withInset: contentOffset, relation: .greaterThanOrEqual)
        progressView.autoPinEdge(toSuperviewEdge: .right, withInset: contentOffset, relation: .greaterThanOrEqual)
        
        hudView.addSubview(textLabel)
        fixLabelPosition()
        textLabel.autoPinEdge(toSuperviewEdge: .bottom, withInset: contentOffset)
        textLabel.autoPinEdge(toSuperviewEdge: .left, withInset: contentOffset)
        textLabel.autoPinEdge(toSuperviewEdge: .right, withInset: contentOffset)
        
        set(style: style)
        
        addSubview(hudView)
        hudView.autoCenterInSuperview()
    }
    
    // MARK: - MRLabel Delegate
    
    public func labelDidChangeText(text: String?) {
        fixLabelPosition()
    }
    
    private func fixLabelPosition() {
     
        let validText = textLabel.text != nil && textLabel.text?.isEmpty == false
        let offset: CGFloat = validText ? contentOffset : 0
        textLabel.autoPinEdge(.top, to: .bottom, of: progressView, withOffset: contentOffset)
    }
    
    // MARK: - Other Methods
    
    open func set(style: MRHudStyle) {
        
        if style == .indefinite {
            
            progressView.removeSubviews()
            let spinner = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
            
            progressView.addSubview(spinner)
            spinner.autoPinEdgesToSuperviewEdges()
            spinner.startAnimating()
            
        } else if style == .linearProgress {
            
            
        }
    }
    
    open func enableShadow(enable: Bool) {
        
        if enable {
            hudView.layer.shadowColor = UIColor.black.cgColor
            hudView.layer.shadowOffset = .zero
            hudView.layer.shadowRadius = 5
            hudView.layer.shadowOpacity = 0.3
        } else {
            hudView.layer.shadowColor = UIColor.black.cgColor
            hudView.layer.shadowOffset = .zero
            hudView.layer.shadowRadius = 0
            hudView.layer.shadowOpacity = 0
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
    
    open func set(progress: Float) {
        
        
    }
}
