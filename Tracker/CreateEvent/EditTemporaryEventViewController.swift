//
//  EditTemporaryEventViewController.swift
//  Tracker
//
//  Created by Вадим Дзюба on 29.09.2024.
//

import UIKit


final class EditTemporaryEventViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CategoryProtocol {
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    var currentDays: String = ""
    var selectedTracker: TrackerCoreData?
    var currentDate: String = ""
    var nameOfTracker: String = ""
    private let daysLabel = UILabel()
    private let label = UILabel()
    private let nameOfHabit = UITextField()
    private let buttonСancel = UIButton(type: .system)
    private let buttonAccept = UIButton(type: .system)
    private let tableView = UITableView()
    private let emojiCollectiomView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewFlowLayout()
        )
        collectionView.backgroundColor = .ypBackground
        collectionView.isScrollEnabled = false
        collectionView.register(CustomEmojiCell.self, forCellWithReuseIdentifier: CustomEmojiCell.identifier)
        return collectionView
    }()
    private let emojiLabel = UILabel()
    var selectedEmoji: String = ""
    private let errorLabel = UILabel()
    private var selectedEmojiIndexPath: IndexPath?
    private let colorLabel = UILabel()
    private var selectedColorIndexPath: IndexPath?
    var selectedColor: UIColor = UIColor.clear
    private let colorsCollectiomView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewFlowLayout()
        )
        collectionView.backgroundColor = .ypBackground
        collectionView.isScrollEnabled = false
        collectionView.register(CustomColorCell.self, forCellWithReuseIdentifier: CustomColorCell.identifier)
        return collectionView
    }()
    var dataProvider: TrackerStore?
    weak var closeDelegate: CloseControllerProtocol?
    var selectedCategory: TrackerCategoryCoreData?
    
    private let data = [NSLocalizedString("categoryViewTitleText", comment: "Категория")]
    private let emoji = ["🙂", "😻", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🥶", "🤔", "🙌", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝", "😪"]
    private let colors = [UIColor.ypRedPlate1, UIColor.ypOrangePlate2, UIColor.ypBluePlate3, UIColor.ypVioletPlate4, UIColor.ypGreenPlate5, UIColor.ypPinkPlate6, UIColor.ypPinkPlate7, UIColor.ypBluePlate8, UIColor.ypGreenPlate9, UIColor.ypVioletPlate10, UIColor.ypOrangePlate11, UIColor.ypPinkPlate12, UIColor.ypOrangePlate13, UIColor.ypBluePlate14, UIColor.ypVioletPlate15, UIColor.ypVioletPlate16, UIColor.ypVioletPlate17, UIColor.ypGreenPlate18]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        view.backgroundColor = .ypBackground
        nameOfHabit.delegate = self
        setupScrollView()
        addDaysLabel()
        addLabel()
        addTextField()
        addTableView()
        addEmojiLabel()
        addEmojiCollectionView()
        addColorLabel()
        addColorsCollectionView()
        addButtonCancel()
        addButtonAccept()
    }
    
    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
        ])
    }
    
    private func addErrorLabel() {
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(errorLabel)
        errorLabel.text = NSLocalizedString("trackerNameWarningLabelText", comment: "Ограничение 38 символов")
        errorLabel.textColor = .ypRed
        errorLabel.font = UIFont(name: "SFPro-Regular", size: 17)
        NSLayoutConstraint.activate([
            errorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorLabel.topAnchor.constraint(equalTo: nameOfHabit.bottomAnchor, constant: 8)
        ])
    }
    
    private func addEmojiLabel() {
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(emojiLabel)
        emojiLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28).isActive = true
        emojiLabel.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 32).isActive = true
        emojiLabel.text = NSLocalizedString("emojiLabelText", comment: "Emoji")
        emojiLabel.font = UIFont(name: "SFPro-Bold", size: 19)
    }
    
    private func addDaysLabel() {
        daysLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(daysLabel)
        daysLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        daysLabel.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 24).isActive = true
        daysLabel.text = currentDays
        daysLabel.font = UIFont(name: "SFPro-Bold", size: 32)
    }
    
    
    private func addColorLabel() {
        colorLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(colorLabel)
        colorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28).isActive = true
        colorLabel.topAnchor.constraint(equalTo: emojiCollectiomView.bottomAnchor, constant: 32).isActive = true
        colorLabel.text = NSLocalizedString("colorsLabelText", comment: "Цвет")
        colorLabel.font = UIFont(name: "SFPro-Bold", size: 19)
    }
    
    private func addColorsCollectionView() {
        colorsCollectiomView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(colorsCollectiomView)
        colorsCollectiomView.topAnchor.constraint(equalTo: colorLabel.bottomAnchor, constant: 19).isActive = true
        colorsCollectiomView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18).isActive = true
        colorsCollectiomView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -18).isActive = true
        colorsCollectiomView.heightAnchor.constraint(equalToConstant: 156).isActive = true
        colorsCollectiomView.dataSource = self
        colorsCollectiomView.delegate = self
        
    }
    
    private func addEmojiCollectionView() {
        emojiCollectiomView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(emojiCollectiomView)
        emojiCollectiomView.topAnchor.constraint(equalTo: emojiLabel.bottomAnchor, constant: 19).isActive = true
        emojiCollectiomView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18).isActive = true
        emojiCollectiomView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -18).isActive = true
        emojiCollectiomView.heightAnchor.constraint(equalToConstant: 156).isActive = true
        emojiCollectiomView.dataSource = self
        emojiCollectiomView.delegate = self
        
    }
    
    private func addTableView(){
        tableView.frame = self.view.bounds
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(tableView)
        tableView.layer.masksToBounds = true
        tableView.layer.cornerRadius = 16
        tableView.backgroundColor = .ypTableViewCell
        tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16).isActive = true
        tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16).isActive = true
        tableView.topAnchor.constraint(equalTo: nameOfHabit.bottomAnchor, constant: 24).isActive = true
        tableView.heightAnchor.constraint(equalToConstant: 74).isActive = true
        tableView.isScrollEnabled = false
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        tableView.separatorColor = .ypLightGrey
    }
    
    private func addLabel(){
        label.text = NSLocalizedString("viewTitleForEditEvent", comment: "Редактирование нерегулярного события")
        label.font = UIFont(name: "SFPro-Medium", size: 16)
        navigationItem.titleView = label
    }
    
    private func addTextField(){
        nameOfHabit.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(nameOfHabit)
        nameOfHabit.placeholder = NSLocalizedString("trackerNamePlaceholderTitle", comment: "Введите название трекера")
        nameOfHabit.text = nameOfTracker
        nameOfHabit.heightAnchor.constraint(equalToConstant: 75).isActive = true
        nameOfHabit.topAnchor.constraint(equalTo: daysLabel.bottomAnchor, constant: 40).isActive = true
        nameOfHabit.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16).isActive = true
        nameOfHabit.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16).isActive = true
        nameOfHabit.layer.masksToBounds = true
        nameOfHabit.layer.cornerRadius = 16
        nameOfHabit.backgroundColor = .ypTableViewCell
        nameOfHabit.font = UIFont(name: "SFPro-Regular", size: 17)
        nameOfHabit.textInputView.leadingAnchor.constraint(equalTo: nameOfHabit.leadingAnchor, constant: 16).isActive = true
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: nameOfHabit.frame.height))
        nameOfHabit.leftView = paddingView
        nameOfHabit.leftViewMode = .always
        nameOfHabit.addTarget(self, action: #selector(checkAllConditions), for: .editingChanged)
    }
    
    private func addButtonCancel(){
        buttonСancel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(buttonСancel)
        buttonСancel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        buttonСancel.topAnchor.constraint(equalTo: colorsCollectiomView.bottomAnchor, constant: 32).isActive = true
        buttonСancel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20).isActive = true
        buttonСancel.widthAnchor.constraint(equalToConstant: 166).isActive = true
        buttonСancel.heightAnchor.constraint(equalToConstant: 60).isActive = true
        buttonСancel.layer.masksToBounds = true
        buttonСancel.layer.borderWidth = 1
        buttonСancel.layer.cornerRadius = 16
        buttonСancel.layer.borderColor = UIColor.ypRed.cgColor
        buttonСancel.setTitle(NSLocalizedString("cancelButtonTitle", comment: "Отменить"), for: .normal)
        buttonСancel.titleLabel?.font = UIFont(name: "SFPro-Medium", size: 16)
        buttonСancel.tintColor = .ypRed
        buttonСancel.addTarget(self, action: #selector(closeThisWindow), for: .touchUpInside)
    }
    
    private func addButtonAccept(){
        buttonAccept.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(buttonAccept)
        buttonAccept.topAnchor.constraint(equalTo: colorsCollectiomView.bottomAnchor, constant: 32).isActive = true
        buttonAccept.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20).isActive = true
        buttonAccept.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true
        buttonAccept.widthAnchor.constraint(equalToConstant: 166).isActive = true
        buttonAccept.heightAnchor.constraint(equalToConstant: 60).isActive = true
        buttonAccept.layer.masksToBounds = true
        buttonAccept.layer.cornerRadius = 16
        buttonAccept.setTitle(NSLocalizedString("trackerSaveButtonForEditingTitle", comment: "Сохранить"), for: .normal)
        buttonAccept.titleLabel?.font = UIFont(name: "SFPro-Medium", size: 16)
        buttonAccept.backgroundColor = .ypReBackground
        buttonAccept.setTitleColor(UIColor.ypBackground, for: .normal)
        buttonAccept.addTarget(self, action: #selector(EditTempEvent), for: .touchUpInside)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomTableViewCell
        
        cell.configureTemporaryEvent(with: data[indexPath.row], optionalText: selectedCategory?.name)
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        categoryButtonTapped()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    private func categoryButtonTapped(){
        let categoryViewController = CategoryViewController(viewModel: CategoryViewModel())
        categoryViewController.delegate = self
        let category = selectedCategory
        categoryViewController.trackerCategory = category
        let navigationController = UINavigationController(rootViewController: categoryViewController)
        present(navigationController, animated: true)
    }
    
    private func selectEmoji(indexPath: IndexPath){
        selectedEmoji = emoji[indexPath.row]
        checkAllConditions()
    }
    
    private func findNumOfEmoji(emojis: String) -> Int{
        return emoji.firstIndex(of: emojis) ?? -1
    }
    
    private func selectColor(indexPath: IndexPath){
        selectedColor = colors[indexPath.row]
        checkAllConditions()
    }
    
    func selectCategory(selected: TrackerCategoryCoreData) {
        selectedCategory = selected
        tableView.reloadData()
        checkAllConditions()
    }
    
    @objc private func checkAllConditions(){
        if nameOfHabit.text?.count ?? 0 > 38 {
            buttonAccept.backgroundColor = .ypLightGrey
            buttonAccept.isEnabled = false
            addErrorLabel()
        } else if (!nameOfHabit.text!.isEmpty && selectedCategory != nil && selectedEmoji != "" && selectedColor != UIColor.clear){
            buttonAccept.backgroundColor = .ypReBackground
            buttonAccept.isEnabled = true
            errorLabel.removeFromSuperview()
        } else{
            buttonAccept.backgroundColor = .ypLightGrey
            buttonAccept.isEnabled = false
        }
    }
    
    @objc private func EditTempEvent(){
        guard let nameOfTracker = nameOfHabit.text
        else{
            fatalError("Что-то с именем события")
        }
        guard let category = selectedCategory
        else{
            assertionFailure("Категория пуста")
            return
        }
        guard let selectedTracker else{
            return
        }
        dataProvider?.edit(tracker: selectedTracker, name: nameOfTracker, color: UIColorMarshalling().hexString(from: selectedColor), emoji: selectedEmoji, shedule: currentDate, category: category)
        closeThisWindow()
        closeDelegate?.closeController()
    }
    
    @objc private func closeThisWindow(){
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension EditTemporaryEventViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var result = 0
        if collectionView == emojiCollectiomView {
            result = emoji.count
        }
        else if collectionView == colorsCollectiomView {
            result = colors.count
        }
        return result
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == emojiCollectiomView {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CustomEmojiCell.identifier, for: indexPath) as? CustomEmojiCell {
                let emojiInCell = emoji[indexPath.row]
                cell.changeCell(emoji: emojiInCell)
                cell.layer.masksToBounds = true
                cell.layer.cornerRadius = 16
                if emojiInCell == selectedEmoji {
                    selectedEmojiIndexPath = indexPath
                    cell.setSelectedBackground(true)
                } else {
                    cell.setSelectedBackground(false)
                }
                return cell
            }
        }
        else if collectionView == colorsCollectiomView {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CustomColorCell.identifier, for: indexPath) as? CustomColorCell {
                let color = colors[indexPath.row]
                let colorFabric = UIColorMarshalling().translateColor(colors: color)
                
                if colorFabric == selectedColor {
                    selectedColorIndexPath = indexPath
                    cell.changeCell(color: color, isSelected: true)
                } else {
                    cell.changeCell(color: color, isSelected: false)
                }
                return cell
            }
        }
        assertionFailure("не найдена ячейка")
        return UICollectionViewCell()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
}

