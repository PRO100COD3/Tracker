//
//  TrackerStore.swift
//  Tracker
//
//  Created by Вадим Дзюба on 25.08.2024.
//

import CoreData
import UIKit


final class TrackerStore: NSObject, NSFetchedResultsControllerDelegate {
    
    weak var delegate: CollectionViewProviderDelegate?
    private let uiColorMarshalling = UIColorMarshalling()
    var currentDate = Date()
    
    var trackerMixes: [TrackerCategory] {
        guard let objects = fetchedResultsController?.fetchedObjects else { return [] }
        var mixes = [TrackerCategory]()
        for object in objects {
            if let mix = try? self.trackerMix(from: object) {
                mixes.append(mix)
            }
        }
        return mixes
    }
    
    private var context: NSManagedObjectContext {
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData>? = {
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        let formattedDate = dateFormatter.string(from: currentDate)
        
        let dateFormatterDay = DateFormatter()
        dateFormatterDay.dateFormat = "EEEE"
        let dayName = dateFormatterDay.string(from: currentDate)
        
        let predicate = NSPredicate(format: "ANY trackers.schedule == %@", formattedDate)
        let dayPredicate = NSPredicate(format: "ANY trackers.schedule CONTAINS %@", dayName)
        let compoundPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [predicate, dayPredicate])
        fetchRequest.predicate = compoundPredicate
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: false)]
        
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
    
    func tempEventOrHabit(date: String) -> Bool {
        let digitsSet = CharacterSet(charactersIn: "123456789")
        if date.rangeOfCharacter(from: digitsSet) != nil {
            return true
        }
        return false
    }
    
    func addPin(tracker: TrackerCoreData) {
        tracker.pin = true
        saveContext()
        delegate?.didUpdate()
    }
    
    func deletePin(tracker: TrackerCoreData) {
        tracker.pin = false
        saveContext()
        delegate?.didUpdate()
    }
    
    func isHavePinnedCategory() -> Bool {
        for cat in trackerMixes {
            if cat.trackers.first(where: \.pin) != nil {
                return true
            }
        }
        return false
    }
    
    func isContextEmpty(for entityName: String) -> Bool {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        let formattedDate = dateFormatter.string(from: currentDate)
        
        let dateFormatterDay = DateFormatter()
        dateFormatterDay.dateFormat = "EEEE"
        let dayName = dateFormatterDay.string(from: currentDate)
        
        let predicate = NSPredicate(format: "schedule == %@", formattedDate)
        let dayPredicate = NSPredicate(format: "schedule CONTAINS %@", dayName)
        let compoundPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [predicate, dayPredicate])
        fetchRequest.predicate = compoundPredicate
        fetchRequest.fetchLimit = 1
        do {
            let count = try context.count(for: fetchRequest)
            return count == 0
        } catch {
            print("Ошибка при проверке данных в контексте: \(error)")
            return true
        }
    }
    
    func transformTrackerCoreDataToTracker(trackerCoreData: [TrackerCoreData?]) -> [Tracker] {
        var result: [Tracker] = []
        for element in trackerCoreData {
            guard let emoji = element?.emoji,
                  let colorHex = element?.color,
                  let id = element?.id,
                  let schedule = element?.schedule,
                  let name = element?.name,
                  let pin = element?.pin
            else {
                assertionFailure("Некорректные данные из Core Data")
                return []
            }
            result.append(Tracker(id: id, name: name, color: uiColorMarshalling.color(from: colorHex), emoji: emoji, schedule: schedule, pin: pin))
        }
        return result
    }
    
    func fetchTrackerEntity(id: UUID) -> TrackerCoreData? {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        
        let predicate = NSPredicate(format: "id == %@", id as CVarArg)
        fetchRequest.predicate = predicate
        
        do {
            let fetchedObjects = try context.fetch(fetchRequest)
            
            return fetchedObjects.first
        } catch {
            print("Ошибка при выполнении запроса: \(error)")
            return nil
        }
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
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdate()
    }
}

extension TrackerStore: TrackerProviderProtocol {
    var numberOfSections: Int {
        return fetchedResultsController?.sections?.count ?? 0
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        return trackerMixes[section].trackers.count
    }
    
    func findTracker(at indexPath: IndexPath, id: UUID) -> TrackerCoreData? {
        let newIndexPath = IndexPath(row: 0, section: indexPath.section)
        guard let category = fetchedResultsController?.object(at: newIndexPath) as? TrackerCategoryCoreData else {
            return nil
        }
        if let trackers = category.trackers as? Set<TrackerCoreData> {
            if let tracker = trackers.first(where: { $0.id == id }) {
                return tracker
            }
        }
        return nil
    }
    
    func object(at indexPath: IndexPath, id: UUID) -> TrackerCoreData? {
        guard let category = fetchedResultsController?.object(at: indexPath) as? TrackerCategoryCoreData else {
            return nil
        }
        
        if let trackers = category.trackers as? Set<TrackerCoreData> {
            if let tracker = trackers.first(where: { $0.id == id }) {
                return tracker
            }
        }
        return nil
    }
    
    func add(name: String, color: String, emoji: String, shedule: String, category: TrackerCategoryCoreData) {
        let newTracker = TrackerCoreData(context: context)
        newTracker.name = name
        newTracker.color = color
        newTracker.emoji = emoji
        newTracker.schedule = shedule
        newTracker.category = category
        newTracker.id = UUID()
        newTracker.pin = false
        saveContext()
    }
    
    func edit(tracker: TrackerCoreData, name: String, color: String, emoji: String, shedule: String, category: TrackerCategoryCoreData) {
        tracker.name = name
        tracker.color = color
        tracker.emoji = emoji
        tracker.schedule = shedule
        tracker.category = category
        saveContext()
        delegate?.didUpdate()
    }
    
    func delete(record: NSManagedObject) {
        context.delete(record)
        saveContext()
    }
}
