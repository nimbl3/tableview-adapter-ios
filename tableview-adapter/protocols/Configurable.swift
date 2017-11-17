//
//  Configurable.swift
//  tableview-adapter
//
//  Created by Pirush Prechathavanich on 11/17/17.
//  Copyright © 2017 Pirush Prechathavanich. All rights reserved.
//


protocol Configurable: class {
    
    associatedtype ItemType
    func configure(with item: ItemType)
    
}
