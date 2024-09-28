//
//  CategoryViewModel.swift
//  Tracker
//
//  Created by Вадим Дзюба on 24.09.2024.
//

import Foundation


typealias Binding<T> = (T) -> Void
final class CategoryViewModel {
    
    var categories = [TrackerCategoryCoreData]()
    var selectedCategory: TrackerCategoryCoreData?
    
    private lazy var dataProvider = TrackerCategoryStore(delegate: self)
    var onCategoriesUpdated: Binding<[TrackerCategoryCoreData]>?
    var onCategorySelected: Binding<TrackerCategoryCoreData?>?
    
    func loadCategories() {
        categories = dataProvider.categories
        onCategoriesUpdated?(categories)
    }
    
    func selectCategory(at index: Int) {
        selectedCategory = categories[index]
        onCategorySelected?(selectedCategory)
    }
    
    func indexPathFromeCoreData(category: TrackerCategoryCoreData) -> IndexPath{
        return dataProvider.indexPath(for: category) ?? IndexPath()
    }
    
    func isShouldShowPlaceholder() -> Bool {
        return categories.count != 0 ? true : false
    }
    
    func isLastCategory(index: Int) -> Bool {
        return categories.count - 1 == index
    }
}

extension CategoryViewModel: NewCategoryDelegate {
    func add(name title: String) {
        dataProvider.add(name: title)
        loadCategories()
    }
}

extension CategoryViewModel: CategoryProviderDelegate {
    func didUpdateCategories() {
        categories = dataProvider.categories
        onCategorySelected?(selectedCategory)
    }
}

extension CategoryViewModel: EditCategoryDelegate {
    func edit(name: String, index: IndexPath) {
        dataProvider.editCategory(indexPath: index, name: name)
        loadCategories()
    }
}
