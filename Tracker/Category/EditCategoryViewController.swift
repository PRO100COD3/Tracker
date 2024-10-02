//
//  EditCategoryViewController.swift
//  Tracker
//
//  Created by Вадим Дзюба on 29.09.2024.
//

import UIKit


final class EditCategoryViewController: UIViewController {
    weak var delegate: EditCategoryDelegate?
    private let label = UILabel()
    private let buttonEditCategory = UIButton(type: .system)
    private let nameOfCategory = UITextField()
    private var index: IndexPath = []
    private var name: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        view.backgroundColor = .ypBackground
        
        nameOfCategory.delegate = self
        
        addLabel()
        addTextField()
        addButtonEditCategory()
    }
    
    init(delegate: EditCategoryDelegate?, index: IndexPath, name: String) {
        super.init(nibName: nil, bundle: nil)
        self.delegate = delegate
        self.index = index
        self.name = name
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addLabel() {
        label.text = NSLocalizedString("viewTitleTextForNewCategory", comment: "Новая категория")
        label.font = UIFont(name: "SFPro-Medium", size: 16)
        navigationItem.titleView = label
    }
    
    private func addButtonEditCategory() {
        buttonEditCategory.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonEditCategory)
        buttonEditCategory.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        buttonEditCategory.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        buttonEditCategory.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
        buttonEditCategory.heightAnchor.constraint(equalToConstant: 60).isActive = true
        buttonEditCategory.layer.masksToBounds = true
        buttonEditCategory.layer.cornerRadius = 16
        buttonEditCategory.setTitle(NSLocalizedString("readyButtonTitle", comment: "Готово"), for: .normal)
        buttonEditCategory.titleLabel?.font = UIFont(name: "SFPro-Medium", size: 16)
        buttonEditCategory.backgroundColor = .ypReBackground
        buttonEditCategory.setTitleColor(UIColor.ypBackground, for: .normal)
        buttonEditCategory.addTarget(self, action: #selector(didTapEditButton), for: .touchUpInside)
    }
    
    private func addTextField() {
        nameOfCategory.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameOfCategory)
        nameOfCategory.text = name
        nameOfCategory.placeholder = NSLocalizedString("trackerNamePlaceholderTitle", comment: "Введите название категории")
        nameOfCategory.heightAnchor.constraint(equalToConstant: 75).isActive = true
        nameOfCategory.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24).isActive = true
        nameOfCategory.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        nameOfCategory.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        nameOfCategory.layer.masksToBounds = true
        nameOfCategory.layer.cornerRadius = 16
        nameOfCategory.backgroundColor = .ypTableViewCell
        nameOfCategory.font = UIFont(name: "SFPro-Regular", size: 17)
        nameOfCategory.textInputView.leadingAnchor.constraint(equalTo: nameOfCategory.leadingAnchor, constant: 16).isActive = true
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: nameOfCategory.frame.height))
        nameOfCategory.leftView = paddingView
        nameOfCategory.leftViewMode = .always
        nameOfCategory.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    @objc private func textFieldDidChange() {
        if let text = nameOfCategory.text, !text.isEmpty {
            buttonEditCategory.backgroundColor = .ypReBackground
            buttonEditCategory.isEnabled = true
        } else {
            buttonEditCategory.backgroundColor = .ypLightGrey
            buttonEditCategory.isEnabled = false
        }
    }
    
    @objc private func didTapEditButton(){
        guard let text = nameOfCategory.text else{
            assertionFailure("пустая строка добавления категории")
            return
        }
        delegate?.edit(name: text, index: index)
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension EditCategoryViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
