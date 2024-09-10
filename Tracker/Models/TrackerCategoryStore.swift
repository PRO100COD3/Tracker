//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Вадим Дзюба on 25.08.2024.
//

import CoreData
import UIKit


struct CategoryStoreUpdate {
    let insertedIndexes: IndexSet
    let deletedIndexes: IndexSet
    let updatedIndexes: IndexSet
}

final class TrackerCategoryStore: NSObject{
    
    weak var delegate: TableViewProviderDelegate?
    //    weak var collectionDelegate: CollectionViewProviderDelegate?
    
    
    //    var trackerMixes: [TrackerCategory] {
    //        guard
    //            let objects = self.fetchedResultsControllerForCollectionView.fetchedObjects,
    //            let trackerMixes = try? objects.map({ try self.trackerMix(from: $0) })
    //        else { return [] }
    //        return trackerMixes
    //    }
    
    private let uiColorMarshalling = UIColorMarshalling()
    private var insertedIndexes: IndexSet?
    private var deletedIndexes: IndexSet?
    private var updatedIndexes: IndexSet?
    
    private var context: NSManagedObjectContext {
        (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData> = {
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
    
    //    private lazy var fetchedResultsControllerForCollectionView: NSFetchedResultsController<TrackerCategoryCoreData> = {
    //        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
    //        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
    //
    //        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
    //                                                                  managedObjectContext: context,
    //                                                                  sectionNameKeyPath: nil,
    //                                                                  cacheName: nil)
    //        fetchedResultsController.delegate = self
    //        try? fetchedResultsController.performFetch()
    //        return fetchedResultsController
    //    }()
    
    init(delegate: TableViewProviderDelegate) {
        self.delegate = delegate
    }
    
    //    init(collectionDelegate: CollectionViewProviderDelegate) {
    //        self.collectionDelegate = collectionDelegate
    //    }
    
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
    
    //    func trackerMix(from trackerCategoryCoreData: TrackerCategoryCoreData) throws -> TrackerCategory {
    //        guard let name = trackerCategoryCoreData.name else {
    //            assertionFailure("Нет названия категории в бд")
    //            return TrackerCategory(name: "", trackers: [])
    //        }
    //        guard let setTrackers = trackerCategoryCoreData.trackers else {
    //            assertionFailure("Нет трекеров в бд")
    //            return TrackerCategory(name: "", trackers: [])
    //        }
    //        let trackers = setTrackers.allObjects as! [Tracker]
    //
    //        return TrackerCategory(name: name, trackers: trackers)
    //        guard let emojies = trackerCoreData.emoji else {
    //            assertionFailure("Нет эмоджи в бд")
    //            return Tracker(id: UUID(), name: "", color: UIColor(), emoji: "", schedule: "")
    //        }
    //        guard let colorHex = trackerCoreData.color else {
    //            assertionFailure("Нет цвета в бд")
    //            return Tracker(id: UUID(), name: "", color: UIColor(), emoji: "", schedule: "")
    //        }
    //        guard let id = trackerCoreData.id else {
    //            assertionFailure("Нет id в бд")
    //            return Tracker(id: UUID(), name: "", color: UIColor(), emoji: "", schedule: "")
    //        }
    //        guard let schedule = trackerCoreData.schedule else {
    //            assertionFailure("Нет расписания в бд")
    //            return Tracker(id: UUID(), name: "", color: UIColor(), emoji: "", schedule: "")
    //        }
    //        guard let name = trackerCoreData.name else {
    //            assertionFailure("Нет названия в бд")
    //            return Tracker(id: UUID(), name: "", color: UIColor(), emoji: "", schedule: "")
    //        }
    //        return Tracker(id: id, name: name, color: uiColorMarshalling.color(from: colorHex), emoji: emojies, schedule: schedule)
    
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
    
    extension TrackerCategoryStore: CategoryProviderProtocol {
        var numberOfSections: Int {
            fetchedResultsController.sections?.count ?? 0
        }
        
        func numberOfRowsInSection(_ section: Int) -> Int {
            fetchedResultsController.sections?[section].numberOfObjects ?? 0
        }
        
        func object(at indexPath: IndexPath) -> TrackerCategoryCoreData? {
            fetchedResultsController.object(at: indexPath)
        }
        
        func add(name: String) {
            let newCategory = TrackerCategoryCoreData(context: context)
            newCategory.name = name
            newCategory.trackers = []
            saveContext()
        }
        
        func delete(record: NSManagedObject) {
            context.delete(record)
            saveContext()
        }
    }
    
    // MARK: - NSFetchedResultsControllerDelegate
    
    extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
        
        func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            if controller == fetchedResultsController {
                insertedIndexes = IndexSet()
                deletedIndexes = IndexSet()
                updatedIndexes = IndexSet()
            } else {
                
            }
        }
        
        func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            if controller == fetchedResultsController {
                guard let insertedIndexes = insertedIndexes,
                      let deletedIndexes = deletedIndexes,
                      let updatedIndexes = updatedIndexes else {
                    return
                }
                
                delegate?.didUpdate(CategoryStoreUpdate(insertedIndexes: insertedIndexes, deletedIndexes: deletedIndexes, updatedIndexes: updatedIndexes))
                
                self.insertedIndexes = nil
                self.deletedIndexes = nil
                self.updatedIndexes = nil
                
            } else {
                
            }
        }
        
        func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
            if controller == fetchedResultsController {
                
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
                    default:
                        break
                }
            } else {
                
            }
        }
    }
