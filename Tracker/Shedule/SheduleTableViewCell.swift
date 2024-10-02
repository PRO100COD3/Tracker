//
//  SheduleCell.swift
//  Tracker
//
//  Created by Вадим Дзюба on 12.07.2024.
//
import UIKit

final class SheduleTableViewCell: UITableViewCell {
    
    let switchControl = UISwitch()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.textLabel?.font = UIFont(name: "SFPro-Regular", size: 17)
        self.textLabel?.textColor = UIColor.label
        self.backgroundColor = .ypTableViewCell
        self.separatorInset = .init(top: 0, left: 20, bottom: 0, right: 20)
        self.selectionStyle = .none
        
        switchControl.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(switchControl)
        
        switchControl.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 22).isActive = true
        switchControl.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 22).isActive = true
        switchControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16).isActive = true
        switchControl.isEnabled = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
