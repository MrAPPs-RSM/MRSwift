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

open class MRDataListItem : NSObject {
    
    public var key: String?
    public var title: String?
    public var subtitle: String?
    public var selected: Bool = false
    public var index: Int = 0
    
    public convenience init(key: String?, title: String?, subtitle: String?, selected: Bool) {
        self.init()
        
        self.key = key
        self.title = title
        self.subtitle = subtitle
        self.selected = selected
    }
}

public protocol MRDataListViewControllerDelegate : class {
    func mrDataListViewControllerDidSelectValue(viewController: UIViewController, value: MRDataListItem)
    func mrDataListViewControllerDidSelectValues(viewController: UIViewController, value: [MRDataListItem])
}

open class MRDataListViewController: MRPrimitiveViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    // MARK: - Layout
    
    var searchBar: UISearchBar!
    var list: UITableView!
    
    // MARK: - Constants & Variables
    
    private var allData = [MRDataListItem]()
    private var data = [MRDataListItem]()
    open var navTitle: String?
    open var navBackIcon: UIImage?
    open var selectedValue: String?
    open var searchTintColor: UIColor?
    open var backgroundColor = UIColor(netHex: 0xf5f5f5)
    open var titleColor = UIColor(netHex: 0x444444)
    open var valueColor = UIColor.black
    open var cellBackgroundColor = UIColor.white
    open var autoDismissOnSelect: Bool = false
    open var multiSelect: Bool = false
    private var selectedCount: Int = 0
    private let cellIdentifier = "cellIdentifier"
    public weak var delegate: MRDataListViewControllerDelegate?
    
    private let searchController = UISearchController(searchResultsController: nil)
    private var searchDispose: Disposable?
    private let rowHeight = MRDataListViewController.defaultRowHeight
    private let rowFontSize = MRDataListViewController.defaultRowFontSize
    
    // MARK: - Initialization
    
    public convenience init(data: [MRDataListItem], navTitle: String?, navBackIcon: UIImage?, selectedValue: String?) {
        self.init()
        
        self.allData = data
        self.data = data
        self.navTitle = navTitle
        self.navBackIcon = navBackIcon
        self.selectedValue = selectedValue
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
        
        view.backgroundColor = backgroundColor
        
        searchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.searchBarStyle = .minimal
        searchBar.tintColor = searchTintColor
        view.addSubview(searchBar)
        searchBar.autoPinEdge(toSuperviewEdge: .top)
        searchBar.autoPinEdge(toSuperviewEdge: .leading)
        searchBar.autoPinEdge(toSuperviewEdge: .trailing)
        
        list = UITableView(frame: view.frame, style: .grouped)
        list.dataSource = self
        list.delegate = self
        list.backgroundColor = .clear
        list.contentInset = UIEdgeInsets(top: -36, left: 0, bottom: 0, right: 0)
        list.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        view.addSubview(list)
        list.autoPinEdge(.top, to: .bottom, of: searchBar)
        list.autoPinEdge(toSuperviewEdge: .bottom)
        list.autoPinEdge(toSuperviewEdge: .leading)
        list.autoPinEdge(toSuperviewEdge: .trailing)

        if let textfield = searchBar.value(forKey: "searchField") as? UITextField {
            textfield.textColor = .black
            textfield.tintColor = .black
            if let backgroundview = textfield.subviews.first {
                backgroundview.backgroundColor = .white
                backgroundview.layer.cornerRadius = 10
                backgroundview.clipsToBounds = true;
            }
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
    
    public func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    public func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
    }
    
    public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        search(query: searchBar.text)
    }
    
    func search(query: String?) {
        
        if let query = query, !query.isEmpty {
            data = allData.filter { item in
                if let title = item.title {
                    return title.lowercased().contains(query.lowercased())
                }
                return false
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
        
        let item = data[indexPath.row]
        
        cell.backgroundColor = cellBackgroundColor
        cell.textLabel?.font = UIFont.systemFont(ofSize: rowFontSize, weight: .regular)
        cell.textLabel?.text = item.title
        cell.textLabel?.textColor = valueColor
        cell.accessoryType = item.selected ? .checkmark : .none
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        if !multiSelect {
            resetSelection()
        }
        
        let item = data[indexPath.row]
        item.selected = !item.selected
        
        if item.selected {
            selectedCount += 1
        } else {
            selectedCount -= 1
        }
 
        if let index = allData.index(where: { (allDataItem) -> Bool in
            return allDataItem.key == item.key || allDataItem.title == item.title
        }) {
            
            allData.remove(at: index)
            allData.insert(item, at: index)
            
            data.remove(at: indexPath.row)
            data.insert(item, at: indexPath.row)
            
            tableView.reloadData()
            
            if multiSelect {
                
                var selectedItems = [MRDataListItem]()
                for i in 0..<allData.count {
                    let allDataItem = allData[i]
                    if allDataItem.selected {
                        allDataItem.index = i
                        selectedItems.append(allDataItem)
                    }
                }
                delegate?.mrDataListViewControllerDidSelectValues(viewController: self, value: selectedItems)
                
            } else {
                
                item.index = index
                delegate?.mrDataListViewControllerDidSelectValue(viewController: self, value: item)
            }

        } else {
            tableView.reloadData()
        }
        
        if !multiSelect && autoDismissOnSelect {
            navigationController?.popViewController(animated: true)
        }
    }
    
    // MARK: - Other Methods
    
    func resetSelection() {
        
        var updatedAllData = [MRDataListItem]()
        for item in allData {
            item.selected = false
            updatedAllData.append(item)
        }
        
        var updatedData = [MRDataListItem]()
        for item in data {
            item.selected = false
            updatedData.append(item)
        }
        
        allData = updatedAllData
        data = updatedData
    }
    
    @objc func goBack() {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Battery Warning
    
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
