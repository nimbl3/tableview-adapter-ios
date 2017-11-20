//
//  DataAdapter.swift
//  tableview-adapter
//
//  Created by Pirush Prechathavanich on 11/20/17.
//  Copyright © 2017 Pirush Prechathavanich. All rights reserved.
//

import ReactiveSwift
import Result

class DataAdapter {
    
    typealias Changeset = Differ<ConfiguratorType>
    
    private(set) var configuratorsList: [ConfiguratorType]
    
    private let changePipe = Signal<Changeset, NoError>.pipe()
    private let replacePipe = Signal<Void, NoError>.pipe()
//    private let updater: Updater
//    private let differ: Differ<ConfiguratorType>
    
    let changeSignal: Signal<Changeset, NoError>
    let replaceSignal: Signal<Void, NoError>
    
    init(list: [ConfiguratorType] = []) {
        configuratorsList = list
        changeSignal = changePipe.output
        replaceSignal = replacePipe.output
//        updater = Updater(itemsCount: list.count)
    }
    
    func update(with newConfiguratorsList: [ConfiguratorType]) {
        let differ = Differ(oldItems: configuratorsList,
                            newItems: newConfiguratorsList,
                            matchingBlock: { $0.isEqual($1) })
        configuratorsList = newConfiguratorsList
        changePipe.input.send(value: differ)
    }
    
    func replace(with newConfiguratorsList: [ConfiguratorType]) {
        configuratorsList = newConfiguratorsList
        replacePipe.input.send(value: ())
    }
    
//    func append(_ configurator: ConfiguratorType) {
//        updater.appendingItems.append(configurator)
//    }
//
//    func update(at index: Int) {
//        updater.updatingItems.insert(index)
//    }
//
//    func update(_ configurator: ConfiguratorType) {
//        if let index = configuratorsList.index(where: { $0 === configurator }) {
//            updater.updatingItems.insert(index)
//        }
//    }
//
//    func remove(at index: Int) {
//        updater.removingItems.insert(index)
//    }
//
//    func remove(_ configurator: ConfiguratorType) {
//        if let index = configuratorsList.index(where: { $0 === configurator }) {
//            updater.removingItems.insert(index)
//        }
//    }
    
//    func applyChanges() {
//        configuratorsList = configuratorsList.enumerated()
//            .flatMap {
//                guard !self.updater.removingItems.contains($0.offset) else { return nil }
//                return $0.element
//        }
//        configuratorsList.append(contentsOf: updater.appendingItems)
//        //todo:- updater update configuratorsList first!
//        changePipe.input.send(value: updater.changeset)
//        updater.reset()
//        updater.itemCounts = configuratorsList.count
//
//    }
    
//    func replace(with list: [ConfiguratorType]) {
//        configuratorsList = list
//        updater.itemCounts = list.count
//        replacePipe.input.send(value: ())
//    }
    
}
