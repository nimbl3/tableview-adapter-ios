//
//  TableViewAdapter.swift
//  tableview-adapter
//
//  Created by Pirush Prechathavanich on 11/17/17.
//  Copyright © 2017 Pirush Prechathavanich. All rights reserved.
//

import UIKit
import ReactiveSwift
import Result

//todo:- conform tableview adapter to scrollview adapter

class TableViewAdapter: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    private weak var tableView: UITableView!
    
    var configuratorsList: MutableProperty<[ConfiguratorType]>
    
    var list: [ConfiguratorType] { return configuratorsList.value }
    
    init(for tableView: UITableView, configuratorsList: MutableProperty<[ConfiguratorType]>) {
        self.tableView = tableView
        self.configuratorsList = configuratorsList
        super.init()
        tableView.delegate = self
        tableView.dataSource = self
        setup()
    }
    
    private func setup() {
        configuratorsList.signal
            .take(during: tableView.reactive.lifetime)
            .observeValues { [weak self] list in
                //todo:- use map function to make tableview update only changing cells
                self?.tableView.reloadData()
        }
    }
    
    //MARK:- tableview datasource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //todo:- support Section
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let configurator = list[indexPath.row]
        let cell = tableView.dequeueReusableCell(configurator.cellClass, for: indexPath)
        configurator.configure(cell)
        return cell
    }
    
    func register<T: UITableViewCell>(_ cellClass: T.Type) where T: Configurable {
        tableView.registerReusableCell(cellClass)
    }
    
    //MARK:- tableview delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    
}
