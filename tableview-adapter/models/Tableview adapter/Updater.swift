//
//  Updater.swift
//  tableview-adapter
//
//  Created by Pirush Prechathavanich on 11/17/17.
//  Copyright © 2017 Pirush Prechathavanich. All rights reserved.
//

import Foundation

enum AdapterChangeType {
    
    case insert
    case update
    case remove
    
}

struct Differ {
    
    let insertions: Set<Int>
    let updates: Set<Int>
    let deletions: Set<Int>
    
    init<T: AnyObject>(oldItems: [T], newItems: [T]) {
        insertions = Set(newItems
            .difference(from: oldItems)
            .flatMap { item in newItems.index(where: { $0 === item }) })
        //todo:- updating is not supported yet. use binding instead (for now)
        updates = Set<Int>()
        deletions = Set(oldItems
            .difference(from: newItems)
            .flatMap { item in oldItems.index(where: { $0 === item }) })
    }
    
    init(itemsCount: Int,
         appendingCount: Int = 0,
         insertions: [Int] = [],
         updates: [Int] = [],
         deletions: [Int] = []) {
        var totalInsertion = insertions
        for index in itemsCount..<itemsCount+appendingCount {
            totalInsertion.append(index)
        }
        self.insertions = Set(totalInsertion)
        self.updates = Set(updates)
        self.deletions = Set(deletions)
    }
    
    func indexPaths(of type: AdapterChangeType, section: Int = 0) -> [IndexPath] {
        switch type {
        case .insert:       return insertions.map { IndexPath(row: $0, section: section) }
        case .update:       return updates.map { IndexPath(row: $0, section: section) }
        case .remove:       return deletions.map { IndexPath(row: $0, section: section) }
        }
    }
    
}
