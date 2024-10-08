//
//  StatisticViewController.swift
//  Tracker
//
//  Created by Вадим Дзюба on 05.07.2024.
//

import UIKit


struct StatisticsCellViewModel {
    let title: String
    let value: Int
}

struct StatisticsElement {
    let type: StatisticsType
    let value: Int
}

enum StatisticsType: CustomStringConvertible {
    case bestPeriod
    case completedTrackers
    case averageTrackers
    case idealDaysCount
    
    var description: String {
        switch self {
            case .bestPeriod:
                return NSLocalizedString("statisticsTypeBestPeriod", comment: "Лучший период")
            case .completedTrackers:
                return NSLocalizedString("statisticsTypeCompleted", comment: "Трекеров завершено")
            case .averageTrackers:
                return NSLocalizedString("statisticsTypeAverage", comment: "Среднее значение")
            case .idealDaysCount:
                return NSLocalizedString("statisticsTypeIdealDaysCount", comment: "Идеальные дни")
        }
    }
}

final class StatisticsViewController: UIViewController {
    
    var trackerStore = TrackerStore.shared
    var trackerRecordStore = TrackerRecordStore.shared
    private var statistics: [StatisticsElement] = []
    private let label = UILabel()
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewFlowLayout()
        )
        collectionView.backgroundColor = .ypBackground
        collectionView.isScrollEnabled = false
        collectionView.register(StatisticsCollectionViewCell.self, forCellWithReuseIdentifier: StatisticsCollectionViewCell.Constants.identifier)
        return collectionView
    }()
    
    private lazy var statisticsStubImage: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.image = UIImage(named: "StatisticImage")
        image.contentMode = .center
        return image
    }()
    
    private lazy var statisticsStubImageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "SFPro-Medium", size: 12)
        label.textColor = .yPblack
        label.text = NSLocalizedString("statisticsStubImageLabelText", comment: "Анализировать пока нечего")
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBackground
        
        addTitle()
        setupCollectionView()
        calculateStatistics()
    }
    
    private func addTitle() {
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        label.font = UIFont(name: "SFPro-Bold", size: 34)
        label.text = NSLocalizedString("statisticsTabBarItemTitle", comment: "Статистика")
        label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 44).isActive = true
        label.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
    }
    
    private func setupCollectionView() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 77),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 126)
        ])
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        calculateStatistics()
    }
    
    private func calculateStatistics() {
        let bestPeriod = calculateBestPeriod()
        statistics = [
            StatisticsElement(type: .bestPeriod, value: bestPeriod),
            StatisticsElement(type: .completedTrackers, value: trackerRecordStore.getCompletedTrackerCount()),
            StatisticsElement(type: .averageTrackers, value: trackerRecordStore.getAverageTrackersCompletionPerDay()),
            StatisticsElement(type: .idealDaysCount, value: trackerRecordStore.getIdealCompletionDatesCount())
        ]
        
        if statistics.filter({ $0.value > 0 }).isEmpty {
            showStatistics()
        } else {
            hideStatistics()
        }
        
        collectionView.reloadData()
    }
    
    private func calculateBestPeriod() -> Int {
        let allCompletionDateStrings = trackerRecordStore.records
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        dateFormatter.locale = Locale(identifier: "en_GB")
        
        let allCompletionDates: [Date] = allCompletionDateStrings.compactMap { dateString in
            return dateFormatter.date(from: dateString.date)
        }
        
        guard !allCompletionDates.isEmpty else { return 0 }
        
        let sortedDates = allCompletionDates.sorted()
        
        var maxStreak = 1
        var currentStreak = 1
        
        for i in 1..<sortedDates.count {
            let previousDate = sortedDates[i - 1]
            let currentDate = sortedDates[i]
            
            if Calendar.current.isDate(currentDate, inSameDayAs: Calendar.current.date(byAdding: .day, value: 1, to: previousDate)!) {
                currentStreak += 1
            } else {
                maxStreak = max(maxStreak, currentStreak)
                currentStreak = 1
            }
        }
        
        return max(maxStreak, currentStreak)
    }
    
    private func showStatistics() {
        view.addSubview(statisticsStubImage)
        view.addSubview(statisticsStubImageLabel)
        NSLayoutConstraint.activate([
            statisticsStubImage.widthAnchor.constraint(equalToConstant: 80),
            statisticsStubImage.heightAnchor.constraint(equalToConstant: 80),
            statisticsStubImage.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            statisticsStubImage.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            statisticsStubImageLabel.topAnchor.constraint(equalTo: statisticsStubImage.bottomAnchor, constant: 8),
            statisticsStubImageLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor)
        ])
        collectionView.isHidden = true
    }
    
    private func hideStatistics() {
        statisticsStubImage.removeFromSuperview()
        statisticsStubImageLabel.removeFromSuperview()
        collectionView.reloadData()
        collectionView.isHidden = false
    }
}

extension StatisticsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return statistics.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: StatisticsCollectionViewCell.Constants.identifier,
            for: indexPath) as? StatisticsCollectionViewCell
        else {
            return UICollectionViewCell()
        }
        
        let statisticsItem = statistics[indexPath.row]
        let cellViewModel = StatisticsCellViewModel(
            title: statisticsItem.type.description,
            value: statisticsItem.value
        )
        cell.showCellViewModel(cellViewModel)
        return cell
    }
}

extension StatisticsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.frame.width - 32
        let cellWidth = availableWidth / CGFloat(1)
        return CGSize(width: cellWidth, height: 90)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 12
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
