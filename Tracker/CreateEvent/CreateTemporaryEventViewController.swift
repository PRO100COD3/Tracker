//
//  CreateTemporaryEventViewController.swift
//  Tracker
//
//  Created by Вадим Дзюба on 10.07.2024.
//

import UIKit

final class CreateTemporaryEventViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CategoryProtocol {
    
    var currentDate: Date = Date()
    let label = UILabel()
    let nameOfHabit = UITextField()
    let buttonСancel = UIButton(type: .system)
    let buttonAccept = UIButton(type: .system)
    let tableView = UITableView()
    var addCategoryDelegate: AddNewCategoryProtocol?
    weak var closeDelegate: CloseControllerProtocol?
    weak var delegate: CreateTrackerProtocol?
    var categories: [TrackerCategory] = []
    var selectedCategory: TrackerCategory?
    
    let data = ["Категория"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        view.backgroundColor = .white
        addLabel()
        addTextField()
        addButtonCancel()
        addButtonAccept()
        addTableView()
    }
    
    func addTableView(){
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
        tableView.heightAnchor.constraint(equalToConstant: 74).isActive = true
        tableView.isScrollEnabled = false
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        tableView.separatorColor = .ypLightGrey
    }
    
    func addLabel(){
        label.text = "Новое нерегулярное событие"
        label.font = UIFont(name: "SFPro-Medium", size: 16)
        navigationItem.titleView = label
    }
    
    func addTextField(){
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
    
    func addButtonCancel(){
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
    
    func addButtonAccept(){
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
        buttonAccept.addTarget(self, action: #selector(addNewTempEvent), for: .touchUpInside)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomTableViewCell
        
        cell.textLabel?.text = data[indexPath.row]
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
    
    func categoryButtonTapped(){
        let categoryViewController = CategoryViewController()
        categoryViewController.delegate = self
        categoryViewController.addCategoryDelegate = self.addCategoryDelegate
        categoryViewController.categories = self.categories
        let navigationController = UINavigationController(rootViewController: categoryViewController)
        present(navigationController, animated: true)
    }
    
    func selectCategory(selected: TrackerCategory) {
        selectedCategory = selected
        checkAllConditions()
    }
    
    @objc func checkAllConditions(){
        if (!nameOfHabit.text!.isEmpty && selectedCategory != nil){
            buttonAccept.backgroundColor = .yPblack
            buttonAccept.isEnabled = true
        }
        else{
            buttonAccept.backgroundColor = .ypLightGrey
            buttonAccept.isEnabled = false
        }
    }
    
    @objc func addNewTempEvent(){
        guard let nameOfTracker = nameOfHabit.text
        else{
            fatalError("Что-то с именем привычки")
        }
        guard let category = selectedCategory
        else{
            fatalError("Категория пуста")
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        let formattedDate = dateFormatter.string(from: currentDate)
        
        delegate?.createNewTracker(name: nameOfTracker, shedule: [formattedDate], category: category)
        closeThisWindow()
        closeDelegate?.closeController()
    }
    
    @objc func closeThisWindow(){
        dismiss(animated: true, completion: nil)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

