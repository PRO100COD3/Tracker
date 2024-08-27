//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Вадим Дзюба on 25.08.2024.
//

import CoreData
import UIKit

public final class TrackerCategoryStore: NSObject, NSFetchedResultsControllerDelegate {
    
    public static let shared = TrackerCategoryStore()
    
    private var appDelegate: AppDelegate {
        UIApplication.shared.delegate as! AppDelegate
    }

    private var context: NSManagedObjectContext {
        appDelegate.persistentContainer.viewContext
    }

    private var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData>!

    var numberOfSections: Int {
        fetchedResultsController.sections?.count ?? 0
    }

    public override init() {
        super.init()

        let fetchRequest = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: false)]
        
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        controller.delegate = self
        self.fetchedResultsController = controller
        
        do {
            try controller.performFetch()
        } catch {
            print("Failed to fetch TrackerCategoryCoreData: \(error)")
        }
    }
    
    func simpleFetch() {
        // Создаём запрос.
        // Указываем, что хотим получить записи Author и ответ привести к типу Author.
        let request = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        // Выполняем запрос, используя контекст.
        // В результате получаем массив объектов Author.
        let authors = try? context.fetch(request)
        // Печатаем в консоль имена и год автора.
        authors?.forEach { print("\($0.name)") }
    }
    
    func addNewCategory(nameOfCategory: String) {
        let category = TrackerCategoryCoreData(context: context)
        category.name = nameOfCategory
        print("\(nameOfCategory)")
        appDelegate.saveContext()
    }
    
    func object(at indexPath: IndexPath) -> TrackerCategoryCoreData? {
        return fetchedResultsController.object(at: indexPath)
    }
    
    func fetchAllCategories() -> [TrackerCategory] {
        let fetchRequest = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            var result: [TrackerCategory]
            let categories = try context.fetch(fetchRequest)
            categories.forEach { cat in
                result.append(TrackerCategory(name: cat.name!, trackers: <#[Tracker]#>))
            }
            return result
        } catch {
            print("Failed to fetch TrackerCategoryCoreData: \(error)")
            return []
        }
    }

}
