//
//  MRFileToDownload.swift
//  MRSwift
//
//  Created by Nicola Innocenti on 24/04/17.
//  Copyright © 2017 Nicola Innocenti. All rights reserved.
//

import UIKit

public class MRFileToDownload : NSObject {
    
    public var remoteStringUrl: String = ""
    public var localUrl: URL?
    
    public convenience init(remoteStringUrl: String, localUrl: URL) {
        self.init()
        
        self.remoteStringUrl = remoteStringUrl
        self.localUrl = localUrl
    }
    
    public var isInvalid : Bool {
        return self.remoteStringUrl.isEmpty || self.localUrl == nil
    }
}
