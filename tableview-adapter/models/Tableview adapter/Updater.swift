//
//  Differ.swift
//  tableview-adapter
//
//  Created by Pirush Prechathavanich on 11/17/17.
//  Copyright © 2017 Pirush Prechathavanich. All rights reserved.
//

import Foundation

struct Differ {
    
    var insertions = Set<IndexPath>()
    var updates = Set<IndexPath>()
    var deletions = Set<IndexPath>()
    
    //MARK:- Instantiation
    
    init<T: AnyObject>(oldItems: [T], newItems: [T], section: Int) {
        insertions = Set(newItems
            .difference(from: oldItems)
            .flatMap { item in newItems.index(where: { $0 === item }) }
            .map { IndexPath(row: $0, section: section) })
        //todo:- updating is not supported yet. use binding instead (for now)
        updates = Set<IndexPath>()
        deletions = Set(oldItems
            .difference(from: newItems)
            .flatMap { item in oldItems.index(where: { $0 === item }) }
            .map { IndexPath(row: $0, section: section)})
    }
    
    init(oldSections: [Section], newSections: [Section]) {
        let oldConfigurators = oldSections.totalConfigurators
        let newConfigurators = newSections.totalConfigurators
        insertions = Set((newConfigurators
            .difference(from: oldConfigurators) as [AnyObject])
            .flatMap { newSections.indexPath(of: $0) })
        updates = Set()
        deletions = Set((oldConfigurators
            .difference(from: newConfigurators) as [AnyObject])
            .flatMap { oldSections.indexPath(of: $0) })
    }
    
    init(itemsCount: Int,
         appendingCount: Int = 0,
         insertions: [Int] = [],
         updates: [Int] = [],
         deletions: [Int] = [],
         section: Int) {
        var totalInsertion = insertions
        for index in itemsCount..<itemsCount+appendingCount {
            totalInsertion.append(index)
        }
        self.insertions = Set(totalInsertion.map { IndexPath($0, in: section) })
        self.updates = Set(updates.map { IndexPath($0, in: section) })
        self.deletions = Set(deletions.map { IndexPath($0, in: section) })
    }
    
    //MARK:- Output
    
    func indexPaths(of type: AdapterChangeType) -> [IndexPath] {
        switch type {
        case .insert:       return insertions.map { $0 }
        case .update:       return updates.map { $0 }
        case .remove:       return deletions.map { $0 }
        }
    }
    
    func sections(of type: AdapterChangeType) -> IndexSet {
        switch type {
        case .insert:       return IndexSet(insertions.map { $0.section })
        case .update:       return IndexSet(updates.map { $0.section })
        case .remove:       return IndexSet(deletions.map { $0.section })
        }
    }
    
    //MARK:- Private helpers
    
    private func indexPath(for item: AnyObject, sections: [Section]) -> IndexPath? {
        let configurators = sections.totalConfigurators
        guard configurators.contains(where: { $0 === item }) else { return nil }
        
        for (index, section) in sections.enumerated() {
            if let rowIndex = section.index(of: item as! ConfiguratorType) {
                return IndexPath(row: rowIndex, section: index)
            }
        }
        return nil
    }
    
    private func indexPath(for configurator: ConfiguratorType, sections: [Section]) -> IndexPath? {
        let configurators = sections.totalConfigurators
        guard configurators.contains(where: { $0 === configurator }) else { return nil }
        
        for (index, section) in sections.enumerated() {
            if let rowIndex = section.index(of: configurator) {
                return IndexPath(row: rowIndex, section: index)
            }
        }
        return nil
    }
    
}

fileprivate extension Array where Element: Section {
    
    var totalConfigurators: [ConfiguratorType] {
        var configurators: [ConfiguratorType] = []
        forEach { configurators.append(contentsOf: $0.configurators) }
        return configurators
    }
    
    func indexPath(of item: AnyObject) -> IndexPath? {
        let configurators = totalConfigurators
        guard configurators.contains(where: { $0 === item }) else { return nil }
        
        for (index, section) in enumerated() {
            //todo:- force casting!
            if let rowIndex = section.index(of: item as! ConfiguratorType) {
                return IndexPath(rowIndex, in: index)
            }
        }
        return nil
    }
    
}
