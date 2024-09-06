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

    weak var delegate: TrackerProviderDelegate?
    private let uiColorMarshalling = UIColorMarshalling()
    
    private var insertedIndexes: IndexSet?
    private var deletedIndexes: IndexSet?
    private var updatedIndexes: IndexSet?
    private var movedIndexes: Set<TrackerStoreUpdate.Move>?
    
    var emojiMixes: [Tracker] {
        guard
            let objects = self.fetchedResultsController.fetchedObjects,
            let emojiMixes = try? objects.map({ try self.trackerMix(from: $0) })
        else { return [] }
        return emojiMixes
    }
            
    private var context: NSManagedObjectContext {
        (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
        
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCoreData> = {
        let fetchRequest = TrackerCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: context,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        fetchedResultsController.delegate = self
        try? fetchedResultsController.performFetch()
        return fetchedResultsController
    }()
        
    init(delegate: TrackerProviderDelegate) {
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
    
    func trackerMix(from trackerCoreData: TrackerCoreData) throws -> Tracker {
        guard let emojies = trackerCoreData.emoji else {
            assertionFailure("Нет эмоджи в бд")
            return Tracker(id: UUID(), name: "", color: UIColor(), emoji: "", schedule: "")
        }
        guard let colorHex = trackerCoreData.color else {
            assertionFailure("Нет цвета в бд")
            return Tracker(id: UUID(), name: "", color: UIColor(), emoji: "", schedule: "")
        }
        guard let id = trackerCoreData.id else {
            assertionFailure("Нет id в бд")
            return Tracker(id: UUID(), name: "", color: UIColor(), emoji: "", schedule: "")
        }
        guard let schedule = trackerCoreData.schedule else {
            assertionFailure("Нет расписания в бд")
            return Tracker(id: UUID(), name: "", color: UIColor(), emoji: "", schedule: "")
        }
        guard let name = trackerCoreData.name else {
            assertionFailure("Нет названия в бд")
            return Tracker(id: UUID(), name: "", color: UIColor(), emoji: "", schedule: "")
        }
        return Tracker(id: id, name: name, color: uiColorMarshalling.color(from: colorHex), emoji: emojies, schedule: schedule)
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
        fetchedResultsController.sections?.count ?? 0
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func object(at indexPath: IndexPath) -> TrackerCoreData? {
        fetchedResultsController.object(at: indexPath)
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
