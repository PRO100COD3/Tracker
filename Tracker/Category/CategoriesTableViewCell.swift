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
        view.backgroundColor = .ypGrey
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 16
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return view
    }()
    
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .yPblack
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
        
//        let interaction = UIContextMenuInteraction(delegate: self)
//        mainView.addInteraction(interaction)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configurate(name: String, isSelected: Bool, isLastCategory: Bool) {
        titleLabel.text = name
        accessoryImageView.image = isSelected ? UIImage(systemName: "checkmark") : nil
        if isLastCategory {
            mainView.layer.cornerRadius = 16
            mainView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }
    }
}

extension CategoriesTableViewCell: UIContextMenuInteractionDelegate {
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        
        let configuration = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ -> UIMenu? in
            
            // Создание действий для контекстного меню
            let editAction = UIAction(title: "Редактировать", image: UIImage(systemName: "")) { action in
                // Логика для редактирования
                print("Редактировать нажато")
            }
            
            let deleteAction = UIAction(title: "Удалить", image: UIImage(systemName: ""), attributes: .destructive) { action in
                // Логика для удаления
                print("Удалить нажато")
            }
            
            return UIMenu(title: "", children: [editAction, deleteAction])
        }
                    
        return configuration
    }
    

}
