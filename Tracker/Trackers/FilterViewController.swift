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
    private let dateFormatter = DateFormatter()
    var selectedFilter: String
    var currentDate: String
    
    
    private let data = [NSLocalizedString("trackersFilterTitleForAllTrackers", comment: "Все трекеры"), NSLocalizedString("trackersFilterTitleForCurrentDayTrackers", comment: "Трекеры на сегодня"), NSLocalizedString("trackersFilterTitleForComplitedTrackers", comment: "Завершённые"), NSLocalizedString("trackersFilterTitleForRunningTrackers", comment: "Не завершённые")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBackground
        
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        dateFormatter.locale = Locale(identifier: "en_GB")
        
        let date = dateFormatter.string(from: Date())
        if (selectedFilter == "" || (currentDate != date && selectedFilter == "today")) {
            selectedFilter = "all"
        }
        addLabel()
        addTableView()
    }
    
    init(currentDate: String, delegate: FilterChangeDelegate, filter: String) {
        self.currentDate = currentDate
        self.delegate = delegate
        self.selectedFilter = filter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        tableView.backgroundColor = .ypTableViewCell
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 138).isActive = true
        tableView.heightAnchor.constraint(equalToConstant: 299).isActive = true
        tableView.isScrollEnabled = false
    }
    
    private func addLabel() {
        label.text = NSLocalizedString("filterButtonTitle", comment: "Фильтры")
        label.font = UIFont(name: "SFPro-Medium", size: 16)
        navigationItem.titleView = label
    }
    
    private func checkSelected(name: String) -> Bool {
        if name == NSLocalizedString("trackersFilterTitleForAllTrackers", comment: "Все трекеры") {
            return "all" == selectedFilter
        } else if name == NSLocalizedString("trackersFilterTitleForCurrentDayTrackers", comment: "Трекеры на сегодня") {
            return "today" == selectedFilter
        } else if name == NSLocalizedString("trackersFilterTitleForComplitedTrackers", comment: "Завершённые") {
            return selectedFilter == "completed"
        } else if name == NSLocalizedString("trackersFilterTitleForRunningTrackers", comment: "Не завершённые") {
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
            delegate?.changeDataByFilter()
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
