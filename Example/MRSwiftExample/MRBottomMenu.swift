//
//  MRBottomMenu.swift
//  MRSwiftExample
//
//  Created by Nicola Innocenti on 11/07/2019.
//  Copyright © 2019 Nicola Innocenti. All rights reserved.
//

import UIKit
import PureLayout

extension UIViewController: UIViewControllerTransitioningDelegate {
    
    // MARK: - Animation
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return MRBottomMenuAnimation(presenting: true)
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return MRBottomMenuAnimation(presenting: false)
    }
}

class MRBottomMenuAnimation: NSObject, UIViewControllerAnimatedTransitioning {
    
    private var presenting: Bool = true
    
    convenience init(presenting: Bool) {
        self.init()
        
        self.presenting = presenting
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 1.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        if presenting {
            
            guard let toViewController = transitionContext.viewController(forKey: .to) else {
                return
            }
            transitionContext.containerView.addSubview(toViewController.view)
            toViewController.view.alpha = 0
            
            let duration = self.transitionDuration(using: transitionContext)
            UIView.animate(withDuration: duration, animations: {
                toViewController.view.frame = CGRect(x: 0, y: 0, width: toViewController.view.frame.size.width, height: toViewController.view.frame.size.height)
            }, completion: { _ in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            })
            
        } else {
            
            guard let fromViewController = transitionContext.viewController(forKey: .from) else {
                return
            }
 
            let duration = self.transitionDuration(using: transitionContext)
            UIView.animate(withDuration: duration, animations: {
                fromViewController.view.frame = CGRect(x: 0, y: fromViewController.view.frame.size.height, width: fromViewController.view.frame.size.width, height: fromViewController.view.frame.size.height)
            }, completion: { _ in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            })
        }
    }
}

public typealias MRBottomMenuAction = () -> Void

public class MRBottomMenuSection : NSObject {
    
    public var key: String?
    public var title: String?
    public var items = [MRBottomMenuItem]()
    
    convenience init(key: String?, title: String?, items: [MRBottomMenuItem]) {
        self.init()
        
        self.key = key
        self.title = title
        self.items = items
    }
}

public class MRBottomMenuItem : NSObject {
    
    public var key: String?
    public var title: String?
    public var image: UIImage?
    public var action: MRBottomMenuAction?
    
    convenience init(key: String?, title: String?, image: UIImage?, action: MRBottomMenuAction?) {
        self.init()
        
        self.key = key
        self.title = title
        self.image = image
        self.action = action
    }
}

private class MRBottomMenuHeader : UICollectionReusableView {
    
    var textLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        textLabel = UILabel()
        textLabel.textAlignment = .left
        textLabel.textColor = .lightGray
        textLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        addSubview(textLabel)
        textLabel.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16))
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

private class MRBottomMenuCollectionCell : UICollectionViewCell {
    
    var textLabel: UILabel!
    var imageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .clear
        
        let view = UIView()
        view.backgroundColor = .clear
        addSubview(view)
        view.autoSetDimensions(to: CGSize(width: 100, height: 100))
        view.autoCenterInSuperview()
        
        imageView = UIImageView()
        imageView.backgroundColor = .lightGray
        imageView.layer.cornerRadius = 50
        view.addSubview(imageView)
        imageView.autoPinEdge(toSuperviewEdge: .top)
        imageView.autoPinEdge(toSuperviewEdge: .leading, withInset: 0, relation: .greaterThanOrEqual)
        imageView.autoPinEdge(toSuperviewEdge: .trailing, withInset: 0, relation: .greaterThanOrEqual)
        imageView.autoAlignAxis(toSuperviewAxis: .vertical)
        
        textLabel = UILabel()
        textLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        textLabel.textAlignment = .center
        textLabel.textColor = .black
        view.addSubview(textLabel)
        textLabel.autoPinEdges(toSuperviewMarginsExcludingEdge: .top)
        textLabel.autoPinEdge(.top, to: .bottom, of: imageView, withOffset: 8)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let imageViewSize = frame.size.width*0.5
        imageView.layer.cornerRadius = imageViewSize/2
        imageView.autoSetDimensions(to: CGSize(width: imageViewSize, height: imageViewSize))
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func configure(item: MRBottomMenuItem) {
        
        textLabel.text = item.title
        imageView.image = item.image
    }
}

