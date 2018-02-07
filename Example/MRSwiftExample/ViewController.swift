//
//  ViewController.swift
//  MRSwiftExample
//
//  Created by Nicola Innocenti on 28/05/17.
//  Copyright © 2017 Nicola Innocenti. All rights reserved.
//

import UIKit
import MRSwift

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
        
        MRImagePicker.shared.pickWithActionSheet(in: self, mediaType: .photo, editing: false, iPadStartFrame: nil, completionBlock: { (image, videoUrl) in
            print("Image: \(image != nil)\nVideo: \(videoUrl != nil)")
        }, errorBlock: nil)
    }
    
    @IBAction func didTapMediaPlayerButton(_ sender: Any) {
        
        let image1 = MRMedia(id: nil, title: nil, description: nil, url: URL(string: "https://foto.sportal.it/2017-44/ludovica-pagani_1106643Photogallery.jpg"), type: .image)
        let image2 = MRMedia(id: nil, title: nil, description: nil, url: URL(string: "https://images2.corriereobjects.it/methode_image/2017/10/21/Sport/Foto%20Gallery/21317799_1682669915084905_5303942900951660357_n.jpg"), type: .image)
        let video1 = MRMedia(id: nil, title: nil, description: nil, url: URL(string: "https://youtu.be/vl5jT-XbEDQ"), type: .video)
        
        let viewController = MRMediaPlayerViewController(medias: [video1, image1, image2], selectedIndex: nil)
        self.present(viewController, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
