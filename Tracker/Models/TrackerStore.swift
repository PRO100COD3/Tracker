//
//  TrackerStore.swift
//  Tracker
//
//  Created by Вадим Дзюба on 25.08.2024.
//

import CoreData
import UIKit

//struct TrackerStoreUpdate {
//    struct Move: Hashable {
//        let oldIndex: Int
//        let newIndex: Int
//    }
//    let insertedIndexes: IndexSet
//    let deletedIndexes: IndexSet
//    let updatedIndexes: IndexSet
//    let movedIndexes: Set<Move>
//    let insertedSections: IndexSet
//    let deletedSections: IndexSet
//    let updatedSections: IndexSet
//    let movedSections: Set<Move>
//}

final class TrackerStore: NSObject, NSFetchedResultsControllerDelegate {
    
    weak var delegate: CollectionViewProviderDelegate?
    private let uiColorMarshalling = UIColorMarshalling()
    var currentDate = Date()
    
//    private var insertedIndexes: IndexSet?
//    private var deletedIndexes: IndexSet?
//    private var updatedIndexes: IndexSet?
//    private var movedIndexes: Set<TrackerStoreUpdate.Move>?
//    
//    private var insertedSections: IndexSet?
//    private var deletedSections: IndexSet?
//    private var updatedSections: IndexSet?
//    private var movedSections: Set<TrackerStoreUpdate.Move>?
    
    var trackerMixes: [TrackerCategory] {
        guard let objects = fetchedResultsController?.fetchedObjects else { return [] }
        return objects.compactMap { try? self.trackerMix(from: $0) }
    }
    
    private var context: NSManagedObjectContext {
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData>? = {
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        let formattedDate = dateFormatter.string(from: self.currentDate)
        
        let predicate = NSPredicate(format: "ANY trackers.schedule == %@", formattedDate)
        fetchRequest.predicate = predicate
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: context,
                                                                  sectionNameKeyPath: "name",
                                                                  cacheName: nil)
        fetchedResultsController.delegate = self
        try? fetchedResultsController.performFetch()
        return fetchedResultsController
    }()
    
    init(delegate: CollectionViewProviderDelegate, date: Date) {
        self.delegate = delegate
        self.currentDate = date
    }
    
    func isContextEmpty(for entityName: String) -> Bool {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        let formattedDate = dateFormatter.string(from: self.currentDate)
        
        let predicate = NSPredicate(format: "schedule == %@", formattedDate)
        fetchRequest.predicate = predicate
        fetchRequest.fetchLimit = 1
        do {
            let count = try context.count(for: fetchRequest)
            return count == 0
        } catch {
            print("Ошибка при проверке данных в контексте: \(error)")
            return true
        }
    }
    
    func transformTrackerCoreDataToTracker(trackerCoreData: [TrackerCoreData]) -> [Tracker] {
        var result: [Tracker] = []
        for element in trackerCoreData {
            guard let emoji = element.emoji,
                  let colorHex = element.color,
                  let id = element.id,
                  let schedule = element.schedule,
                  let name = element.name else {
                assertionFailure("Некорректные данные из Core Data")
                return []
            }
            result.append(Tracker(id: id, name: name, color: uiColorMarshalling.color(from: colorHex), emoji: emoji, schedule: schedule))
        }
        return result
    }
    
    func trackerMix(from trackerCategoryCoreData: TrackerCategoryCoreData) throws -> TrackerCategory {
        guard let name = trackerCategoryCoreData.name, let setTrackers = trackerCategoryCoreData.trackers else {
            assertionFailure("Некорректные данные из Core Data")
            return TrackerCategory(name: "", trackers: [])
        }
        let trackersCoreData = setTrackers.allObjects as! [TrackerCoreData]
        let trackers = transformTrackerCoreDataToTracker(trackerCoreData: trackersCoreData)
        return TrackerCategory(name: name, trackers: trackers)
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
    
    // MARK: - NSFetchedResultsControllerDelegate
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        insertedIndexes = IndexSet()
//        deletedIndexes = IndexSet()
//        updatedIndexes = IndexSet()
//        movedIndexes = Set<TrackerStoreUpdate.Move>()
//        
//        insertedSections = IndexSet()
//        deletedSections = IndexSet()
//        updatedSections = IndexSet()
//        movedSections = Set<TrackerStoreUpdate.Move>()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        guard let insertedIndexes = insertedIndexes,
//              let deletedIndexes = deletedIndexes,
//              let updatedIndexes = updatedIndexes,
//              let movedIndexes = movedIndexes,
//              let insertedSections = insertedSections,
//              let deletedSections = deletedSections,
//              let updatedSections = updatedSections,
//              let movedSections = movedSections else {
//            return
//        }
        
        delegate?.didUpdate(/*TrackerStoreUpdate(insertedIndexes: insertedIndexes, deletedIndexes: deletedIndexes, updatedIndexes: updatedIndexes, movedIndexes: movedIndexes, insertedSections: insertedSections, deletedSections: deletedSections, updatedSections: updatedSections, movedSections: movedSections)*/)
        
//        self.insertedIndexes = nil
//        self.deletedIndexes = nil
//        self.updatedIndexes = nil
//        self.movedIndexes = nil
//        self.insertedSections = nil
//        self.deletedSections = nil
//        self.updatedSections = nil
//        self.movedSections = nil
    }
    
//    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
//        switch type {
//            case .insert:
//                insertedSections?.insert(sectionIndex)
//            case .delete:
//                deletedSections?.insert(sectionIndex)
//            case .update:
//                updatedSections?.insert(sectionIndex)
//            case .move:
//                // Handle section move if needed
//                break
//            default:
//                break
//        }
//    }
    
//    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
//        switch type {
//            case .insert:
//                if let newIndexPath = newIndexPath {
//                    insertedIndexes?.insert(newIndexPath.item)
//                }
//            case .delete:
//                if let indexPath = indexPath {
//                    deletedIndexes?.insert(indexPath.item)
//                }
//            case .update:
//                if let indexPath = indexPath {
//                    updatedIndexes?.insert(indexPath.item)
//                }
//            case .move:
//                if let oldIndexPath = indexPath, let newIndexPath = newIndexPath {
//                    movedIndexes?.insert(TrackerStoreUpdate.Move(oldIndex: oldIndexPath.item, newIndex: newIndexPath.item))
//                }
//            default:
//                break
//        }
//    }
}

extension TrackerStore: TrackerProviderProtocol {
    var numberOfSections: Int {
        return fetchedResultsController?.sections?.count ?? 0
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        guard let sectionInfo = fetchedResultsController?.sections?[section] else { return 0 }
        return trackerMixes[section].trackers.count
    }
    
    func object(at indexPath: IndexPath) -> TrackerCategoryCoreData? {
        fetchedResultsController?.object(at: indexPath)
    }
    
    func add(name: String, color: String, emoji: String, shedule: String, category: TrackerCategoryCoreData) {
        let newTracker = TrackerCoreData(context: context)
        newTracker.name = name
        newTracker.color = color
        newTracker.emoji = emoji
        newTracker.schedule = shedule
        newTracker.category = category
        newTracker.id = UUID()
        saveContext()
    }
    
    func delete(record: NSManagedObject) {
        context.delete(record)
        saveContext()
    }
}
