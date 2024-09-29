//
//  ViewController.swift
//  Tracker
//
//  Created by Вадим Дзюба on 25.06.2024.
//

import UIKit
import CoreData

class TrackersViewController: UIViewController, TrackerRecordProtocol {
    
    private lazy var dataProvider = TrackerStore(delegate: self, date: currentDate)
    private lazy var recordsProvider = TrackerRecordStore(delegate: self, currentDate: currentDate)
    private var imageView = UIImageView()
    private var button = UIButton(type: .system)
    private var filterButton = UIButton(type: .system)
    private let label = UILabel()
    private let centreText = UILabel()
    private let searchBar = UISearchTextField()
    private let dateButton: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .compact
        return picker
    }()
    private var currentDate: Date = Date()
    private var categories: [TrackerCategory] = []
    private var trackersCategoriesOnCollection: [TrackerCategory] = []
    private var pinnedTrackers: [TrackerCategory] = []
    private var records: [TrackerRecord] = []
    private var filter = "today"
    private let dateFormatter = DateFormatter()
    
    private let collectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewFlowLayout()
        )
        collectionView.isScrollEnabled = true
        collectionView.register(TrackersCollectionViewCell.self, forCellWithReuseIdentifier: TrackersCollectionViewCell.identifier)
        collectionView.register(CollectionViewHeaders.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CollectionViewHeaders.identifier)
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        searchBar.delegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        categories = dataProvider.trackerMixes
        records = recordsProvider.records
        
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        
        currentDate = dateButton.date
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: dateButton)
        
        configureDisplay()
    }
    
    private func configureDisplay() {
        addTitle()
        addPlusButton()
        addSearchBar()
        addDateButton()
        checkTrackers()
    }
    
    private func configureFilterButton() {
        filterButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(filterButton)
        filterButton.backgroundColor = .yPblue
        filterButton.setTitle("Фильтры", for: .normal)
        filterButton.setTitleColor(.white, for: .normal)
        filterButton.titleLabel?.font = UIFont(name: "SFPro-Regular", size: 17)
        filterButton.layer.masksToBounds = true
        filterButton.layer.cornerRadius = 16
        filterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16).isActive = true
        filterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        filterButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        filterButton.widthAnchor.constraint(equalToConstant: 114).isActive = true
        filterButton.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
    }
    
    private func setupCollectionView() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 18).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 1).isActive = true
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 66, right: 0)
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    private func addTitle() {
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        label.font = UIFont(name: "SFPro-Bold", size: 34)
        label.text = "Трекеры"
        label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 1).isActive = true
        label.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
    }
    
    private func addPlusButton() {
        button.setTitle("+", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont(name: "SFPro-Regular", size: 34)
        button.widthAnchor.constraint(equalToConstant: 44).isActive = true
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        button.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
    }
    
    private func addSearchBar() {
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchBar)
        searchBar.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 7).isActive = true
        searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        searchBar.placeholder = "Поиск"
        searchBar.heightAnchor.constraint(equalToConstant: 36).isActive = true
    }
    
    private func addDateButton() {
        dateButton.addTarget(self, action: #selector(changeDate), for: .valueChanged)
        dateButton.widthAnchor.constraint(equalToConstant: 110).isActive = true
    }
    
    private func tempEventOrHabit(date: String) -> Bool {
        let digitsSet = CharacterSet(charactersIn: "123456789")
        if date.rangeOfCharacter(from: digitsSet) != nil {
            return true
        }
        return false
    }
    
    private func checkTrackers() {
        func checkTrackersEvent(tr: Tracker, trackersOnCollection: inout [Tracker]) {
            if tempEventOrHabit(date: tr.schedule) {
                if tr.schedule == selectedDate {
                    if filter == "completed" {
                        for record in records {
                            if record.id == tr.id && record.date == selectedDate {
                                trackersOnCollection.append(tr)
                            }
                        }
                    } else if filter == "notCompleted" {
                        var setOfCompletedTrackers = Set<UUID>()
                        for record in records {
                            if record.date == selectedDate || record.date == dayName {
                                setOfCompletedTrackers.insert(record.id)
                            }
                        }
                        if !setOfCompletedTrackers.contains(tr.id) {
                            trackersOnCollection.append(tr)
                        }
                    } else {
                        trackersOnCollection.append(tr)
                    }
                }
            } else {
                let wordsArray = tr.schedule.components(separatedBy: " ")
                for s in wordsArray {
                    if s == dayName {
                        if filter == "completed" {
                            for record in records {
                                if record.id == tr.id && record.date == selectedDate {
                                    trackersOnCollection.append(tr)
                                }
                            }
                        } else if filter == "notCompleted" {
                            var setOfCompletedTrackers = Set<UUID>()
                            for record in records {
                                if record.date == selectedDate || record.date == dayName {
                                    setOfCompletedTrackers.insert(record.id)
                                }
                            }
                            if !setOfCompletedTrackers.contains(tr.id) {
                                trackersOnCollection.append(tr)
                            }
                        } else {
                            trackersOnCollection.append(tr)
                        }
                    }
                }
            }
        }
        
        trackersCategoriesOnCollection = []
        
        let dateFormatterDay = DateFormatter()
        dateFormatterDay.dateFormat = "EEEE"
        let dayName = dateFormatterDay.string(from: currentDate)
        
        let selectedDate = dateFormatter.string(from: currentDate)
        
        var pinCategory = TrackerCategory(name: "Закрепленные", trackers: [])
        
        for cat in categories {
            for tr in cat.trackers {
                if tr.pin {
                    pinCategory.trackers.append(tr)
                }
            }
        }
        
        if !pinCategory.trackers.isEmpty {
            trackersCategoriesOnCollection.append(pinCategory)
        }
        
        for cat in categories {
            var trackersOnCollection: [Tracker] = []
            var tempCat = TrackerCategory(name: cat.name, trackers: [])
            
            for tr in cat.trackers {
                if !tr.pin {
                    checkTrackersEvent(tr: tr, trackersOnCollection: &trackersOnCollection)
                }
            }
            
            if !trackersOnCollection.isEmpty {
                tempCat = TrackerCategory(name: tempCat.name, trackers: trackersOnCollection)
                trackersCategoriesOnCollection.append(tempCat)
            }
        }
        
        setupCollectionView()
        
        if trackersCategoriesOnCollection.isEmpty {
            addCentrePictures()
            addCentreText()
            deleteFilterButton()
        } else {
            deleteCentre()
            configureFilterButton()
        }
        
        collectionView.reloadData()
    }
    
    private func addCentrePictures() {
        let image = UIImage(named: "Star")
        imageView = UIImageView(image: image)
        view.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    private func addCentreText() {
        centreText.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(centreText)
        centreText.text = "Что будем отслеживать?"
        centreText.font = UIFont(name: "SFPro-Medium", size: 12)
        centreText.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8).isActive = true
        centreText.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    func deleteCentre() {
        centreText.removeFromSuperview()
        imageView.removeFromSuperview()
    }
    
    func deleteFilterButton() {
        filterButton.removeFromSuperview()
    }
    
    func didTapAddButton(on cell: TrackersCollectionViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        addNewRecord(indexPath: indexPath)
        checkTrackers()
    }
    
    func didRetapAddButton(on cell: TrackersCollectionViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        deleteRecord(indexPath: indexPath)
        checkTrackers()
    }
    
    private func addNewRecord(indexPath: IndexPath) {
        let formattedDate = dateFormatter.string(from: currentDate)
        
        let uuid = trackersCategoriesOnCollection[indexPath.section].trackers[indexPath.row].id
        guard let tracker = dataProvider.findTracker(at: indexPath, id: uuid) else { return }
        recordsProvider.add(date: formattedDate, uuid: uuid, tracker: tracker)
    }
    
    private func deleteRecord(indexPath: IndexPath){
        let formattedDate = dateFormatter.string(from: currentDate)
        let uuid = trackersCategoriesOnCollection[indexPath.section].trackers[indexPath.row].id
        
        recordsProvider.delete(id: uuid, date: formattedDate)
    }
    
    @objc private func changeDate() {
        currentDate = dateButton.date
        recordsProvider = TrackerRecordStore(delegate: self, currentDate: currentDate)
        dataProvider = TrackerStore(delegate: self, date: currentDate)
        categories = dataProvider.trackerMixes
        records = recordsProvider.records
        checkTrackers()
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func createButtonTapped() {
        let createTrackerViewController = CreateTrackerViewController()
        createTrackerViewController.delegate = self
        createTrackerViewController.currentDate = self.currentDate
        let navigationController = UINavigationController(rootViewController: createTrackerViewController)
        present(navigationController, animated: true)
    }
    
    
    @objc private func filterButtonTapped() {
        let createFilterViewController = FilterViewController(currentDate: dateFormatter.string(from: currentDate), delegate: self, filter: filter)
        let navigationController = UINavigationController(rootViewController: createFilterViewController)
        present(navigationController, animated: true)
    }
}

extension TrackersViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return trackersCategoriesOnCollection[section].trackers.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return trackersCategoriesOnCollection.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackersCollectionViewCell.identifier, for: indexPath) as? TrackersCollectionViewCell {
            let tracker = trackersCategoriesOnCollection[indexPath.section].trackers[indexPath.row]
            let uuid = trackersCategoriesOnCollection[indexPath.section].trackers[indexPath.row].id
            var recordDaysCount = 0
            var i = false
            for record in records{
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .medium
                dateFormatter.timeStyle = .none
                let formattedDate = dateFormatter.string(from: currentDate)
                if (uuid == record.id && record.date == formattedDate){
                    i = true
                }
                if (uuid == record.id) {
                    recordDaysCount += 1
                }
            }
            guard let category = dataProvider.fetchTrackerEntity(id: tracker.id)?.category else { return UICollectionViewCell() }
            cell.changeCell(color: tracker.color, emoji: tracker.emoji, title: tracker.name, daysCount: recordDaysCount, checkThisDayRecord: i, uuid: tracker.id, category: category, isPinned: tracker.pin)
            cell.dataProvider = dataProvider
            cell.presentDelegate = self
            cell.delegate = self
            return cell
        }
        assertionFailure("не найдена ячейка")
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CollectionViewHeaders.identifier, for: indexPath) as! CollectionViewHeaders
        let category = trackersCategoriesOnCollection[indexPath.section]
        header.configure(with: category.name)
        return header
    }
}

extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.bounds.width - 41) / 2, height: 148)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 12, left: 16, bottom: 0, right: 16)
    }
}

extension TrackersViewController: NewTrackerDelegate {
    func add(name: String, color: String, emoji: String, shedule: String, category: TrackerCategoryCoreData) {
        dataProvider.add(name: name, color: color, emoji: emoji, shedule: shedule, category: category)
    }
}

extension TrackersViewController: RecordProviderDelegate {
    func didUpdateRecords() {
        records = recordsProvider.records
        checkTrackers()
        collectionView.reloadData()
    }
}

extension TrackersViewController: CollectionViewProviderDelegate {
    func didUpdate() {
        categories = dataProvider.trackerMixes
        checkTrackers()
        collectionView.reloadData()
    }
}

extension TrackersViewController: UISearchTextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}

extension TrackersViewController: FilterChangeDelegate {
    func changeDataByFilter() {
        dateButton.date = Date()
        changeDate()
        checkTrackers()
    }
    
    func filterDidChange(filter: String) {
        self.filter = filter
        checkTrackers()
    }
}

extension TrackersViewController: TrackersCollectionViewCellDelegate {
    func presentViewController(navController: UINavigationController) {
        self.present(navController, animated: true)
    }
    func presentAlertController(alerController: UIAlertController) {
        self.present(alerController, animated: true, completion: nil)
    }
}

//extension TrackersViewController: UISearchBarDelegate {
//    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        categories = trackerStore.searchTracker(with: searchText)
//        checkTrackers()
//    }
//}
