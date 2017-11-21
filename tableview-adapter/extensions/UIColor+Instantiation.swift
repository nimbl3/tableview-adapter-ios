//
//  UIColor+Instantiation.swift
//  tableview-adapter
//
//  Created by Pirush Prechathavanich on 11/21/17.
//  Copyright © 2017 Pirush Prechathavanich. All rights reserved.
//

import UIKit

extension UIColor {
    
    static func rgba(_ red: Int, _ green: Int, _ blue: Int, _ alpha: CGFloat = 1.0) -> UIColor {
        return UIColor(red: CGFloat(red)/255.0,
                       green: CGFloat(green)/255.0,
                       blue: CGFloat(blue)/255.0,
                       alpha: alpha)
    }
    
    static let cloudGray: UIColor = .rgba(231, 232, 240)
    
    static let mandy: UIColor = .rgba(236, 80, 105)
    static let lightMandy: UIColor = .rgba(255, 244, 246)
    
    static let jordy: UIColor = .rgba(97, 155, 236)
    static let lightJordy: UIColor = .rgba(246, 250, 255)
    
    static let conifer: UIColor = .rgba(124, 208, 71)
    static let lightConifer: UIColor = .rgba(246, 255, 240)
    
    static let aerialGray: UIColor = .rgba(208, 205, 204)
    static let lightAerialGray: UIColor = .rgba(249, 252, 254)
    
}
