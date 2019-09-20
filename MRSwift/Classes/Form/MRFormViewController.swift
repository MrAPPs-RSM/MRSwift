//
//  MRFormViewController.swift
//  MRSwiftExample
//
//  Created by Nicola Innocenti on 22/05/18.
//  Copyright © 2018 Nicola Innocenti. All rights reserved.
//

import UIKit
import PureLayout

public extension UITableViewCell {
    
    @objc func configure(with row: MRFormRow) {
        
        accessoryType = row.type == .rowList || row.type == .rowListMulti ? .disclosureIndicator : row.accessoryType
        textLabel?.text = row.mandatory ? "\(row.title ?? "")*" : row.title
        if row.type == .rowList {
            if let item = row.value as? MRDataListItem {
                detailTextLabel?.text = item.title
            } else {
                detailTextLabel?.text = ""
            }
        } else if row.type == .rowListMulti {
            if let items = row.value as? [MRDataListItem] {
                detailTextLabel?.text = "\(items.count) sel."
            } else {
                detailTextLabel?.text = ""
            }
        } else {
            detailTextLabel?.text = row.type == .rowSubtitle ? row.subtitle : row.value as? String
        }
        imageView?.image = row.image
    }
}

public enum MRFormRowType {
    case rowDefault
    case rowSubtitle
    case rowTextField
    case rowSwitch
    case rowDate
    case rowList
    case rowListMulti
}

open class MRFormRow : NSObject {
    
    public var id: Any?
    public var key: String = ""
    public var title: String?
    public var subtitle: String?
    public var value: Any?
    public var placeholder: String?
    public var mandatory: Bool = false
    public var image: UIImage?
    public var extraData: Any?
    public var accessoryType: UITableViewCell.AccessoryType = .none
    public var type: MRFormRowType = .rowDefault
    public var dateFormat: String = ""
    public var visible: Bool = true
    public var visibilityBindKey: String?
    
    public convenience init(default key: String?, title: String?, value: String?, visibilityBindKey: String?) {
        self.init()
        
        self.key = key ?? ""
        self.title = title
        self.value = value
        self.visibilityBindKey = visibilityBindKey
        self.type = .rowDefault
    }
    
    public convenience init(switch key: String?, title: String?, value: Bool, visibilityBindKey: String?) {
        self.init()
        
        self.key = key ?? ""
        self.title = title
        self.value = value
        self.visibilityBindKey = visibilityBindKey
        self.type = .rowSwitch
    }
    
    public convenience init(date key: String?, title: String?, placeholder: String?, dateFormat: String, value: Date, visibilityBindKey: String?) {
        self.init()
        
        self.key = key ?? ""
        self.title = title
        self.dateFormat = dateFormat
        self.value = value
        self.visibilityBindKey = visibilityBindKey
        self.type = .rowDate
    }
    
    public convenience init(textField key: String?, title: String?, placeholder: String?, value: String?, visibilityBindKey: String?) {
        self.init()
        
        self.key = key ?? ""
        self.title = title
        self.value = value
        self.visibilityBindKey = visibilityBindKey
        self.type = .rowTextField
    }
    
    public convenience init(subtitle key: String?, title: String?, subtitle: String?, visibilityBindKey: String?) {
        self.init()
        
        self.key = key ?? ""
        self.title = title
        self.subtitle = title
        self.visibilityBindKey = visibilityBindKey
        self.type = .rowSubtitle
    }
    
    public convenience init(list key: String?, title: String?, value: String?, extraData: Any?, visibilityBindKey: String?) {
        self.init()
        
        self.key = key ?? ""
        self.title = title
        self.value = value
        self.extraData = extraData
        self.visibilityBindKey = visibilityBindKey
        self.type = .rowList
    }
    
    public convenience init(listMulti key: String?, title: String?, value: String?, extraData: Any?, visibilityBindKey: String?) {
        self.init()
        
        self.key = key ?? ""
        self.title = title
        self.value = value
        self.extraData = extraData
        self.visibilityBindKey = visibilityBindKey
        self.type = .rowListMulti
    }
    
    public convenience init(id: Any?, key: String?, title: String?, subtitle: String?, value: Any?, placeholder: String?, image: UIImage?, extraData: Any?, dateFormat: String?, accessoryType: UITableViewCell.AccessoryType, mandatory: Bool, type: MRFormRowType, visible: Bool = true) {
        self.init()
        
        self.id = id
        self.key = key ?? ""
        self.title = title
        self.subtitle = subtitle
        self.value = value
        self.placeholder = placeholder
        self.image = image
        self.extraData = extraData
        self.dateFormat = dateFormat ?? ""
        self.accessoryType = accessoryType
        self.mandatory = mandatory
        self.type = type
        self.visible = visible
    }
}

