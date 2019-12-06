//
//  MRSwitchTableCell.swift
//  MRSwiftExample
//
//  Created by Nicola Innocenti on 23/05/18.
//  Copyright © 2018 Nicola Innocenti. All rights reserved.
//

import UIKit

public protocol MRSwitchTableCellDelegate : class {
    func mrSwitchTableCellDidChangeSelection(cell: MRSwitchTableCell)
}

public class MRSwitchTableCell: UITableViewCell {
    
    public var lblTitle: UILabel!
    public var swSwitch: UISwitch!
    
    public weak var delegate: MRSwitchTableCellDelegate?
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        clipsToBounds = true
        setupInterface()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupInterface() {
        
        lblTitle = UILabel()
        lblTitle.numberOfLines = 0
        addSubview(lblTitle)
        
        swSwitch = UISwitch()
        swSwitch.setOn(false, animated: false)
        swSwitch.addTarget(self, action: #selector(switchDidChangeValue(sender:)), for: .valueChanged)
        addSubview(swSwitch)
        
        let margin = MRFormViewController.cellsMargin
        
        lblTitle.autoSetDimension(.height, toSize: 20, relation: .greaterThanOrEqual)
        lblTitle.autoPinEdge(toSuperviewEdge: .top, withInset: margin)
        lblTitle.autoPinEdge(toSuperviewEdge: .leading, withInset: 20)
        lblTitle.autoPinEdge(toSuperviewEdge: .bottom, withInset: margin)
        lblTitle.autoPinEdge(.trailing, to: .leading, of: swSwitch, withOffset: -20)
        
        swSwitch.autoSetDimension(.width, toSize: 49, relation: .equal)
        swSwitch.autoSetDimension(.height, toSize: 31, relation: .equal)
        swSwitch.autoPinEdge(toSuperviewEdge: .trailing, withInset: 20)
        swSwitch.autoAlignAxis(toSuperviewAxis: .horizontal)
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
        swSwitch.isOn = (row.value as? Bool) ?? false
    }
    
    @objc func switchDidChangeValue(sender: UISwitch) {
        delegate?.mrSwitchTableCellDidChangeSelection(cell: self)
    }
}
