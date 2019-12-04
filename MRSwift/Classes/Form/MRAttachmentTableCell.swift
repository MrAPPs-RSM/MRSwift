//
//  MRAttachmentTableCell.swift
//  MRSwiftExample
//
//  Created by Nicola Innocenti on 14/10/2019.
//  Copyright © 2019 Nicola Innocenti. All rights reserved.
//

import UIKit

class MRAttachmentTableCell: UITableViewCell {
    
    public var lblTitle: UILabel!
    public var imgAttachment: UIImageView!
    public var lblFileName: UILabel!
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        clipsToBounds = true
        accessoryType = .disclosureIndicator
        setupInterface()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func setupInterface() {
        
        lblTitle = UILabel()
        lblTitle.numberOfLines = 0
        addSubview(lblTitle)
        
        imgAttachment = UIImageView()
        addSubview(imgAttachment)
        
        lblFileName = UILabel()
        lblFileName.numberOfLines = 1
        addSubview(lblFileName)
        
        //lblTitle.autoSetDimension(.height, toSize: 20, relation: .greaterThanOrEqual)
        lblTitle.autoPinEdge(toSuperviewEdge: .top, withInset: 16)
        lblTitle.autoPinEdge(toSuperviewEdge: .leading, withInset: 20)
        lblTitle.autoPinEdge(toSuperviewEdge: .bottom, withInset: 16)
        lblTitle.autoPinEdge(.trailing, to: .leading, of: imgAttachment, withOffset: -20, relation: .greaterThanOrEqual)
        lblTitle.autoPinEdge(.trailing, to: .leading, of: lblFileName, withOffset: -20, relation: .greaterThanOrEqual)
        lblTitle.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        lblTitle.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        imgAttachment.layer.cornerRadius = 3
        imgAttachment.clipsToBounds = true
        imgAttachment.autoSetDimension(.width, toSize: 30, relation: .equal)
        imgAttachment.autoSetDimension(.height, toSize: 30, relation: .equal)
        imgAttachment.autoPinEdge(toSuperviewEdge: .trailing, withInset: 40)
        imgAttachment.autoAlignAxis(toSuperviewAxis: .horizontal)
        
        //lblFileName.autoSetDimension(.height, toSize: 20, relation: .greaterThanOrEqual)
        lblFileName.autoPinEdge(toSuperviewEdge: .top, withInset: 16)
        lblFileName.autoPinEdge(toSuperviewEdge: .trailing, withInset: 40)
        lblFileName.autoPinEdge(toSuperviewEdge: .bottom, withInset: 16)
        lblFileName.setContentHuggingPriority(.defaultLow, for: .horizontal)
        lblFileName.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
    }

    public override func configure(with row: MRFormRow) {
        
        lblTitle.text = row.mandatory ? "\(row.title ?? "")*" : row.title
        if let url = row.attachmentUrl {
            if let image = UIImage(contentsOfFile: url.absoluteString.replacingOccurrences(of: "file://", with: "")) {
                imgAttachment.image = image
                lblFileName.text = nil
            } else {
                imgAttachment.image = nil
                lblFileName.text = url.lastPathComponent
            }
        } else {
            imgAttachment.image = nil
            lblFileName.text = nil
        }
    }
}