open class MRBottomMenu: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    // MARK: - Layout
    
    private var cvItems: UICollectionView!
    
    // MARK: - Constants & Variables
    
    private var data = [MRBottomMenuSection]()
    private let headerIdentifier = "headerIdentifier"
    private let cellIdentifier = "cellIdentifier"
    private var columns: CGFloat = 4
    private let spacing: CGFloat = 8
    
    // MARK: - Initialization
    
    convenience init(data: [MRBottomMenuSection]) {
        self.init()
        
        self.data = data
        modalPresentationStyle = .custom
    }
    
    // MARK: - UIViewController Methods

    override open func viewDidLoad() {
        super.viewDidLoad()
    
        setupLayout()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(close))
        tap.numberOfTapsRequired = 1
        view.addGestureRecognizer(tap)
    }
    
    private func setupLayout() {
        
        //view.backgroundColor = .clear
        
        let effect = UIBlurEffect(style: .prominent)
        let background = UIVisualEffectView(effect: effect)
        view.addSubview(background)
        background.autoPinEdgesToSuperviewEdges()
        
        let container = UIView()
        container.backgroundColor = .clear
        container.clipsToBounds = true
        container.layer.cornerRadius = 24
        //container.layer.masksToBounds = false
        //container.layer.shadowRadius = 10
        //container.layer.shadowColor = UIColor.black.cgColor
        //container.layer.shadowOpacity = 0.2
        view.addSubview(container)
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            
            columns = 4
            container.autoPinEdge(toSuperviewEdge: .bottom, withInset: UIView.safeArea.bottom > 0 ? 0 : spacing*2)
            container.autoSetDimension(.width, toSize: 400)
            container.autoSetDimension(.height, toSize: 300)
            container.autoAlignAxis(toSuperviewAxis: .vertical)
            
        } else {
            
            columns = 4
            container.autoPinEdge(toSuperviewEdge: .bottom, withInset: UIView.safeArea.bottom > 0 ? UIView.safeArea.bottom : spacing*2)
            container.autoPinEdge(toSuperviewEdge: .leading, withInset: UIView.safeArea.left > 0 ? UIView.safeArea.left : spacing*2)
            container.autoPinEdge(toSuperviewEdge: .trailing, withInset: UIView.safeArea.right > 0 ? UIView.safeArea.right : spacing*2)
            container.autoSetDimension(.height, toSize: 300)
        }
        
        cvItems = UICollectionView(frame: view.frame, collectionViewLayout: UICollectionViewFlowLayout())
        cvItems.contentInset = UIEdgeInsets(top: spacing, left: 0, bottom: spacing, right: 0)
        cvItems.clipsToBounds = true
        cvItems.layer.cornerRadius = 24
        cvItems.dataSource = self
        cvItems.delegate = self
        cvItems.backgroundColor = .clear
        cvItems.showsVerticalScrollIndicator = false
        cvItems.register(MRBottomMenuCollectionCell.self, forCellWithReuseIdentifier: cellIdentifier)
        cvItems.register(MRBottomMenuHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIdentifier)
        
        container.addSubview(cvItems)
        cvItems.autoPinEdgesToSuperviewEdges()
    }
    
    // MARK: - UICollectionView DataSource
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return data.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        let dataSection = data[section]
        return dataSection.items.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let section = data[indexPath.section]
        
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerIdentifier, for: indexPath) as! MRBottomMenuHeader
        header.textLabel.text = section.title?.uppercased()
        return header
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! MRBottomMenuCollectionCell
        
        let section = data[indexPath.section]
        let row = section.items[indexPath.row]
        cell.configure(item: row)
        
        return cell
    }
    
    // MARK: - UICollectionView Delegate
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let section = data[indexPath.section]
        let row = section.items[indexPath.row]
        
        if let action = row.action {
            action()
        }
    }
    
    // MARK: - UICollectionViewFlowLayout Delegate
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.size.width, height: 44)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = ((collectionView.frame.size.width-(spacing*(columns+1)))/columns).rounded(.down)
        let height = width
        return CGSize(width: width, height: height)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return spacing
    }

    // MARK: - Other Methods
    
    @objc func close() {
        dismiss(animated: true, completion: nil)
    }
}
