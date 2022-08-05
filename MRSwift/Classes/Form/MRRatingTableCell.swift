//
//  MRRatingTableCell.swift
//  MRSwiftExample
//
//  Created by Nicola Innocenti on 03/08/22.
//  Copyright © 2022 Nicola Innocenti. All rights reserved.
//

import UIKit

public protocol MRRatingTableCellDelegate {
    func mrRatingTableCellDidRate(cell: MRRatingTableCell, value: Double)
}

public class MRRatingTableCell: UITableViewCell {
    // MARK: - Layout
    public let lblTitle: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let ratingContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private let btnStar1: UIButton = {
        let button = UIButton()
        button.tag = 1
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    private let btnStar2: UIButton = {
        let button = UIButton()
        button.tag = 2
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    private let btnStar3: UIButton = {
        let button = UIButton()
        button.tag = 3
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    private let btnStar4: UIButton = {
        let button = UIButton()
        button.tag = 4
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    private let btnStar5: UIButton = {
        let button = UIButton()
        button.tag = 5
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Variables
    private var activeStarColor = UIColor(netHex: 0xfcba03)
    private var inactiveStarColor = UIColor(netHex: 0xbbbbbb)
    private var imageConfig: UIImage.SymbolConfiguration!
    private let ratingSpacing: CGFloat = 2
    public var delegate: MRRatingTableCellDelegate?
    
    // MARK: - Configuration
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
        setupBindings()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        selectionStyle = .none
        imageConfig = UIImage.SymbolConfiguration(pointSize: 24, weight: .regular)
        contentView.addSubview(lblTitle)
        contentView.addSubview(ratingContainer)
        ratingContainer.addSubview(btnStar1)
        ratingContainer.addSubview(btnStar2)
        ratingContainer.addSubview(btnStar3)
        ratingContainer.addSubview(btnStar4)
        ratingContainer.addSubview(btnStar5)
        NSLayoutConstraint.activate([
            lblTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            lblTitle.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            ratingContainer.leadingAnchor.constraint(greaterThanOrEqualTo: lblTitle.trailingAnchor, constant: 16),
            ratingContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            ratingContainer.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: 15),
            ratingContainer.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -16),
            btnStar1.leadingAnchor.constraint(equalTo: ratingContainer.leadingAnchor),
            btnStar1.topAnchor.constraint(equalTo: ratingContainer.topAnchor),
            btnStar1.bottomAnchor.constraint(equalTo: ratingContainer.bottomAnchor),
            btnStar2.leadingAnchor.constraint(equalTo: btnStar1.trailingAnchor, constant: ratingSpacing),
            btnStar2.topAnchor.constraint(equalTo: btnStar1.topAnchor),
            btnStar2.bottomAnchor.constraint(equalTo: btnStar1.bottomAnchor),
            btnStar3.leadingAnchor.constraint(equalTo: btnStar2.trailingAnchor, constant: ratingSpacing),
            btnStar3.topAnchor.constraint(equalTo: btnStar1.topAnchor),
            btnStar3.bottomAnchor.constraint(equalTo: btnStar1.bottomAnchor),
            btnStar4.leadingAnchor.constraint(equalTo: btnStar3.trailingAnchor, constant: ratingSpacing),
            btnStar4.topAnchor.constraint(equalTo: btnStar1.topAnchor),
            btnStar4.bottomAnchor.constraint(equalTo: btnStar1.bottomAnchor),
            btnStar5.leadingAnchor.constraint(equalTo: btnStar4.trailingAnchor, constant: ratingSpacing),
            btnStar5.topAnchor.constraint(equalTo: btnStar1.topAnchor),
            btnStar5.bottomAnchor.constraint(equalTo: btnStar1.bottomAnchor),
            btnStar5.trailingAnchor.constraint(equalTo: ratingContainer.trailingAnchor)
        ])
        
    }
    
    private func setupBindings() {
        btnStar1.addTarget(self, action: #selector(onStarPress(sender:)), for: .touchUpInside)
        btnStar2.addTarget(self, action: #selector(onStarPress(sender:)), for: .touchUpInside)
        btnStar3.addTarget(self, action: #selector(onStarPress(sender:)), for: .touchUpInside)
        btnStar4.addTarget(self, action: #selector(onStarPress(sender:)), for: .touchUpInside)
        btnStar5.addTarget(self, action: #selector(onStarPress(sender:)), for: .touchUpInside)
    }
    
    public func configureColors(activeStar: UIColor?, inactiveStar: UIColor?) {
        if let color = activeStar {
            activeStarColor = color
        }
        if let color = inactiveStar {
            inactiveStarColor = color
        }
    }
    
    public override func configure(with row: MRFormRow) {
        lblTitle.text = row.mandatory ? "\(row.title ?? "")*" : row.title
        setRating(value: row.value as? Double ?? 0)
    }
    
    private func setRating(value: Double) {
        setButtonStar(button: btnStar1, starSystemName: value < 0.25 ? "star" : value < 0.75 ? "star.leadinghalf.filled" : "star.fill")
        setButtonStar(button: btnStar2, starSystemName: value < 1.25 ? "star" : value < 1.75 ? "star.leadinghalf.filled" : "star.fill")
        setButtonStar(button: btnStar3, starSystemName: value < 2.25 ? "star" : value < 2.75 ? "star.leadinghalf.filled" : "star.fill")
        setButtonStar(button: btnStar4, starSystemName: value < 3.25 ? "star" : value < 3.75 ? "star.leadinghalf.filled" : "star.fill")
        setButtonStar(button: btnStar5, starSystemName: value < 4.25 ? "star" : value < 4.75 ? "star.leadinghalf.filled" : "star.fill")
    }
    
    private func setButtonStar(button: UIButton, starSystemName: String) {
        button.tintColor = starSystemName == "star" ? inactiveStarColor : activeStarColor
        button.setImage(
            UIImage(
                systemName: starSystemName,
                withConfiguration: imageConfig),
            for: .normal
        )
    }
    
    @objc private func onStarPress(sender: UIButton) {
        let value = Double(sender.tag)
        delegate?.mrRatingTableCellDidRate(cell: self, value: value)
        setRating(value: value)
    }
}
