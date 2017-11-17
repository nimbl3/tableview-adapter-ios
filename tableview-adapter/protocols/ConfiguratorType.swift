//
//  ConfiguratorType.swift
//  tableview-adapter
//
//  Created by Pirush Prechathavanich on 11/17/17.
//  Copyright © 2017 Pirush Prechathavanich. All rights reserved.
//

import UIKit

protocol ConfiguratorType {
    
    var cellClass: UITableViewCell.Type { get }
    
    func configure(_ cell: UITableViewCell)
    
}
