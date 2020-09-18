//
//  MRWeb.swift
//  MRSwiftExample
//
//  Created by Nicola Innocenti on 13/06/17.
//  Copyright © 2017 Nicola Innocenti. All rights reserved.
//

import UIKit
import Alamofire
import MRSwift

// MARK: - Promises

typealias PromiseString = (completed: Bool, message: String?)
typealias PromiseData = (completed: Bool, data: Any?, message: String?)

// MARK: - Completion Blocks

typealias CompleteBlock = (_ completed: Bool) -> Void
typealias StringCompleteBlock = (_ completed: Bool, _ message: String?) -> Void
typealias DataCompleteBlock = (_ completed: Bool, _ data: AnyObject?, _ message: String?) -> Void
typealias ProgressBlock = (_ progress: Float) -> Void
typealias FileUploadBlock = (_ completed: Bool, _ fileUrl: URL?, _ fileName: String?, _ message: String) -> Void

// MARK: - Other Declarations

typealias Payload = [String : Any]

protocol MRWebProtocol {
    
    func download(files: [MRFileToDownload], completion: @escaping StringCompleteBlock, progress progressBlock: ProgressBlock?)
    func download(file: MRFileToDownload, completion: @escaping StringCompleteBlock, progress progressBlock: ProgressBlock?)
}

class MRWeb : MRWebProtocol {

    func download(files: [MRFileToDownload], completion: @escaping StringCompleteBlock, progress progressBlock: ProgressBlock?) {
        
    }
    
    func download(file: MRFileToDownload, completion: @escaping StringCompleteBlock, progress progressBlock: ProgressBlock?) {
        
        let destination: DownloadRequest.Destination = { _, _ in
            return (file.localUrl!, [.removePreviousFile, .createIntermediateDirectories])
        }
        
        AF.download(file.remoteStringUrl, to: destination).response { response in
            
            completion(response.error == nil, response.error?.localizedDescription)
            
        }.downloadProgress(closure: { (progress) in
            
            if progressBlock != nil {
                progressBlock!(Float(progress.fractionCompleted))
            }
        })
    }
}
