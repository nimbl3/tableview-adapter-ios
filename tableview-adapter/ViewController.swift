//
//  ViewController.swift
//  tableview-adapter
//
//  Created by Pirush Prechathavanich on 11/17/17.
//  Copyright © 2017 Pirush Prechathavanich. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var redButton: UIButton!
    @IBOutlet weak var greenButton: UIButton!
    @IBOutlet weak var blueButton: UIButton!
    
    private var tableViewAdapter: TableViewAdapter!
    private var configurators = MutableProperty<[ConfiguratorType]>([])
    private var dataAdapter = DataAdapter(sections: [
        Section(configurators:[
            Row(ImageTableViewCell.self, item: ImageViewModel()),
            Row(ImageTableViewCell.self, item: ImageViewModel()),
            Row(TextTableViewCell.self, item: TextViewModel(text: "BIG (tricked)")),
            Row(TextTableViewCell.self, item: TextViewModel()),
            Row(TextTableViewCell.self, item: TextViewModel())
        ]),
        Section(configurators:[
            Row(ImageTableViewCell.self, item: ImageViewModel()),
            Row(ImageTableViewCell.self, item: ImageViewModel(text: "BIG")),
            Row(TextTableViewCell.self, item: TextViewModel())
        ]),
        Section(configurators:[
            Row(ImageTableViewCell.self, item: ImageViewModel(text: "BIG")),
            Row(ImageTableViewCell.self, item: ImageViewModel()),
            Row(TextTableViewCell.self, item: TextViewModel())
        ])
    ])
    
    // for testing purpose, used to test updating sections
    private var cachedSection: Section = Section(configurators: [
        Row(ImageTableViewCell.self, item: ImageViewModel(text: "update all image!")),
        Row(TextTableViewCell.self, item: TextViewModel(text: "update all text!")),
    ])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSections()
        setupTableView()
        setupTableViewAdapter()
        setupHeightConfigurator()
        setupButtons()
    }
    
    //MARK:- Private setup
    
    private func setupSections() {
        let redSection = dataAdapter.section(at: 0)
        redSection.headerView = HeaderView.red
        
        let greenSection = dataAdapter.section(at: 1)
        greenSection.headerView = HeaderView.green
        
        let blueSection = dataAdapter.section(at: 2)
        blueSection.headerView = HeaderView.blue
        
        cachedSection.headerView = HeaderView.gray
    }
    
    private func setupTableView() {
        tableView.tableFooterView = UIView()
        tableView.layer.cornerRadius = 12.0
        tableView.layer.borderWidth = 2.0
        tableView.layer.borderColor = UIColor.cloudGray.cgColor
        tableView.separatorColor = .cloudGray
    }
    
    private func setupHeightConfigurator() {
        let heightConfigurator = RowHeightConfigurator()
        heightConfigurator.heightBlock = { (configurator, _) -> CGFloat in
            if let item = configurator.item(of: ImageTableViewCell.self), item.text.contains("BIG") {
                return 100.0
            }
            return UITableViewAutomaticDimension
        }
        tableViewAdapter.heightConfigurator = heightConfigurator
    }
    
    private func setupTableViewAdapter() {
        tableViewAdapter = TableViewAdapter(for: tableView, dataAdapter: dataAdapter)
        //todo:- make adapter register its cells on init?
        tableViewAdapter.register(ImageTableViewCell.self)
        tableViewAdapter.register(TextTableViewCell.self)
        tableViewAdapter.didSelectCell
            .take(during: tableView.reactive.lifetime)
            .observeValues { (_, row, _) in
                guard let item = row.item(of: ImageTableViewCell.self) else { return }
                item.selected.value = !item.selected.value
        }
    }
    
    private func setupButtons() {
        redButton.layer.cornerRadius = 8.0
        greenButton.layer.cornerRadius = 8.0
        blueButton.layer.cornerRadius = 8.0
        redButton.reactive.controlEvents(.touchUpInside)
            .take(during: reactive.lifetime)
            .observeValues { [unowned self] _ in self.updateRow(at: 0) }
        greenButton.reactive.controlEvents(.touchUpInside)
            .take(during: reactive.lifetime)
            .observeValues { [unowned self] _ in self.swapSections() }
        blueButton.reactive.controlEvents(.touchUpInside)
            .take(during: reactive.lifetime)
            .observeValues { [unowned self] _ in self.updateAll() }
    }
    
    //MARK:- Test functions
    
    private func updateRow(at section: Int) {
        let newRow = Row(ImageTableViewCell.self, item: ImageViewModel(text: "added image"))
        var updatingList = dataAdapter.sections[section].configurators
        updatingList.remove(at: 2)
        updatingList.append(newRow)
        dataAdapter.update(with: updatingList, section: section)
    }
    
    private func swapSections() {
        dataAdapter.swap(from: dataAdapter.section(at: 0), to: dataAdapter.section(at: 1))
    }
    
    private func updateAll() {
        let section = cachedSection
//        section.append(dataAdapter.configurator(at: IndexPath(row: 1, section: 1)))
        var updatingSections = dataAdapter.sections
        cachedSection = dataAdapter.section(at: 1)
        updatingSections.replaceSubrange(1...1, with: [section])
        dataAdapter.update(with: updatingSections)
    }
    
}
