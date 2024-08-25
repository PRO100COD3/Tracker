//
//  AddNewCategoryViewController.swift
//  Tracker
//
//  Created by Вадим Дзюба on 13.07.2024.
//
import UIKit


final class AddNewCategoryViewController: UIViewController {
    
    weak var delegate: CategoryViewController?
    weak var addCategoryDelegate: AddNewCategoryProtocol?
    private let label = UILabel()
    private let buttonAddNewCategory = UIButton(type: .system)
    private let nameOfCategory = UITextField()
    private let categoryStore = TrackerCategoryStore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        view.backgroundColor = .white
        
        addLabel()
        addTextField()
        addButtonAddNewCategory()
    }
    
    private func addLabel() {
        label.text = "Новая категория"
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
        buttonAddNewCategory.setTitle("Готово", for: .normal)
        buttonAddNewCategory.titleLabel?.font = UIFont(name: "SFPro-Medium", size: 16)
        buttonAddNewCategory.backgroundColor = .ypLightGrey
        buttonAddNewCategory.tintColor = .white
        buttonAddNewCategory.isEnabled = false
        buttonAddNewCategory.addTarget(self, action: #selector(didTapAddButton), for: .touchUpInside)
    }
    
    private func addTextField() {
        nameOfCategory.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameOfCategory)
        nameOfCategory.placeholder = "Введите название категории"
        nameOfCategory.heightAnchor.constraint(equalToConstant: 75).isActive = true
        nameOfCategory.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24).isActive = true
        nameOfCategory.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        nameOfCategory.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        nameOfCategory.layer.masksToBounds = true
        nameOfCategory.layer.cornerRadius = 16
        nameOfCategory.backgroundColor = .ypGrey
        nameOfCategory.font = UIFont(name: "SFPro-Regular", size: 17)
        nameOfCategory.textInputView.leadingAnchor.constraint(equalTo: nameOfCategory.leadingAnchor, constant: 16).isActive = true
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: nameOfCategory.frame.height))
        nameOfCategory.leftView = paddingView
        nameOfCategory.leftViewMode = .always
        nameOfCategory.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    @objc private func textFieldDidChange() {
        if let text = nameOfCategory.text, !text.isEmpty {
            buttonAddNewCategory.backgroundColor = .yPblack
            buttonAddNewCategory.isEnabled = true
        } else {
            buttonAddNewCategory.backgroundColor = .ypLightGrey
            buttonAddNewCategory.isEnabled = false
        }
    }
    
    @objc private func didTapAddButton(){
        guard let text = nameOfCategory.text else{
            assertionFailure("пустая строка добавления категории")
            return
        }
        
        categoryStore.saveNewCategory(nameOfCategory: text)
        addCategoryDelegate?.addCategoryAtArray(nameOfCategory: text)
        dismiss(animated: true, completion: nil)
        delegate?.reloadTable(nameOfCategory: text)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}
