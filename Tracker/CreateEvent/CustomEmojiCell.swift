//
//  CustomEmojiCell.swift
//  Tracker
//
//  Created by Вадим Дзюба on 18.08.2024.
//

import UIKit


final class CustomEmojiCell: UICollectionViewCell {
    static let identifier = "CustomCell"
    private var emojiLabel: UILabel = {
        let emojiLabel = UILabel()
        emojiLabel.textAlignment = .center
        emojiLabel.textColor = .white
        emojiLabel.font = UIFont(name: "SFPro-Bold", size: 32)
        return emojiLabel
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .ypBackground
        contentView.addSubview(emojiLabel)
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            emojiLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            emojiLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            emojiLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            emojiLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func changeCell(emoji: String) {
        emojiLabel.text = emoji
    }
    
    func setSelectedBackground(_ isSelected: Bool) {
        contentView.backgroundColor = isSelected ? .ypGreyNOTransparent : .ypBackground
    }
}
