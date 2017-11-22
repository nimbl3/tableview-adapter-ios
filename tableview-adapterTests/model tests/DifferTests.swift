//
//  DifferTests.swift
//  tableview-adapterTests
//
//  Created by Pirush Prechathavanich on 11/22/17.
//  Copyright © 2017 Pirush Prechathavanich. All rights reserved.
//

import Quick
import Nimble
@testable import tableview_adapter

extension ConfiguratorType {
    
    var equatable: AnyEquatableConfigurator {
        return AnyEquatableConfigurator(self)
    }
    
}

class AnyEquatableConfigurator: ConfiguratorType {
    
    fileprivate let configurator: ConfiguratorType
    
    var cellClass: UITableViewCell.Type { return configurator.cellClass }
    var height: CGFloat? { return configurator.height }
    var estimatedHeight: CGFloat? { return configurator.estimatedHeight }
    
    init(_ configurator: ConfiguratorType) {
        self.configurator = configurator
    }
    
    func configure(_ cell: UITableViewCell) {
        configurator.configure(cell)
    }
    
}

extension AnyEquatableConfigurator: Equatable {
    
    static func ==(lhs: AnyEquatableConfigurator, rhs: AnyEquatableConfigurator) -> Bool {
        return lhs.configurator === rhs.configurator
    }
    
}

class DifferSpec: QuickSpec {
    
    override func spec() {
        
        describe("A differ for configurator") {
            let imageRow1 = makeImageRow()
            let imageRow2 = makeImageRow()
            let imageRow3 = makeImageRow(text: "hello!")
            
            let textRow1 = makeTextRow()
            let textRow2 = makeTextRow(text: "hello?")
            let textRow3 = makeTextRow()
            
            let oldConfigurators: [ConfiguratorType] = [imageRow1, imageRow2, imageRow3, textRow3]
            let newConfigurators: [ConfiguratorType] = [imageRow2, imageRow3, textRow1, textRow3, textRow2]

            // expected insertions: textRow1, textRow2
            // expected deletions: imageRow1
            
            it("should have the correct changeset information when comparing") {
                let differ = Differ(oldItems: oldConfigurators,
                                    newItems: newConfigurators as [AnyObject],
                                    section: 0)
                let insertions = self.items(from: differ, type: .insert, in: newConfigurators)
                let deletions = self.items(from: differ, type: .remove, in: oldConfigurators)
                expect(insertions) == [textRow2.equatable, textRow1.equatable]
                expect(deletions).to(contain(imageRow1.equatable))
            }
            
            it("should have the correct changeset information as input") {
                let section = 0
                let differ = Differ(itemsCount: oldConfigurators.count,
                                    appendingCount: 2,
                                    insertions: [1],
                                    updates: [2, 3],
                                    deletions: [0, 1],
                                    section: section)
                
                let insertion1 = IndexPath(1, in: section)
                let insertion2 = IndexPath(oldConfigurators.count, in: section)
                let insertion3 = IndexPath(oldConfigurators.count+1, in: section)
                
                let update1 = IndexPath(2, in: section)
                let update2 = IndexPath(3, in: section)
                
                let deletion1 = IndexPath(0, in: section)
                let deletion2 = IndexPath(1, in: section)
                
                expect(differ.indexPaths(of: .insert)) == [insertion3, insertion1, insertion2]
                expect(differ.indexPaths(of: .update)) == [update2, update1]
                expect(differ.indexPaths(of: .remove)) == [deletion1, deletion2]
            }
            
        }
        
        describe("A differ for section") {
            let section1 = makeSection()
            let section2 = makeSection()
            let section3 = makeSection()
            let section4 = makeSection()
            let section5 = makeSection()
            
            let oldSections = [section1, section2, section3, section4]
            let newSections = [section2, section1, section5]
            
            // expected insertions: section5
            // expected deletions: section3, section4
            
            it("should have the correct changeset information when comparing") {
                let differ = Differ(oldSections: oldSections, newSections: newSections)
                
                let indexSection3 = 2
                let indexSection4 = 3
                let indexSection5 = 2
                
                let insertingSections = differ.sections(of: .insert)
                let deletingSections = differ.sections(of: .remove)
                
                expect(insertingSections) == IndexSet(integer: indexSection5)
                expect(deletingSections) == IndexSet([indexSection3, indexSection4])
            }
            
            it("should have the correct changeset information as input") {
                let differ = Differ(sectionsCount: oldSections.count,
                                    appendingCount: 1,
                                    insertions: [1, 2, 3],
                                    updates: [0],
                                    deletions: [1, 2, 3])
                
                let insertions = IndexSet([1, 2, 3, oldSections.count])
                let updates = IndexSet(integer: 0)
                let deletions = IndexSet([1, 2, 3])
                
                let insertingSections = differ.sections(of: .insert)
                let updatingSections = differ.sections(of: .update)
                let deletingSections = differ.sections(of: .remove)
                
                expect(insertingSections) == insertions
                expect(updatingSections) == updates
                expect(deletingSections) == deletions
            }
        }
    }
    
    //MARK:- Private helpers
    
    private func makeImageRow(text: String = "image") -> Row<ImageTableViewCell> {
        return Row(ImageTableViewCell.self, item: ImageViewModel(text: text))
    }
    
    private func makeTextRow(text: String = "text") -> Row<TextTableViewCell> {
        return Row(TextTableViewCell.self, item: TextViewModel(text: text))
    }
    
    private func makeSection() -> Section {
        return Section(configurators: [makeImageRow(), makeImageRow(), makeTextRow()])
    }
    
    private func items(from differ: Differ,
                       type: AdapterChangeType,
                       in configurators: [ConfiguratorType]) -> [AnyEquatableConfigurator] {
        switch type {
        case .insert:       return differ.indexPaths(of: .insert).map { configurators[$0.row].equatable }
        case .update:       return differ.indexPaths(of: .update).map { configurators[$0.row].equatable }
        case .remove:       return differ.indexPaths(of: .remove).map { configurators[$0.row].equatable }
        }
    }
    
}
