//
//  Configurable.swift
//  tableview-adapter
//
//  Created by Pirush Prechathavanich on 11/17/17.
//  Copyright © 2017 Pirush Prechathavanich. All rights reserved.
//

import UIKit

protocol Configurable: class {
    
    associatedtype ItemType
    
    static var height: CGFloat? { get }
    static var estimatedHeight: CGFloat? { get }
    
    func configure(with item: ItemType)
    
}

extension Configurable where Self: UITableViewCell {
    
    static var height: CGFloat? { return nil }
    static var estimatedHeight: CGFloat? { return nil }
    
}
