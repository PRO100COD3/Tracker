//
//  StatisticViewCell.swift
//  Tracker
//
//  Created by Вадим Дзюба on 29.09.2024.
//

import UIKit


final class StatisticsCollectionViewCell: UICollectionViewCell {
    
    private let gradientLayer = CAGradientLayer()
    private let borderLayer = CAShapeLayer()
    private lazy var labelsContainer: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.distribution = .equalSpacing
        view.alignment = .leading
        view.spacing = Constants.labelsContainerSpacing
        return view
    }()
    private lazy var valueLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = UIFont(name: "SFPro-Bold", size: 34)
        view.textColor = .ypReBackground
        view.textAlignment = .natural
        return view
    }()
    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = UIFont(name: "SFPro-Medium", size: 12)
        view.textColor = .ypReBackground
        view.textAlignment = .natural
        return view
    }()
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        createAndLayoutViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = self.bounds
        borderLayer.path = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.layer.cornerRadius).cgPath
    }
        
    public func showCellViewModel(_ model: StatisticsCellViewModel) {
        valueLabel.text = ("\(model.value)")
        titleLabel.text = model.title
    }
        
    private func createAndLayoutViews() {
        backgroundColor = .clear
        labelsContainer.addArrangedSubview(valueLabel)
        labelsContainer.addArrangedSubview(titleLabel)
        contentView.addSubview(labelsContainer)
        setupGradientBorder()
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate(
            [
                labelsContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
                labelsContainer.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
            ]
        )
    }
    
    private func setupGradientBorder() {
        self.layer.cornerRadius = Constants.cornerRadius
        self.layer.masksToBounds = true
        
        gradientLayer.colors = [UIColor.red.cgColor, UIColor.green.cgColor, UIColor.blue.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.frame = self.bounds
        gradientLayer.cornerRadius = self.layer.cornerRadius
        self.layer.insertSublayer(gradientLayer, at: 0)
        
        let borderPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.layer.cornerRadius).cgPath
        borderLayer.path = borderPath
        borderLayer.lineWidth = Constants.marginWidth
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.strokeColor = UIColor.black.cgColor
        gradientLayer.mask = borderLayer
    }
}

extension StatisticsCollectionViewCell {
    enum Constants {
        static let identifier = "StatisticsCollectionViewCell"
        static let cornerRadius: CGFloat = 16
        static let marginWidth: CGFloat = 2
        static let labelsContainerSpacing: CGFloat = 7
        static let labelInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
    }
}
