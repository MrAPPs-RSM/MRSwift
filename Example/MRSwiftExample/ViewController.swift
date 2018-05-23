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

	@objc func didTapLeftButton() {
        self.openLeftDrawerView()
    }
    
   @objc func didTapRightButton() {
        self.openRightDrawerView()
    }

    @IBAction func didTapPickerButton(_ sender: Any) {
        
        MRImagePicker.shared.pickWithActionSheet(in: self, mediaType: .photo, editing: false, iPadStartFrame: nil, completionBlock: { (image, videoUrl, fileName) in
            print("Image: \(image != nil)\nVideo: \(videoUrl != nil)")
        }, errorBlock: nil)
    }
    
    @IBAction func didTapMediaPlayerButton(_ sender: Any) {
        
		let image1 = MRMedia(id: nil, title: nil, description: nil, remoteUrl: URL(string: "https://foto.sportal.it/2017-44/ludovica-pagani_1106643Photogallery.jpg"), localUrl: nil, type: .image, fileExtension: .jpg)
		let image2 = MRMedia(id: nil, title: nil, description: nil, remoteUrl: URL(string: "https://images2.corriereobjects.it/methode_image/2017/10/21/Sport/Foto%20Gallery/21317799_1682669915084905_5303942900951660357_n.jpg"), localUrl: nil, type: .image, fileExtension: .jpg)
		let video1 = MRMedia(id: nil, title: nil, description: nil, remoteUrl: Bundle.main.url(forResource: "solo_video", withExtension: "mp4"), localUrl: nil, type: .video, fileExtension: .mp4)
        
        let viewController = MRMediaPlayerViewController(medias: [video1, image1, image2], selectedIndex: nil)
        self.present(viewController, animated: true, completion: nil)
    }
    
    @IBAction func didTapHudButton(_ sender: Any) {
        
        let hud = MRHud(theme: .light, style: .linearProgress)
        hud.textLabel?.text = "Ciao sono una label"
        hud.enableShadow(enable: true)
        //hud.setProgressColors(emptyColor: UIColor(netHex: 0xdddddd), filledColor: UIColor(netHex: 0x00ba0e))
        //hud.setShadow(color: .red, offset: .zero, radius: 10, opacity: 0.5)
        hud.show(in: view, animated: true)
        
        DispatchQueue.main.asyncAfter(deadline: .now()+2) {
            hud.set(style: .indeterminate)
            hud.set(buttons: [
                MRHudButton(title: "Button 1", highlighted: false, action: {
                    print("Tapped Button 1")
                }),
                MRHudButton(title: "Button 2", highlighted: false, action: {
                    print("Tapped Button 2")
                })
            ])
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now()+4) {
            hud.addButtons(buttons: [
                MRHudButton(title: "Button 3", highlighted: false, action: {
                    print("Tapped Button 3")
                }),
                MRHudButton(title: "Button 4", highlighted: true, action: {
                    print("Tapped Button 4")
                })
            ])
        }
    }
    
    @IBAction func didTapFormButton(_ sender: Any) {
        
        let viewController = MRFormViewController()
        
        viewController.data = [
            MRFormSection(id: nil, title: "Standard", subtitle: nil, value: nil, rows: [
                MRFormRow(id: nil, key: nil, title: "Title 1-1", subtitle: nil, value: "Value 1-1", placeholder: nil, image: nil, extraData: nil, dateFormat: nil, accessoryType: .none, mandatory: false, type: .rowDefault),
                MRFormRow(id: nil, key: nil, title: "Title 1-2", subtitle: nil, value: "Value 1-2", placeholder: nil, image: nil, extraData: nil, dateFormat: nil, accessoryType: .none, mandatory: false, type: .rowDefault)
                ]),
            MRFormSection(id: nil, title: "TextField", subtitle: nil, value: nil, rows: [
                MRFormRow(id: nil, key: nil, title: "Title 2-1", subtitle: nil, value: "Value 2-1", placeholder: nil, image: nil, extraData: nil, dateFormat: nil, accessoryType: .none, mandatory: false, type: .rowTextField),
                MRFormRow(id: nil, key: nil, title: "Title 2-2", subtitle: nil, value: "Value 2-2", placeholder: "Placeholder", image: nil, extraData: nil, dateFormat: nil, accessoryType: .none, mandatory: false, type: .rowTextField)
                ]),
            MRFormSection(id: nil, title: "Subtitle", subtitle: nil, value: nil, rows: [
                MRFormRow(id: nil, key: nil, title: "Title 3-1", subtitle: "Subtitle 3-1", value: nil, placeholder: nil, image: nil, extraData: nil, dateFormat: nil, accessoryType: .none, mandatory: false, type: .rowSubtitle),
                MRFormRow(id: nil, key: nil, title: "Title 3-2", subtitle: "Subtitle 3-2", value: nil, placeholder: nil, image: nil, extraData: nil, dateFormat: nil, accessoryType: .none, mandatory: false, type: .rowSubtitle)
                ]),
            MRFormSection(id: nil, title: "Switch", subtitle: nil, value: nil, rows: [
                MRFormRow(id: nil, key: nil, title: "Title 4-1", subtitle: nil, value: true, placeholder: nil, image: nil, extraData: nil, dateFormat: nil, accessoryType: .none, mandatory: false, type: .rowSwitch),
                MRFormRow(id: nil, key: nil, title: "Title 4-2", subtitle: nil, value: false, placeholder: nil, image: nil, extraData: nil, dateFormat: nil, accessoryType: .none, mandatory: false, type: .rowSwitch)
                ]),
            MRFormSection(id: nil, title: "Date", subtitle: nil, value: nil, rows: [
                MRFormRow(id: nil, key: nil, title: "Title 5-1", subtitle: nil, value: nil, placeholder: nil, image: nil, extraData: nil, dateFormat: "dd/MM/yyyy", accessoryType: .none, mandatory: false, type: .rowDate),
                MRFormRow(id: nil, key: nil, title: "Title 5-2", subtitle: nil, value: nil, placeholder: nil, image: nil, extraData: nil, dateFormat: "HH:mm:ss", accessoryType: .none, mandatory: false, type: .rowDate)
                ]),
            MRFormSection(id: nil, title: "List", subtitle: nil, value: nil, rows: [
                MRFormRow(id: nil, key: nil, title: "Title 6-1", subtitle: nil, value: nil, placeholder: nil, image: nil, extraData: ["A", "B", "C"], dateFormat: nil, accessoryType: .none, mandatory: false, type: .rowList),
                MRFormRow(id: nil, key: nil, title: "Title 6-2", subtitle: nil, value: "1", placeholder: nil, image: nil, extraData: ["1", "2", "3"], dateFormat: nil, accessoryType: .none, mandatory: false, type: .rowList)
                ])
        ]
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
