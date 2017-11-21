//
//  UIView+NibInstantiation.swift
//  tableview-adapter
//
//  Created by Pirush Prechathavanich on 11/21/17.
//  Copyright © 2017 Pirush Prechathavanich. All rights reserved.
//

import UIKit

extension UIView {
    
    static func fromNib<T: UIView>(_ owner: AnyObject? = nil,
                                   options: [String: AnyObject]? = nil) -> T {
        return Bundle.main.loadNibNamed(String(describing: T.self),
                                        owner: owner,
                                        options: options)!.first! as! T
    }
    
    static func fromNib<T: UIView>(_ viewClass: T.Type) -> T {
        return Bundle.main.loadNibNamed(String(describing: viewClass),
                                        owner: nil,
                                        options: nil)!.first! as! T
    }
    
}
