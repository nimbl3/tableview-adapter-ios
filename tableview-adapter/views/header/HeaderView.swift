//
//  HeaderView.swift
//  tableview-adapter
//
//  Created by Pirush Prechathavanich on 11/21/17.
//  Copyright © 2017 Pirush Prechathavanich. All rights reserved.
//

import UIKit

class HeaderView: UIView {

    @IBOutlet weak var titleLabel: UILabel!
    
    static var red: HeaderView {
        let view = UIView.fromNib(HeaderView.self)
        view.titleLabel.text = "Red section"
        view.titleLabel.textColor = .mandy
        view.backgroundColor = .lightMandy
        return view
    }
    
    static var blue: HeaderView {
        let view = UIView.fromNib(HeaderView.self)
        view.titleLabel.text = "Blue section"
        view.titleLabel.textColor = .jordy
        view.backgroundColor = .lightJordy
        return view
    }

    static var green: HeaderView {
        let view = UIView.fromNib(HeaderView.self)
        view.titleLabel.text = "Green section"
        view.titleLabel.textColor = .conifer
        view.backgroundColor = .lightConifer
        return view
    }
    
}
