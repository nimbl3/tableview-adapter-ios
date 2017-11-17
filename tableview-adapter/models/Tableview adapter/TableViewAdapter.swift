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

typealias CellWithIndexPath = (cell: UITableViewCell, indexPath: IndexPath)
typealias CellWithConfiguratorAndIndexPath = (cell: UITableViewCell, configurator: ConfiguratorType, indexPath: IndexPath)

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
    
    //MARK:- Adapter action signals
    
    private let actionPipe = Signal<AdapterActionType, NoError>.pipe()
    private let dataPipe = Signal<CellWithIndexPath, NoError>.pipe()
    private let dataWithConfiguratorPipe = Signal<CellWithConfiguratorAndIndexPath, NoError>.pipe()
    
    private(set) lazy var didSelectCell: Signal<CellWithConfiguratorAndIndexPath, NoError> = {
        return makeSignalWithConfigurator(action: .select)
    }()
    
    private(set) lazy var willDisplayCell: Signal<CellWithIndexPath, NoError> = {
        return makeSignal(action: .willDisplay)
    }()
    
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
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        actionPipe.input.send(value: .select)
        dataWithConfiguratorPipe.input.send(value: (cell, list[indexPath.row], indexPath))
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        actionPipe.input.send(value: .willDisplay)
        dataPipe.input.send(value: (cell, indexPath))
    }
    
    //MARK:- Private Factory
    
    private func makeSignal(action: AdapterActionType) -> Signal<CellWithIndexPath, NoError> {
        return actionPipe.output
            .filter { $0 == action }
            .sample(with: dataPipe.output)
            .map { ($1.cell, $1.indexPath) }
    }
    
    private func makeSignalWithConfigurator(action: AdapterActionType) -> Signal<CellWithConfiguratorAndIndexPath, NoError> {
        return actionPipe.output
            .filter { $0 == action }
            .sample(with: dataWithConfiguratorPipe.output)
            .map { $1 }
    }
    
}
