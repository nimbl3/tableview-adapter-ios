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
    
    typealias Changeset = Differ
    
    private(set) var configuratorsList: [ConfiguratorType]
    
    private let changePipe = Signal<Changeset, NoError>.pipe()
    private let replacePipe = Signal<Void, NoError>.pipe()
    
    let changeSignal: Signal<Changeset, NoError>
    let replaceSignal: Signal<Void, NoError>
    
    init(list: [ConfiguratorType] = []) {
        configuratorsList = list
        changeSignal = changePipe.output
        replaceSignal = replacePipe.output
    }
    
    func append(_ newConfigurators: [ConfiguratorType]) {
        let differ = Differ(itemsCount: configuratorsList.count,
                            appendingCount: newConfigurators.count)
        configuratorsList = configuratorsList.appended(with: newConfigurators)
        changePipe.input.send(value: differ)
    }
    
    func update(with newConfiguratorsList: [ConfiguratorType]) {
        let differ = Differ(oldItems: configuratorsList, newItems: newConfiguratorsList)
        configuratorsList = newConfiguratorsList
        changePipe.input.send(value: differ)
    }
    
    func replace(with newConfiguratorsList: [ConfiguratorType]) {
        configuratorsList = newConfiguratorsList
        replacePipe.input.send(value: ())
    }
    
}
