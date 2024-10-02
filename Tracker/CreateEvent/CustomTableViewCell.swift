//
//  CustomTableViewCell.swift
//  Tracker
//
//  Created by Вадим Дзюба on 10.07.2024.
//

import UIKit

class CustomTableViewCell: UITableViewCell {
    
    let leftLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "SFPro-Regular", size: 17)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let optionalLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "SFPro-Regular", size: 17)
        label.textColor = .ypLightGrey
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.textLabel?.font = UIFont(name: "SFPro-Regular", size: 17)
        self.textLabel?.textColor = .ypReBackground
        self.backgroundColor = .ypTableViewCell
        self.separatorInset = .init(top: 0, left: 20, bottom: 0, right: 20)
        self.selectionStyle = .none
        
        
        contentView.addSubview(leftLabel)
        contentView.addSubview(optionalLabel)
        
        
        NSLayoutConstraint.activate([
            leftLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            leftLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
            
            optionalLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            optionalLabel.topAnchor.constraint(equalTo: leftLabel.bottomAnchor, constant: 2),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureTemporaryEvent(with category: String, optionalText: String?) {
        if optionalText == nil {
            textLabel?.text = category
        } else {
            textLabel?.text = ""
            leftLabel.text = category
            optionalLabel.text = optionalText
        }
    }
    func configureHabit(with mainText: String, optionalCategoryText: String?, optionalDaysText: String) {
        if mainText == NSLocalizedString("categoryViewTitleText", comment: "Категория") {
            if optionalCategoryText == nil {
                textLabel?.text = mainText
            } else {
                textLabel?.text = ""
                leftLabel.text = mainText
                optionalLabel.text = optionalCategoryText
            }
        } else {
            if optionalDaysText == "" {
                textLabel?.text = mainText
            } else {
                textLabel?.text = ""
                leftLabel.text = mainText
                optionalLabel.text = optionalDaysText
            }
        }
    }
    
    func configureFilter(with mainText: String, isSelected: Bool) {
        textLabel?.text = mainText
        selectionStyle = .none
        accessoryType = isSelected ? .checkmark : .none
    }
}
