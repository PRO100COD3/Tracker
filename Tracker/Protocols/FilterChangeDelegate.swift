//
//  FilterChangeDelegate.swift
//  Tracker
//
//  Created by Вадим Дзюба on 26.09.2024.
//

import Foundation


protocol FilterChangeDelegate: AnyObject {
    func filterDidChange(filter: String)
}
