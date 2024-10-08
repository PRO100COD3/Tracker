//
//  CategoryViewController.swift
//  Tracker
//
//  Created by Вадим Дзюба on 12.07.2024.
//


import UIKit

final class CategoryViewController: UIViewController {
    
    private var viewModel: CategoryViewModel
    weak var delegate: CategoryProtocol?
    private let label = UILabel()
    private let buttonAddNewCategory = UIButton(type: .system)
    private let tableView = UITableView()
    private var imageView = UIImageView()
    private let quote = UILabel()
    
    private var selectedIndexPath: IndexPath?
    var trackerCategory: TrackerCategoryCoreData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBackground
        coreDataToIndexPath()
        addLabel()
        addButtonAddNewCategory()
        bindViewModel()
        viewModel.loadCategories()
    }
    
    init(viewModel: CategoryViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func bindViewModel() {
        viewModel.onCategoriesUpdated = { [weak self] categories in
            
            self?.checkCategories(isShouldShowPlaceholder: self?.viewModel.isShouldShowPlaceholder() ?? false)
            self?.tableView.reloadData()
        }
        
        viewModel.onCategorySelected = { [weak self] selectedCategory in
            guard let self, let delegate = self.delegate, let selectedCategory else { return }
            delegate.selectCategory(selected: selectedCategory)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    private func checkCategories(isShouldShowPlaceholder: Bool) {
        if isShouldShowPlaceholder {
            removePlaceholderFromSuperview()
            addTableView()
        } else {
            addImageView()
            addCentreText()
        }
    }
    
    private func coreDataToIndexPath() {
        guard let trackerCategory else { return }
        selectedIndexPath = viewModel.indexPathFromeCoreData(category: trackerCategory)
    }
    
    private func addLabel() {
        label.text = NSLocalizedString("categoryViewTitleText", comment: "Категория")
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
        buttonAddNewCategory.setTitle(NSLocalizedString("addCategoryButtonTitle", comment: "Добавить категорию"), for: .normal)
        buttonAddNewCategory.titleLabel?.font = UIFont(name: "SFPro-Medium", size: 16)
        buttonAddNewCategory.backgroundColor = .ypReBackground
        buttonAddNewCategory.setTitleColor(UIColor.ypBackground, for: .normal)
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
        quote.text = NSLocalizedString("categoriesStubImageLabelText", comment: "Привычки и события можно объединить по смыслу")
        quote.font = UIFont(name: "SFPro-Medium", size: 12)
        quote.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8).isActive = true
        quote.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        quote.heightAnchor.constraint(equalToConstant: 36).isActive = true
        quote.widthAnchor.constraint(equalToConstant: 200).isActive = true
    }
    
    private func removePlaceholderFromSuperview() {
        imageView.removeFromSuperview()
        quote.removeFromSuperview()
    }
    
    @objc private func addNewCategory() {
        let addNewCategoryViewController = AddNewCategoryViewController()
        addNewCategoryViewController.delegate = viewModel
        let navigationController = UINavigationController(rootViewController: addNewCategoryViewController)
        present(navigationController, animated: true)
    }
    
    private func addTableView() {
        tableView.frame = self.view.bounds
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(CategoriesTableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        tableView.backgroundColor = .ypBackground
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16).isActive = true
        tableView.heightAnchor.constraint(equalToConstant: 524).isActive = true
    }
}

extension CategoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? CategoriesTableViewCell {
            guard indexPath.row < viewModel.categories.count else {
                return UITableViewCell()
            }
            let category = viewModel.categories[indexPath.row]
            guard let name = category.name else { return UITableViewCell() }
            let isLastCategory = viewModel.isLastCategory(index: indexPath.row)
            let isFirstCategory = indexPath.row == 0 
            cell.configurate(name: name, isSelected: indexPath == selectedIndexPath, isLastCategory: isLastCategory, isFirstCategory: isFirstCategory)
            
            return cell
        }
        assertionFailure("не найдена ячейка")
        return UITableViewCell()
    }
}


extension CategoryViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.selectCategory(at: indexPath.row)
        selectedIndexPath = indexPath
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let configuration = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
            let editAction = UIAction(title: NSLocalizedString("editActionText", comment: "Редактировать")) {_ in
                let category = self?.viewModel.categories[indexPath.row]
                let editCategoryViewController = EditCategoryViewController(delegate: self?.viewModel ?? nil, index: indexPath, name: category?.name ?? "")
                editCategoryViewController.delegate = self?.viewModel
                let navigationController = UINavigationController(rootViewController: editCategoryViewController)
                self?.present(navigationController, animated: true)
            }
            let deleteAction = UIAction(title: NSLocalizedString("deleteButtonTitle", comment: "Удалить"), attributes: .destructive) { _ in
                let actionSheet = UIAlertController(title: NSLocalizedString("confirmCategoryDeleteAlertMessage", comment: "Эта категория точно не нужна?"), message: nil, preferredStyle: .actionSheet)
                
                let deleteAction = UIAlertAction(title: NSLocalizedString("deleteButtonTitle", comment: "Удалить"), style: .destructive) { _ in
                    self?.viewModel.delete(index: indexPath)
                }
                let cancelAction = UIAlertAction(title: NSLocalizedString("cancelButtonTitle", comment: "Отменить"), style: .cancel, handler: nil)
                
                actionSheet.addAction(deleteAction)
                actionSheet.addAction(cancelAction)
                
                self?.present(actionSheet, animated: true, completion: nil)
            }
            return UIMenu(title: "", children: [editAction, deleteAction])
        }
        return configuration
    }
}
