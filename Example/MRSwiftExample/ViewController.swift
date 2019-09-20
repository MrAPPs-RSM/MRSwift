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
    
    @IBOutlet weak var btnImagePicker: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .darkGray
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Left", style: .plain, target: self, action: #selector(self.didTapLeftButton))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Right", style: .plain, target: self, action: #selector(self.didTapRightButton))
        
        btnImagePicker.observe(event: .touchUpInside) {
            MRImagePicker.shared.pickWithActionSheet(in: self, mediaType: .photo, editing: false, iPadStartFrame: nil, completionBlock: { (image, videoUrl, fileName) in
                print("Image: \(image != nil)\nVideo: \(videoUrl != nil)")
            }, errorBlock: nil)
        }
    }

	@objc func didTapLeftButton() {
        self.openLeftDrawerView()
    }
    
   @objc func didTapRightButton() {
        self.openRightDrawerView()
    }
    
    @IBAction func didTapMediaPlayerButton(_ sender: Any) {
        
		let image1 = MRMedia(id: nil, title: nil, description: nil, remoteUrl: URL(string: "https://foto.sportal.it/2017-44/ludovica-pagani_1106643Photogallery.jpg"), localUrl: nil, type: .image, fileExtension: .jpg)
		let image2 = MRMedia(id: nil, title: nil, description: nil, remoteUrl: URL(string: "https://images2.corriereobjects.it/methode_image/2017/10/21/Sport/Foto%20Gallery/21317799_1682669915084905_5303942900951660357_n.jpg"), localUrl: nil, type: .image, fileExtension: .jpg)
		let video1 = MRMedia(id: nil, title: nil, description: nil, remoteUrl: Bundle.main.url(forResource: "solo_video", withExtension: "mp4"), localUrl: nil, type: .video, fileExtension: .mp4)
        
        let viewController = MRMediaPlayerViewController(medias: [video1, image1, image2], selectedIndex: nil)
        self.present(viewController, animated: true, completion: nil)
    }
    
    @IBAction func didTapHudButton(_ sender: Any) {
        
        let hud = MRHud(theme: .dark, style: .linearProgress)
        hud.textLabel?.text = "Ciao sono una label"
        hud.enableShadow(enable: true)
        hud.setProgressColors(emptyColor: UIColor(netHex: 0xdddddd), filledColor: UIColor(netHex: 0x00ba0e))
        //hud.setShadow(color: .red, offset: .zero, radius: 10, opacity: 0.5)
        hud.show(in: navigationController!.view, animated: true)
        
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
        
        DispatchQueue.main.asyncAfter(deadline: .now()+6) {
            hud.hide(animated: true)
        }
    }
    
    @IBAction func didTapFormButton(_ sender: Any) {
        
        let viewController = MRFormViewController()
        
        viewController.data = [
            MRFormSection(id: nil, title: "Standard", subtitle: nil, value: nil, rows: [
                MRFormRow(default: nil, title: "Title 1-1", value: "Value 1-1", visibilityBindKey: nil),
                MRFormRow(default: nil, title: "Title 1-2", value: "Value 1-2", visibilityBindKey: nil)
            ]),
            MRFormSection(id: nil, title: "TextField", subtitle: nil, value: nil, rows: [
                MRFormRow(textField: nil, title: "Title 2-1", placeholder: nil, value: "Value 2-1", visibilityBindKey: nil),
                MRFormRow(textField: nil, title: "Title 2-2", placeholder: nil, value: "Value 2-2", visibilityBindKey: nil)
            ]),
            MRFormSection(id: nil, title: "Subtitle", subtitle: nil, value: nil, rows: [
                MRFormRow(subtitle: nil, title: "Title 3-1", subtitle: "Subtitle 3-1", visibilityBindKey: nil),
                MRFormRow(subtitle: nil, title: "Title 3-2", subtitle: "Subtitle 3-2", visibilityBindKey: nil)
            ]),
            MRFormSection(id: nil, title: "Switch", subtitle: nil, value: nil, rows: [
                MRFormRow(switch: nil, title: "Title 4-1", value: true, visibilityBindKey: nil),
                MRFormRow(switch: nil, title: "Title 4-2", value: false, visibilityBindKey: nil)
            ]),
            MRFormSection(id: nil, title: "Date", subtitle: nil, value: nil, rows: [
                MRFormRow(date: nil, title: "Title 5-1", placeholder: nil, dateFormat: "dd/MM/YYYY", value: Date(), visibilityBindKey: nil),
                MRFormRow(date: nil, title: "Title 5-2", placeholder: nil, dateFormat: "HH:mm", value: Date(), visibilityBindKey: nil)
            ]),
            MRFormSection(id: nil, title: "List", subtitle: nil, value: nil, rows: [
                MRFormRow(list: nil, title: "Title 6-1", value: nil, extraData: [
                    MRDataListItem(key: nil, title: "A", subtitle: nil, selected: false),
                    MRDataListItem(key: nil, title: "B", subtitle: nil, selected: false),
                    MRDataListItem(key: nil, title: "C", subtitle: nil, selected: false)
                ], visibilityBindKey: nil),
                MRFormRow(listMulti: nil, title: "Title 6-2", value: nil, extraData: [
                    MRDataListItem(key: nil, title: "1", subtitle: nil, selected: true),
                    MRDataListItem(key: nil, title: "2", subtitle: nil, selected: true),
                    MRDataListItem(key: nil, title: "3", subtitle: nil, selected: false)
                ], visibilityBindKey: nil)
            ])
        ]
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func didTapChatButton(_ sender: Any) {
        
        let chat = MRChatViewController()
        chat.playButtonImage = "ico_play.png".image
        navigationController?.pushViewController(chat, animated: true)
    }
    
    @IBAction func didTapBottomMenu(_ sender: Any) {
        
        let menu = MRBottomMenu(data: [
            MRBottomMenuSection(key: "section1", title: "Section 1", items: [
                MRBottomMenuItem(key: "item1", title: "Item 1", image: nil, action: {
                    print("Pressed Item 1")
                }),
                MRBottomMenuItem(key: "item2", title: "Item 2", image: nil, action: {
                    print("Pressed Item 2")
                }),
                MRBottomMenuItem(key: "item3", title: "Item 3", image: nil, action: {
                    print("Pressed Item 3")
                })
            ]),
            MRBottomMenuSection(key: "section2", title: "Section 2", items: [
                MRBottomMenuItem(key: "item4", title: "Item 4", image: nil, action: {
                    print("Pressed Item 4")
                }),
                MRBottomMenuItem(key: "item5", title: "Item 5", image: nil, action: {
                    print("Pressed Item 5")
                })
            ])
        ])
        menu.transitioningDelegate = self
        present(menu, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
