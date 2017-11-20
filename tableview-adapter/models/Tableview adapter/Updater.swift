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


struct Differ<T> {//}<T: Equatable> {
    
    let insertions: [Int]
    let updates: [Int]
    let deletions: [Int]
    
    typealias MatchingBlock = ((T, T) -> Bool)
    
    init(oldItems: [T], newItems: [T], matchingBlock: MatchingBlock) {
        insertions = newItems
            .difference(from: oldItems, matchingBlock: matchingBlock)
            .flatMap { item in newItems.index(where: { matchingBlock($0, item) }) }
        updates = oldItems
            .intersection(of: newItems, matchingBlock: matchingBlock)
            .flatMap { item in oldItems.index(where: { matchingBlock($0, item) }) }
        deletions = oldItems
            .difference(from: newItems, matchingBlock: matchingBlock)
            .flatMap { item in oldItems.index(where: { matchingBlock($0, item) }) }
    }
    
//    init(currentItems: [T],
//         appendingItems: [T]? = nil,
//         updatingItems: [T]? = nil,
//         removingItems: [T]? = nil,
//         matchingBlock: MatchingBlock) {
//        insertions = currentItems
//            .
//    }
    
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
