//
//  NavigationController.swift
//  Tracker
//
//  Created by Вадим Дзюба on 09.07.2024.
//

import UIKit

final class CreateHabitViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SheduleProtocol, CategoryProtocol {
    
    weak var addCategoryDelegate: AddNewCategoryProtocol?
    weak var closeDelegate: CloseControllerProtocol?
    weak var delegate: CreateTrackerProtocol?
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
        collectionView.isScrollEnabled = false
        collectionView.register(CustomEmojiCell.self, forCellWithReuseIdentifier: CustomEmojiCell.identifier)
        return collectionView
    }()
    private let emojiLabel = UILabel()
    private let colorLabel = UILabel()
    private var selectedColorIndexPath: IndexPath?
    private var selectedColor: UIColor = UIColor.clear
    private let colorsCollectiomView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewFlowLayout()
        )
        collectionView.isScrollEnabled = false
        collectionView.register(CustomColorCell.self, forCellWithReuseIdentifier: CustomColorCell.identifier)
        return collectionView
    }()
    private let colors = [UIColor.ypRedPlate1, UIColor.ypOrangePlate2, UIColor.ypBluePlate3, UIColor.ypVioletPlate4, UIColor.ypGreenPlate5, UIColor.ypPinkPlate6, UIColor.ypPinkPlate7, UIColor.ypBluePlate8, UIColor.ypGreenPlate9, UIColor.ypVioletPlate10, UIColor.ypOrangePlate11, UIColor.ypPinkPlate12, UIColor.ypOrangePlate13, UIColor.ypBluePlate14, UIColor.ypVioletPlate15, UIColor.ypVioletPlate16, UIColor.ypVioletPlate17, UIColor.ypGreenPlate18]
    var categories: [TrackerCategory] = []
    private var selectedCategory: TrackerCategory?
    private var selectedDays: [String] = []
    private var selectedEmoji: String = ""
    private var selectedEmojiIndexPath: IndexPath?
    
    private let data = ["Категория", "Расписание"]
    private let emoji = ["🙂", "😻", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🥶", "🤔", "🙌", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝", "😪"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        view.backgroundColor = .white
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
    
    func addCategoryAtProtocol(name: String) {
        let newCategory = TrackerCategory(name: name, trackers: [])
        categories.append(newCategory)
    }
    
    private func addColorLabel() {
        colorLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(colorLabel)
        colorLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28).isActive = true
        colorLabel.topAnchor.constraint(equalTo: emojiCollectiomView.bottomAnchor, constant: 32).isActive = true
        colorLabel.text = "Цвет"
        colorLabel.font = UIFont(name: "SFPro-Bold", size: 19)
    }
    
    private func addColorsCollectionView() {
        colorsCollectiomView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(colorsCollectiomView)
        colorsCollectiomView.topAnchor.constraint(equalTo: colorLabel.bottomAnchor, constant: 19).isActive = true
        colorsCollectiomView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18).isActive = true
        colorsCollectiomView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18).isActive = true
        colorsCollectiomView.heightAnchor.constraint(equalToConstant: 156).isActive = true
        colorsCollectiomView.dataSource = self
        colorsCollectiomView.delegate = self
        
    }
    
    private func addEmojiLabel() {
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emojiLabel)
        emojiLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28).isActive = true
        emojiLabel.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 32).isActive = true
        emojiLabel.text = "Emoji"
        emojiLabel.font = UIFont(name: "SFPro-Bold", size: 19)
    }
    
    private func addTableView() {
        tableView.frame = self.view.bounds
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(tableView)
        tableView.layer.masksToBounds = true
        tableView.layer.cornerRadius = 16
        tableView.backgroundColor = .ypGrey
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        tableView.topAnchor.constraint(equalTo: nameOfHabit.bottomAnchor, constant: 24).isActive = true
        tableView.heightAnchor.constraint(equalToConstant: 149).isActive = true
        tableView.isScrollEnabled = false
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        tableView.separatorColor = .ypLightGrey
    }
    
    private func addEmojiCollectionView() {
        emojiCollectiomView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emojiCollectiomView)
        emojiCollectiomView.topAnchor.constraint(equalTo: emojiLabel.bottomAnchor, constant: 19).isActive = true
        emojiCollectiomView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18).isActive = true
        emojiCollectiomView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18).isActive = true
        emojiCollectiomView.heightAnchor.constraint(equalToConstant: 156).isActive = true
        emojiCollectiomView.dataSource = self
        emojiCollectiomView.delegate = self
        
    }
    
    private func addLabel() {
        label.text = "Новая привычка"
        label.font = UIFont(name: "SFPro-Medium", size: 16)
        navigationItem.titleView = label
    }
    
    private func addTextField() {
        nameOfHabit.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameOfHabit)
        nameOfHabit.placeholder = "Введите название трекера"
        nameOfHabit.heightAnchor.constraint(equalToConstant: 75).isActive = true
        nameOfHabit.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24).isActive = true
        nameOfHabit.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        nameOfHabit.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        nameOfHabit.layer.masksToBounds = true
        nameOfHabit.layer.cornerRadius = 16
        nameOfHabit.backgroundColor = .ypGrey
        nameOfHabit.font = UIFont(name: "SFPro-Regular", size: 17)
        nameOfHabit.textInputView.leadingAnchor.constraint(equalTo: nameOfHabit.leadingAnchor, constant: 16).isActive = true
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: nameOfHabit.frame.height))
        nameOfHabit.leftView = paddingView
        nameOfHabit.leftViewMode = .always
        nameOfHabit.addTarget(self, action: #selector(checkAllConditions), for: .editingChanged)
    }
    
    private func addButtonCancel() {
        buttonСancel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonСancel)
        buttonСancel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        buttonСancel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        buttonСancel.widthAnchor.constraint(equalToConstant: 166).isActive = true
        buttonСancel.heightAnchor.constraint(equalToConstant: 60).isActive = true
        buttonСancel.layer.masksToBounds = true
        buttonСancel.layer.borderWidth = 1
        buttonСancel.layer.cornerRadius = 16
        buttonСancel.layer.borderColor = UIColor.ypRed.cgColor
        buttonСancel.setTitle("Отменить", for: .normal)
        buttonСancel.titleLabel?.font = UIFont(name: "SFPro-Medium", size: 16)
        buttonСancel.tintColor = .ypRed
        buttonСancel.addTarget(self, action: #selector(closeThisWindow), for: .touchUpInside)
    }
    
    private func addButtonAccept() {
        buttonAccept.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonAccept)
        buttonAccept.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        buttonAccept.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        buttonAccept.widthAnchor.constraint(equalToConstant: 166).isActive = true
        buttonAccept.heightAnchor.constraint(equalToConstant: 60).isActive = true
        buttonAccept.layer.masksToBounds = true
        buttonAccept.layer.cornerRadius = 16
        buttonAccept.setTitle("Создать", for: .normal)
        buttonAccept.titleLabel?.font = UIFont(name: "SFPro-Medium", size: 16)
        buttonAccept.backgroundColor = .ypLightGrey
        buttonAccept.tintColor = .white
        buttonAccept.isEnabled = false
        buttonAccept.addTarget(self, action: #selector(addNewHabit), for: .touchUpInside)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? CustomTableViewCell{
            cell.textLabel?.text = data[indexPath.row]
            cell.accessoryType = .disclosureIndicator
            return cell
        }
        assertionFailure("не найдена ячейка")
        return UITableViewCell()
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 {
            print(1)
            categoryButtonTapped()
        } else if indexPath.row == 1 {
            print(2)
            sheduleButtonTapped()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func sheduleButtonTapped() {
        let sheduleViewController = SheduleViewController()
        sheduleViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: sheduleViewController)
        present(navigationController, animated: true)
    }
    
    private func selectColor(indexPath: IndexPath){
        selectedColor = colors[indexPath.row]
        checkAllConditions()
    }
    
    private func categoryButtonTapped(){
        let categoryViewController = CategoryViewController()
        categoryViewController.delegate = self
        categoryViewController.addCategoryDelegate = self.addCategoryDelegate
        categoryViewController.categories = self.categories
        let navigationController = UINavigationController(rootViewController: categoryViewController)
        present(navigationController, animated: true)
    }
    
    func addDayAtShedule(numOfDay: [Bool]) {
        let daysOfWeek = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
        
        for (i, day) in daysOfWeek.enumerated(){
            if numOfDay[i] == true{
                selectedDays.append(day)
            }
        }
        checkAllConditions()
    }
    
    func selectCategory(selected: TrackerCategory) {
        selectedCategory = selected
        checkAllConditions()
    }
    
    private func selectEmoji(indexPath: IndexPath){
        selectedEmoji = emoji[indexPath.row]
        checkAllConditions()
    }
    
    @objc private func checkAllConditions(){
        if (!nameOfHabit.text!.isEmpty && !selectedDays.isEmpty && selectedCategory != nil && selectedEmoji != "" && selectedColor != UIColor.clear){
            buttonAccept.backgroundColor = .yPblack
            buttonAccept.isEnabled = true
        }
        else{
            buttonAccept.backgroundColor = .ypLightGrey
            buttonAccept.isEnabled = false
        }
    }
    
    @objc private func addNewHabit(){
        guard let nameOfTracker = nameOfHabit.text
        else{
            assertionFailure("Что-то с именем привычки")
            return
        }
        guard let category = selectedCategory
        else{
            assertionFailure("Категория пуста")
            return
        }
        delegate?.createNewTracker(name: nameOfTracker, shedule: selectedDays, category: category, emoji: selectedEmoji)
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

extension CreateHabitViewController: UICollectionViewDataSource {
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
                return cell
            }
        }
        else if collectionView == colorsCollectiomView {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CustomColorCell.identifier, for: indexPath) as? CustomColorCell {
                let color = colors[indexPath.row]
                cell.changeCell(color: color, isSelected: false)
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


extension CreateHabitViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.bounds.width - 36) / 6, height: 52)
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

extension CreateHabitViewController: UICollectionViewDelegate {
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

