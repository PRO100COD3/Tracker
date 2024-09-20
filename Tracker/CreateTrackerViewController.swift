//
//  CreateTrackerViewController.swift
//  Tracker
//
//  Created by Вадим Дзюба on 09.07.2024.
//

import UIKit


final class CreateTrackerViewController: UIViewController, CloseControllerProtocol{
    
    weak var delegate: NewTrackerDelegate?
    private let habitButton = UIButton(type: .system)
    private let temporaryEventButton = UIButton(type: .system)
    private let label = UILabel()
    var categories: [TrackerCategory] = []
    var trackers: [Tracker] = []
    var currentDate: Date = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        addLabel()
        addHabitButton()
        addTemporaryEventButton()
    }
    
    private func addLabel(){
        label.text = "Создание трекера"
        label.font = UIFont(name: "SFPro-Medium", size: 16)
        navigationItem.titleView = label
    }
    
    private func addHabitButton() {
        habitButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(habitButton)
        habitButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 281).isActive = true
        habitButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20).isActive = true
        habitButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20).isActive = true
        habitButton.setTitle("Привычка", for: .normal)
        habitButton.titleLabel?.font = UIFont(name: "SFPro-Medium", size: 16)
        habitButton.backgroundColor = .yPblack
        habitButton.layer.masksToBounds = true
        habitButton.layer.cornerRadius = 20
        habitButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        habitButton.tintColor = .white
        habitButton.addTarget(self, action: #selector(habitButtonTapped), for: .touchUpInside)
    }
    
    private func addTemporaryEventButton(){
        temporaryEventButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(temporaryEventButton)
        temporaryEventButton.topAnchor.constraint(equalTo: habitButton.bottomAnchor, constant: 16).isActive = true
        temporaryEventButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20).isActive = true
        temporaryEventButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20).isActive = true
        temporaryEventButton.setTitle("Нерегулярное событие", for: .normal)
        temporaryEventButton.titleLabel?.font = UIFont(name: "SFPro-Medium", size: 16)
        temporaryEventButton.backgroundColor = .yPblack
        temporaryEventButton.layer.masksToBounds = true
        temporaryEventButton.layer.cornerRadius = 20
        temporaryEventButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        temporaryEventButton.tintColor = .white
        temporaryEventButton.addTarget(self, action: #selector(temporaryEventButtonTapped), for: .touchUpInside)
    }
    
    func closeController(){
        dismiss(animated: true, completion: nil)
    }
    
    func addCategoryAtArray(nameOfCategory: String) {
        var newArray:[TrackerCategory] = categories
        let newCategory = TrackerCategory(name: nameOfCategory, trackers: [])
        newArray.append(newCategory)
        categories = newArray
    }
    
    @objc private func habitButtonTapped() {
        let createHabitViewController = CreateHabitViewController()
        createHabitViewController.categories = self.categories
        createHabitViewController.closeDelegate = self
        createHabitViewController.delegate = self.delegate
        let navigationController = UINavigationController(rootViewController: createHabitViewController)
        present(navigationController, animated: true)
    }
    
    @objc private func temporaryEventButtonTapped() {
        let createTemporaryEventViewController = CreateTemporaryEventViewController()
        createTemporaryEventViewController.closeDelegate = self
        createTemporaryEventViewController.delegate = self.delegate
        createTemporaryEventViewController.currentDate = self.currentDate
        let navigationController = UINavigationController(rootViewController: createTemporaryEventViewController)
        present(navigationController, animated: true)
    }
}
