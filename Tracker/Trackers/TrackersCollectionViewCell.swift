//
//  TrackersCollectionViewCell.swift
//  Tracker
//
//  Created by Вадим Дзюба on 15.07.2024.
//

import UIKit

final class TrackersCollectionViewCell: UICollectionViewCell {
    
    private var countTappedDay = 0
    static let identifier = "CustomCell"
    weak var delegate: TrackerRecordProtocol?
    private var checkButtonTap = false
    
    private var mainView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemGreen
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 16
        return view
    }()
    
    private var emojiLabel: UILabel = {
        let emojiLabel = UILabel()
        emojiLabel.textAlignment = .center
        emojiLabel.backgroundColor = .ypTransparentWhite
        emojiLabel.textColor = .white
        emojiLabel.font = UIFont(name: "SFPro-Medium", size: 12)
        emojiLabel.layer.masksToBounds = true
        emojiLabel.layer.cornerRadius = 12
        return emojiLabel
    }()
    
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.textColor = .white
        label.font = UIFont(name: "SFPro-Medium", size: 12)
        return label
    }()
    
    private var daysLabel: UILabel = {
        let label = UILabel()
        label.text = "0 дней"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        return label
    }()
    
    private var addButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.orange
        button.setTitle("+", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont(name: "SFPro-Regular", size: 17)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 17
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        return button
    }()
    
    func changeCell(color: UIColor, emoji: String, title: String, daysCount: Int, checkThisDayRecord: Bool){
        mainView.backgroundColor = color
        emojiLabel.text = emoji
        titleLabel.text = title
        countTappedDay = daysCount
        updateDaysLabel()
        
        if (daysCount > 0 && checkThisDayRecord) {
            checkButtonTap = true
            if let color = mainView.backgroundColor {
                var red: CGFloat = 0
                var green: CGFloat = 0
                var blue: CGFloat = 0
                var alpha: CGFloat = 0
                color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
                let newColor = UIColor(red: red, green: green, blue: blue, alpha: 0.3)
                addButton.backgroundColor = newColor
            }
            addButton.setTitle("", for: .normal)
            addButton.setImage(UIImage(named: "Done"), for: .normal)
        } else {
            checkButtonTap = false
            if let color = mainView.backgroundColor {
                var red: CGFloat = 0
                var green: CGFloat = 0
                var blue: CGFloat = 0
                var alpha: CGFloat = 0
                color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
                let newColor = UIColor(red: red, green: green, blue: blue, alpha: alpha)
                addButton.backgroundColor = newColor
            }
            addButton.setTitle("+", for: .normal)
            addButton.setImage(nil, for: .normal)
        }
    }
    
    private func updateDaysLabel() {
        if countTappedDay % 10 == 1 && countTappedDay % 100 != 11 {
            daysLabel.text = "\(countTappedDay) день"
        } else if ((countTappedDay % 10 == 2 && countTappedDay % 100 != 12) || (countTappedDay % 10 == 3 && countTappedDay % 100 != 13) || (countTappedDay % 10 == 4 && countTappedDay % 100 != 14)) {
            daysLabel.text = "\(countTappedDay) дня"
        } else {
            daysLabel.text = "\(countTappedDay) дней"
        }
    }
    
    @objc private func buttonTapped(){
        if checkButtonTap == false {
            countTappedDay += 1
            delegate?.didTapAddButton(on: self)
        } else {
            countTappedDay -= 1
            delegate?.didRetapAddButton(on: self)
        }
        updateDaysLabel()
        updateButtonAppearance()
    }
    
    private func updateButtonAppearance() {
        if checkButtonTap {
            if let color = mainView.backgroundColor {
                var red: CGFloat = 0
                var green: CGFloat = 0
                var blue: CGFloat = 0
                var alpha: CGFloat = 0
                color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
                let newColor = UIColor(red: red, green: green, blue: blue, alpha: 0.3)
                addButton.backgroundColor = newColor
            }
            addButton.setTitle("", for: .normal)
            addButton.setImage(UIImage(named: "Done"), for: .normal)
            checkButtonTap = true
        } else {
            if let color = mainView.backgroundColor {
                var red: CGFloat = 0
                var green: CGFloat = 0
                var blue: CGFloat = 0
                var alpha: CGFloat = 0
                color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
                let newColor = UIColor(red: red, green: green, blue: blue, alpha: alpha)
                addButton.backgroundColor = newColor
            }
            addButton.setTitle("+", for: .normal)
            addButton.setImage(nil, for: .normal)
            checkButtonTap = false
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(mainView)
        mainView.addSubview(emojiLabel)
        mainView.addSubview(titleLabel)
        contentView.addSubview(daysLabel)
        contentView.addSubview(addButton)
        
        mainView.translatesAutoresizingMaskIntoConstraints = false
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        daysLabel.translatesAutoresizingMaskIntoConstraints = false
        addButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            mainView.topAnchor.constraint(equalTo: contentView.topAnchor),
            mainView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            mainView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            mainView.heightAnchor.constraint(equalToConstant: 90),
            
            emojiLabel.topAnchor.constraint(equalTo: mainView.topAnchor, constant: 12),
            emojiLabel.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: 12),
            emojiLabel.widthAnchor.constraint(equalToConstant: 24),
            emojiLabel.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.topAnchor.constraint(equalTo: mainView.topAnchor, constant: 44),
            titleLabel.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -12),
            titleLabel.bottomAnchor.constraint(equalTo: mainView.bottomAnchor, constant: -12),
            
            
            daysLabel.topAnchor.constraint(equalTo: mainView.bottomAnchor, constant: 16),
            daysLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            
            addButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            addButton.topAnchor.constraint(equalTo: mainView.bottomAnchor, constant: 8),
            addButton.widthAnchor.constraint(equalToConstant: 34),
            addButton.heightAnchor.constraint(equalToConstant: 34)
        ])
    }
    
    required init?(coder: NSCoder) {
        self.init()
        assertionFailure("init(coder:) has not been implemented")
    }
}
