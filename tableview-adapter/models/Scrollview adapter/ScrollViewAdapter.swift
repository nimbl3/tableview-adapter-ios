//
//  ScrollViewAdapter.swift
//  tableview-adapter
//
//  Created by Pirush Prechathavanich on 11/20/17.
//  Copyright © 2017 Pirush Prechathavanich. All rights reserved.
//

import UIKit
import ReactiveSwift
import Result

typealias ScrollViewWithVelocity = (scrollView: UIScrollView, velocity: CGPoint)

protocol ScrollViewAdapter: UIScrollViewDelegate {
    
    var scrollView: UIScrollView { get }
    
    var didScroll: Signal<UIScrollView, NoError> { get }
    var didBeginDragging: Signal<UIScrollView, NoError> { get }
    var didEndDragging: Signal<ScrollViewWithVelocity, NoError> { get }
    var willBeginDecelerating: Signal<UIScrollView, NoError> { get }
    var didEndDecelerating: Signal<UIScrollView, NoError> { get }
    
}

class Section {
    
    var configurators: [ConfiguratorType]
    
    var headerTitle: String?
    var footerTitle: String?
    var indexTitle: String?
    
    var headerView: UIView?
    var footerView: UIView?
    
    var headerHeight: CGFloat? = nil
    var footerHeight: CGFloat? = nil
    
    var numberOfConfigurators: Int { return configurators.count }
    var isEmpty: Bool { return configurators.isEmpty }
    
    init(configurators: [ConfiguratorType] = []) {
        self.configurators = configurators
    }
    
    func index(of configurator: ConfiguratorType) -> Int? {
        return configurators.index { $0 === configurator }
    }
    
    func append(_ configurator: ConfiguratorType) {
        configurators.append(configurator)
    }
    
}
