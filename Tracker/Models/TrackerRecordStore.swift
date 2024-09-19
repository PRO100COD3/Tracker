//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Вадим Дзюба on 25.08.2024.
//

import CoreData
import UIKit


final class TrackerRecordStore: NSObject{
    private var context: NSManagedObjectContext {
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
    
    //var idOfSearching: UUID?
    weak var delegate: RecordProviderDelegate?
    var currentDate = Date()
    
//    var categories: [TrackerCategory] = []
    
    var records: [TrackerRecord] {
        guard let objects = fetchedResultsController?.fetchedObjects else { return [] }
        return objects.compactMap { try? self.recordMix(from: $0) }
    }
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerRecordCoreData>? = {
        let fetchRequest = TrackerRecordCoreData.fetchRequest()
//        
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateStyle = .medium
//        dateFormatter.timeStyle = .none
//        let formattedDate = dateFormatter.string(from: self.currentDate)
//        
//        let predicate = NSPredicate(format: "date == %@", formattedDate)
//        fetchRequest.predicate = predicate
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: context,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        fetchedResultsController.delegate = self
        try? fetchedResultsController.performFetch()
        return fetchedResultsController
    }()
    
    init(delegate: RecordProviderDelegate, currentDate: Date) {
        self.currentDate = currentDate
        self.delegate = delegate
    }
    
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
