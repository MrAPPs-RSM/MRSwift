//
//  MRFilePicker.swift
//  MRSwiftExample
//
//  Created by Nicola Innocenti on 27/09/2019.
//  Copyright © 2019 Nicola Innocenti. All rights reserved.
//

import UIKit
import MobileCoreServices

public typealias FilePickerCompletion = (_ fileUrl: URL?, _ message: String?) -> Void

open class MRFilePicker: NSObject, UIDocumentPickerDelegate, UINavigationControllerDelegate {
    
    private static let MRFilePickerPickTitleText = "MRFilePickerPickTitleText"
    private static let MRFilePickerCancelTitleText = "MRFilePickerCancelTitleText"
    
    private var viewController: UIViewController?
    private var pickerCompletion: FilePickerCompletion?
    
    public var pickerTitleText : String? {
        get { return UserDefaults.standard.string(forKey: MRFilePicker.MRFilePickerPickTitleText) ?? "Search document" }
        set (newValue) { UserDefaults.standard.set(newValue, forKey: MRFilePicker.MRFilePickerPickTitleText) }
    }
    
    public var pickerCancelText : String? {
        get { return UserDefaults.standard.string(forKey: MRFilePicker.MRFilePickerCancelTitleText) ?? "Cancel" }
        set (newValue) { UserDefaults.standard.set(newValue, forKey: MRFilePicker.MRFilePickerCancelTitleText) }
    }
    
    open func pickFile(on viewController: UIViewController?, completion: @escaping FilePickerCompletion) {
        
        self.viewController = viewController
        self.pickerCompletion = completion
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: MRImagePicker.shared.photoCameraText, style: .default, handler: { (action) in
            if let onViewController = viewController {
                MRImagePicker.shared.pick(in: onViewController, type: .photoCamera, editing: true, completionBlock: { (image, imageUrl, message) in
                    if let completion = self.pickerCompletion {
                        completion(imageUrl, nil)
                    }
                }) { (error) in
                    let alert = UIAlertController(title: nil, message: error, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "close".localized, style: .cancel, handler: nil))
                    onViewController.present(alert, animated: true, completion: nil)
                }
            }
        }))
        alert.addAction(UIAlertAction(title: MRImagePicker.shared.cameraRollText, style: .default, handler: { (action) in
            if let onViewController = viewController {
                MRImagePicker.shared.pick(in: onViewController, type: .photoLibrary, editing: true, completionBlock: { (image, imageUrl, message) in
                    if let completion = self.pickerCompletion {
                        completion(imageUrl, nil)
                    }
                }) { (error) in
                    let alert = UIAlertController(title: nil, message: error, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "close".localized, style: .cancel, handler: nil))
                    onViewController.present(alert, animated: true, completion: nil)
                }
            }
        }))
        alert.addAction(UIAlertAction(title: pickerTitleText, style: .default, handler: { (action) in
            let picker = UIDocumentPickerViewController(documentTypes: [String(kUTTypePDF), String(kUTTypePNG), String(kUTTypeJPEG)], in: .import)
            picker.delegate = self
            viewController?.present(picker, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: pickerCancelText, style: .cancel, handler: { (action) in
            if let completion = self.pickerCompletion {
                completion(nil, nil)
            }
        }))
        
        viewController?.present(alert, animated: true, completion: nil)
    }

    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        
        if let fileUrl = urls.first {
            print("[MRFilePicker] Document Url: \(fileUrl)")
            if let completion = pickerCompletion {
                completion(fileUrl, nil)
            }
        }
    }
    
    public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        
        viewController?.dismiss(animated: true, completion: nil)
    }
}
