//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Вадим Дзюба on 25.08.2024.
//

import CoreData
import UIKit


final class TrackerRecordStore: NSObject{
    
    static let shared = TrackerRecordStore()
    private var context: NSManagedObjectContext {
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
    
    weak var delegate: RecordProviderDelegate?
    var currentDate = Date()
    var trackerStore: TrackerStore?
    
    var records: [TrackerRecord] {
        guard let objects = fetchedResultsController?.fetchedObjects else { return [] }
        return objects.compactMap { try? self.recordMix(from: $0) }
    }
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerRecordCoreData>? = {
        let fetchRequest = TrackerRecordCoreData.fetchRequest()
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: context,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        fetchedResultsController.delegate = self
        try? fetchedResultsController.performFetch()
        return fetchedResultsController
    }()
    
    func isContextEmpty(for entityName: String) -> Bool {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        fetchRequest.fetchLimit = 1
        do {
            let count = try context.count(for: fetchRequest)
            return count == 0
        } catch {
            print("Ошибка при проверке данных в контексте: \(error)")
            return true
        }
    }
    
    func getCompletedTrackerCount() -> Int {
        return records.count
    }
    
    public func getAverageTrackersCompletionPerDay() -> Int {
        let dateDescription = NSExpressionDescription()
        dateDescription.name = "date"
        dateDescription.expression = NSExpression(forKeyPath: #keyPath(TrackerRecordCoreData.date))
        dateDescription.expressionResultType = .dateAttributeType
        
        let countDescription = NSExpressionDescription()
        countDescription.name = "trackersCount"
        countDescription.expression = NSExpression(forFunction: "count:", arguments: [NSExpression(forKeyPath: #keyPath(TrackerRecordCoreData.date))])
        countDescription.expressionResultType = .integer64AttributeType
        
        let completedTrackersCountRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TrackerRecordCoreData")
        completedTrackersCountRequest.propertiesToFetch = [dateDescription, countDescription]
        completedTrackersCountRequest.propertiesToGroupBy = [dateDescription]
        completedTrackersCountRequest.resultType = .dictionaryResultType
        
        guard let results = try? context.fetch(completedTrackersCountRequest) as? [[String: Any]] else {
            return 0
        }
        var datesCount = 0
        var totalTrackersCount = 0
        for result in results {
            if let trackersCount = result["trackersCount"] as? Int {
                totalTrackersCount += trackersCount
                datesCount += 1
            }
        }
        return Int(datesCount > 0 ? Double(totalTrackersCount) / Double(datesCount) : 0)
    }
    
    public func getIdealCompletionDatesCount() -> Int {
        let uniqueDates = records.compactMap { $0.date }
        let unDates = Set<String>(uniqueDates)
        var idealDaysCount = 0
        
        for date in unDates {
            if checkCompleteAtThatDay(at: date) {
                idealDaysCount += 1
            }
        }
        
        return idealDaysCount
    }
    
    func checkCompleteAtThatDay(at date: String) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        
        guard let dateFormat = dateFormatter.date(from: date) else {
            print("Неверный формат даты: \(date)")
            return false
        }
        
        let calendar = Calendar.current
        let dateWithoutTime = calendar.startOfDay(for: dateFormat)
        
        let fetchRequest = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
        
        let dateFormatterDay = DateFormatter()
        dateFormatterDay.dateFormat = "EEEE"
        let dayName = dateFormatterDay.string(from: dateWithoutTime)
        
        fetchRequest.predicate = NSPredicate(format: "ANY schedule CONTAINS %@", dayName)
        
        do {
            let trackers = try context.fetch(fetchRequest)
            
            if trackers.isEmpty {
                return false
            }
            
            for tracker in trackers {
                guard let trackerRecords = tracker.record as? Set<TrackerRecordCoreData> else {
                    return false
                }
                
                let isCompleted = trackerRecords.contains { trackerRecord in
                    if let recordDateString = trackerRecord.date,
                       let recordDate = dateFormatter.date(from: recordDateString) {
                        return calendar.isDate(recordDate, inSameDayAs: dateWithoutTime)
                    }
                    return false
                }
                
                if !isCompleted {
                    return false
                }
            }
            return true
        } catch {
            print("Ошибка при выполнении запроса: \(error)")
            return false
        }
    }
    
    
    func recordMix(from trackerRecordCoreData: TrackerRecordCoreData) throws -> TrackerRecord {
        guard let id = trackerRecordCoreData.id, let date = trackerRecordCoreData.date else {
            assertionFailure("Некорректные данные из Core Data")
            return TrackerRecord(id: UUID(), date: "")
        }
        return TrackerRecord(id: id, date: date)
    }
    
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Error saving context: \(error)")
            }
        }
    }
}

extension TrackerRecordStore: RecordProviderProtocol {
    func object(at indexPath: IndexPath) -> TrackerRecordCoreData? {
        fetchedResultsController?.object(at: indexPath)
    }
    
    func add(date: String, uuid: UUID, tracker: TrackerCoreData) {
        let record = TrackerRecordCoreData(context: context)
        record.date = date
        record.id = uuid
        record.tracker = tracker
        saveContext()
    }
    
    func delete(id: UUID, date: String) {
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@ AND date == %@", id as CVarArg, date)
        do {
            let results = try context.fetch(fetchRequest)
            
            if let trackerRecord = results.first {
                context.delete(trackerRecord)
            } else {
                print("Объект не найден")
            }
        } catch {
            print("Ошибка при выполнении запроса: \(error)")
        }
        saveContext()
    }
}
extension TrackerRecordStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdateRecords()
    }
}
