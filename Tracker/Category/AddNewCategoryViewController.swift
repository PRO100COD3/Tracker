//
//  AddNewCategoryViewController.swift
//  Tracker
//
//  Created by Вадим Дзюба on 13.07.2024.
//
import UIKit


final class AddNewCategoryViewController: UIViewController {
    
    
    weak var delegate: NewCategoryDelegate?
    private let label = UILabel()
    private let buttonAddNewCategory = UIButton(type: .system)
    private let nameOfCategory = UITextField()
    private let errorLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        view.backgroundColor = .ypBackground
        
        nameOfCategory.delegate = self  
        
        addLabel()
        addTextField()
        addButtonAddNewCategory()
    }
    
    private func addLabel() {
        label.text = NSLocalizedString("viewTitleTextForNewCategory", comment: "Новая категория")
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
        buttonAddNewCategory.setTitle(NSLocalizedString("readyButtonTitle", comment: "Готово"), for: .normal)
        buttonAddNewCategory.titleLabel?.font = UIFont(name: "SFPro-Medium", size: 16)
        buttonAddNewCategory.backgroundColor = .ypLightGrey
        buttonAddNewCategory.setTitleColor(UIColor.ypBackground, for: .normal)
        buttonAddNewCategory.isEnabled = false
        buttonAddNewCategory.addTarget(self, action: #selector(didTapAddButton), for: .touchUpInside)
    }
    
    private func addTextField() {
        nameOfCategory.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameOfCategory)
        nameOfCategory.placeholder = NSLocalizedString("categoryNamePlaceholder", comment: "Введите название категории")
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
    
    private func addErrorLabel() {
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(errorLabel)
        errorLabel.text = NSLocalizedString("trackerNameWarningLabelText", comment: "Ограничение 38 символов")
        errorLabel.textColor = .ypRed
        errorLabel.font = UIFont(name: "SFPro-Regular", size: 17)
        NSLayoutConstraint.activate([
            errorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorLabel.topAnchor.constraint(equalTo: nameOfCategory.bottomAnchor, constant: 8)
        ])
    }
    
    @objc private func textFieldDidChange() {
        if nameOfCategory.text?.count ?? 0 > 38 {
            buttonAddNewCategory.backgroundColor = .ypLightGrey
            buttonAddNewCategory.isEnabled = false
            addErrorLabel()
        } else if let text = nameOfCategory.text, !text.isEmpty {
            buttonAddNewCategory.backgroundColor = .ypReBackground
            buttonAddNewCategory.isEnabled = true
            errorLabel.removeFromSuperview()
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
        delegate?.add(name: text)
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension AddNewCategoryViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
