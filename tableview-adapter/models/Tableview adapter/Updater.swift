//
//  Updater.swift
//  tableview-adapter
//
//  Created by Pirush Prechathavanich on 11/17/17.
//  Copyright © 2017 Pirush Prechathavanich. All rights reserved.
//

import ReactiveSwift
import Result

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
