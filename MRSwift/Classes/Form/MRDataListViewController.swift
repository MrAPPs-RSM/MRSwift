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

public class MRDataListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating {

    // MARK: - Layout
    
    var list: UITableView!
    
    // MARK: - Constants & Variables
    
    private var allData = [String]()
    private var data = [String]()
    private var selectedValue: String?
    private let cellIdentifier = "cellIdentifier"
    public weak var delegate: MRDataListViewControllerDelegate?
    
    private let searchController = UISearchController(searchResultsController: nil)
    private var searchDispose: Disposable?
    
    // MARK: - Initialization
    
    convenience init(data: [String], selectedValue: String?) {
        self.init()
        
        self.allData = data
        self.data = data
        self.selectedValue = selectedValue
    }
    
    deinit {
        list.tableHeaderView = nil
    }
    
    // MARK: - UIViewController Methods
    
    override public func viewDidLoad() {
        super.viewDidLoad()

        list = UITableView(frame: view.frame, style: .grouped)
        list.dataSource = self
        list.delegate = self
        list.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        view.addSubview(list)
        list.autoPinEdgesToSuperviewEdges()
        
        let footer = UIView()
        footer.backgroundColor = .clear
        list.tableFooterView = footer
        
        searchController.searchBar.searchBarStyle = .minimal
        searchController.searchBar.showsCancelButton = false
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        list.tableHeaderView = searchController.searchBar
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
    
    // MARK: - UITableView DataSource & Delegate
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        
        let value = data[indexPath.row]
        
        cell.textLabel?.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        cell.textLabel?.text = value
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
    
    

    // MARK: - Battery Warning
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
