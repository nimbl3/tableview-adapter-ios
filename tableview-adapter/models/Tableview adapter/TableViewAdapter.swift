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
    
    let dataAdapter: DataAdapter
    
    var rowHeight: CGFloat? = nil
    var estimatedRowHeight: CGFloat? = nil
    var rowAnimation: UITableViewRowAnimation = .automatic
    
    init(for tableView: UITableView, dataAdapter: DataAdapter) {
        self.tableView = tableView
        self.dataAdapter = dataAdapter
        super.init()
        tableView.delegate = self
        tableView.dataSource = self
        setup()
    }
    
    private func setup() {
        dataAdapter.replaceSignal
            .take(during: tableView.reactive.lifetime)
            .observeValues { [weak self] _ in
                self?.tableView.reloadData()
        }
        dataAdapter.rowChangeSignal
            .take(during: tableView.reactive.lifetime)
            .observeValues { [weak self] changeset in
                guard let strongSelf = self else { return }
                strongSelf.tableView.beginUpdates()
                strongSelf.tableView.insertRows(at: changeset.indexPaths2(of: .insert),
                                                with: strongSelf.rowAnimation)
                strongSelf.tableView.reloadRows(at: changeset.indexPaths2(of: .update),
                                                with: strongSelf.rowAnimation)
                strongSelf.tableView.deleteRows(at: changeset.indexPaths2(of: .remove),
                                                with: strongSelf.rowAnimation)
                strongSelf.tableView.endUpdates()
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
    
    private(set) lazy var didEndDisplayingCell: Signal<CellWithIndexPath, NoError> = {
        return makeSignal(action: .didEndDisplaying)
    }()
    
    private(set) lazy var willSetItem: Signal<CellWithConfiguratorAndIndexPath, NoError> = {
        return makeSignalWithConfigurator(action: .willSetItem)
    }()
    
    private(set) lazy var didSetItem: Signal<CellWithConfiguratorAndIndexPath, NoError> = {
        return makeSignalWithConfigurator(action: .didSetItem)
    }()
    
    //MARK:- tableview datasource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataAdapter.numberOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataAdapter.numberOfRows(in: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let configurator = dataAdapter.configurator(at: indexPath)
        let cell = tableView.dequeueReusableCell(configurator.cellClass, for: indexPath)
        actionPipe.input.send(value: .willSetItem)
        dataWithConfiguratorPipe.input.send(value: (cell, configurator, indexPath))
        configurator.configure(cell)
        actionPipe.input.send(value: .didSetItem)
        dataWithConfiguratorPipe.input.send(value: (cell, configurator, indexPath))
        return cell
    }
    
    func register<T: UITableViewCell>(_ cellClass: T.Type) where T: Configurable {
        tableView.registerReusableCell(cellClass)
    }
    
    //MARK:- tableview datasource - index
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return dataAdapter.indexTitles
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return dataAdapter.sectionForIndexTitles[title] ?? 0
    }
    
    //MARK:- tableview delegate - height
    
    var heightConfigurator: HeightConfigurator?
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let configurator = dataAdapter.configurator(at: indexPath)
        
        return heightConfigurator?.height(for: configurator, at: indexPath)
            ?? configurator.height
            ?? rowHeight
            ?? tableView.rowHeight
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let configurator = dataAdapter.configurator(at: indexPath)
        return heightConfigurator?.estimatedHeight(for: configurator, at: indexPath)
            ?? configurator.estimatedHeight
            ?? estimatedRowHeight
            ?? tableView.estimatedRowHeight
    }
    
    //MARK:- tableview delegate - section
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return dataAdapter.section(at: section).headerTitle
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return dataAdapter.section(at: section).footerTitle
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return dataAdapter.section(at: section).headerView
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return dataAdapter.section(at: section).footerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let section = dataAdapter.section(at: section)
        return section.headerHeight ?? section.headerView?.frame.height ?? UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let section = dataAdapter.section(at: section)
        return section.footerHeight ?? section.footerView?.frame.height ?? UITableViewAutomaticDimension
    }
    
    //MARK:- tableview delegate - actions
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        actionPipe.input.send(value: .select)
        dataWithConfiguratorPipe.input.send(value: (cell, dataAdapter.configurator(at: indexPath), indexPath))
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        actionPipe.input.send(value: .willDisplay)
        dataPipe.input.send(value: (cell, indexPath))
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        actionPipe.input.send(value: .didEndDisplaying)
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
