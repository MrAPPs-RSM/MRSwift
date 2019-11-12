//
//  MRImagePickerController.swift
//  MRSwiftExample
//
//  Created by Nicola Innocenti on 28/05/17.
//  Copyright © 2017 Nicola Innocenti. All rights reserved.
//

import UIKit
import MobileCoreServices
import Photos

public typealias MRImagePickerCompletionBlock = (_ image: UIImage?, _ videoUrl: URL?, _ fileName: String) -> Void
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
    private var currentFileExtension = MRFileExtension.jpg
    private var currentMaxSize: Int?  //Bytes
    
    private var picker: UIImagePickerController!
    private var lastCacheUpdate: TimeInterval = 0
    
    public var cacheClearInterval : TimeInterval {
        
        set {
            UserDefaults.standard.set(newValue, forKey: "MRImagePickerClearCacheInterval")
            UserDefaults.standard.synchronize()
        }
        get {
            let currentValue = UserDefaults.standard.double(forKey: "MRImagePickerClearCacheInterval")
            return currentValue > 0 ? currentValue : 604800
        }
    }
    
    var cacheFolder : URL {
        
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory.appendingPathComponent("MRImagePickerCache")
    }
    
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
    
    public func pickWithActionSheet(in viewController: UIViewController, mediaType: MRMediaType, fileExtension: MRFileExtension, maxSize: Int?, editing: Bool, iPadStartFrame: CGRect?, completionBlock: @escaping MRImagePickerCompletionBlock, errorBlock: MRImagePickerErrorBlock?) {
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) && UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            
            let alert = UIAlertController.new(title: self.pickerTitleText, message: nil, tintColor: nil, preferredStyle: .actionSheet)
            if UIDevice.isIpad {
                alert.popoverPresentationController?.sourceView = viewController.view
                if let frame = iPadStartFrame {
                    alert.popoverPresentationController?.sourceRect = frame
                } else {
                    alert.popoverPresentationController?.sourceRect = viewController.view.frame
                }
            }
            
            alert.addAction(UIAlertAction(title: self.photoCameraText, style: .default, handler: { (action) in
                let pickerType: MRImagePickerType = mediaType == .photo ? .photoCamera : mediaType == .video ? .videoCamera : .photoAndVideoCamera
                self.pick(in: viewController, type: pickerType, fileExtension: fileExtension, maxSize: maxSize, editing: editing, completionBlock: completionBlock, errorBlock: errorBlock)
            }))
            alert.addAction(UIAlertAction(title: self.cameraRollText, style: .default, handler: { (action) in
                let pickerType: MRImagePickerType = mediaType == .photo ? .photoLibrary : mediaType == .video ? .videoLibrary : .photoAndVideoLibrary
                self.pick(in: viewController, type: pickerType, fileExtension: fileExtension, maxSize: maxSize, editing: editing, completionBlock: completionBlock, errorBlock: errorBlock)
            }))
            alert.addAction(UIAlertAction(title: self.cancelText, style: .cancel, handler: nil))
            viewController.present(alert, animated: true, completion: nil)
            
        } else if UIImagePickerController.isSourceTypeAvailable(.camera) {
            
            let pickerType: MRImagePickerType = mediaType == .photo ? .photoCamera : mediaType == .video ? .videoCamera : .photoAndVideoCamera
            self.pick(in: viewController, type: pickerType, fileExtension: fileExtension, maxSize: maxSize, editing: editing, completionBlock: completionBlock, errorBlock: errorBlock)
            
        } else if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            
            let pickerType: MRImagePickerType = mediaType == .photo ? .photoLibrary : mediaType == .video ? .videoLibrary : .photoAndVideoLibrary
            self.pick(in: viewController, type: pickerType, fileExtension: fileExtension, maxSize: maxSize, editing: editing, completionBlock: completionBlock, errorBlock: errorBlock)
        }
    }
    
    public func pick(in viewController: UIViewController, type: MRImagePickerType, fileExtension: MRFileExtension, maxSize: Int?, editing: Bool, completionBlock: @escaping MRImagePickerCompletionBlock, errorBlock: MRImagePickerErrorBlock?) {
        
        self.completionBlock = completionBlock
        self.errorBlock = errorBlock
        self.currentFileExtension = fileExtension
        self.currentMaxSize = maxSize
        
        let isLibrary = type == .photoLibrary || type == .videoLibrary || type == .photoAndVideoLibrary
        let isPhoto = type == .photoLibrary || type == .photoCamera || type == .photoAndVideoLibrary || type == .photoAndVideoCamera
        let isVideo = type == .videoLibrary || type == .videoCamera || type == .photoAndVideoLibrary || type == .photoAndVideoCamera
        
        let sourceType: UIImagePickerController.SourceType = isLibrary ? .photoLibrary : .camera
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
        
        if isLibrary {
            let photos = PHPhotoLibrary.authorizationStatus()
            if photos == .notDetermined {
                PHPhotoLibrary.requestAuthorization({status in
                    if status == .authorized {
                        DispatchQueue.main.async {
                            viewController.present(self.picker, animated: true, completion: nil)
                        }
                    } else {
                        if self.errorBlock != nil {
                            self.errorBlock!("Photo library permissions are disabled")
                        }
                    }
                })
            } else if photos == .authorized {
                viewController.present(self.picker, animated: true, completion: nil)
            }
        } else {
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    viewController.present(self.picker, animated: true, completion: nil)
                } else {
                    if self.errorBlock != nil {
                        self.errorBlock!("Camera permissions are disabled")
                    }
                }
            }
        }
    }
    
    private func mediaTypesFor(sourceType: UIImagePickerController.SourceType, photo: Bool, video: Bool) -> [String]? {
        
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
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        var image: UIImage?
        var fileUrl: URL?
        let fileName: String = "file"
        
        if (info[.mediaType] as! String) == (kUTTypeImage as String) {
            
            if let pickedImage = info[.editedImage] as? UIImage {
                image = pickedImage
            } else if let pickedImage = info[.originalImage] as? UIImage {
                image = pickedImage
            }
            if let image = image {
                if let imageUrl = saveImageToLocalFolder(image: image) {
                    fileUrl = imageUrl
                }
            }
            
        } else if (info[.mediaType] as! String) == (kUTTypeMovie as String) {
            
            if let pickedVideoUrl = info[.mediaURL] as? URL {
                fileUrl = pickedVideoUrl
            }
        }
        
        if let fileUrl = fileUrl, let data = try? Data(contentsOf: fileUrl), let maxSize = currentMaxSize, maxSize < data.count {
            completionBlock(image, fileUrl, "File too big")
            return
        }
        
        completionBlock(image, fileUrl, fileName)
        picker.dismiss(animated: true, completion: nil)
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Other Methods
    
    public func clearCacheIfNeeded() {
        
        let currentTimeInterval = Date().timeIntervalSince1970
        if currentTimeInterval - lastCacheUpdate > cacheClearInterval {
            do {
                try FileManager.default.removeItem(at: cacheFolder)
            } catch {
                print("[MRImagePicker] Error: " + error.localizedDescription)
            }
        }
    }
    
    private func saveImageToLocalFolder(image: UIImage?) -> URL? {
        
        clearCacheIfNeeded()
        
        guard let image = image else { return nil }
        
        let cacheFolder = self.cacheFolder
        let manager = FileManager.default
        
        var isDir: ObjCBool = false
        if !manager.fileExists(atPath: cacheFolder.absoluteString, isDirectory: &isDir) {
            do {
                try manager.createDirectory(at: cacheFolder, withIntermediateDirectories: false, attributes: nil)
            } catch {
                print("[MRImagePicker] Error: " + error.localizedDescription)
            }
        }
        
        var fileDir: URL!
        var data: Data?
        if currentFileExtension == .png {
            data = image.pngData()
            fileDir = cacheFolder.appendingPathComponent("\(UUID().uuidString).png")
        } else {
            data = image.jpegData(compressionQuality: 1.0)
            fileDir = cacheFolder.appendingPathComponent("\(UUID().uuidString).jpg")
        }
        do {
            try data?.write(to: fileDir)
            lastCacheUpdate = Date().timeIntervalSince1970
        } catch {
            print("[MRImagePicker] Error: " + error.localizedDescription)
        }
        
        return fileDir
    }
}
