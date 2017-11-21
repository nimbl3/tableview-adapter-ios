//
//  HeightConfigurator.swift
//  tableview-adapter
//
//  Created by Pirush Prechathavanich on 11/21/17.
//  Copyright © 2017 Pirush Prechathavanich. All rights reserved.
//

import UIKit

protocol HeightConfigurator {
    
    func height(for configurator: ConfiguratorType, at indexPath: IndexPath) -> CGFloat
    func estimatedHeight(for configurator: ConfiguratorType, at indexPath: IndexPath) -> CGFloat
    
}

class RowHeightConfigurator: HeightConfigurator {
    
    typealias HeightBlock = (_ configurator: ConfiguratorType, _ indexPath: IndexPath) -> CGFloat
    
    var heightBlock: HeightBlock?
    var estimatedHeightBlock: HeightBlock?
    
    init(height: HeightBlock? = nil, estimatedHeight: HeightBlock? = nil) {
        heightBlock = height
        estimatedHeightBlock = estimatedHeight
    }
    
    func height(for configurator: ConfiguratorType, at indexPath: IndexPath) -> CGFloat {
        return heightBlock?(configurator, indexPath) ?? UITableViewAutomaticDimension
    }
    
    func estimatedHeight(for configurator: ConfiguratorType, at indexPath: IndexPath) -> CGFloat {
        return estimatedHeightBlock?(configurator, indexPath) ?? UITableViewAutomaticDimension
    }
    
}
