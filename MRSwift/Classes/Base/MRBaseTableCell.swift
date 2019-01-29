//
//  MRBaseTableCell.swift
//  Pods
//
//  Created by Nicola Innocenti on 29/01/2019.
//

import UIKit

@objc public class MRBaseTableCell : UITableViewCell {
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        
        let view = UIView()
        view.backgroundColor = UIColor(netHex: 0xeeeeee)
        selectedBackgroundView = view
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let view = UIView()
        view.backgroundColor = UIColor(netHex: 0xeeeeee)
        selectedBackgroundView = view
    }
    
    init() {
        super.init(style: .default, reuseIdentifier: MRBaseTableCell.identifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
