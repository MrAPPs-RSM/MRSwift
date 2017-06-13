//
//  MRUIImageExtension.swift
//  MRSwift
//
//  Created by Nicola Innocenti on 22/04/17.
//  Copyright © 2017 Nicola Innocenti. All rights reserved.
//

import Foundation

public extension UIImage {
    
    public var resized : UIImage {
        return self.resizeIfNeeded(compressionQuality: 0.5)
    }
    
    public var thumbnail : UIImage {
        return self.resizeIfNeeded(compressionQuality: 0.05)
    }
    
    public func resizeIfNeeded(compressionQuality: CGFloat) -> UIImage {
        
        var newImage: UIImage = self.copy() as! UIImage
        newImage = newImage.resizeWith(width: 800, height: 600)!
        
        let imgData = UIImageJPEGRepresentation(newImage, compressionQuality)!
        let oldData: Data = UIImageJPEGRepresentation(self, 1.0)!
        
        print("Compressed image from", (oldData.count/1024), "Kb to", (imgData.count/1024), "Kb")
        
        //return newImage
        return UIImage(data: imgData)!
    }
    
    public func resizeImage() -> UIImage {
        
        let cgImage = self.cgImage
        
        let width = cgImage!.width / 2
        let height = cgImage!.height / 2
        let bitsPerComponent = cgImage!.bitsPerComponent
        let bytesPerRow = cgImage!.bytesPerRow
        let colorSpace = cgImage!.colorSpace
        let bitmapInfo = cgImage!.bitmapInfo
        
        let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace!, bitmapInfo: bitmapInfo.rawValue)
        context?.interpolationQuality = CGInterpolationQuality(rawValue: CGInterpolationQuality.high.rawValue)!
        context?.draw(cgImage!, in: CGRect(x: 0, y: 0, width: width, height: height))
        let scaledCGImage = context?.makeImage()
        let scaledImage = UIImage(cgImage: scaledCGImage!)
        
        return scaledImage
    }
    
    public func fixOrientation() -> UIImage {
        
        if self.imageOrientation == UIImageOrientation.up {
            return self
        }
        
        var transform = CGAffineTransform.identity
        
        switch self.imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: self.size.height)
            transform = transform.rotated(by: CGFloat(Double.pi));
            
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0);
            transform = transform.rotated(by: CGFloat(Double.pi/2));
            
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: self.size.height);
            transform = transform.rotated(by: CGFloat(-(Double.pi/2)));
            
        case .up, .upMirrored:
            break
        }
        
        switch self.imageOrientation {
            
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
            
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: self.size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1);
            
        default:
            break;
        }
        
        // Now we draw the underlying CGImage into a new context, applying the transform
        // calculated above.
        let ctx = CGContext(
            data: nil,
            width: Int(self.size.width),
            height: Int(self.size.height),
            bitsPerComponent: (self.cgImage?.bitsPerComponent)!,
            bytesPerRow: 0,
            space: (self.cgImage?.colorSpace!)!,
            bitmapInfo: UInt32((self.cgImage?.bitmapInfo.rawValue)!)
        )
        
        ctx?.concatenate(transform);
        
        switch self.imageOrientation {
            
        case .left, .leftMirrored, .right, .rightMirrored:
            // Grr...
            ctx?.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: self.size.height,height: self.size.width));
            
        default:
            ctx?.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: self.size.width,height: self.size.height));
            break;
        }
        
        // And now we just create a new UIImage from the drawing context
        let cgimg = ctx?.makeImage()
        
        let img = UIImage(cgImage: cgimg!)
        
        //CGContextRelease(ctx);
        //CGImageRelease(cgimg);
        
        return img;
    }
    
    public func resizeWith(percentage: CGFloat) -> UIImage? {
        
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: size.width * percentage, height: size.height * percentage)))
        imageView.contentMode = .scaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return result
    }
    
    public func resizeWith(width: CGFloat, height: CGFloat) -> UIImage? {
        
        var newWidth = width
        var newHeight = height
        
        if size.width > size.height {
            newHeight = CGFloat(ceil(width/size.width * size.height))
        } else {
            newWidth = CGFloat(ceil(height/size.height * size.width))
        }
        
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: newWidth, height: newHeight)))
        imageView.contentMode = .scaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return result
    }
    
    public func flipped() -> UIImage {
        var imageOrientation: UIImageOrientation?
        switch(self.imageOrientation){
        case .down: imageOrientation = .downMirrored; break
        case .downMirrored: imageOrientation = .down; break
        case .left: imageOrientation = .leftMirrored; break
        case .leftMirrored: imageOrientation = .left; break
        case .right: imageOrientation = .rightMirrored; break
        case .rightMirrored: imageOrientation = .right; break
        case .up: imageOrientation = .upMirrored; break
        case .upMirrored: imageOrientation = .up; break
        }
        return UIImage(cgImage: self.cgImage!, scale: self.scale, orientation: imageOrientation!)
    }
    
    public func mergeTop(bottomImage: UIImage) -> UIImage? {
        
        UIGraphicsBeginImageContextWithOptions(self.size, false, 0.0)
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: bottomImage.size.height))
        bottomImage.draw(in: CGRect(x: 0, y: 0, width: bottomImage.size.width, height: self.size.height))
        
        if let mergedImage = UIGraphicsGetImageFromCurrentImageContext() {
            return mergedImage
        }
        UIGraphicsEndImageContext()
        
        return nil
    }
    
    public class func maskImage(image: UIImage, withMask maskImage: UIImage) -> UIImage {
        
        let maskRef = maskImage.cgImage
        
        let mask = CGImage(
            maskWidth: maskRef!.width,
            height: maskRef!.height,
            bitsPerComponent: maskRef!.bitsPerComponent,
            bitsPerPixel: maskRef!.bitsPerPixel,
            bytesPerRow: maskRef!.bytesPerRow,
            provider: maskRef!.dataProvider!,
            decode: nil,
            shouldInterpolate: false)
        
        let masked = image.cgImage!.masking(mask!)
        let maskedImage = UIImage(cgImage: masked!)
        return maskedImage
    }
    
    public func image(with color: UIColor) -> UIImage {
        
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        color.setFill()
        
        let context = UIGraphicsGetCurrentContext()! as CGContext
        context.translateBy(x: 0, y: self.size.height)
        context.scaleBy(x: 1.0, y: -1.0);
        context.setBlendMode(CGBlendMode.normal)
        
        let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height) as CGRect
        context.clip(to: rect, mask: self.cgImage!)
        context.fill(rect)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()! as UIImage
        UIGraphicsEndImageContext()
        
        return newImage
    }
}
