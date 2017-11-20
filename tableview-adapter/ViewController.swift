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
//                self.dataAdapter.append([newRow])
                var updatingList = self.dataAdapter.configuratorsList
                updatingList.remove(at: 2)
                updatingList.append(newRow)
                self.dataAdapter.update(with: updatingList)
        }
    }
    
}

extension Array {
    
    func appended(with addingArray: [Element]) -> [Element] {
        var result = self
        result.append(contentsOf: addingArray)
        return result
    }
    
    //MARK:- Any object
    
    func difference<T: AnyObject>(from otherArray: [T]) -> [T] {
        return self
            .flatMap { $0 as? T }
            .filter { element in !otherArray.contains(where: { $0 === element }) }
    }
    
    func intersection<T: AnyObject>(of otherArray: [T]) -> [T] {
        return self
            .flatMap { $0 as? T }
            .filter { element in otherArray.contains(where: { $0 === element }) }
    }
    
    //MARK:- Equatable element
    
    func difference<T: Equatable>(from otherArray: [T]) -> [T] {
        return self
            .flatMap { $0 as? T }
            .filter { !otherArray.contains($0) }
    }
    
    func intersection<T: Equatable>(of otherArray: [T]) -> [T] {
        return self
            .flatMap { $0 as? T }
            .filter { otherArray.contains($0) }
    }
    
    //MARK:- Any element
    
    func difference<T>(from otherArray: [T], matchingBlock: (T, T) -> Bool) -> [T] {
        return self
            .flatMap { $0 as? T }
            .filter { element in
                !otherArray.contains(where: { matchingBlock($0, element) })
            }
    }
    
    func intersection<T>(of otherArray: [T], matchingBlock: ((T, T) -> Bool)) -> [T] {
        return self
            .flatMap { $0 as? T }
            .filter { element in
                otherArray.contains(where: { matchingBlock($0, element) })
            }
    }
    
}
