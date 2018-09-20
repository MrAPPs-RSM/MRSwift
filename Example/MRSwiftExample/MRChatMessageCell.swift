//
//  MRChatMessageCell.swift
//  MRSwiftExample
//
//  Created by Nicola Innocenti on 18/06/18.
//  Copyright © 2018 Nicola Innocenti. All rights reserved.
//

import UIKit
import MRSwift
import PureLayout
import TTTAttributedLabel

public protocol MRChatMessageCellDelegate : class {
    func mrChatMessageCellDidSelectUrl(cell: MRChatMessageCell, url: URL)
    func mrChatMessageCellDidSelectImage(cell: MRChatMessageCell, image: UIImage?)
}

public enum MRChatMessageCellStyle {
    case text
    case audio
    case video
    case image
}

open class MRChatMessageCell: UITableViewCell, TTTAttributedLabelDelegate {
    
    // MARK: - Layout
    
    open var bubbleContainerView: UIView!
    open var bubbleView: UIImageView?
    open var lblSenderName: UILabel?
    open var lblMessage: TTTAttributedLabel?
    open var imgImage: UIImageView?
    open var lblMessageDate: UILabel!
    
    // MARK: - Constraints
    
    private var cntBubbleContainerTop: NSLayoutConstraint!
    private var cntBubbleContainerLeading: NSLayoutConstraint!
    private var cntBubbleContainerTrailing: NSLayoutConstraint!
    
    // MARK: - Constants & Variables
    
    open weak var delegate: MRChatMessageCellDelegate?
    open var style = MRChatMessageCellStyle.text
    open var isSender = true
    open var isSenderNameActive = false
    var senderPosition = ItemPosition.inside
    var messageDatePosition = ItemPosition.inside
    
    // MARK: - Initialization
    
