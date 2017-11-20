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
    private var dataAdapter = DataAdapter(list: [
        Row(ImageTableViewCell.self, item: ImageViewModel()),
        Row(ImageTableViewCell.self, item: ImageViewModel()),
        Row(TextTableViewCell.self, item: TextViewModel()),
        Row(TextTableViewCell.self, item: TextViewModel()),
        Row(TextTableViewCell.self, item: TextViewModel())
    ])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        setupTableViewAdapter()
        setupButton()
    }
    
    private func setupTableView() {
        tableView.tableFooterView = UIView()
        tableView.layer.cornerRadius = 12.0
    }
    
    private func setupTableViewAdapter() {
        tableViewAdapter = TableViewAdapter(for: tableView, dataAdapter: dataAdapter)
        //todo:- make adapter register its cells on init?
        tableViewAdapter.register(ImageTableViewCell.self)
        tableViewAdapter.register(TextTableViewCell.self)
        tableViewAdapter.didSelectCell
            .take(during: tableView.reactive.lifetime)
            .observeValues { (_, row, _) in
                guard let item = (row as? Row<ImageTableViewCell>)?.item else { return }
                item.selected.value = !item.selected.value
        }
    }
    
    private func setupButton() {
        button.layer.cornerRadius = 8.0
        button.reactive.controlEvents(.touchUpInside)
            .take(during: reactive.lifetime)
            .observeValues { [unowned self] _ in
                let newRow = Row(ImageTableViewCell.self, item: ImageViewModel(text: "added image"))
                var updatingList = self.dataAdapter.configuratorsList
                updatingList.remove(at: 2)
                updatingList.append(newRow)
                self.dataAdapter.update(with: updatingList)
        }
    }
    
}
