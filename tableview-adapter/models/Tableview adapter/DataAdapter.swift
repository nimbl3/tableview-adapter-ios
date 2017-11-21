//
//  DataAdapter.swift
//  tableview-adapter
//
//  Created by Pirush Prechathavanich on 11/20/17.
//  Copyright © 2017 Pirush Prechathavanich. All rights reserved.
//

import ReactiveSwift
import Result

//todo:- create a Protocol to limit access to this class

class DataAdapter {
    
    typealias Changeset = Differ
    
    private(set) var sections: [Section] = []
    
    private let changePipe = Signal<Changeset, NoError>.pipe()
    private let replacePipe = Signal<Void, NoError>.pipe()
    
    let changeSignal: Signal<Changeset, NoError>
    let replaceSignal: Signal<Void, NoError>
    
    init(sections: [Section] = []) {
        self.sections = sections
        changeSignal = changePipe.output
        replaceSignal = replacePipe.output
    }
    
    convenience init(list: [ConfiguratorType]) {
        self.init(sections: [Section(configurators: list)])
    }
    
    //MARK:- Datasource
    
    var numberOfSections: Int { return sections.count }
    
    func numberOfRows(in section: Int) -> Int {
        return sections[section].numberOfConfigurators
    }
    
    func section(at section: Int) -> Section {
        return sections[section]
    }
    
    func configurator(at indexPath: IndexPath) -> ConfiguratorType {
        return sections[indexPath.section].configurators[indexPath.row]
    }
    
    //MARK:- Data updating
    
    func append(_ newConfigurators: [ConfiguratorType], section: Int = 0) {
        let section = sections[section]
        let differ = Differ(itemsCount: section.numberOfConfigurators,
                            appendingCount: newConfigurators.count)
        section.configurators.append(contentsOf: newConfigurators)
        changePipe.input.send(value: differ)
    }
    
    func update(with newConfiguratorsList: [ConfiguratorType], section: Int = 0) {
        let section = sections[section]
        let differ = Differ(oldItems: section.configurators, newItems: newConfiguratorsList)
        section.configurators = newConfiguratorsList
        changePipe.input.send(value: differ)
    }
    
    func replace(with newConfiguratorsList: [ConfiguratorType], section: Int = 0) {
        sections[section].configurators = newConfiguratorsList
        replacePipe.input.send(value: ())
    }
    
}
