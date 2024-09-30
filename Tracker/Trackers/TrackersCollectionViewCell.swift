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
    weak var presentDelegate: TrackersCollectionViewCellDelegate?
    private var checkButtonTap = false
    var id: UUID?
    var dataProvider: TrackerStore?
    var trackerCategoryCD: TrackerCategoryCoreData?
    var indexOfSection: IndexPath?
    
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
        label.textColor = UIColor.label
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        return label
    }()
    
    private var pinnedImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Pinned")
        return imageView
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
    
    func changeCell(color: UIColor, emoji: String, title: String, daysCount: Int, checkThisDayRecord: Bool, uuid: UUID, category: TrackerCategoryCoreData, isPinned: Bool){
        id = uuid
        mainView.backgroundColor = color
        emojiLabel.text = emoji
        titleLabel.text = title
        countTappedDay = daysCount
        trackerCategoryCD = category
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
        if isPinned {
            addPin()
        } else {
            deletePin()
        }
    }
    
    private func addPin() {
        mainView.addSubview(pinnedImageView)
        pinnedImageView.translatesAutoresizingMaskIntoConstraints = false
        pinnedImageView.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -4).isActive = true
        pinnedImageView.topAnchor.constraint(equalTo: mainView.topAnchor, constant: 12).isActive = true
        pinnedImageView.widthAnchor.constraint(equalToConstant: 24).isActive = true
        pinnedImageView.heightAnchor.constraint(equalToConstant: 24).isActive = true
    }
    
    private func deletePin() {
        pinnedImageView.removeFromSuperview()
    }
    
    private func updateDaysLabel() {
        let formatString = String.localizedStringWithFormat(NSLocalizedString("numberOfDays", comment: "Days count"), countTappedDay)
        daysLabel.text = formatString
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
        contentView.backgroundColor = .ypBackground
        
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
        let interaction = UIContextMenuInteraction(delegate: self)
        mainView.addInteraction(interaction)
    }
    
    private func makeContextMenu() -> UIMenu {
        guard let tracker = self.dataProvider?.fetchTrackerEntity(id: self.id ?? UUID()) else { return UIMenu()}
        var pinAction = UIAction(title: "") { action in
            
        }
        if tracker.pin {
            pinAction = UIAction(title: NSLocalizedString("trackersCollectionMenuPinOffTitle", comment: "Открепить")) { action in
                self.dataProvider?.deletePin(tracker: tracker)
            }
        } else {
            pinAction = UIAction(title: NSLocalizedString("trackersCollectionMenuPinOnTitle", comment: "Закрепить")) { action in
                self.dataProvider?.addPin(tracker: tracker)
            }
        }
        
        let editAction = UIAction(title: NSLocalizedString("editActionText", comment: "Редактировать")) { action in
            if (self.dataProvider?.tempEventOrHabit(date: tracker.schedule ?? "") == true) {
                let editTempEventController = EditTemporaryEventViewController()
                editTempEventController.currentDays = self.daysLabel.text ?? ""
                editTempEventController.dataProvider = self.dataProvider
                editTempEventController.selectedTracker = tracker
                editTempEventController.currentDate = tracker.schedule ?? ""
                editTempEventController.nameOfTracker = tracker.name ?? ""
                editTempEventController.selectedCategory = self.trackerCategoryCD
                editTempEventController.selectedColor = UIColorMarshalling().color(from: tracker.color ?? "")
                editTempEventController.selectedEmoji = tracker.emoji ?? ""
                
                let navigationController = UINavigationController(rootViewController: editTempEventController)
                self.presentDelegate?.presentViewController(navController: navigationController)
            } else {
                let editHabitController = EditHabitViewController()
                editHabitController.currentDays = self.daysLabel.text ?? ""
                editHabitController.dataProvider = self.dataProvider
                editHabitController.selectedTracker = tracker
                editHabitController.selectedDays = tracker.schedule ?? ""
                editHabitController.nameOfTracker = tracker.name ?? ""
                editHabitController.selectedCategory = self.trackerCategoryCD
                editHabitController.selectedColor = UIColorMarshalling().color(from: tracker.color ?? "")
                editHabitController.selectedEmoji = tracker.emoji ?? ""
                
                let navigationController = UINavigationController(rootViewController: editHabitController)
                self.presentDelegate?.presentViewController(navController: navigationController)
            }
            let params: AnalyticsEventParam = ["screen": "Main", "item": "edit"]
            AnalyticsService.report(event: "click", params: params)
            print("Зарегистрировано событие аналитики 'click' с параметрами \(params)")
        }
        
        let deleteAction = UIAction(title: NSLocalizedString("deleteButtonTitle", comment: "Удалить"), attributes: .destructive) { action in
            let actionSheet = UIAlertController(title: NSLocalizedString("confirmCategoryDeleteAlertMessage", comment: "Эта категория точно не нужна?"), message: nil, preferredStyle: .actionSheet)
            
            let deleteAction = UIAlertAction(title: NSLocalizedString("deleteButtonTitle", comment: "Удалить"), style: .destructive) { _ in
                self.dataProvider?.delete(record: tracker)
                let params: AnalyticsEventParam = ["screen": "Main", "item": "delete"]
                AnalyticsService.report(event: "click", params: params)
                print("Зарегистрировано событие аналитики 'click' с параметрами \(params)")
            }
            let cancelAction = UIAlertAction(title: NSLocalizedString("cancelButtonTitle", comment: "Отменить"), style: .cancel, handler: nil)
            
            actionSheet.addAction(deleteAction)
            actionSheet.addAction(cancelAction)
            
            self.presentDelegate?.presentAlertController(alerController: actionSheet)
        }
        
        return UIMenu(title: "", children: [pinAction, editAction, deleteAction])
    }
    
    required init?(coder: NSCoder) {
        self.init()
        assertionFailure("init(coder:) has not been implemented")
    }
}

extension TrackersCollectionViewCell: UIContextMenuInteractionDelegate {
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] suggestedActions in
            return self?.makeContextMenu()
        }
    }
}
