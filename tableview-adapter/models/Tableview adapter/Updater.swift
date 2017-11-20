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

struct ChangeData {
    
    let type: AdapterChangeType
    let indexPath: IndexPath
    
    init(type: AdapterChangeType, at indexPath: IndexPath) {
        self.type = type
        self.indexPath = indexPath
    }
    
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

struct Changeset {
    
    private(set) var changes: [ChangeData]
    
    init(changes: [ChangeData] = []) {
        self.changes = changes
    }
    
    func changes(type: AdapterChangeType) -> [ChangeData] {
        return changes.filter { $0.type == type }
    }
    
    func indexPaths(type: AdapterChangeType) -> [IndexPath] {
        return changes(type: type).map { $0.indexPath }
    }
    
}

class Updater {
    
    var itemCounts: Int
    
    var appendingItems = [ConfiguratorType]()
    var updatingItems = Set<Int>()
    var removingItems = Set<Int>()
    
    init(itemsCount: Int = 0) {
        self.itemCounts = itemsCount
    }
    
    func reset() {
        appendingItems = []
        updatingItems = Set()
        removingItems = Set()
    }
    
    var changeset: Changeset {
        var changes = appendingItems.enumerated().map {
            return ChangeData(type: .insert,
                              at: IndexPath(row: self.itemCounts + $0.offset, section: 0))
        }
        changes.append(contentsOf: updatingItems.map { ChangeData(type: .update,
                                                                  at: IndexPath(row: $0, section: 0)) })
        changes.append(contentsOf: removingItems.map { ChangeData(type: .remove,
                                                                  at: IndexPath(row: $0, section: 0)) })
        return Changeset(changes: changes)
    }
    
}
