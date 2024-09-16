//
//  TrackerStore.swift
//  Tracker
//
//  Created by Вадим Дзюба on 25.08.2024.
//

import CoreData
import UIKit


struct TrackerStoreUpdate {
    struct Move: Hashable {
        let oldIndex: Int
        let newIndex: Int
    }
    let insertedIndexes: IndexSet
    let deletedIndexes: IndexSet
    let updatedIndexes: IndexSet
    let movedIndexes: Set<Move>
}

final class TrackerStore: NSObject{

    weak var delegate: CollectionViewProviderDelegate?
    private let uiColorMarshalling = UIColorMarshalling()
    var currentDate = Date()
    
    private var insertedIndexes: IndexSet?
    private var deletedIndexes: IndexSet?
    private var updatedIndexes: IndexSet?
    private var movedIndexes: Set<TrackerStoreUpdate.Move>?
    
    var trackerMixes: [TrackerCategory] {
        guard
            let objects = self.fetchedResultsController?.fetchedObjects,
            let trackerMixes = try? objects.map({ try self.trackerMix(from: $0) })
        else { return [] }
        return trackerMixes
    }
            
    private var context: NSManagedObjectContext {
        (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
        
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData>? = {
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        let formattedDate = dateFormatter.string(from: self.currentDate)
        
        //let daysArray = formattedDate.components(separatedBy: " ")
//        for s in daysArray {
//            if (s == dayName || s == formattedDate){
//                trackersOnCollection.append(tr)
//            }
//        }

        
        let predicate = NSPredicate(format: "ANY trackers.schedule == %@", formattedDate)

        fetchRequest.predicate = predicate

        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: context,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        fetchedResultsController.delegate = self
        try? fetchedResultsController.performFetch()
        return fetchedResultsController
    }()
        
    init(delegate: CollectionViewProviderDelegate, date: Date) {
        self.delegate = delegate
        self.currentDate = date
    }
    
    func addFetchResultController() {
        fetchedResultsController = {
            let fetchRequest = TrackerCategoryCoreData.fetchRequest()
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
            
            let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                      managedObjectContext: context,
                                                                      sectionNameKeyPath: nil,
                                                                      cacheName: nil)
            fetchedResultsController.delegate = self
            try? fetchedResultsController.performFetch()
            return fetchedResultsController
        }()
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
    
    func transformTrackerCoreDataToTracker (trackerCoreData: [TrackerCoreData]) -> [Tracker] {
        var result: [Tracker] = []
        for element in trackerCoreData {
            guard let emojie = element.emoji else {
                assertionFailure("Нет эмоджи в бд")
                return []
            }
            guard let colorHex = element.color else {
                assertionFailure("Нет цвета в бд")
                return []
            }
            guard let id = element.id else {
                assertionFailure("Нет id в бд")
                return []
            }
            guard let schedule = element.schedule else {
                assertionFailure("Нет расписания в бд")
                return []
            }
            guard let name = element.name else {
                assertionFailure("Нет названия в бд")
                return []
            }
            result.append(Tracker(id: id, name: name, color: uiColorMarshalling.color(from: colorHex), emoji: emojie, schedule: schedule))
        }
        return result
    }
    
    func trackerMix(from trackerCategoryCoreData: TrackerCategoryCoreData) throws -> TrackerCategory {
        guard let name = trackerCategoryCoreData.name else {
            assertionFailure("Нет названия категории в бд")
            return TrackerCategory(name: "", trackers: [])
        }
        guard let setTrackers = trackerCategoryCoreData.trackers else {
            assertionFailure("Нет трекеров в бд")
            return TrackerCategory(name: "", trackers: [])
        }
        let trackersCoreData = setTrackers.allObjects as! [TrackerCoreData]
        let trackers = transformTrackerCoreDataToTracker(trackerCoreData: trackersCoreData)
        return TrackerCategory(name: name, trackers: trackers)
    }
    
//    func fromCoreDataToTrackerCategory(coreData: NSSet) -> [TrackerCategory]{
//        var result: [TrackerCategory] = []
//        for category in coreData {
//            let cat = TrackerCategory(name: (category as AnyObject).name ?? "", trackers: fromCoreDataToTrackers(coreData: (category as AnyObject).trackers ?? []))
//            result.append(cat)
//        }
//        return result
//    }
//    
    func fromCoreDataToTrackers(coreData: NSSet) -> [Tracker] {
        var result: [Tracker] = []
        for tracker in coreData {
            let tr = Tracker(id: (tracker as AnyObject).id ?? UUID(), name: (tracker as AnyObject).name ?? "", color: uiColorMarshalling.color(from: (tracker as AnyObject).color ?? ""), emoji: (tracker as AnyObject).emoji ?? "", schedule: (tracker as AnyObject).schedule ?? "")
            result.append(tr)
        }
        return result
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

extension TrackerStore: TrackerProviderProtocol {
    
    var numberOfSections: Int {
        print(fetchedResultsController?.sections?.count ?? 0)
        return fetchedResultsController?.sections?.count ?? 0
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        //print(fetchedResultsController?.sections?[section].numberOfObjects ?? 0)
        return fetchedResultsController?.sections?[section].numberOfObjects ?? 0
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

extension TrackerStore: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexes = IndexSet()
        deletedIndexes = IndexSet()
        updatedIndexes = IndexSet()
        movedIndexes = Set<TrackerStoreUpdate.Move>()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let insertedIndexes = insertedIndexes,
              let deletedIndexes = deletedIndexes,
              let updatedIndexes = updatedIndexes,
              let movedIndexes = movedIndexes else {
            return
        }
        
        delegate?.didUpdate(TrackerStoreUpdate(insertedIndexes: insertedIndexes, deletedIndexes: deletedIndexes, updatedIndexes: updatedIndexes, movedIndexes: movedIndexes))
        
        self.insertedIndexes = nil
        self.deletedIndexes = nil
        self.updatedIndexes = nil
        self.movedIndexes = nil
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
            case .delete:
                if let indexPath = indexPath {
                    deletedIndexes?.insert(indexPath.item)
                }
            case .insert:
                if let indexPath = newIndexPath {
                    insertedIndexes?.insert(indexPath.item)
                }
            case .update:
                if let indexPath = indexPath {
                    updatedIndexes?.insert(indexPath.item)
                }
            case .move:
                guard let oldIndexPath = indexPath, let newIndexPath = newIndexPath else { fatalError() }
                movedIndexes?.insert(.init(oldIndex: oldIndexPath.item, newIndex: newIndexPath.item))
            default:
                break
        }
    }
}
