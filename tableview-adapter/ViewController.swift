//
//  ViewController.swift
//  tableview-adapter
//
//  Created by Pirush Prechathavanich on 11/17/17.
//  Copyright © 2017 Pirush Prechathavanich. All rights reserved.
//

import UIKit
import ReactiveSwift

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    private var tableViewAdapter: TableViewAdapter!
    private var configurators = MutableProperty<[ConfiguratorType]>([])
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        
    }
    
}


