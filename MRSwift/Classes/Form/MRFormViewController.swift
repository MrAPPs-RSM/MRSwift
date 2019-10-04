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
                detailTextLabel?.text = row.value as? String
            }
        } else if row.type == .rowListMulti {
            if let items = row.value as? [MRDataListItem] {
                detailTextLabel?.text = items.count > 0 ? "\(items.count) sel." : nil
            } else {
                detailTextLabel?.text = row.value as? String
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
    case rowTextArea
    case rowSwitch
    case rowDate
    case rowList
    case rowListMulti
    case rowAttachment
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
    public var enabled: Bool = true
    public var visible: Bool = true
    public var visibilityBindKey: String?
    public var visibilityBindValue: Any?
    public var extraInfo: String?
    public var attachmentUrl: URL?
    
    public convenience init(default key: String?, title: String?, value: String?, visibilityBindKey: String?, visibilityBindValue: Any? = nil) {
        self.init()
        
        self.key = key ?? ""
        self.title = title
        self.value = value
        self.visibilityBindKey = visibilityBindKey
        self.visibilityBindValue = visibilityBindValue
        self.visible = visibilityBindKey == nil
        self.type = .rowDefault
    }
    
    public convenience init(attachment key: String?, title: String?, value: String?, attachmentUrl: URL?, visibilityBindKey: String?, visibilityBindValue: Any? = nil) {
        self.init()
        
        self.key = key ?? ""
        self.title = title
        self.value = value
        self.visibilityBindKey = visibilityBindKey
        self.visibilityBindValue = visibilityBindValue
        self.visible = visibilityBindKey == nil
        self.type = .rowAttachment
    }
    
    public convenience init(switch key: String?, title: String?, value: Bool, visibilityBindKey: String?, visibilityBindValue: Any? = nil) {
        self.init()
        
        self.key = key ?? ""
        self.title = title
        self.value = value
        self.visibilityBindKey = visibilityBindKey
        self.visibilityBindValue = visibilityBindValue
        self.visible = visibilityBindKey == nil
        self.type = .rowSwitch
    }
    
    public convenience init(date key: String?, title: String?, placeholder: String?, dateFormat: String, value: Date?, visibilityBindKey: String?, visibilityBindValue: Any? = nil) {
        self.init()
        
        self.key = key ?? ""
        self.title = title
        self.dateFormat = dateFormat
        self.value = value
        self.visibilityBindKey = visibilityBindKey
        self.visibilityBindValue = visibilityBindValue
        self.visible = visibilityBindKey == nil
        self.type = .rowDate
    }
    
    public convenience init(textField key: String?, title: String?, placeholder: String?, value: String?, visibilityBindKey: String?, visibilityBindValue: Any? = nil) {
        self.init()
        
        self.key = key ?? ""
        self.title = title
        self.value = value
        self.visibilityBindKey = visibilityBindKey
        self.visibilityBindValue = visibilityBindValue
        self.visible = visibilityBindKey == nil
        self.type = .rowTextField
    }
    
    public convenience init(textArea key: String?, title: String?, placeholder: String?, value: String?, visibilityBindKey: String?, visibilityBindValue: Any? = nil) {
        self.init()
        
        self.key = key ?? ""
        self.title = title
        self.value = value
        self.visibilityBindKey = visibilityBindKey
        self.visibilityBindValue = visibilityBindValue
        self.visible = visibilityBindKey == nil
        self.type = .rowTextArea
    }
    
    public convenience init(subtitle key: String?, title: String?, subtitle: String?, visibilityBindKey: String?, visibilityBindValue: Any? = nil) {
        self.init()
        
        self.key = key ?? ""
        self.title = title
        self.subtitle = subtitle
        self.visibilityBindKey = visibilityBindKey
        self.visibilityBindValue = visibilityBindValue
        self.visible = visibilityBindKey == nil
        self.type = .rowSubtitle
    }
    
    public convenience init(list key: String?, title: String?, value: String?, extraData: Any?, visibilityBindKey: String?, visibilityBindValue: Any? = nil) {
        self.init()
        
        self.key = key ?? ""
        self.title = title
        self.value = value
        self.extraData = extraData
        self.visibilityBindKey = visibilityBindKey
        self.visibilityBindValue = visibilityBindValue
        self.visible = visibilityBindKey == nil
        self.type = .rowList
    }
    
    public convenience init(listMulti key: String?, title: String?, value: String?, extraData: Any?, visibilityBindKey: String?, visibilityBindValue: Any? = nil) {
        self.init()
        
        self.key = key ?? ""
        self.title = title
        self.value = value
        self.extraData = extraData
        self.visibilityBindKey = visibilityBindKey
        self.visibilityBindValue = visibilityBindValue
        self.visible = visibilityBindKey == nil
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

open class MRFormViewController: MRPrimitiveViewController, UITableViewDataSource, UITableViewDelegate, MRTextFieldTableCellDelegate, MRTextViewTableCellDelegate, MRSwitchTableCellDelegate, MRDateTableCellDelegate, MRDataListViewControllerDelegate {
    
    // MARK: - Layout
    
    open var form: UITableView!
    private var scrollView: UIScrollView!
    private var containerView: UIView!
    
    // MARK: - Constraints
    
    private var cntContentHeight: NSLayoutConstraint?
    private var cntContentLeading: NSLayoutConstraint?
    private var cntContentTrailing: NSLayoutConstraint?
    
    // MARK: - Constants & Variables
    
    open var data = [MRFormSection]()
    private let cellIdentifier = "cellIdentifier"
    private let subtitleIdentifier = "subtitleIdentifier"
    private let textfieldIdentifier = "textFieldIdentifier"
    private let textAreaIdentifier = "textAreaIdentifier"
    private let switchIdentifier = "switchIdentifier"
    private let dateIdentifier = "dateIdentifier"
    
    open var tintColor: UIColor?
    open var switchColor: UIColor?
    open var backgroundColor = UIColor(netHex: 0xf5f5f5)
    open var sectionTitleColor = UIColor.lightGray
    open var titleColor = UIColor.black
    open var valueColor = UIColor.black
    open var cellBackgroundColor = UIColor.white
    open var editingEnabled: Bool = true
    open var searchTintColor: UIColor?
    open var navBackIcon: UIImage?
    open var sectionTitleFont = UIFont.systemFont(ofSize: 13, weight: .regular)
    open var cellTitleFont = UIFont.systemFont(ofSize: 16, weight: .regular)
    open var cellValueFont = UIFont.systemFont(ofSize: 16, weight: .regular)
    open var autoDismissListsOnSelection: Bool = true
    open var iPadMargin: CGFloat = 100
    
    open var currentIndexPath = IndexPath(row: 0, section: 0)
    
    private var marginsActive : Bool {
        return UIDevice.isIpad && iPadMargin > 0
    }
    
    // MARK: - Initialization
    
    deinit {
        if marginsActive {
            form.removeObserver(self, forKeyPath: "contentSize")
        }
    }
    
    // MARK: - UIViewController Methods
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        if let backIcon = navBackIcon {
            navigationItem.leftBarButtonItem = UIBarButtonItem(image: backIcon, style: .plain, target: self, action: #selector(goBack))
        }
        
        if #available(iOS 13, *) {
            
            sectionTitleColor = .secondaryLabel
            titleColor = .secondaryLabel
            valueColor = UIColor { (traitCollection: UITraitCollection) -> UIColor in
                switch traitCollection.userInterfaceStyle {
                    case
                        .unspecified,
                        .light: return .black
                    case
                        .dark: return .white
                }
            }
            backgroundColor = .groupTableViewBackground
            cellBackgroundColor = .secondarySystemGroupedBackground
            searchTintColor = .label
        }
        
        view.backgroundColor = backgroundColor
        
        form = UITableView(frame: view.frame, style: .grouped)
        form.dataSource = self
        form.delegate = self
        form.keyboardDismissMode = .interactive
        form.backgroundColor = .clear
        form.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        form.register(MRTextFieldTableCell.self, forCellReuseIdentifier: textfieldIdentifier)
        form.register(MRTextViewTableCell.self, forCellReuseIdentifier: textAreaIdentifier)
        form.register(MRSwitchTableCell.self, forCellReuseIdentifier: switchIdentifier)
        form.register(MRDateTableCell.self, forCellReuseIdentifier: dateIdentifier)
        
        if marginsActive {
            
            scrollView = UIScrollView()
            view.addSubview(scrollView)
            scrollView.autoPinEdgesToSuperviewEdges()
            
            let containerView = UIView()
            scrollView.addSubview(containerView)
            scrollView.alwaysBounceVertical = true
            scrollView.showsVerticalScrollIndicator = true
            containerView.autoPinEdgesToSuperviewEdges()
            containerView.autoMatch(.width, to: .width, of: scrollView)
            
            containerView.addSubview(form)
            form.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: UIView.safeArea.bottom, right: 0)
            form.autoPinEdge(toSuperviewEdge: .top)
            form.autoPinEdge(toSuperviewEdge: .bottom)
            form.isScrollEnabled = false
            form.showsVerticalScrollIndicator = false
            cntContentLeading = form.autoPinEdge(toSuperviewEdge: .leading)
            cntContentTrailing = form.autoPinEdge(toSuperviewEdge: .trailing)
            cntContentHeight = form.autoSetDimension(.height, toSize: 100)
            form.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
            
        } else {
            
            view.addSubview(form)
            form.autoPinEdgesToSuperviewEdges()
            form.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: UIView.safeArea.bottom, right: 0)
        }
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        registerForKeyboardNotifications()
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        unregisterForKeyboardNotifications()
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if marginsActive {
            cntContentLeading?.constant = UIApplication.shared.statusBarOrientation.isPortrait ? iPadMargin : iPadMargin*1.8
            cntContentTrailing?.constant = UIApplication.shared.statusBarOrientation.isPortrait ? -iPadMargin : -(iPadMargin*1.8)
        }
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
        
        let dataSection = data[indexPath.section]
        let dataRow = dataSection.rows[indexPath.row]
        return dataRow.visible ? UITableView.automaticDimension : 0
    }
    
    open func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let dataSection = data[section]
        
        let header = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 36))
        let title = UILabel(frame: header.frame)
        header.addSubview(title)
        
        title.autoPinEdge(toSuperviewEdge: .leading, withInset: 20)
        title.autoPinEdge(toSuperviewEdge: .trailing, withInset: 20)
        title.autoPinEdge(toSuperviewEdge: .bottom, withInset: 8)
        title.font = sectionTitleFont
        title.textColor = sectionTitleColor
        title.text = dataSection.title?.uppercased()
        
        return header
    }
    
    open func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        let dataSection = data[section]
        return dataSection.title != nil ? 36.0 : 0
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let section = data[indexPath.section]
        let row = section.rows[indexPath.row]
        
        if row.type == .rowAttachment {
            
            let cell = UITableViewCell(style: .value1, reuseIdentifier: cellIdentifier)
            cell.isHidden = !row.visible
            cell.selectionStyle = .default
            cell.backgroundColor = cellBackgroundColor
            cell.clipsToBounds = true
            cell.textLabel?.textColor = titleColor
            cell.textLabel?.font = cellTitleFont
            cell.detailTextLabel?.textColor = valueColor
            cell.detailTextLabel?.font = cellValueFont
            cell.textLabel?.text = row.title
            cell.detailTextLabel?.text = row.attachmentUrl != nil ? "File" : ""
            cell.accessoryType = .disclosureIndicator
            if tintColor != nil { cell.tintColor = tintColor }
            return cell
            
        } else if row.type == .rowDefault || row.type == .rowAttachment || row.type == .rowList || row.type == .rowListMulti {
            
            let cell = UITableViewCell(style: .value1, reuseIdentifier: cellIdentifier)
            cell.isHidden = !row.visible
            cell.selectionStyle = row.type != .rowDefault ? .default : .none
            cell.backgroundColor = cellBackgroundColor
            cell.clipsToBounds = true
            cell.textLabel?.textColor = titleColor
            cell.textLabel?.font = cellTitleFont
            cell.detailTextLabel?.textColor = valueColor
            cell.detailTextLabel?.font = cellValueFont
            cell.configure(with: row)
            if tintColor != nil { cell.tintColor = tintColor }
            return cell
            
        } else if row.type == .rowSubtitle {
            
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: subtitleIdentifier)
            cell.isHidden = !row.visible
            cell.selectionStyle = .none
            cell.backgroundColor = cellBackgroundColor
            cell.clipsToBounds = true
            cell.textLabel?.textColor = titleColor
            cell.textLabel?.font = cellTitleFont
            cell.detailTextLabel?.textColor = valueColor
            cell.detailTextLabel?.font = cellValueFont
            cell.configure(with: row)
            if tintColor != nil { cell.tintColor = tintColor }
            return cell
            
        } else if row.type == .rowTextField {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: textfieldIdentifier, for: indexPath) as! MRTextFieldTableCell
            cell.isHidden = !row.visible
            cell.selectionStyle = .none
            cell.delegate = self
            cell.backgroundColor = cellBackgroundColor
            cell.accessoryType = .none
            cell.lblTitle.font = cellTitleFont
            cell.lblTitle.textColor = titleColor
            cell.txfValue.isEnabled = editingEnabled
            cell.txfValue.font = cellValueFont
            cell.txfValue.textColor = valueColor
            cell.configure(with: row)
            if tintColor != nil { cell.tintColor = tintColor }
            return cell
            
        } else if row.type == .rowTextArea {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: textAreaIdentifier, for: indexPath) as! MRTextViewTableCell
            cell.isHidden = !row.visible
            cell.selectionStyle = .none
            cell.delegate = self
            cell.backgroundColor = cellBackgroundColor
            cell.accessoryType = .none
            cell.lblTitle.font = cellTitleFont
            cell.lblTitle.textColor = titleColor
            cell.txwValue.isEditable = editingEnabled
            cell.txwValue.font = cellValueFont
            cell.txwValue.textColor = valueColor
            cell.configure(with: row)
            if tintColor != nil { cell.tintColor = tintColor }
            return cell
            
        } else if row.type == .rowSwitch {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: switchIdentifier, for: indexPath) as! MRSwitchTableCell
            cell.isHidden = !row.visible
            cell.selectionStyle = .none
            cell.delegate = self
            cell.backgroundColor = cellBackgroundColor
            cell.accessoryType = .none
            cell.swSwitch.isEnabled = editingEnabled
            cell.lblTitle.textColor = titleColor
            cell.lblTitle.font = cellTitleFont
            cell.configure(with: row)
            if switchColor != nil { cell.swSwitch.onTintColor = switchColor }
            if tintColor != nil { cell.tintColor = tintColor }
            return cell
            
        } else if row.type == .rowDate {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: dateIdentifier, for: indexPath) as! MRDateTableCell
            cell.isHidden = !row.visible
            cell.selectionStyle = .none
            cell.delegate = self
            cell.backgroundColor = cellBackgroundColor
            cell.accessoryType = .none
            cell.lblTitle.textColor = titleColor
            cell.lblTitle.font = cellTitleFont
            cell.txfValue.textColor = valueColor
            cell.txfValue.font = cellValueFont
            cell.configure(with: row)
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
                list.autoDismissOnSelect = autoDismissListsOnSelection
                list.delegate = self
                
                if UIDevice.isIpad {
                    let nav = UINavigationController(rootViewController: list)
                    if #available(iOS 13.0, *) {
                        
                    } else {
                        nav.modalPresentationStyle = .formSheet
                    }
                    present(nav, animated: true, completion: nil)
                } else {
                    navigationController?.pushViewController(list, animated: true)
                }
            }
            
        } else if row.type == .rowAttachment {
            
            let picker = MRFilePicker()
            picker.pickFile(on: self) { (fileUrl, message) in
                self.data[indexPath.section].rows[indexPath.row].attachmentUrl = fileUrl
                tableView.reloadRows(at: [indexPath], with: .none)
            }
        }
    }
    
    // MARK: - MRTextFieldTableCell Delegate
    
    open func mrTextFieldTableCellDidChangeText(cell: MRTextFieldTableCell) {
        
        if let indexPath = form.indexPath(for: cell) {
            
            data[indexPath.section].rows[indexPath.row].value = cell.txfValue.text
            let item = data[indexPath.section].rows[indexPath.row]
            showLinkedItems(key: item.key, value: cell.txfValue.text)
        }
    }
    
    // MARK: - MRTextViewTableCell Delegate
    
    public func mrTextViewTableCellDidChangeText(cell: MRTextViewTableCell) {
        
        if let indexPath = form.indexPath(for: cell) {
            
            data[indexPath.section].rows[indexPath.row].value = cell.txwValue.text
            let item = data[indexPath.section].rows[indexPath.row]
            showLinkedItems(key: item.key, value: cell.txwValue.text)
        }
    }
    
    // MARK: - MRSwitchTableCell Delegate
    
    open func mrSwitchTableCellDidChangeSelection(cell: MRSwitchTableCell) {
        
        if let indexPath = form.indexPath(for: cell) {
            
            data[indexPath.section].rows[indexPath.row].value = cell.swSwitch.isOn
            let item = data[indexPath.section].rows[indexPath.row]
            showLinkedItems(key: item.key, value: cell.swSwitch.isOn)
        }
    }
    
    // MARK: - MRDateTableCell Delegate
    
    open func mrDateTableCellDidChangeDate(cell: MRDateTableCell) {
        
        if let indexPath = form.indexPath(for: cell) {
            
            data[indexPath.section].rows[indexPath.row].value = cell.datePicker.date
            let item = data[indexPath.section].rows[indexPath.row]
            showLinkedItems(key: item.key, value: cell.datePicker.date)
        }
    }
    
    // MARK: - MRDataListViewController Delegate
    
    open func mrDataListViewControllerDidSelectValue(viewController: UIViewController, value: MRDataListItem) {
        
        data[currentIndexPath.section].rows[currentIndexPath.row].value = value
        form.reloadRows(at: [currentIndexPath], with: .none)
        
        let item = data[currentIndexPath.section].rows[currentIndexPath.row]
        showLinkedItems(key: item.key, value: value)
    }
    
    open func mrDataListViewControllerDidSelectValues(viewController: UIViewController, value: [MRDataListItem]) {
        
        data[currentIndexPath.section].rows[currentIndexPath.row].value = value
        form.reloadRows(at: [currentIndexPath], with: .none)
        
        let item = data[currentIndexPath.section].rows[currentIndexPath.row]
        showLinkedItems(key: item.key, value: value.count > 0)
    }
    
    // MARK: - Other Methods
    
    @objc func goBack() {
        navigationController?.popViewController(animated: true)
    }
    
    private func showLinkedItems(key: String, value: Any?) {
        
        var indexPathsToUpdate = [IndexPath]()
        
        for i in 0..<data.count {
            let section = data[i]
            for j in 0..<section.rows.count {
                let row = section.rows[j]
                var show = true
                if row.visibilityBindKey == key {
                    if let visibilityValue = row.visibilityBindValue {
                        show = false
                        if let stringValue = value as? String, let visStringValue = visibilityValue as? String {
                            show = stringValue.compare(visStringValue) == .orderedSame
                        } else if let intValue = value as? Int, let visIntValue = visibilityValue as? Int {
                            show = intValue == visIntValue
                        } else if let boolValue = value as? Bool, let visBoolValue = visibilityValue as? Bool {
                            show = boolValue == visBoolValue
                        }
                    } else {
                       show = value != nil
                    }
                }
                if data[i].rows[j].visible != show {
                    data[i].rows[j].visible = show
                    indexPathsToUpdate.append(IndexPath(row: j, section: i))
                }
            }
        }
        
        form.reloadRows(at: indexPathsToUpdate, with: .automatic)
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == "contentSize" && object is UITableView && marginsActive {
            cntContentHeight?.constant = form.contentSize.height
        }
    }
    
    // MARK: - Battery Warning
    
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
