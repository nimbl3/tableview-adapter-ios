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
    
    private let rowChangePipe = Signal<Changeset, NoError>.pipe()
    private let sectionChangePipe = Signal<Changeset, NoError>.pipe()
    private let replacePipe = Signal<Void, NoError>.pipe()
    
    let rowChangeSignal: Signal<Changeset, NoError>
    let sectionChangeSignal: Signal<Changeset, NoError>
    let replaceSignal: Signal<Void, NoError>
    
    init(sections: [Section] = []) {
        self.sections = sections
        rowChangeSignal = rowChangePipe.output
        sectionChangeSignal = sectionChangePipe.output
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
    
    private(set) var sectionForIndexTitles: [String: Int] = [:]
    
    var indexTitles: [String]? {
        sectionForIndexTitles = [:]
        var titles: [String] = []
        sections.enumerated().forEach {
            if let title = $1.indexTitle {
                titles.append(title)
                sectionForIndexTitles[title] = $0
            }
        }
        guard !titles.isEmpty else { return nil }
        return titles
    }
    
    //MARK:- Data updating - row
    
    func append(_ newConfigurators: [ConfiguratorType], section: Int) {
        let selectedSection = sections[section]
        let differ = Differ(itemsCount: selectedSection.numberOfConfigurators,
                            appendingCount: newConfigurators.count,
                            section: section)
        selectedSection.configurators.append(contentsOf: newConfigurators)
        rowChangePipe.input.send(value: differ)
    }
    
    func update(with newConfiguratorsList: [ConfiguratorType], section: Int) {
        let selectedSection = sections[section]
        let newItems: [AnyObject] = newConfiguratorsList
        let differ = Differ(oldItems: selectedSection.configurators,
                            newItems: newItems,  //todo:- fix this, hacked to compile
                            section: section)
        selectedSection.configurators = newConfiguratorsList
        rowChangePipe.input.send(value: differ)
    }
    
    //MARK:- Data updating - section
    
    func update(with newSections: [Section]) {
        let differ = Differ(oldSections: sections, newSections: newSections)
        sections = newSections
        rowChangePipe.input.send(value: differ)
    }
    
    func replace(with newConfiguratorsList: [ConfiguratorType], section: Int) {
        sections[section].configurators = newConfiguratorsList
        replacePipe.input.send(value: ())
    }
    
}
