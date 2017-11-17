//
//  Row.swift
//  tableview-adapter
//
//  Created by Pirush Prechathavanich on 11/17/17.
//  Copyright © 2017 Pirush Prechathavanich. All rights reserved.
//

import UIKit

struct Row<CellType: UITableViewCell>: ConfiguratorType where CellType: Configurable {
    
    let item: CellType.ItemType
    let cellClass: UITableViewCell.Type // = CellType.self
    
    init(_ cellClass: CellType.Type, item: CellType.ItemType) {
        self.item = item
        self.cellClass = cellClass
    }
    
    func configure(_ cell: UITableViewCell) {
        if let cell = cell as? CellType {
            cell.configure(with: item)
        }
    }
    
}
