//
//  ImageTableViewCell.swift
//  tableview-adapter
//
//  Created by Pirush Prechathavanich on 11/17/17.
//  Copyright © 2017 Pirush Prechathavanich. All rights reserved.
//

import UIKit

struct ImageViewModel {
    
    static var count = 0
    let text: String
    
    init(text: String = "image") {
        self.text = text + ": \(ImageViewModel.count)"
        ImageViewModel.count += 1
    }
    
}

class ImageTableViewCell: UITableViewCell, Configurable {
    
    func configure(with item: ImageViewModel) {
        textLabel?.font = UIFont(name: "AvenirNext-Medium", size: 16.0)
        textLabel?.text = item.text
    }
    
}
