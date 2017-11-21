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
        //todo:- guard input not over itemsCount
        self.insertions = Set(totalInsertion.map { IndexPath($0, in: section) })
        self.updates = Set(updates.map { IndexPath($0, in: section) })
        self.deletions = Set(deletions.map { IndexPath($0, in: section) })
    }
    
    init(sectionsCount: Int,
         appendingCount: Int = 0,
         insertions: [Int] = [],
         updates: [Int] = [],
         deletions: [Int] = []) {
        var totalInsertion = insertions
        for index in sectionsCount..<sectionsCount+appendingCount {
            totalInsertion.append(index)
        }
        //todo:- row 0 is mocked as it's not required, fix!
        self.insertions = Set(totalInsertion.map { IndexPath(0, in: $0) })
        self.updates = Set(updates.map { IndexPath(0, in: $0) })
        self.deletions = Set(deletions.map { IndexPath(0, in: $0) })
    }
    
    //todo:- incomplete, need to find a better way handle swapping real data
    //       without making it work twice (used to swap row with another row)
    init?(fromConfigurator: ConfiguratorType,
          to toConfigurator: ConfiguratorType,
          in sections: [Section]) {
        guard
            let fromIndexPath = sections.indexPath(of: fromConfigurator),
            let toIndexPath = sections.indexPath(of: toConfigurator)
        else { return }
        insertions = Set(arrayLiteral: fromIndexPath, toIndexPath)
        updates = Set()
        deletions = Set(arrayLiteral: fromIndexPath, toIndexPath)
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
