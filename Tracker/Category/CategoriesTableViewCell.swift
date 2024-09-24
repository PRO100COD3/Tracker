//
//  CategoriesTableViewCell.swift
//  Tracker
//
//  Created by Вадим Дзюба on 14.07.2024.
//

import UIKit

final class CategoriesTableViewCell: UITableViewCell {
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.textLabel?.font = UIFont(name: "SFPro-Regular", size: 17)
        self.textLabel?.textColor = .yPblack
        self.backgroundColor = .ypGrey
        self.separatorInset = .init(top: 0, left: 20, bottom: 0, right: 20)
        self.selectionStyle = .none
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configurate(name: String, isSelected: Bool) {
        textLabel?.text = name
        accessoryType = isSelected ? .checkmark : .none
    }
}
