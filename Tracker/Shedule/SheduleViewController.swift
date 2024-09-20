//
//  SheduleViewController.swift
//  Tracker
//
//  Created by Вадим Дзюба on 12.07.2024.
//

import UIKit

final class SheduleViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    weak var delegate: SheduleProtocol?
    private let label = UILabel()
    private let buttonAccept = UIButton(type: .system)
    private let tableView = UITableView()
    private var switchStates = [Bool](repeating: false, count: 7)
    
    private let data = ["Понедельник", "Вторник", "Среда", "Четверг", "Пятница", "Суббота", "Воскресенье"]
    
    override func viewDidLoad() {
        view.backgroundColor = .white
        addLabel()
        addTableView()
        addButtonAccept()
    }
    
    private func addTableView(){
        tableView.frame = self.view.bounds
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(SheduleTableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(tableView)
        tableView.layer.masksToBounds = true
        tableView.layer.cornerRadius = 16
        tableView.backgroundColor = .ypGrey
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16).isActive = true
        tableView.heightAnchor.constraint(equalToConstant: 524).isActive = true
        tableView.isScrollEnabled = false
        tableView.separatorColor = .ypLightGrey
    }
    
    private func addLabel(){
        label.text = "Расписание"
        label.font = UIFont(name: "SFPro-Medium", size: 16)
        navigationItem.titleView = label
    }
    
    private func addButtonAccept(){
        buttonAccept.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonAccept)
        buttonAccept.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        buttonAccept.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        buttonAccept.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
        buttonAccept.heightAnchor.constraint(equalToConstant: 60).isActive = true
        buttonAccept.layer.masksToBounds = true
        buttonAccept.layer.cornerRadius = 16
        buttonAccept.setTitle("Готово", for: .normal)
        buttonAccept.titleLabel?.font = UIFont(name: "SFPro-Medium", size: 16)
        buttonAccept.backgroundColor = .yPblack
        buttonAccept.tintColor = .white
        buttonAccept.addTarget(self, action: #selector(didTapAcceptButton), for: .touchUpInside)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SheduleTableViewCell
        
        cell.textLabel?.text = data[indexPath.row]
        cell.accessoryType = .none
        cell.switchControl.tag = indexPath.row
        cell.switchControl.isOn = switchStates[indexPath.row]
        cell.switchControl.addTarget(self, action: #selector(switchValueChanged(_:)), for: .valueChanged)
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    @objc private func didTapAcceptButton(){
        delegate?.addDayAtShedule(numOfDay: switchStates)
        dismiss(animated: true, completion: nil)
    }
    @objc private func switchValueChanged(_ sender: UISwitch) {
        switchStates[sender.tag] = sender.isOn
    }
}
