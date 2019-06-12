//
//  MRDataListViewController.swift
//  MRSwiftExample
//
//  Created by Nicola Innocenti on 23/05/18.
//  Copyright © 2018 Nicola Innocenti. All rights reserved.
//

import UIKit
import PureLayout
import RxSwift

public protocol MRDataListViewControllerDelegate : class {
    func mrDataListViewControllerDidSelectValue(value: String, at index: Int)
}

open class MRDataListViewController: MRPrimitiveViewController, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating {
    
    // MARK: - Layout
    
    var list: UITableView!
    
    // MARK: - Constants & Variables
    
    private var allData = [String]()
    private var data = [String]()
    private var navTitle: String?
    private var navBackIcon: UIImage?
    private var selectedValue: String?
    private var valueColor = UIColor.black
    private var searchTintColor: UIColor?
    private let cellIdentifier = "cellIdentifier"
    public weak var delegate: MRDataListViewControllerDelegate?
    
    private let searchController = UISearchController(searchResultsController: nil)
    private var searchDispose: Disposable?
    private let rowHeight = MRDataListViewController.defaultRowHeight
    private let rowFontSize = MRDataListViewController.defaultRowFontSize
    
    // MARK: - Initialization
    
    convenience init(data: [String], navTitle: String?, navBackIcon: UIImage?, selectedValue: String?, valueColor: UIColor, searchTintColor: UIColor?) {
        self.init()
        
        self.allData = data
        self.data = data
        self.navTitle = navTitle
        self.navBackIcon = navBackIcon
        self.selectedValue = selectedValue
        self.valueColor = valueColor
        self.searchTintColor = searchTintColor
    }
    
    deinit {
        list.tableHeaderView = nil
    }
    
    open class var defaultRowHeight : CGFloat {
        get {
            let rowHeight = CGFloat(UserDefaults.standard.float(forKey: "MRDataListViewControllerDefaultRowHeight"))
            if rowHeight > 0 {
                return rowHeight
            } else {
                return 50
            }
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "MRDataListViewControllerDefaultRowHeight")
            UserDefaults.standard.synchronize()
        }
    }
    
    open class var defaultRowFontSize : CGFloat {
        get {
            let fontSize = CGFloat(UserDefaults.standard.float(forKey: "MRDataListViewControllerRowFontSize"))
            if fontSize > 0 {
                return fontSize
            } else {
                return 16
            }
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "MRDataListViewControllerRowFontSize")
            UserDefaults.standard.synchronize()
        }
    }
    
    // MARK: - UIViewController Methods
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = navTitle
        if let navBackIcon = navBackIcon {
            navigationItem.leftBarButtonItem = UIBarButtonItem(image: navBackIcon, style: .plain, target: self, action: #selector(goBack))
        }
        
        list = UITableView(frame: view.frame, style: .grouped)
        list.dataSource = self
        list.delegate = self
        list.backgroundColor = .clear
        list.contentInset = UIEdgeInsets(top: -36, left: 0, bottom: 0, right: 0)
        list.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        view.addSubview(list)
        list.autoPinEdgesToSuperviewEdges()
        
        let footer = UIView()
        footer.backgroundColor = .clear
        list.tableFooterView = footer
        
        searchController.searchBar.showsCancelButton = false
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        
        if let searchTintColor = searchTintColor {
            searchController.searchBar.tintColor = searchTintColor
        } else {
            searchController.searchBar.tintColor = .black
        }
        
        if let textfield = searchController.searchBar.value(forKey: "searchField") as? UITextField {
            textfield.textColor = UIColor.black
            textfield.tintColor = .lightGray
            if let backgroundview = textfield.subviews.first {
                backgroundview.backgroundColor = .white
                backgroundview.layer.cornerRadius = 10;
                backgroundview.clipsToBounds = true;
            }
        }
        
        if #available(iOS 11.0, *) {
            searchController.searchBar.barStyle = navigationController?.navigationBar.barTintColor?.isDark == true ? .black : .default
            navigationItem.searchController = searchController
        } else {
            list.tableHeaderView = searchController.searchBar
        }
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerForKeyboardNotifications()
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unregisterForKeyboardNotifications()
    }
    
    // MARK: - Search Handlers
    
    public func updateSearchResults(for searchController: UISearchController) {
        search(query: searchController.searchBar.text)
    }
    
    func search(query: String?) {
        
        if let query = query, !query.isEmpty {
            data = allData.filter { value in
                return value.lowercased().contains(query.lowercased())
            }
        } else {
            data = allData
        }
        list.reloadData()
    }
    
    // MARK: - Keyboard Handlers
    
    open override func keyboardDidShow(keyboardInfo: KeyboardInfo) {
        let inset = UIEdgeInsets(top: -36, left: 0, bottom: keyboardInfo.endFrame.size.height, right: 0)
        list.contentInset = inset
        list.scrollIndicatorInsets = inset
    }
    
    open override func keyboardDidHide(keyboardInfo: KeyboardInfo) {
        let inset = UIEdgeInsets(top: -36, left: 0, bottom: 0, right: 0)
        list.contentInset = inset
        list.scrollIndicatorInsets = inset
    }
    
    // MARK: - UITableView DataSource & Delegate
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return rowHeight
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        
        let value = data[indexPath.row]
        
        cell.textLabel?.font = UIFont.systemFont(ofSize: rowFontSize, weight: .regular)
        cell.textLabel?.text = value
        cell.textLabel?.textColor = valueColor
        cell.accessoryType = selectedValue != nil ? selectedValue! == value ? .checkmark : .none : .none
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        let value = data[indexPath.row]
        selectedValue = value
        tableView.reloadData()
        
        let index = allData.index { (value) -> Bool in
            return value == data[indexPath.row]
        }
        
        delegate?.mrDataListViewControllerDidSelectValue(value: value, at: index!)
    }
    
    // MARK: - Other Methods
    
    @objc func goBack() {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Battery Warning
    
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
