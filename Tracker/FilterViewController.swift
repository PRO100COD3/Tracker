//
//  FilterViewController.swift
//  Tracker
//
//  Created by Вадим Дзюба on 26.09.2024.
//

import UIKit


final class FilterViewController: UIViewController {
    weak var delegate: FilterChangeDelegate?
    private let tableView = UITableView()
    private let label = UILabel()
    var selectedFilter: String = "all"

    private let data = ["Все трекеры", "Трекеры на сегодня", "Завершенные", "Не завершенные"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        if selectedFilter == "" {
            selectedFilter = "all"
        }
        addLabel()
        addTableView()
    }
    
    private func addTableView() {
        tableView.frame = self.view.bounds
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        tableView.layer.masksToBounds = true
        tableView.layer.cornerRadius = 16
        tableView.backgroundColor = .ypGrey
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 138).isActive = true
        tableView.heightAnchor.constraint(equalToConstant: 299).isActive = true
        tableView.isScrollEnabled = false
//        tableView.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
//        tableView.separatorColor = .ypLightGrey
    }
    
    private func addLabel() {
        label.text = "Фильтры"
        label.font = UIFont(name: "SFPro-Medium", size: 16)
        navigationItem.titleView = label
    }
    
    private func checkSelected(name: String) -> Bool {
        if name == "Все трекеры" {
            return "all" == selectedFilter
        } else if name == "Трекеры на сегодня" {
            return "today" == selectedFilter
        } else if name == "Завершенные" {
            return selectedFilter == "completed"
        } else if name == "Не завершенные" {
            return selectedFilter == "notCompleted"
        }
        return false
    }
}

extension FilterViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 {
            delegate?.filterDidChange(filter: "all")
        } else if indexPath.row == 1 {
            delegate?.filterDidChange(filter: "today")
        } else if indexPath.row == 2 {
            delegate?.filterDidChange(filter: "completed")
        } else if indexPath.row == 3 {
            delegate?.filterDidChange(filter: "notCompleted")
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}

extension FilterViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? CustomTableViewCell{
            cell.configureFilter(with: data[indexPath.row], isSelected: checkSelected(name: data[indexPath.row]))
            return cell
        }
        assertionFailure("не найдена ячейка")
        return UITableViewCell()
    }
}
