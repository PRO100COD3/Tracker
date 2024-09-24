//
//  CategoryViewModel.swift
//  Tracker
//
//  Created by Вадим Дзюба on 24.09.2024.
//

import Foundation


typealias Binding<T> = (T) -> Void

final class CategoryViewModel {    
    
    var categories: [TrackerCategoryCoreData] = []
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

