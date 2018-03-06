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
    
    @IBOutlet private var lblAppName : UILabel!
    @IBOutlet private var lblIntroMrApps : UILabel!
    @IBOutlet private var imgHeaderBackground : UIImageView!
    @IBOutlet private var gradientView : UIView!
    @IBOutlet private var backButton : UIButton!
    @IBOutlet private var headerView : UIView!
    @IBOutlet private var lblNavTitle : UILabel!
    @IBOutlet private var tableView : UITableView!
    @IBOutlet private var cntTableViewTrailing : NSLayoutConstraint!
    @IBOutlet private var cntTableViewLeading : NSLayoutConstraint!
    @IBOutlet weak var cntGradientViewHeight: NSLayoutConstraint!
    
    private var elements : [CreditsElement] = []
    private var bundle : Bundle!
    private var navGradient : CAGradientLayer!
    private var isPresenting = false
    private var cellIdentifier = "cellIdentifier"
    private var localizationBundle : Bundle!

    var appName : String = ""
    var color : UIColor!
    var regularFont : UIFont!
    var boldFont : UIFont!
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public init(appName:String?, color:UIColor?, regularFont:UIFont?, boldFont:UIFont?) {
        

        self.bundle = Bundle(for:MRCreditsViewController.self)
        self.localizationBundle = Bundle(path: self.bundle.bundlePath + "/CreditsLocalizations.bundle")

        super.init(nibName:"MRCreditsViewController", bundle:self.bundle)
        
        
        if let appName = appName {
            self.appName = appName
        } else {
            self.appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as! String
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
    
    override open func viewDidLoad() {
        
        super.viewDidLoad()
        
        lblAppName.text = self.appName
        
        tableView.tableHeaderView = self.headerView
        tableView.alwaysBounceVertical = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.contentInset = .zero
        
        elements = [
            CreditsElement(title: NSLocalizedString("Scopri Mr. APPs", tableName: nil, bundle: localizationBundle, value: "", comment: ""),
                           image: "icona_cella_mrapps.png",
                           link: "http://www.mr-apps.com"),
            CreditsElement(title: NSLocalizedString("Sviluppo App", tableName: nil, bundle: localizationBundle, value: "", comment: ""),
                           image: "icona_cella_appdesign.png",
                           link: "http://www.mr-apps.com/it/servizi/sviluppo-app"),
            CreditsElement(title: NSLocalizedString("Realizzazione Siti Web", tableName: nil, bundle: localizationBundle, value: "", comment: ""),
                           image: "icona_cella_webdesign.png",
                           link: "http://www.mr-apps.com/it/servizi/realizzazione-siti-web"),
            CreditsElement(title: NSLocalizedString("Progettazione E-Commerce", tableName: nil, bundle: localizationBundle, value: "", comment: ""),
                           image: "icona_cella_standard.png",
                           link: "http://www.mr-apps.com/it/servizi/realizzazione-ecommerce"),
            CreditsElement(title: NSLocalizedString("Le nostre App", tableName: nil, bundle: localizationBundle, value: "", comment: ""),
                           image: "icona_cella_portfolio.png",
                           link: "itms://itunes.apple.com/it/artist/mr.-apps-s.r.l./id493882589"),
            CreditsElement(title: NSLocalizedString("Contattaci ora", tableName: nil, bundle: localizationBundle, value: "", comment: ""),
                           image: "icona_cella_mail.png",
                           link: "http://www.mr-apps.com/it/contatti"),
            CreditsElement(title: NSLocalizedString("Richiedi un preventivo", tableName: nil, bundle: localizationBundle, value: "", comment: ""),
                           image: "icona_cella_file.png",
                           link: "http://www.mr-apps.com/it/il-tuo-progetto")
            
        ]
        
        lblIntroMrApps.text = NSLocalizedString("è un'applicazione realizzata da Mr. APPs", tableName: nil, bundle: localizationBundle, value: "", comment: "")
        lblIntroMrApps.font = regularFont
        lblAppName.font = boldFont
        
        navGradient = CAGradientLayer()
        navGradient.frame = gradientView.bounds
        navGradient.colors = [
            UIColor.black.withAlphaComponent(0.8).cgColor,
            UIColor.black.withAlphaComponent(0.3).cgColor,
            UIColor.clear.cgColor
        ]
        
        gradientView.layer.insertSublayer(navGradient, at: 0)
        cntGradientViewHeight.constant = 64.0 + UIView.safeArea.top
        
        
        if let boldFont = boldFont {
            lblNavTitle.font = boldFont
        }
        
        if navigationController != nil && navigationController!.viewControllers.count > 1  {
            backButton.setImage(UIImage(named: "ico_back", in: bundle, compatibleWith: self.traitCollection)?.paint(with: UIColor.white), for: .normal)
            backButton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        } else  {
            backButton.setImage(UIImage(named: "ico_nav_chiudi", in: bundle, compatibleWith: self.traitCollection)?.paint(with: UIColor.white), for: .normal)
            backButton.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
        }
        
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !isPresenting {
            navigationController?.setNavigationBarHidden(true, animated: true)
        }
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if !isPresenting {
            navigationController?.setNavigationBarHidden(false, animated: true)
        }
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        isPresenting = false
    }
    
    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        navGradient.frame = gradientView.bounds
    }
    
    func showNavigationBar(_ show : Bool) {
        
        if show {
            navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
            navigationController?.navigationBar.shadowImage = nil;
            navigationController?.navigationBar.isTranslucent = false;
        } else {
            navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
            navigationController?.navigationBar.shadowImage = UIImage();
            navigationController?.navigationBar.isTranslucent = true;
        }
        
    }
    
    @objc open func dismissView() {
        dismiss(animated: true, completion: nil)
    }
    
    //Tableview delegate methods
    
    open func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return elements.count
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)!
        let element = elements[indexPath.row]
        cell.textLabel?.font = regularFont
        cell.textLabel?.text = element.title
        cell.accessoryType = .disclosureIndicator
        cell.imageView?.image = UIImage(named: element.image, in: bundle, compatibleWith: self.traitCollection)?.paint(with: color)
        
        return cell
    }
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        isPresenting = true
        UIApplication.shared.openURL(URL(string: elements[indexPath.row].link)!)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @objc open func didTapBackButton() {
        navigationController?.popViewController(animated: true)
    }
}
    
    
    
    // MARK: - Initialization
    /*
    init(){
        super.init(nibName: "MRCreditsViewController", bundle: MRCreditsViewController.self)
    }
    
    convenience override init(appName: String, tintColor: UIColor, regularFont: UIFont, boldFont: UIFont) {
        self.init()
        
        self.appName = appName
        self.mainColor = tintColor
        self.regularFont = regularFont
        self.boldFont = boldFont
        //self.iconsPath = "\(Bundle.main.pathForResource("MRCreditsViewController", ofType: "bundle")!)/"
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - UIViewController Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if !UIDevice.isIpad() {
            self.backButton.setImage(UIImage(named: "ico_indietro"), forState: .Normal)
            self.backButton.addTarget(self, action: #selector(CreditsViewController.didTapBackButton), forControlEvents: .TouchUpInside)
        }
    }
    
    // MARK: - UIBarButtonItems Handlers
    
    func didTapBackButton() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    // MARK: - Others Functions

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }*/
