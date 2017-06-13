//
//  ViewController.swift
//  SCSwiftExample
//
//  Created by Nicola Innocenti on 28/05/17.
//  Copyright © 2017 Nicola Innocenti. All rights reserved.
//

import UIKit
import SCSwift

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Left", style: .plain, target: self, action: #selector(self.didTapLeftButton))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Right", style: .plain, target: self, action: #selector(self.didTapRightButton))
    }
    
    func didTapLeftButton() {
        self.openLeftDrawerView()
    }
    
    func didTapRightButton() {
        self.openRightDrawerView()
    }

    @IBAction func didTapPickerButton(_ sender: Any) {
        
        SCImagePicker.shared.pickWithActionSheet(in: self, mediaType: .photo, editing: false, completionBlock: { (image, videoUrl) in
            print("Image: \(image != nil)\nVideo: \(videoUrl != nil)")
        }, errorBlock: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
