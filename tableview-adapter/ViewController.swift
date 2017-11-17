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
        configurators.value = [
            Row(ImageTableViewCell.self, item: ImageViewModel()),
            Row(ImageTableViewCell.self, item: ImageViewModel()),
            Row(TextTableViewCell.self, item: TextViewModel()),
            Row(TextTableViewCell.self, item: TextViewModel())
        ]
        
        tableViewAdapter = TableViewAdapter(for: tableView, configuratorsList: configurators)
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
                self.configurators.value.append(newRow)
        }
    }
    
}


