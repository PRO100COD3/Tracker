//
//  CustomTableViewCell.swift
//  Tracker
//
//  Created by Вадим Дзюба on 10.07.2024.
//

import UIKit


final class CustomTableViewCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.textLabel?.font = UIFont(name: "SFPro-Regular", size: 17)
        self.textLabel?.textColor = .yPblack
        self.backgroundColor = .ypGrey
        self.separatorInset = .init(top: 0, left: 20, bottom: 0, right: 20)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
