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


class DataAdapter {
    
    private(set) var configuratorsList: [ConfiguratorType]
    
    private let changePipe = Signal<Changeset, NoError>.pipe()
    private let replacePipe = Signal<Void, NoError>.pipe()
    private let updater: Updater
    
    let changeSignal: Signal<Changeset, NoError>
    let replaceSignal: Signal<Void, NoError>
    
    init(list: [ConfiguratorType] = []) {
        configuratorsList = list
        changeSignal = changePipe.output
        replaceSignal = replacePipe.output
        updater = Updater(itemsCount: list.count)
    }
    
    func append(_ configurator: ConfiguratorType) {
        updater.appendingItems.append(configurator)
    }
    
    func update(at index: Int) {
        updater.updatingItems.insert(index)
    }
    
    func update(_ configurator: ConfiguratorType) {
        if let index = configuratorsList.index(where: { $0 === configurator }) {
            updater.updatingItems.insert(index)
        }
    }
    
    func remove(at index: Int) {
        updater.removingItems.insert(index)
    }
    
    func remove(_ configurator: ConfiguratorType) {
        if let index = configuratorsList.index(where: { $0 === configurator }) {
            updater.removingItems.insert(index)
        }
    }
    
    func applyChanges() {
        configuratorsList = configuratorsList.enumerated()
            .flatMap {
                guard !self.updater.removingItems.contains($0.offset) else { return nil }
                return $0.element
        }
        configuratorsList.append(contentsOf: updater.appendingItems)
        //todo:- updater update configuratorsList first!
        changePipe.input.send(value: updater.changeset)
        updater.reset()
        updater.itemCounts = configuratorsList.count
    }
    
    func replace(with list: [ConfiguratorType]) {
        configuratorsList = list
        updater.itemCounts = list.count
        replacePipe.input.send(value: ())
    }
}
