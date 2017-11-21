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
    @IBOutlet weak var button: UIButton!
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSections()
        setupTableView()
        setupTableViewAdapter()
        setupHeightConfigurator()
        setupButton()
    }
    
    //MARK:- Private setup
    
    private func setupSections() {
        let redSection = dataAdapter.section(at: 0)
        redSection.headerView = HeaderView.red
        
        let greenSection = dataAdapter.section(at: 1)
        greenSection.headerView = HeaderView.green
        
        let blueSection = dataAdapter.section(at: 2)
        blueSection.headerView = HeaderView.blue
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
        heightConfigurator.heightBlock = { (configurator, indexPath) -> CGFloat in
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
    
    private func setupButton() {
        button.layer.cornerRadius = 8.0
        button.reactive.controlEvents(.touchUpInside)
            .take(during: reactive.lifetime)
            .observeValues { [unowned self] _ in
                let newRow = Row(ImageTableViewCell.self, item: ImageViewModel(text: "added image"))
                var updatingList = self.dataAdapter.sections[0].configurators
                updatingList.remove(at: 2)
                updatingList.append(newRow)
                self.dataAdapter.update(with: updatingList)
        }
    }
    
}
