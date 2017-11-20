//
//  Array+LogicalOperations.swift
//  tableview-adapter
//
//  Created by Pirush Prechathavanich on 11/20/17.
//  Copyright © 2017 Pirush Prechathavanich. All rights reserved.
//

import Foundation

extension Array {
    
    func appended(with addingArray: [Element]) -> [Element] {
        var result = self
        result.append(contentsOf: addingArray)
        return result
    }
    
    //MARK:- Any object
    
    func difference<T: AnyObject>(from otherArray: [T]) -> [T] {
        return self
            .flatMap { $0 as? T }
            .filter { element in !otherArray.contains(where: { $0 === element }) }
    }
    
    func intersection<T: AnyObject>(of otherArray: [T]) -> [T] {
        return self
            .flatMap { $0 as? T }
            .filter { element in otherArray.contains(where: { $0 === element }) }
    }
    
    //MARK:- Equatable element
    
    func difference<T: Equatable>(from otherArray: [T]) -> [T] {
        return self
            .flatMap { $0 as? T }
            .filter { !otherArray.contains($0) }
    }
    
    func intersection<T: Equatable>(of otherArray: [T]) -> [T] {
        return self
            .flatMap { $0 as? T }
            .filter { otherArray.contains($0) }
    }
    
    //MARK:- Any element
    
    func difference<T>(from otherArray: [T], matchingBlock: (T, T) -> Bool) -> [T] {
        return self
            .flatMap { $0 as? T }
            .filter { element in
                !otherArray.contains(where: { matchingBlock($0, element) })
        }
    }
    
    func intersection<T>(of otherArray: [T], matchingBlock: ((T, T) -> Bool)) -> [T] {
        return self
            .flatMap { $0 as? T }
            .filter { element in
                otherArray.contains(where: { matchingBlock($0, element) })
        }
    }
    
}
