//
//  CategoriesTableViewCell.swift
//  Tracker
//
//  Created by Вадим Дзюба on 14.07.2024.
//

import UIKit

final class CategoriesTableViewCell: UITableViewCell {
    
    private var mainView: UIView = {
        let view = UIView()
        view.backgroundColor = .ypTableViewCell
        view.layer.masksToBounds = true
        return view
    }()
    
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypReBackground
        label.font = UIFont(name: "SFPro-Regular", size: 17)
        return label
    }()
    
    let accessoryImageView = UIImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(mainView)
        mainView.addSubview(titleLabel)
        mainView.addSubview(accessoryImageView)
        
        mainView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        accessoryImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            mainView.topAnchor.constraint(equalTo: contentView.topAnchor),
            mainView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            mainView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            mainView.heightAnchor.constraint(equalToConstant: 75),
            
            titleLabel.topAnchor.constraint(equalTo: mainView.topAnchor, constant: 26),
            titleLabel.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: 16),
            
            accessoryImageView.topAnchor.constraint(equalTo: mainView.topAnchor, constant: 26),
            accessoryImageView.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -16)
        ])
        
        self.separatorInset = .init(top: 0, left: 32, bottom: 0, right: 32)
        self.selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configurate(name: String, isSelected: Bool, isLastCategory: Bool, isFirstCategory: Bool) {
        titleLabel.text = name
        accessoryImageView.image = isSelected ? UIImage(systemName: "checkmark") : nil
        if isLastCategory && isFirstCategory {
            mainView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner, .layerMinXMinYCorner, .layerMaxXMinYCorner]
            mainView.layer.cornerRadius = 16
        } else if isFirstCategory{
            mainView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            mainView.layer.cornerRadius = 16
        } else if isLastCategory {
            mainView.layer.cornerRadius = 16
            mainView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        } else {
            mainView.layer.cornerRadius = 0
        }
    }
}

