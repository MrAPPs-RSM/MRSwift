//
//  MRDateTableCell.swift
//  MRSwiftExample
//
//  Created by Nicola Innocenti on 23/05/18.
//  Copyright © 2018 Nicola Innocenti. All rights reserved.
//

import UIKit

public protocol MRDateTableCellDelegate : AnyObject {
    func mrDateTableCellDidChangeDate(cell: MRDateTableCell)
}

public class MRDateTableCell: UITableViewCell, UITextFieldDelegate {
    
    public var lblTitle: UILabel!
    public var txfValue: UITextField!
    public var datePicker: UIDatePicker!
    
    public weak var delegate: MRDateTableCellDelegate?
    private var dateFormatter = DateFormatter()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        clipsToBounds = true
        setupInterface()
    }
    
    private func setupInterface() {
        
        datePicker = UIDatePicker()
        datePicker.minimumDate = Date.distantPast
        datePicker.addTarget(self, action: #selector(datePickerDidChangeValue(picker:)), for: .valueChanged)
        
        lblTitle = UILabel()
        lblTitle.numberOfLines = 0
        contentView.addSubview(lblTitle)
        
        let margin = MRFormViewController.cellsMargin
        
        //lblTitle.autoSetDimension(.height, toSize: 28, relation: .greaterThanOrEqual)
        lblTitle.autoPinEdge(toSuperviewEdge: .top, withInset: margin)
        lblTitle.autoPinEdge(toSuperviewEdge: .leading, withInset: 20)
        lblTitle.autoPinEdge(toSuperviewEdge: .bottom, withInset: margin)
        lblTitle.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        if #available(iOS 14, *) {
            
            contentView.addSubview(datePicker)
            
            lblTitle.autoPinEdge(.trailing, to: .leading, of: datePicker, withOffset: -20)
            
            datePicker.autoPinEdge(toSuperviewEdge: .top, withInset: 8, relation: .greaterThanOrEqual)
            datePicker.autoPinEdge(toSuperviewEdge: .trailing, withInset: 20)
            datePicker.autoPinEdge(toSuperviewEdge: .bottom, withInset: 8, relation: .greaterThanOrEqual)
            datePicker.autoAlignAxis(toSuperviewAxis: .horizontal)
            datePicker.setContentHuggingPriority(.defaultHigh, for: .horizontal)
            
        } else {
            
            txfValue = UITextField()
            txfValue.delegate = self
            txfValue.textAlignment = .right
            contentView.addSubview(txfValue)
            lblTitle.autoPinEdge(.trailing, to: .leading, of: txfValue, withOffset: -20)
            
            txfValue.inputView = datePicker
            txfValue.autoPinEdge(toSuperviewEdge: .top, withInset: 8, relation: .greaterThanOrEqual)
            txfValue.autoPinEdge(toSuperviewEdge: .trailing, withInset: 20)
            txfValue.autoPinEdge(toSuperviewEdge: .bottom, withInset: 8, relation: .greaterThanOrEqual)
            txfValue.autoAlignAxis(toSuperviewAxis: .horizontal)
            txfValue.setContentHuggingPriority(.defaultLow, for: .horizontal)
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    @objc func datePickerDidChangeValue(picker: UIDatePicker) {
        setDate(date: picker.date)
        delegate?.mrDateTableCellDidChangeDate(cell: self)
    }
    
    public override func configure(with row: MRFormRow) {
        
        dateFormatter = DateFormatter()
        if !row.dateFormat.isEmpty {
            dateFormatter.dateFormat = row.dateFormat
            let format = row.dateFormat.lowercased()
            datePicker.datePickerMode = format.contains("hh") && row.dateFormat.contains("y") ? .dateAndTime : format.contains("hh") && !row.dateFormat.contains("y") ? .time : .date
        } else {
            dateFormatter.dateStyle = .medium
            datePicker.datePickerMode = .date
        }
        
        lblTitle.text = row.mandatory ? "\(row.title ?? "")*" : row.title
        if #available(iOS 14, *) {
            
        } else {
            txfValue.placeholder = row.placeholder
        }
        setDate(date: row.value as? Date)
    }
    
    private func setDate(date: Date?) {
        
        if #available(iOS 14, *) {
            
        } else {
            if let date = date {
                txfValue.text = dateFormatter.string(from: date)
            } else {
                txfValue.text = ""
            }
        }
    }
    
    override public func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    // MARK: - UITextField Delegate
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        setDate(date: datePicker.date)
        delegate?.mrDateTableCellDidChangeDate(cell: self)
    }
}