open class MRFormSection : NSObject {
    
    public var id: Any?
    public var key: String = ""
    public var title: String?
    public var subtitle: String?
    public var value: Any?
    public var stackable: Bool = false
    public var stacked: Bool = true
    public var rows = [MRFormRow]()
    
    public convenience init(id: Any?, key: String = "", title: String?, subtitle: String?, value: Any?, stackable: Bool = false, rows: [MRFormRow]) {
        self.init()
        
        self.id = id
        self.key = key
        self.title = title
        self.subtitle = subtitle
        self.value = value
        self.stackable = stackable
        self.rows = rows
    }
}

open class MRFormViewController: MRPrimitiveViewController, UITableViewDataSource, UITableViewDelegate, MRTextFieldTableCellDelegate, MRSwitchTableCellDelegate, MRDateTableCellDelegate, MRDataListViewControllerDelegate {
    
    // MARK: - Layout
    
    open var form: UITableView!
    
    // MARK: - Constants & Variables
    
    open var data = [MRFormSection]()
    private let cellIdentifier = "cellIdentifier"
    private let subtitleIdentifier = "subtitleIdentifier"
    private let textfieldIdentifier = "textfieldIdentifier"
    private let switchIdentifier = "switchIdentifier"
    private let dateIdentifier = "dateIdentifier"
    
    open var tintColor: UIColor?
    open var switchColor: UIColor?
    open var backgroundColor = UIColor(netHex: 0xf5f5f5)
    open var titleColor = UIColor(netHex: 0x444444)
    open var valueColor = UIColor.black
    open var cellBackgroundColor = UIColor.white
    open var editingEnabled: Bool = true
    open var searchTintColor: UIColor?
    open var navBackIcon: UIImage?
    
    open var currentIndexPath = IndexPath(row: 0, section: 0)
    
