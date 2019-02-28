//
//  MRCreditsViewController.swift
//  MRSwiftSDK
//
//  Created by Nicola Innocenti on 04/08/16.
//  Copyright © 2016 Mr. APPs srl. All rights reserved.
//

import UIKit

public class CreditsElement {
    var title = ""
    var image = ""
    var link = ""
    
    init(title : String, image : String, link : String) {
        self.title = title
        self.image = image
        self.link = link
    }
}

open class MRCreditsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Xibs
    
    @IBOutlet open var lblAppName : UILabel!
    @IBOutlet open var lblIntroMrApps : UILabel!
    @IBOutlet private var imgHeaderBackground : UIImageView!
    @IBOutlet private var headerView : UIView!
    @IBOutlet private var tableView : UITableView!
    
    // MARK: - Constraints
    
    @IBOutlet private var cntTableViewTrailing : NSLayoutConstraint!
    @IBOutlet private var cntTableViewLeading : NSLayoutConstraint!
    
    // MARK: - Constants & Variables
    
    private var elements : [CreditsElement] = []
    private var bundle : Bundle!
    private var navGradient : CAGradientLayer!
    private var isPresenting = false
    private var cellIdentifier = "cellIdentifier"
    private var localizationBundle : Bundle!
    
    public var appName : String = ""
    public var color : UIColor!
    public var regularFont : UIFont!
    public  var boldFont : UIFont!
    
    // MARK: - Initialization
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public init(appName:String?, color:UIColor?, regularFont:UIFont?, boldFont:UIFont?) {
        
        bundle = Bundle(for:MRCreditsViewController.self)
        localizationBundle = Bundle(path: self.bundle.bundlePath + "/CreditsLocalizations.bundle")
        
        super.init(nibName:"MRCreditsViewController", bundle: bundle)
        
        if let appName = appName {
            self.appName = appName
        } else {
            self.appName = Bundle.main.appName
        }
        
        if let color = color {
            self.color = color
        } else {
            self.color = UIColor(red: 0.61, green: 0.0, blue: 0.06, alpha: 1.0)
        }
        
        if let regularFont = regularFont {
            self.regularFont = regularFont
        } else {
            self.regularFont = UIFont.systemFont(ofSize: 15.0)
        }
        
        if let boldFont = boldFont {
            self.boldFont = boldFont
        } else {
            self.boldFont = UIFont.boldSystemFont(ofSize: 15.0)
        }
    }
    
    convenience public init() {
        self.init(appName: nil, color: nil, regularFont: nil, boldFont: nil)
    }
    
    convenience public init(appName: String, color: UIColor) {
        self.init(appName: appName, color: color, regularFont: nil, boldFont: nil)
    }
    
    convenience public init(color: UIColor) {
        self.init(appName: nil, color: color, regularFont: nil, boldFont: nil)
    }
    
    // MARK: - UIViewController Methods
    
    override open func viewDidLoad() {
        
        super.viewDidLoad()
        
        navigationItem.title = "Credits"
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "ico_back", in: bundle, compatibleWith: self.traitCollection)?.paint(with: UIColor.white), style: .plain, target: self, action: #selector(didTapBackButton))
        
        lblAppName.text = self.appName
        
        tableView.tableHeaderView = self.headerView
        tableView.register(MRBaseTableCell.self, forCellReuseIdentifier: MRBaseTableCell.identifier)
        tableView.alwaysBounceVertical = false
        tableView.separatorInset = .zero
        tableView.contentInset = UIEdgeInsets(top: -UIView.safeArea.top, left: 0, bottom: 0, right: 0)
        
        elements = [
            CreditsElement(title: NSLocalizedString("credits_1", tableName: nil, bundle: localizationBundle, value: "", comment: ""),
                           image: "icona_cella_mrapps.png",
                           link: "http://www.mr-apps.com"),
            CreditsElement(title: NSLocalizedString("credits_2", tableName: nil, bundle: localizationBundle, value: "", comment: ""),
                           image: "icona_cella_appdesign.png",
                           link: "http://www.mr-apps.com/it/servizi/sviluppo-app"),
            CreditsElement(title: NSLocalizedString("credits_3", tableName: nil, bundle: localizationBundle, value: "", comment: ""),
                           image: "icona_cella_webdesign.png",
                           link: "http://www.mr-apps.com/it/servizi/realizzazione-siti-web"),
            CreditsElement(title: NSLocalizedString("credits_4", tableName: nil, bundle: localizationBundle, value: "", comment: ""),
                           image: "icona_cella_standard.png",
                           link: "http://www.mr-apps.com/it/servizi/realizzazione-ecommerce"),
            CreditsElement(title: NSLocalizedString("credits_5", tableName: nil, bundle: localizationBundle, value: "", comment: ""),
                           image: "icona_cella_portfolio.png",
                           link: "https://itunes.apple.com/it/developer/mr-apps-s-r-l/id493882589"),
            CreditsElement(title: NSLocalizedString("credits_6", tableName: nil, bundle: localizationBundle, value: "", comment: ""),
                           image: "icona_cella_mail.png",
                           link: "http://www.mr-apps.com/it/contatti"),
            CreditsElement(title: NSLocalizedString("credits_7", tableName: nil, bundle: localizationBundle, value: "", comment: ""),
                           image: "icona_cella_file.png",
                           link: "http://www.mr-apps.com/it/il-tuo-progetto")
            
        ]
        
        lblIntroMrApps.text = NSLocalizedString("credits_subtitle", tableName: nil, bundle: localizationBundle, value: "", comment: "")
        lblIntroMrApps.font = regularFont
        lblAppName.font = boldFont
    }
    
    //UITableView DataSource & Delegate
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return elements.count
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: MRBaseTableCell.identifier, for: indexPath) as! MRBaseTableCell
        let element = elements[indexPath.row]
        cell.textLabel?.font = regularFont
        cell.textLabel?.text = element.title
        cell.accessoryType = .disclosureIndicator
        cell.imageView?.image = UIImage(named: element.image, in: bundle, compatibleWith: self.traitCollection)?.paint(with: color)
        
        return cell
    }
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let stringUrl = elements[indexPath.row].link
        if let url = URL(string: stringUrl) {
            if UIApplication.shared.canOpenURL(url) {
                isPresenting = true
                UIApplication.shared.openUrl(stringUrl: stringUrl, on: self)
            }
        }
    }
    
    // MARK: - Other Methods
    
    @objc open func didTapBackButton() {
        navigationController?.popViewController(animated: true)
    }
}
