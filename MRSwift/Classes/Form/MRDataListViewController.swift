//
//  MRDataListViewController.swift
//  MRSwiftExample
//
//  Created by Nicola Innocenti on 23/05/18.
//  Copyright © 2018 Nicola Innocenti. All rights reserved.
//

import UIKit
import PureLayout

public protocol MRDataListViewControllerDelegate : class {
    func mrDataListViewControllerDidSelectValue(value: String, at index: Int)
}

public class MRDataListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    // MARK: - Layout
    
    var list: UITableView!
    
    // MARK: - Constants & Variables
    
    private var data = [String]()
    private var selectedValue: String?
    private let cellIdentifier = "cellIdentifier"
    public weak var delegate: MRDataListViewControllerDelegate?
    
    // MARK: - Initialization
    
    convenience init(data: [String], selectedValue: String?) {
        self.init()
        
        self.data = data
        self.selectedValue = selectedValue
    }
    
    // MARK: - UIViewController Methods
    
    override public func viewDidLoad() {
        super.viewDidLoad()

        list = UITableView(frame: view.frame, style: .grouped)
        list.contentInset = UIEdgeInsets(top: -36, left: 0, bottom: 0, right: 0)
        list.dataSource = self
        list.delegate = self
        list.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        view.addSubview(list)
        list.autoPinEdgesToSuperviewEdges()
        
        let footer = UIView()
        footer.backgroundColor = .clear
        list.tableFooterView = footer
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
        delegate?.mrDataListViewControllerDidSelectValue(value: value, at: indexPath.row)
    }

    // MARK: - Battery Warning
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
