//
//  MRExtensions.swift
//  MRSwift
//
//  Created by Nicola Innocenti on 22/04/17.
//  Copyright © 2017 Nicola Innocenti. All rights reserved.
//

import Foundation
import SafariServices

public extension URL {
    
    public var fileExists : Bool {
        return FileManager.default.fileExists(atPath: self.path)
    }
    
    public func ignoreCloudBackup() {
        
        var urlCopy = self
        var values = URLResourceValues()
        values.isExcludedFromBackup = true
        
        do {
            try urlCopy.setResourceValues(values)
        } catch {
            print("[iCloud URL] \(error.localizedDescription)")
        }
    }
}

public extension String {
    
    public var containsOnlyDecimals : Bool {
        
        let set = NSCharacterSet.decimalDigits.inverted
        let range = self.rangeOfCharacter(from: set)
        return range == nil
    }
    
    public var isValidEmail : Bool {
        do {
            let regex = try NSRegularExpression(pattern: "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}", options: .caseInsensitive)
            return regex.firstMatch(in: self, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, self.characters.count)) != nil
        } catch {
            return false
        }
    }
    
    public var isValidRemoteUrl : Bool {
        
        if let url = URL(string: self) {
            return true
        } else {
            return false
        }
    }
}

public extension UIColor {
    
    public var darker : UIColor {
        
        var r:CGFloat = 0, g:CGFloat = 0, b:CGFloat = 0, a:CGFloat = 0
        if self.getRed(&r, green: &g, blue: &b, alpha: &a){
            return UIColor(red: max(r - 0.10, 0.0), green: max(g - 0.10, 0.0), blue: max(b - 0.10, 0.0), alpha: a)
        }
        return UIColor()
    }
    
    public var lighter : UIColor {
        
        var r:CGFloat = 0, g:CGFloat = 0, b:CGFloat = 0, a:CGFloat = 0
        if self.getRed(&r, green: &g, blue: &b, alpha: &a){
            return UIColor(red: min(r + 0.1, 1.0), green: min(g + 0.1, 1.0), blue: min(b + 0.1, 1.0), alpha: a)
        }
        return UIColor()
    }
}

public extension UIView {
    
    public func removeSubviews() {
        for view in self.subviews {
            view.removeFromSuperview()
        }
    }
    
    public func setBorders(borderWidth: CGFloat, borderColor: UIColor?, cornerRadius: CGFloat) {
        
        self.layer.borderWidth = borderWidth
        if borderColor != nil {
            self.layer.borderColor = borderColor?.cgColor
        }
        self.layer.cornerRadius = cornerRadius
    }
    
    public func addShadow(color: UIColor, offset: CGSize, opacity: Float) {
        
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offset
        layer.shadowRadius = offset.height
    }
}

public extension UIDevice {
    
    public var diskTotalSpace : Int64? {
        
        var value: Int64?
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        if let path = paths.last?.path {
            do {
                let dictionary = try FileManager.default.attributesOfFileSystem(forPath: path) as [FileAttributeKey : Any]
                if let totalSize = dictionary[.systemSize] as? NSNumber {
                    value = (totalSize.int64Value/1024)/1024
                }
            } catch {
                print("[Device Disk Space] Error: \(error.localizedDescription)")
            }
            
        }
        return value
    }
    
    public var diskFreeSpace : Int64? {
        
        var value: Int64?
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        if let path = paths.last?.path {
            do {
                let dictionary = try FileManager.default.attributesOfFileSystem(forPath: path) as [FileAttributeKey : Any]
                if let freeSize = dictionary[.systemFreeSize] as? NSNumber {
                    value = (freeSize.int64Value/1024)/1024
                }
            } catch {
                print("[Device Disk Space] Error: \(error.localizedDescription)")
            }
            
        }
        return value
    }
    
    public class var isPortrait : Bool {
        return UIApplication.shared.statusBarOrientation == .portrait || UIApplication.shared.statusBarOrientation == .portraitUpsideDown
    }
}

public extension Bundle {
    
    public var appName : String {
        return Bundle.main.infoDictionary![kCFBundleNameKey as String] as! String
    }
}

public extension UIScreen {
    
    public class var width : CGFloat {
        return UIDevice.isPortrait ? UIScreen.main.bounds.size.width : UIScreen.main.bounds.size.height
    }
    
    public class var height : CGFloat {
        return UIDevice.isPortrait ? UIScreen.main.bounds.size.height : UIScreen.main.bounds.size.width
    }
    
    public class var separatorHeight : CGFloat {
        return 1/UIScreen.main.scale
    }
}

public typealias UIAlertActionBlock = (_ action: UIAlertAction) -> Void
public extension UIAlertController {
    
    public class func new(title: String?, message: String?, tintColor: UIColor?, preferredStyle: UIAlertControllerStyle) -> UIAlertController {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
        if let tint = tintColor {
            alert.view.tintColor = tint
        }
        return alert
    }
    
    public func addCancelAction(title: String?, handler: UIAlertActionBlock?) {
        
        let action = UIAlertAction(title: title, style: .cancel, handler: handler)
        self.addAction(action)
    }
    
    public func addDefaultAction(title: String?, handler: UIAlertActionBlock?) {
        
        let action = UIAlertAction(title: title, style: .default, handler: handler)
        self.addAction(action)
    }
    
    public func addDestructiveAction(title: String?, handler: UIAlertActionBlock?) {
        
        let action = UIAlertAction(title: title, style: .destructive, handler: handler)
        if #available(iOS 9, *) {
            action.setValue(UIColor.red, forKey: "titleTextColor")
        }
        self.addAction(action)
        
    }
}

public extension UIApplication: SFSafariViewControllerDelegate {
    
    public func openUrl(stringUrl: String?, on viewController: UIViewController?) {
        
        guard let stringUrl = stringUrl else { return }
        guard let url = URL(string: stringUrl) else { return }
        
        if #available(iOS 9.0, *) {
            
            let safari = SFSafariViewController(url: url)
            viewController?.present(safari, animated: true, completion: nil)
            
        } else {
            
            if self.canOpenURL(url) {
                self.openURL(url)
            }
        }
    }
    
    @available(iOS 9.0, *)
    public func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}

public extension UICollectionViewCell {
    
    public func fixedContentSize(width: CGFloat) -> CGSize {
        
        self.setNeedsLayout()
        self.layoutIfNeeded()
        let size = self.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
        return CGSize(width: width, height: size.height)
    }
}

public extension UINavigationController {
    
    public func addFirst(viewController: UIViewController?) {
        
        guard let viewController = viewController else { return }
        viewControllers.insert(viewController, at: 0)
    }
    
    public func addLast(viewController: UIViewController?) {
        
        guard let viewController = viewController else { return }
        viewControllers.append(viewController)
    }
}
