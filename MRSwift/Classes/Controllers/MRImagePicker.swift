//
//  MRImagePickerController.swift
//  MRSwiftExample
//
//  Created by Nicola Innocenti on 28/05/17.
//  Copyright © 2017 Nicola Innocenti. All rights reserved.
//

import UIKit
import MobileCoreServices

public typealias MRImagePickerCompletionBlock = (_ image: UIImage?, _ videoUrl: URL?) -> Void
public typealias MRImagePickerErrorBlock = (_ error: String) -> Void

public enum MRImagePickerType {
    case photoLibrary
    case videoLibrary
    case photoAndVideoLibrary
    case photoCamera
    case videoCamera
    case photoAndVideoCamera
}

public enum MRMediaType {
    case photo
    case video
    case photoAndVideo
}

public class MRImagePicker: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    public static let shared = MRImagePicker()
    
    private static let MRImagePickerPickTitleText = "MRImagePickerPickTitleText"
    private static let MRImagePickerPhotoCameraString = "MRImagePickerPhotoCameraString"
    private static let MRImagePickerCameraRollString = "MRImagePickerCameraRollString"
    private static let MRImagePickerCancelString = "MRImagePickerCancelString"
    
    private var completionBlock: MRImagePickerCompletionBlock!
    private var errorBlock: MRImagePickerErrorBlock?
    
    private var picker: UIImagePickerController!
    
    public override init() {
        super.init()
        
        picker = UIImagePickerController()
        picker.delegate = self
    }
    
    public var pickerTitleText : String? {
        get { return UserDefaults.standard.string(forKey: MRImagePicker.MRImagePickerPickTitleText) }
        set (newValue) { UserDefaults.standard.set(newValue, forKey: MRImagePicker.MRImagePickerPickTitleText) }
    }
    
    public var photoCameraText : String {
        get { return UserDefaults.standard.string(forKey: MRImagePicker.MRImagePickerPhotoCameraString) ?? "Camera" }
        set (newValue) { UserDefaults.standard.set(newValue, forKey: MRImagePicker.MRImagePickerPhotoCameraString) }
    }
    
    public var cameraRollText : String {
        get { return UserDefaults.standard.string(forKey: MRImagePicker.MRImagePickerCameraRollString) ?? "Camera roll" }
        set (newValue) { UserDefaults.standard.set(newValue, forKey: MRImagePicker.MRImagePickerCameraRollString) }
    }
    
    public var cancelText : String {
        get { return UserDefaults.standard.string(forKey: MRImagePicker.MRImagePickerCancelString) ?? "Cancel" }
        set (newValue) { UserDefaults.standard.set(newValue, forKey: MRImagePicker.MRImagePickerCancelString) }
    }
    
    public func pickWithActionSheet(in viewController: UIViewController, mediaType: MRMediaType, editing: Bool, completionBlock: @escaping MRImagePickerCompletionBlock, errorBlock: MRImagePickerErrorBlock?) {
        
        let alert = UIAlertController(title: self.pickerTitleText, message: nil, preferredStyle: .actionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.addAction(UIAlertAction(title: self.photoCameraText, style: .default, handler: { (action) in
                let pickerType: MRImagePickerType = mediaType == .photo ? .photoCamera : mediaType == .video ? .videoCamera : .photoAndVideoCamera
                self.pick(in: viewController, type: pickerType, editing: editing, completionBlock: completionBlock, errorBlock: errorBlock)
            }))
        }
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            alert.addAction(UIAlertAction(title: self.cameraRollText, style: .default, handler: { (action) in
                let pickerType: MRImagePickerType = mediaType == .photo ? .photoLibrary : mediaType == .video ? .videoLibrary : .photoAndVideoLibrary
                self.pick(in: viewController, type: pickerType, editing: editing, completionBlock: completionBlock, errorBlock: errorBlock)
            }))
        }
        alert.addAction(UIAlertAction(title: self.cancelText, style: .cancel, handler: nil))
        viewController.present(alert, animated: true, completion: nil)
    }
    
    public func pick(in viewController: UIViewController, type: MRImagePickerType, editing: Bool, completionBlock: @escaping MRImagePickerCompletionBlock, errorBlock: MRImagePickerErrorBlock?) {
        
        self.completionBlock = completionBlock
        self.errorBlock = errorBlock
        
        let isLibrary = type == .photoLibrary || type == .videoLibrary || type == .photoAndVideoLibrary
        let isPhoto = type == .photoLibrary || type == .photoCamera || type == .photoAndVideoLibrary || type == .photoAndVideoCamera
        let isVideo = type == .videoLibrary || type == .videoCamera || type == .photoAndVideoLibrary || type == .photoAndVideoCamera
        
        let sourceType: UIImagePickerControllerSourceType = isLibrary ? .photoLibrary : .camera
        guard let mediaTypes = self.mediaTypesFor(sourceType: sourceType, photo: isPhoto, video: isVideo) else {
            if self.errorBlock != nil {
                self.errorBlock!("No picker media type available")
            }
            return
        }
        
        picker.allowsEditing = editing
        picker.sourceType = sourceType
        picker.mediaTypes = mediaTypes
        
        if isLibrary == false {
            picker.cameraCaptureMode = isPhoto ? .photo : .video
        }
        
        viewController.present(picker, animated: true, completion: nil)
    }
    
    private func mediaTypesFor(sourceType: UIImagePickerControllerSourceType, photo: Bool, video: Bool) -> [String]? {
        
        guard let availableMediaTypes = UIImagePickerController.availableMediaTypes(for: sourceType) else {
            return nil
        }
        
        var mediaTypes: [String]?
        if photo && video {
            mediaTypes = availableMediaTypes
        } else {
            for mediaType in availableMediaTypes {
                if (mediaType.compare(kUTTypeImage as String) == .orderedSame && photo == true) || (mediaType.compare(kUTTypeMovie as String) == .orderedSame && video == true) {
                    mediaTypes = [String]()
                    mediaTypes!.append(mediaType)
                    break
                }
            }
        }
        return mediaTypes
    }
    
    // MARK: - UIImagePickerController Delegate
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if (info[UIImagePickerControllerMediaType] as! String) == (kUTTypeImage as String) {
            
            if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
                self.completionBlock(image, nil)
            } else {
                self.completionBlock(nil, nil)
            }
            
        } else if (info[UIImagePickerControllerMediaType] as! String) == (kUTTypeMovie as String) {
            
            if let videoUrl = info[UIImagePickerControllerMediaURL] as? URL {
                self.completionBlock(nil, videoUrl)
            } else {
                self.completionBlock(nil, nil)
            }
        }
        
        picker.dismiss(animated: true, completion: nil)
    }

    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
