//
//  CategoryViewController.swift
//  Tracker
//
//  Created by Вадим Дзюба on 12.07.2024.
//

import UIKit

final class CategoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    weak var addCategoryDelegate: AddNewCategoryProtocol?
    weak var delegate: CategoryProtocol?
    weak var addCategoryAtCreatorDelegate: AddNewCategoryProtocol?
    private let label = UILabel()
    private let buttonAddNewCategory = UIButton(type: .system)
    private let tableView = UITableView()
    private var imageView = UIImageView()
    private let quote = UILabel()
    var categories: [TrackerCategory] = []
    private var newCategories:[String] = []
    private var selectedIndexPath: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        categoryToString()
        if categories.isEmpty == false {
            addTableView()
        } else {
            addImageView()
            addCentreText()
        }
        addLabel()
        addButtonAddNewCategory()
    }
    
    private func addLabel() {
        label.text = "Категория"
        label.font = UIFont(name: "SFPro-Medium", size: 16)
        navigationItem.titleView = label
    }
    
    private func addButtonAddNewCategory() {
        buttonAddNewCategory.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonAddNewCategory)
        buttonAddNewCategory.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        buttonAddNewCategory.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        buttonAddNewCategory.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
        buttonAddNewCategory.heightAnchor.constraint(equalToConstant: 60).isActive = true
        buttonAddNewCategory.layer.masksToBounds = true
        buttonAddNewCategory.layer.cornerRadius = 16
        buttonAddNewCategory.setTitle("Добавить категорию", for: .normal)
        buttonAddNewCategory.titleLabel?.font = UIFont(name: "SFPro-Medium", size: 16)
        buttonAddNewCategory.backgroundColor = .yPblack
        buttonAddNewCategory.tintColor = .white
        buttonAddNewCategory.addTarget(self, action: #selector(addNewCategory), for: .touchUpInside)
    }
    
    private func addImageView() {
        let image = UIImage(named: "Star")
        imageView = UIImageView(image: image)
        view.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    private func addCentreText() {
        quote.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(quote)
        quote.numberOfLines = 2
        quote.textAlignment = .center
        quote.text = "Привычки и события можно объединить по смыслу?"
        quote.font = UIFont(name: "SFPro-Medium", size: 12)
        quote.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8).isActive = true
        quote.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    @objc private func addNewCategory() {
        let addNewCategoryViewController = AddNewCategoryViewController()
        addNewCategoryViewController.delegate = self
        addNewCategoryViewController.addCategoryDelegate = self.addCategoryDelegate
        let navigationController = UINavigationController(rootViewController: addNewCategoryViewController)
        present(navigationController, animated: true)
    }
    
    private func addTableView() {
        tableView.frame = self.view.bounds
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(CategoriesTableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(tableView)
        tableView.layer.masksToBounds = true
        tableView.layer.cornerRadius = 16
        tableView.backgroundColor = .ypGrey
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16).isActive = true
        tableView.heightAnchor.constraint(equalToConstant: 524).isActive = true
    }
    
    func reloadTable(nameOfCategory: String) {
        let newCategory = TrackerCategory(name: nameOfCategory, trackers: [])
        categories.append(newCategory)
        newCategories.append(nameOfCategory)
        
        if categories.count == 1 {
            imageView.removeFromSuperview()
            quote.removeFromSuperview()
            addTableView()
        } else {
            let newIndexPath = IndexPath(row: categories.count - 1, section: 0)
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        }
        delegate?.addCategoryAtProtocol(name: nameOfCategory)
        addCategoryAtCreatorDelegate?.addCategoryAtArray(nameOfCategory: nameOfCategory)
        
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CategoriesTableViewCell
        
        cell.textLabel?.text = categories[indexPath.row].name
        cell.accessoryType = .none
        if indexPath == selectedIndexPath {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let selectedIndexPath = selectedIndexPath {
            let previousCell = tableView.cellForRow(at: selectedIndexPath)
            previousCell?.accessoryType = .none
        }
        
        let currentCell = tableView.cellForRow(at: indexPath)
        currentCell?.accessoryType = .checkmark
        
        selectedIndexPath = indexPath
        
        guard let select = selectedIndexPath else {
            return
        }
        tableView.reloadData()
        let selectedCategory = newCategories[select.row]
        let category = findCategory(name: selectedCategory)
        
        delegate?.selectCategory(selected: category)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    private func categoryToString() {
        for i in categories {
            newCategories.append(i.name)
        }
    }
    
    private func findCategory(name: String) -> TrackerCategory {
        for i in categories {
            if name == i.name {
                return i
            }
        }
        assertionFailure("ошибка, не найдена категория из ячейки")
        return TrackerCategory(name: "", trackers: [])
    }
}
