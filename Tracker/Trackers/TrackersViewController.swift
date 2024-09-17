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
        
        categories = dataProvider.trackerMixes
        
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
        dateButton.addTarget(self, action: #selector(changeDate), for: .editingDidEnd)
        dateButton.widthAnchor.constraint(equalToConstant: 110).isActive = true
    }
    
    private func checkTrackers() {
        setupCollectionView()
        categories = TrackerStore(delegate: self, date: currentDate).trackerMixes
        collectionView.reloadData()
        if dataProvider.isContextEmpty(for: "TrackerCoreData") {
            addCentrePictures()
            addCentreText()
        } else {
            deleteCentre()
        }
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
    
    func didTapAddButton(on cell: TrackersCollectionViewCell) {
        
    }
    
    func didRetapAddButton(on cell: TrackersCollectionViewCell) {
        
    }
    
    @objc private func changeDate() {
        currentDate = dateButton.date
        dataProvider.currentDate = currentDate
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
}

extension TrackersViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories[section].trackers.count
        return dataProvider.numberOfRowsInSection(section)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return categories.count
        return dataProvider.numberOfSections
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackersCollectionViewCell.identifier, for: indexPath) as? TrackersCollectionViewCell else {
            assertionFailure("Cell not found")
            return UICollectionViewCell()
        }
        if !categories.isEmpty {
            let trackerCategory = categories[indexPath.section]
            let tracker = trackerCategory.trackers[indexPath.row]
            cell.changeCell(color: tracker.color, emoji: tracker.emoji, title: tracker.name, daysCount: 0, checkThisDayRecord: false)
            cell.delegate = self
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CollectionViewHeaders.identifier, for: indexPath) as! CollectionViewHeaders
        if !categories.isEmpty/*dataProvider.isContextEmpty(for: "TrackerCoreData")*/{
            let category = categories[indexPath.section]
            header.configure(with: category.name)
            return header
        }
        return header
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
        categories = dataProvider.trackerMixes
        collectionView.reloadData()
        collectionView.performBatchUpdates({
            if !update.insertedSections.isEmpty {
                collectionView.insertSections(update.insertedSections)
            }
            if !update.deletedSections.isEmpty {
                collectionView.deleteSections(update.deletedSections)
            }
            if !update.updatedSections.isEmpty {
                collectionView.reloadSections(update.updatedSections)
            }
            for move in update.movedSections {
                collectionView.moveSection(move.oldIndex, toSection: move.newIndex)
            }
            
            let insertedIndexPaths = update.insertedIndexes.map { IndexPath(item: $0, section: 0) }
            let deletedIndexPaths = update.deletedIndexes.map { IndexPath(item: $0, section: 0) }
            let updatedIndexPaths = update.updatedIndexes.map { IndexPath(item: $0, section: 0) }
            
            collectionView.insertItems(at: insertedIndexPaths)
            collectionView.deleteItems(at: deletedIndexPaths)
            collectionView.reloadItems(at: updatedIndexPaths)
            
            for move in update.movedIndexes {
                collectionView.moveItem(at: IndexPath(item: move.oldIndex, section: 0), to: IndexPath(item: move.newIndex, section: 0))
            }
        }, completion: nil)
    }
}
