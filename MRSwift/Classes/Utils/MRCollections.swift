//
//  MRTableSection.swift
//  MRSwift
//
//  Created by Nicola Innocenti on 24/04/17.
//  Copyright © 2017 Nicola Innocenti. All rights reserved.
//

import Foundation

public class MRTableSection : NSObject {
    
    public var key: String = ""
    public var title: String = ""
    public var rows = [MRTableRow]()
    
    public convenience init(key: String, title: String, rows: [MRTableRow]) {
        self.init()
        
        self.key = key
        self.title = title
        self.rows = rows
    }
}

public class MRTableRow : NSObject {
    
    public var key: String = ""
    public var title: String = ""
    public var subtitle: String = ""
    public var value: String = ""
    
    public convenience init(key: String, title: String, subtitle: String, value: String) {
        self.init()
        
        self.key = key
        self.title = title
        self.subtitle = subtitle
        self.value = value
    }
}