    public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupUI()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Cell Methods
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        
        setupUI()
    }
    
    override open func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    // MARK: - Configuration Methods
    
    private func setupUI() {
        
        autoresizingMask = [.flexibleHeight]
        
        selectionStyle = .none
        
        //Creating container for all layout components
        
        bubbleContainerView = UIView()
        bubbleContainerView.isUserInteractionEnabled = true
        
        addSubview(bubbleContainerView)
        cntBubbleContainerTop = bubbleContainerView.autoPinEdge(toSuperviewEdge: .top, withInset: 8)
        cntBubbleContainerLeading = bubbleContainerView.autoPinEdge(toSuperviewEdge: .leading, withInset: 40, relation: .greaterThanOrEqual)
        cntBubbleContainerTrailing = bubbleContainerView.autoPinEdge(toSuperviewEdge: .trailing, withInset: 8)
        bubbleContainerView.autoPinEdge(toSuperviewEdge: .bottom, withInset: 0)
        
        //Creating UIImageView to show bubble images
        
        bubbleView = UIImageView()
        bubbleView?.clipsToBounds = true
        bubbleView?.contentMode = .scaleToFill
        bubbleView?.isUserInteractionEnabled = true
        
        bubbleContainerView.addSubview(bubbleView!)
        bubbleView?.autoPinEdgesToSuperviewEdges()
    }
    
    open func configure(style: MRChatMessageCellStyle) {
        
        self.style = style
        
        //Changing trailing and leading constraints to keep lateral spacing depending on current sender
        
        NSLayoutConstraint.deactivate([cntBubbleContainerLeading, cntBubbleContainerTrailing])
        if isSender {
            cntBubbleContainerLeading = bubbleContainerView.autoPinEdge(toSuperviewEdge: .leading, withInset: 40, relation: .greaterThanOrEqual)
            cntBubbleContainerTrailing = bubbleContainerView.autoPinEdge(toSuperviewEdge: .trailing, withInset: 8)
            
        } else {
            cntBubbleContainerLeading = bubbleContainerView.autoPinEdge(toSuperviewEdge: .leading, withInset: 8)
            cntBubbleContainerTrailing = bubbleContainerView.autoPinEdge(toSuperviewEdge: .trailing, withInset: 40, relation: .greaterThanOrEqual)
        }
        NSLayoutConstraint.activate([cntBubbleContainerLeading, cntBubbleContainerTrailing])
        
        if style == .text {
            createMessageLabel()

        } else if style == .image {
            createImage()
        }
        
        if isSenderNameActive {
            createSenderName()
        }
        
        createMessageDate()
        applyConstraints()
    }
    
    open func setBubbleTopSpacing(value: CGFloat) {
        cntBubbleContainerTop.constant = value
    }
    
    open func setText(text: String?) {
        
        var realText = text ?? ""
        let endSpace = " aaaa"
        realText += endSpace
        
        lblMessage?.setText(realText) { (attributedString) -> NSMutableAttributedString? in
            attributedString?.addAttribute(
                kCTForegroundColorAttributeName as NSAttributedStringKey,
                value: UIColor.clear,
                range: NSRange(location: attributedString!.length-endSpace.count, length: endSpace.count)
            )
            return attributedString
        }
    }
    
    private func createMessageLabel() {
        
        //Removing media layout components
        
        imgImage?.removeConstraints()
        imgImage?.removeFromSuperview()
        imgImage = nil
        
        if lblMessage == nil {
            
            //Creating message UILabel with link support
            
            lblMessage = TTTAttributedLabel(frame: .zero)
            lblMessage?.enabledTextCheckingTypes = NSTextCheckingAllTypes
            lblMessage?.delegate = self
            lblMessage?.activeLinkAttributes = [
                NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 16),
                NSAttributedStringKey.foregroundColor: UIColor.white.darker,
                NSAttributedStringKey.underlineStyle: NSUnderlineStyle.styleSingle.rawValue
            ]
            lblMessage?.linkAttributes = [
                NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 16),
                NSAttributedStringKey.foregroundColor: UIColor.white,
                NSAttributedStringKey.underlineStyle: NSUnderlineStyle.styleSingle.rawValue
            ]
            lblMessage?.inactiveLinkAttributes = [
                NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 16),
                NSAttributedStringKey.foregroundColor: UIColor.white,
                NSAttributedStringKey.underlineStyle: NSUnderlineStyle.styleSingle.rawValue
            ]
            lblMessage?.numberOfLines = 0
            lblMessage?.textColor = .white
            bubbleView?.addSubview(lblMessage!)
            
            lblMessage?.autoPinEdge(toSuperviewEdge: .bottom, withInset: 8)
        }
    }
    
    private func createImage() {
        
        //Removing not needed components
        
        lblMessage?.removeConstraints()
        lblMessage?.removeFromSuperview()
        lblMessage = nil
        
        if imgImage == nil {
            
            //Creating UIImageView containing message image
            
            imgImage = UIImageView()
            imgImage?.clipsToBounds = true
            imgImage?.contentMode = .scaleAspectFill
            imgImage?.isUserInteractionEnabled = true
            bubbleView?.insertSubview(imgImage!, at: 0)
            imgImage?.autoPinEdgesToSuperviewEdges()
            imgImage?.autoSetDimension(.width, toSize: 280)
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(didTapImage))
            tap.numberOfTapsRequired = 1
            imgImage?.addGestureRecognizer(tap)
        }
    }
    
    private func createSenderName() {
        
        if lblSenderName == nil {
            
            //Creating UILabel showing message sender
            
            lblSenderName = UILabel()
            lblSenderName?.textColor = .white
            
            //Can be shown inside the bubble or outside
            
            if senderPosition == .inside {
                
                lblSenderName?.textColor = .white
                bubbleView?.addSubview(lblSenderName!)
                lblSenderName!.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8), excludingEdge: .bottom)
                
            } else {
                
                lblSenderName?.textColor = .gray
                addSubview(lblSenderName!)
                lblSenderName?.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8), excludingEdge: .bottom)
                NSLayoutConstraint.deactivate([cntBubbleContainerTop])
                cntBubbleContainerTop = bubbleContainerView.autoPinEdge(.top, to: .bottom, of: lblSenderName!, withOffset: 8)
                NSLayoutConstraint.activate([cntBubbleContainerTop])
            }
        }
        
        if senderPosition == .inside {
            
            if style == .text {
                
                //Sender name without shadow for text messages
                
                lblSenderName?.layer.shadowColor = UIColor.clear.cgColor
                lblSenderName?.layer.shadowOffset = .zero
                lblSenderName?.layer.shadowRadius = 0
                lblSenderName?.layer.shadowOpacity = 0
                lblSenderName?.layer.masksToBounds = true
                
            } else {
                
                //Sender name with shadow for media messages because they can have background with same color
                
                lblSenderName?.layer.shadowColor = UIColor.black.cgColor
                lblSenderName?.layer.shadowOffset = .zero
                lblSenderName?.layer.shadowRadius = 2
                lblSenderName?.layer.shadowOpacity = 1
                lblSenderName?.layer.masksToBounds = false
            }
        }
    }
    
    private func createMessageDate() {
        
        if lblMessageDate == nil {
            
            lblMessageDate = UILabel()
            
            if messageDatePosition == .inside {
                bubbleView?.insertSubview(lblMessageDate!, at: 1)
            } else {
                addSubview(lblMessageDate!)
                lblMessageDate.autoPinEdge(.top, to: .bottom, of: bubbleContainerView, withOffset: 8)
            }
            lblMessageDate?.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8), excludingEdge: .top)
        }
        
        if style == .text || messageDatePosition == .outside {
            
            lblMessageDate.textColor = .white
            
            lblMessageDate?.layer.shadowColor = UIColor.clear.cgColor
            lblMessageDate?.layer.shadowOffset = .zero
            lblMessageDate?.layer.shadowRadius = 0
            lblMessageDate?.layer.shadowOpacity = 0
            lblMessageDate?.layer.masksToBounds = true
            
        } else {
            
            lblMessageDate.textColor = .white
            
            lblMessageDate?.layer.shadowColor = UIColor.black.cgColor
            lblMessageDate?.layer.shadowOffset = .zero
            lblMessageDate?.layer.shadowRadius = 2
            lblMessageDate?.layer.shadowOpacity = 1
            lblMessageDate?.layer.masksToBounds = false
        }
    }
    
    private func applyConstraints() {
        
        if senderPosition == .inside {
            lblMessage?.autoPinEdge(toSuperviewEdge: .leading, withInset: 8)
            lblMessage?.autoPinEdge(toSuperviewEdge: .trailing, withInset: 8)
            lblMessage?.autoPinEdge(.top, to: .bottom, of: lblSenderName!, withOffset: 8)
        } else {
            lblMessage?.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8))
        }
    }
    
    @objc func didTapImage() {
        delegate?.mrChatMessageCellDidSelectImage(cell: self, image: imgImage?.image)
    }
    
    // MARK: - TTTAttributedLabel Delegate
    
    public func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        delegate?.mrChatMessageCellDidSelectUrl(cell: self, url: url)
    }
}
