//
//  MRTextFieldTableCell.swift
//  MRSwiftExample
//
//  Created by Nicola Innocenti on 22/05/18.
//  Copyright © 2018 Nicola Innocenti. All rights reserved.
//

import UIKit
import PureLayout

public protocol MRTextFieldTableCellDelegate : class {
    func mrTextFieldTableCellDidChangeText(cell: MRTextFieldTableCell)
}

public class MRTextFieldTableCell: UITableViewCell {
    
    public var lblTitle: UILabel!
    public var txfValue: UITextField!
    
    public weak var delegate: MRTextFieldTableCellDelegate?
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        clipsToBounds = true
        setupInterface()
    }
    
    private func setupInterface() {
        
        lblTitle = UILabel()
        lblTitle.numberOfLines = 0
        addSubview(lblTitle)
        
        txfValue = UITextField()
        txfValue.textAlignment = .right
        txfValue.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        addSubview(txfValue)
        
        lblTitle.autoSetDimension(.height, toSize: 20, relation: .greaterThanOrEqual)
        lblTitle.autoPinEdge(toSuperviewEdge: .top, withInset: 12)
        lblTitle.autoPinEdge(toSuperviewEdge: .leading, withInset: 20)
        lblTitle.autoPinEdge(toSuperviewEdge: .bottom, withInset: 12)
        lblTitle.autoPinEdge(.trailing, to: .leading, of: txfValue, withOffset: -20)
        lblTitle.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        txfValue.autoPinEdge(toSuperviewEdge: .top, withInset: 12)
        txfValue.autoPinEdge(toSuperviewEdge: .trailing, withInset: 20)
        txfValue.autoPinEdge(toSuperviewEdge: .bottom, withInset: 12)
        txfValue.setContentHuggingPriority(.defaultLow, for: .horizontal)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    public override func configure(with row: MRFormRow) {
        
        lblTitle.text = row.mandatory ? "\(row.title ?? "")*" : row.title
        txfValue.text = row.value as? String
        txfValue.placeholder = row.placeholder
    }
    
    @objc func textFieldDidChange(textField: UITextField) {
        delegate?.mrTextFieldTableCellDidChangeText(cell: self)
    }
    
    override public func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