extension EditTemporaryEventViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        var size: CGSize = CGSize()
        size = CGSize(width: (collectionView.bounds.width - 36) / 6, height: 52)
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

extension EditTemporaryEventViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == emojiCollectiomView {
            if let previousIndexPath = selectedEmojiIndexPath, let previousCell = collectionView.cellForItem(at: previousIndexPath) as? CustomEmojiCell {
                previousCell.setSelectedBackground(false)
            }
            
            selectedEmojiIndexPath = indexPath
            if let cell = collectionView.cellForItem(at: indexPath) as? CustomEmojiCell {
                cell.setSelectedBackground(true)
            }
            
            selectEmoji(indexPath: indexPath)
        }
        if collectionView == colorsCollectiomView {
            if let previousIndexPath = selectedColorIndexPath, let previousCell = collectionView.cellForItem(at: previousIndexPath) as? CustomColorCell {
                previousCell.changeCell(color: colors[previousIndexPath.row], isSelected: false)
            }
            
            selectedColorIndexPath = indexPath
            if let cell = collectionView.cellForItem(at: indexPath) as? CustomColorCell {
                cell.changeCell(color: colors[indexPath.row], isSelected: true)
            }
            
            selectColor(indexPath: indexPath)
        }
        
    }
}

extension EditTemporaryEventViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
