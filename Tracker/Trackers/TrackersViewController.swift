//
//  ViewController.swift
//  Tracker
//
//  Created by Вадим Дзюба on 25.06.2024.
//

import UIKit

class TrackersViewController: UIViewController, TrackerRecordProtocol {
    
    private lazy var dataProvider = TrackerStore(delegate: self, date: currentDate)
    private var imageView = UIImageView()
    private var button = UIButton(type: .system)
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
    private var completedTrackers: [TrackerRecord] = []
    private var trackers: [Tracker] = []
    private var trackersCategoryOnCollection: [TrackerCategory] = []
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
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        currentDate = dateButton.date
        trackersCategoryOnCollection = dataProvider.trackerMixes
        
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
    
    private func setupCollectionView() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 18).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 1).isActive = true
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
        button.setTitleColor(.yPblack, for: .normal)
        button.titleLabel?.font = UIFont(name: "SFPro-Regular", size: 34)
        button.widthAnchor.constraint(equalToConstant: 44).isActive = true
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        button.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
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
        dateButton.addTarget(self, action: #selector(changeDate), for: .editingDidEnd)
        dateButton.widthAnchor.constraint(equalToConstant: 110).isActive = true
    }
    
    func createNewTracker(name: String, schedule: String, category: TrackerCategory, emoji: String, color: UIColor) {
        let tracker = Tracker(id: UUID(), name: name, color: color, emoji: emoji, schedule: schedule)
        //trackers.append(tracker)
        
        if let index = categories.firstIndex(where: { $0.name == category.name }) {
            categories[index].addTracker(tracker: tracker)
        }
        checkTrackers()
    }
    
    private func addNewRecord(indexPath: IndexPath) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        let formattedDate = dateFormatter.string(from: currentDate)
        let uuid = trackersCategoryOnCollection[indexPath.section].trackers[indexPath.row].id
        
        if var record = completedTrackers.first(where: { $0.id == uuid && $0.date == formattedDate }) {
            record.daysCount += 1
        } else {
            let newRecord = TrackerRecord(id: uuid, date: formattedDate, daysCount: 1)
            completedTrackers.append(newRecord)
        }
    }
    
    private func deleteRecord(indexPath: IndexPath) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        let formattedDate = dateFormatter.string(from: currentDate)
        let uuid = trackersCategoryOnCollection[indexPath.section].trackers[indexPath.row].id
        
        if let index = completedTrackers.firstIndex(where: { $0.id == uuid && $0.date == formattedDate }) {
            if completedTrackers[index].daysCount > 1 {
                completedTrackers[index].daysCount -= 1
            } else {
                completedTrackers.remove(at: index)
            }
        }
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
    
    private func addTemporaryEvent(category: TrackerCategory) {
        trackersCategoryOnCollection.append(category)
    }
    
    private func checkTrackers() {
        //trackersCategoryOnCollection.removeAll()
        
        let dateFormatterDay = DateFormatter()
        dateFormatterDay.dateFormat = "EEEE"
        let dayName = dateFormatterDay.string(from: currentDate)
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        let formattedDate = dateFormatter.string(from: currentDate)
        
        categories.forEach { cat in
            var trackersOnCollection: [Tracker] = []
            cat.trackers.forEach { tr in
                let daysArray = tr.schedule.components(separatedBy: " ")
                if daysArray.contains(dayName) || daysArray.contains(formattedDate) {
                    trackersOnCollection.append(tr)
                }
            }
            if !trackersOnCollection.isEmpty {
                let tempCat = TrackerCategory(name: cat.name, trackers: trackersOnCollection)
                trackersCategoryOnCollection.append(tempCat)
            }
        }

        if dataProvider.isContextEmpty(for: "TrackerCoreData") {
            addCentrePictures()
            addCentreText()
        }
        else {
            setupCollectionView()
        }
        
        collectionView.reloadData()
    }
    
    @objc private func changeDate() {
        currentDate = dateButton.date
        checkTrackers()
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func createButtonTapped() {
        let createTrackerViewController = CreateTrackerViewController()
        createTrackerViewController.delegate = self
        createTrackerViewController.categories = self.categories
        //createTrackerViewController.trackers = self.trackers
        createTrackerViewController.currentDate = self.currentDate
        let navigationController = UINavigationController(rootViewController: createTrackerViewController)
        present(navigationController, animated: true)
    }
}

extension TrackersViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        dataProvider.numberOfRowsInSection(section)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        dataProvider.numberOfSections
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackersCollectionViewCell.identifier, for: indexPath) as? TrackersCollectionViewCell else {
            assertionFailure("Cell not found")
            return UICollectionViewCell()
        }
        let trackerCategory = dataProvider.object(at: indexPath)
        let trackers = dataProvider.fromCoreDataToTrackers(coreData: trackerCategory?.trackers ?? [])
        let tracker = trackers[indexPath.section]

        let uuid = tracker.id
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        let formattedDate = dateFormatter.string(from: currentDate)
        
        let recordDaysCount = completedTrackers.filter { $0.id == uuid }.reduce(0) { $0 + $1.daysCount }
        let checkThisDayRecord = completedTrackers.contains { $0.id == uuid && $0.date == formattedDate }
        
        cell.changeCell(color: tracker.color, emoji: tracker.emoji, title: tracker.name, daysCount: 0, checkThisDayRecord: false)
        cell.delegate = self
        return cell
//        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrackersCollectionViewCell", for: indexPath) as? TrackersCollectionViewCell else {
//                return UICollectionViewCell()
//            }
//            
//            let tracker = dataProvider.trackerMixes[indexPath.item]
//            cell.changeCell(tracker: tracker, checkThisDayRecord: false) /*(with: tracker)*/
//            
//            return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CollectionViewHeaders.identifier, for: indexPath) as! CollectionViewHeaders
        if !dataProvider.isContextEmpty(for: "TrackerCoreData"){
            let category = dataProvider.object(at: indexPath)
            header.configure(with: category?.name ?? "")
        }
        return header
    }
}

extension TrackersViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        addNewRecord(indexPath: indexPath)
    }
}

extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.bounds.width - 9) / 2, height: 148)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 52)
    }
}

extension TrackersViewController: NewTrackerDelegate {
    func add(name: String, color: String, emoji: String, shedule: String, category: TrackerCategoryCoreData) {
        dataProvider.add(name: name, color: color, emoji: emoji, shedule: shedule, category: category)
    }
}

extension TrackersViewController: CollectionViewProviderDelegate {
    func didUpdate(_ update: TrackerStoreUpdate) {
        checkTrackers()
        trackersCategoryOnCollection = dataProvider.trackerMixes
        collectionView.performBatchUpdates {
            let insertedIndexPaths = update.insertedIndexes.map { IndexPath(item: $0, section: 0) }
            let deletedIndexPaths = update.deletedIndexes.map { IndexPath(item: $0, section: 0) }
            let updatedIndexPaths = update.updatedIndexes.map { IndexPath(item: $0, section: 0) }
            
            collectionView.insertItems(at: insertedIndexPaths)
            collectionView.deleteItems(at: deletedIndexPaths)
            collectionView.reloadItems(at: updatedIndexPaths)
            
            for move in update.movedIndexes {
                collectionView.moveItem(
                    at: IndexPath(item: move.oldIndex, section: 0),
                    to: IndexPath(item: move.newIndex, section: 0)
                )
            }
        }
    }
}