    // MARK: - UIViewController Methods
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13, *) {
            titleColor = .lightGray
            valueColor = .secondaryLabel
            backgroundColor = .groupTableViewBackground
            cellBackgroundColor = .secondarySystemGroupedBackground
            searchTintColor = .label
        }
        
        form = UITableView(frame: view.frame, style: .grouped)
        form.dataSource = self
        form.delegate = self
        form.keyboardDismissMode = .interactive
        form.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        form.register(MRTextFieldTableCell.self, forCellReuseIdentifier: textfieldIdentifier)
        form.register(MRSwitchTableCell.self, forCellReuseIdentifier: switchIdentifier)
        form.register(MRDateTableCell.self, forCellReuseIdentifier: dateIdentifier)
        
        view.addSubview(form)
        form.autoPinEdgesToSuperviewEdges()
        form.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: UIView.safeArea.bottom, right: 0)
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        registerForKeyboardNotifications()
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        unregisterForKeyboardNotifications()
    }
    
    // MARK: - Keyboard Handlers
    
    override open func keyboardDidShow(keyboardInfo: KeyboardInfo) {
        form.contentInset.bottom = keyboardInfo.endFrame.height
        form.scrollIndicatorInsets.bottom = keyboardInfo.endFrame.height
    }
    
    override open func keyboardDidHide(keyboardInfo: KeyboardInfo) {
        form.contentInset.bottom = 0
        form.scrollIndicatorInsets.bottom = 0
    }
    
    // MARK: - UITableView DataSource & Delegate
    
    open func numberOfSections(in tableView: UITableView) -> Int {
        return data.count
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let dataSection = data[section]
        return (dataSection.stackable && !dataSection.stacked) || !dataSection.stackable ? dataSection.rows.count : 0
    }
    
    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    open func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let dataSection = data[section]
        return dataSection.title
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let section = data[indexPath.section]
        let row = section.rows[indexPath.row]
        
        if row.type == .rowDefault || row.type == .rowList || row.type == .rowListMulti {
            
            let cell = UITableViewCell(style: .value1, reuseIdentifier: cellIdentifier)
            cell.backgroundColor = cellBackgroundColor
            cell.clipsToBounds = true
            cell.textLabel?.textColor = titleColor
            cell.textLabel?.font = UIFont.systemFont(ofSize: 15, weight: .regular)
            cell.detailTextLabel?.textColor = valueColor
            cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 15, weight: .regular)
            cell.configure(with: row)
            if tintColor != nil { cell.tintColor = tintColor }
            return cell
            
        } else if row.type == .rowSubtitle {
            
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: subtitleIdentifier)
            cell.backgroundColor = cellBackgroundColor
            cell.clipsToBounds = true
            cell.textLabel?.textColor = titleColor
            cell.textLabel?.font = UIFont.systemFont(ofSize: 15, weight: .regular)
            cell.detailTextLabel?.textColor = valueColor
            cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 13, weight: .regular)
            cell.configure(with: row)
            if tintColor != nil { cell.tintColor = tintColor }
            return cell
            
        } else if row.type == .rowTextField {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: textfieldIdentifier, for: indexPath) as! MRTextFieldTableCell
            cell.delegate = self
            cell.backgroundColor = cellBackgroundColor
            cell.accessoryType = .none
            cell.configure(with: row)
            cell.lblTitle.textColor = titleColor
            cell.txfValue.isEnabled = editingEnabled
            cell.txfValue.textColor = valueColor
            if tintColor != nil { cell.tintColor = tintColor }
            return cell
            
        } else if row.type == .rowSwitch {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: switchIdentifier, for: indexPath) as! MRSwitchTableCell
            cell.delegate = self
            cell.backgroundColor = cellBackgroundColor
            cell.accessoryType = .none
            cell.configure(with: row)
            cell.swSwitch.isEnabled = editingEnabled
            cell.lblTitle.textColor = titleColor
            if switchColor != nil { cell.swSwitch.onTintColor = switchColor }
            if tintColor != nil { cell.tintColor = tintColor }
            return cell
            
        } else if row.type == .rowDate {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: dateIdentifier, for: indexPath) as! MRDateTableCell
            cell.delegate = self
            cell.backgroundColor = cellBackgroundColor
            cell.accessoryType = .none
            cell.configure(with: row)
            cell.lblTitle.textColor = titleColor
            cell.txfValue.textColor = valueColor
            if tintColor != nil { cell.tintColor = tintColor }
            return cell
        }
        
        return UITableViewCell()
    }
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        let section = data[indexPath.section]
        let row = section.rows[indexPath.row]
        
        if (row.type == .rowList || row.type == .rowListMulti) && editingEnabled {
            if let extraData = row.extraData as? [MRDataListItem] {
                
                currentIndexPath = indexPath
                let list = MRDataListViewController(data: extraData, navTitle: row.title, navBackIcon: navBackIcon, selectedValue: row.value as? String)
                list.searchTintColor = searchTintColor
                list.backgroundColor = backgroundColor
                list.titleColor = titleColor
                list.valueColor = valueColor
                list.cellBackgroundColor = cellBackgroundColor
                list.multiSelect = row.type == .rowListMulti
                list.delegate = self
                navigationController?.pushViewController(list, animated: true)
            }
        }
    }
    
    // MARK: - MRTextFieldTableCell Delegate
    
    open func mrTextFieldTableCellDidChangeText(cell: MRTextFieldTableCell) {
        
        if let indexPath = form.indexPath(for: cell) {
            data[indexPath.section].rows[indexPath.row].value = cell.txfValue.text
        }
    }
    
    // MARK: - MRSwitchTableCell Delegate
    
    open func mrSwitchTableCellDidChangeSelection(cell: MRSwitchTableCell) {
        
        if let indexPath = form.indexPath(for: cell) {
            data[indexPath.section].rows[indexPath.row].value = cell.swSwitch.isOn
        }
    }
    
    // MARK: - MRDateTableCell Delegate
    
    open func mrDateTableCellDidChangeDate(cell: MRDateTableCell) {
        
        if let indexPath = form.indexPath(for: cell) {
            data[indexPath.section].rows[indexPath.row].value = cell.datePicker.date
        }
    }
    
    // MARK: - MRDataListViewController Delegate
    
    public func mrDataListViewControllerDidSelectValue(viewController: UIViewController, value: MRDataListItem) {
        
        data[currentIndexPath.section].rows[currentIndexPath.row].value = value
        form.reloadRows(at: [currentIndexPath], with: .none)
    }
    
    public func mrDataListViewControllerDidSelectValues(viewController: UIViewController, value: [MRDataListItem]) {
        
        data[currentIndexPath.section].rows[currentIndexPath.row].value = value
        form.reloadRows(at: [currentIndexPath], with: .none)
    }
    
    // MARK: - Other Methods
    
    // MARK: - Battery Warning
    
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
