//
//  MRTextViewTableCell.swift
//  MRSwiftExample
//
//  Created by Nicola Innocenti on 04/10/2019.
//  Copyright © 2019 Nicola Innocenti. All rights reserved.
//

import UIKit
import PureLayout

public protocol MRTextViewTableCellDelegate : AnyObject {
    func mrTextViewTableCellDidChangeText(cell: MRTextViewTableCell)
}

public class MRTextViewTableCell: UITableViewCell, UITextViewDelegate {
    
    public var lblTitle: UILabel!
    public var txwValue: UITextView!
    
    public weak var delegate: MRTextViewTableCellDelegate?
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        clipsToBounds = true
        setupInterface()
    }
    
    private func setupInterface() {
        
        lblTitle = UILabel()
        lblTitle.numberOfLines = 0
        contentView.addSubview(lblTitle)
        
        txwValue = UITextView()
        txwValue.delegate = self
        txwValue.textContainerInset.left = -6
        contentView.addSubview(txwValue)
        
        lblTitle.autoSetDimension(.height, toSize: 20, relation: .greaterThanOrEqual)
        lblTitle.autoPinEdge(toSuperviewEdge: .top, withInset: 12)
        lblTitle.autoPinEdge(toSuperviewEdge: .leading, withInset: 20)
        lblTitle.autoPinEdge(toSuperviewEdge: .trailing, withInset: 20)
        
        txwValue.autoSetDimension(.height, toSize: 120, relation: .equal)
        txwValue.autoPinEdge(.top, to: .bottom, of: lblTitle, withOffset: 8)
        txwValue.autoPinEdge(.leading, to: .leading, of: lblTitle)
        txwValue.autoPinEdge(.trailing, to: .trailing, of: lblTitle)
        txwValue.autoPinEdge(toSuperviewEdge: .bottom, withInset: 12)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override public func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    public override func configure(with row: MRFormRow) {
        
        lblTitle.text = row.mandatory ? "\(row.title ?? "")*" : row.title
        txwValue.text = row.value as? String
    }
    
    // MARK: - UITextView Delegate
    
    public func textViewDidChange(_ textView: UITextView) {
        delegate?.mrTextViewTableCellDidChangeText(cell: self)
    }
}
