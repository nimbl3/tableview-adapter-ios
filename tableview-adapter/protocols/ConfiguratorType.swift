//
//  ConfiguratorType.swift
//  tableview-adapter
//
//  Created by Pirush Prechathavanich on 11/17/17.
//  Copyright © 2017 Pirush Prechathavanich. All rights reserved.
//

import UIKit

//todo:- check if we can remove `class`
protocol ConfiguratorType: class {
    
    var cellClass: UITableViewCell.Type { get }
    
    var height: CGFloat? { get }
    var estimatedHeight: CGFloat? { get }
    
    func configure(_ cell: UITableViewCell)
    
}

extension ConfiguratorType {
    
    func item<T: Configurable & UITableViewCell>(of _: T.Type) -> T.ItemType? {
        if let item = (self as? Row<T>)?.item {
            return item
        }
        return nil
    }
    
}
