//
//  ViewController.swift
//  Tracker
//
//  Created by Вадим Дзюба on 25.06.2024.
//

import UIKit
import CoreData

class TrackersViewController: UIViewController, TrackerRecordProtocol {
    
    private lazy var dataProvider = TrackerStore()
    private lazy var recordsProvider = TrackerRecordStore()
    private var imageView = UIImageView()
    private var button = UIButton(type: .system)
    private var filterButton = UIButton(type: .system)
    private let label = UILabel()
    private let centreText = UILabel()
    private let searchBar = {
        let textField = UISearchTextField()
        textField.placeholder = NSLocalizedString("trackersSearchBarPlaceholder", comment: "Поиск")
        let placeholderColor = UIColor.ypBack
        textField.attributedPlaceholder = NSAttributedString(string: textField.placeholder ?? "", attributes: [.foregroundColor: placeholderColor])
        return textField
    }()
    private let dateButton: UIDatePicker = {
        let picker = UIDatePicker()
        picker.locale = Locale(identifier: "ru_RU")
        picker.datePickerMode = .date
        picker.layer.masksToBounds = true
        picker.layer.cornerRadius = 8
        picker.overrideUserInterfaceStyle = .light
        picker.backgroundColor = .ypDatePicker
        picker.preferredDatePickerStyle = .compact
        return picker
    }()
    private var currentDate: Date = Date()
    private var categories: [TrackerCategory] = []
    private var trackersCategoriesOnCollection: [TrackerCategory] = []
    private var pinnedTrackers: [TrackerCategory] = []
    private var records: [TrackerRecord] = []
    private var filter = "all"
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
        view.backgroundColor = .ypBackground
        searchBar.delegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        categories = dataProvider.trackerMixes
        records = recordsProvider.records
        
        dataProvider.delegate = self
        recordsProvider.delegate = self
        
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        dateFormatter.locale = Locale(identifier: "en_GB")
        dateButton.locale = Locale(identifier: "en_GB")
        
        currentDate = dateButton.date
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: dateButton)
        
        configureDisplay()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let params: AnalyticsEventParam = ["screen": "Main"]
        AnalyticsService.report(event: "open", params: params)
        print("Зарегистрировано событие аналитики 'open' c параметрами \(params)")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        let params: AnalyticsEventParam = ["screen": "Main"]
        AnalyticsService.report(event: "close", params: params)
        print("Зарегистрировано событие аналитики 'close' с параметрами \(params)")
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
        filterButton.setTitle(NSLocalizedString("filterButtonTitle", comment: "Фильтры"), for: .normal)
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
        collectionView.backgroundColor = .ypBackground
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
        label.textColor = UIColor.label
        label.font = UIFont(name: "SFPro-Bold", size: 34)
        label.text = NSLocalizedString("trackersTabBarItemTitle", comment: "Трекеры")
        label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 1).isActive = true
        label.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
    }
    
    private func addPlusButton() {
        button.setTitle("+", for: .normal)
        button.setTitleColor(UIColor.label, for: .normal)
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
        dateFormatterDay.locale = Locale(identifier: "en_GB")
        let dayName = dateFormatterDay.string(from: currentDate)
        
        let selectedDate = dateFormatter.string(from: currentDate)
        
        var pinCategory = TrackerCategory(name: NSLocalizedString("fixedTrackersSectionTitle", comment: "Закреплённые"), trackers: [])
        
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
            addCentrePictures(filter: filter)
            addCentreText(filter: filter)
            deleteFilterButton()
        } else {
            deleteCentre()
            configureFilterButton()
        }
        
        collectionView.reloadData()
    }
    
    private func addCentrePictures(filter: String) {
        if filter == "all" {
            let image = UIImage(named: "Star")
            imageView = UIImageView(image: image)
        } else {
            let image = UIImage(named: "FilterImage")
            imageView = UIImageView(image: image)
        }
        view.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    private func addCentreText(filter: String) {
        if filter == "all" {
            centreText.text = NSLocalizedString("trackersStubImageLabelText", comment: "Что будем отслеживать?")
        } else {
            centreText.text = NSLocalizedString("trackersStubEmptyFilterLabelText", comment: "Ничего не найдено")
        }
        centreText.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(centreText)
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
        guard let trackerId = cell.id else { return }
        addNewRecord(trackerId: trackerId)
        checkTrackers()
    }
    
    func didRetapAddButton(on cell: TrackersCollectionViewCell) {
        guard let trackerId = cell.id else { return }
        deleteRecord(trackerId: trackerId)
        checkTrackers()
    }
    
    private func findTracker(byID id: UUID) -> TrackerCoreData? {
        for category in trackersCategoriesOnCollection {
            if let tracker = category.trackers.first(where: { $0.id == id }) {
                return dataProvider.fetchTrackerEntity(id: tracker.id)
            }
        }
        return nil
    }
    
    private func addNewRecord(trackerId: UUID) {
        let params: AnalyticsEventParam = ["screen": "Main", "item" : "track"]
        AnalyticsService.report(event: "AddClick", params: params)
        print("Зарегистрировано событие аналитики 'AddClick' с параметрами \(params)")
        let formattedDate = dateFormatter.string(from: currentDate)
        guard let tracker = findTracker(byID: trackerId) else { return }
        recordsProvider.add(date: formattedDate, uuid: trackerId, tracker: tracker)
    }
    
    private func deleteRecord(trackerId: UUID) {
        let params: AnalyticsEventParam = ["screen": "Main", "item" : "track"]
        AnalyticsService.report(event: "DeleteClick", params: params)
        print("Зарегистрировано событие аналитики 'DeleteClick' с параметрами \(params)")
        let formattedDate = dateFormatter.string(from: currentDate)
        recordsProvider.delete(id: trackerId, date: formattedDate)
    }
    
    @objc private func changeDate() {
        currentDate = dateButton.date
        recordsProvider.currentDate = currentDate
        dataProvider.currentDate = currentDate
        categories = dataProvider.trackerMixes
        records = recordsProvider.records
        checkTrackers()
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func createButtonTapped() {
        let params: AnalyticsEventParam = ["screen": "Main", "item" : "add_track"]
        AnalyticsService.report(event: "click", params: params)
        print("Зарегистрировано событие аналитики 'click' с параметрами \(params)")
        let createTrackerViewController = CreateTrackerViewController()
        createTrackerViewController.delegate = self
        createTrackerViewController.currentDate = self.currentDate
        let navigationController = UINavigationController(rootViewController: createTrackerViewController)
        present(navigationController, animated: true)
    }
    
    
    @objc private func filterButtonTapped() {
        let params: AnalyticsEventParam = ["screen": "Main", "item" : "filter"]
        AnalyticsService.report(event: "click", params: params)
        print("Зарегистрировано событие аналитики 'click' с параметрами \(params)")
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
            cell.indexOfSection = indexPath
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

extension TrackersViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? string
        categories = dataProvider.searchTracker(text: currentText)
        checkTrackers()
        return true
    }
}
