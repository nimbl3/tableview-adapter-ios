//
//  ImageTableViewCell.swift
//  tableview-adapter
//
//  Created by Pirush Prechathavanich on 11/17/17.
//  Copyright © 2017 Pirush Prechathavanich. All rights reserved.
//

import UIKit
import ReactiveSwift

struct ImageViewModel {
    
    static var count = 0
    let text: String
    let selected: MutableProperty<Bool>
    
    init(text: String = "image") {
        self.text = text + ": \(ImageViewModel.count)"
        self.selected = MutableProperty<Bool>(false)
        ImageViewModel.count += 1
    }
    
}

class ImageTableViewCell: UITableViewCell, Configurable {
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with item: ImageViewModel) {
        textLabel?.font = UIFont(name: "AvenirNext-Medium", size: 16.0)
        textLabel?.text = item.text
        item.selected.signal
            .take(until: reactive.prepareForReuse)
            .observeValues { [unowned self] selected in
                self.textLabel?.text = selected ? "selected!" : item.text
        }
    }
    
}
