//
//  CategoryViewController.swift
//  Tracker
//
//  Created by Вадим Дзюба on 12.07.2024.
//


import UIKit

final class CategoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    weak var delegate: CategoryProtocol?
    private let label = UILabel()
    private let buttonAddNewCategory = UIButton(type: .system)
    private let tableView = UITableView()
    private var imageView = UIImageView()
    private let quote = UILabel()
    
    private lazy var dataProvider = TrackerCategoryStore(delegate: self)
    private var selectedIndexPath: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        if dataProvider.isContextEmpty(for: "TrackerCategoryCoreData") == false {
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
    
    private func deleteCentre() {
        quote.removeFromSuperview()
        imageView.removeFromSuperview()
    }
    
    @objc private func addNewCategory() {
        let addNewCategoryViewController = AddNewCategoryViewController()
        addNewCategoryViewController.delegate = self
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        dataProvider.numberOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataProvider.numberOfRowsInSection(section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CategoriesTableViewCell
        
        guard let record = dataProvider.object(at: indexPath) else { return UITableViewCell() }
        cell.textLabel?.text = record.name
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
        
        tableView.reloadData()
        guard let selectedCategory = dataProvider.object(at: indexPath) else {
            return
        }
        
        delegate?.selectCategory(selected: selectedCategory)
        dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}

extension CategoryViewController: TableViewProviderDelegate {
    func didUpdate(_ update: CategoryStoreUpdate) {
        tableView.performBatchUpdates({
            let insertedIndexPaths = update.insertedIndexes.map { IndexPath(item: $0, section: 0) }
            let deletedIndexPaths = update.deletedIndexes.map { IndexPath(item: $0, section: 0) }
            let updatedIndexPaths = update.updatedIndexes.map { IndexPath(item: $0, section: 0) }
            
            tableView.insertRows(at: insertedIndexPaths, with: .automatic)
            tableView.deleteRows(at: deletedIndexPaths, with: .fade)
            tableView.reloadRows(at: updatedIndexPaths, with: .automatic)
        }, completion: nil)
    }
}

extension CategoryViewController: NewCategoryDelegate {
    func add(name title: String) {
        dataProvider.add(name: title)
        if !dataProvider.isContextEmpty(for: "TrackerCategoryCoreData") {
            deleteCentre()
            addTableView()
        } else {
            addImageView()
            addCentreText()
        }
        dismiss(animated: true)
    }
}
