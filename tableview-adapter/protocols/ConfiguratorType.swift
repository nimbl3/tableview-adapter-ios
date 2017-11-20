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
    
    func configure(_ cell: UITableViewCell)
    func isEqual(_ configurator: ConfiguratorType) -> Bool
    
}

extension ConfiguratorType {
    
    func isEqual(_ configurator: ConfiguratorType) -> Bool {
        return true //todo:- fix!
    }
    
}
