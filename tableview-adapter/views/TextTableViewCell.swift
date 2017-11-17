//
//  TextTableViewCell.swift
//  tableview-adapter
//
//  Created by Pirush Prechathavanich on 11/17/17.
//  Copyright © 2017 Pirush Prechathavanich. All rights reserved.
//

import UIKit

struct TextViewModel {
    
    let text: String
    
    init(text: String = "text") {
        self.text = text
    }
    
}

class TextTableViewCell: UITableViewCell, Configurable {
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with item: TextViewModel) {
        textLabel?.font = UIFont(name: "AvenirNext-Medium", size: 16.0)
        textLabel?.text = item.text
    }
    
}
