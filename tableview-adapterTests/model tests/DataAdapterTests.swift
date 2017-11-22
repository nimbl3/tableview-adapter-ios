//
//  DataAdapterTests.swift
//  tableview-adapterTests
//
//  Created by Pirush Prechathavanich on 11/22/17.
//  Copyright © 2017 Pirush Prechathavanich. All rights reserved.
//

import Quick
import Nimble

@testable import tableview_adapter

class DataAdapterSpec: QuickSpec {
    
    override func spec() {
        let section1 = Section(configurators:[
            Row(ImageTableViewCell.self, item: ImageViewModel()),
            Row(ImageTableViewCell.self, item: ImageViewModel()),
            Row(TextTableViewCell.self, item: TextViewModel(text: "BIG (tricked)")),
            Row(TextTableViewCell.self, item: TextViewModel()),
            Row(TextTableViewCell.self, item: TextViewModel())
        ])
        let section2 = Section(configurators:[
            Row(ImageTableViewCell.self, item: ImageViewModel()),
            Row(ImageTableViewCell.self, item: ImageViewModel(text: "BIG")),
            Row(TextTableViewCell.self, item: TextViewModel())
        ])
        let section3 = Section(configurators:[
            Row(ImageTableViewCell.self, item: ImageViewModel(text: "BIG")),
            Row(ImageTableViewCell.self, item: ImageViewModel()),
            Row(TextTableViewCell.self, item: TextViewModel())
        ])
        
        let dataAdapter = DataAdapter(sections: [section1, section2, section3])
        
        var rowChangeResult: Differ?
        var sectionChangeResult: Differ?
        var replaceResult: ReloadType?
        
        dataAdapter.rowChangeSignal
            .observeValues { rowChangeResult = $0 }
        dataAdapter.sectionChangeSignal
            .observeValues { sectionChangeResult = $0 }
        dataAdapter.replaceSignal
            .observeValues { replaceResult = $0 }
        
        describe("A data adapter") {
            
            it("should have a correct number of sections") {
                expect(dataAdapter.numberOfSections) == 3
            }
            
            it("should have a correct number of rows") {
                expect(dataAdapter.numberOfRows(in: 0)) == 5
                expect(dataAdapter.numberOfRows(in: 1)) == 3
                expect(dataAdapter.numberOfRows(in: 2)) == 3
            }
            
            describe("its index titles and section for index titles") {
                it("should match") {
                    section1.indexTitle = "1"
                    section3.indexTitle = "3"
                    expect(dataAdapter.indexTitles?[0]) == "1"
                    expect(dataAdapter.indexTitles?[1]) == "3"
                    expect(dataAdapter.sectionForIndexTitles[section1.indexTitle ?? ""]) == 0
                    expect(dataAdapter.sectionForIndexTitles[section3.indexTitle ?? ""]) == 2
                    expect(dataAdapter.sectionForIndexTitles["2"]).to(beNil())
                }
            }
            
            describe("its row change signal") {
                let section = 1
                
                beforeEach {
                    rowChangeResult = nil
                }
                
                it("should send a correct changeset information when appended") {
                    let row = self.makeImageRow()
                    let count = dataAdapter.numberOfRows(in: section)
                    dataAdapter.append([row], section: section)
                    let insertionResult = rowChangeResult?.indexPaths(of: .insert)
                    
                    expect(insertionResult) == [IndexPath(count, in: section)]
                    expect(dataAdapter.section(at: section).configurators.last as? Row<ImageTableViewCell>) == row
                }
                
                it("should send a correct changeset information when updated") {
                    let row = self.makeImageRow()
                    let count = dataAdapter.numberOfRows(in: section)
                    var updatingList = dataAdapter.section(at: section).configurators
                    let removedConfigurator = updatingList.removeLast() as! Row<ImageTableViewCell>
                    updatingList.append(row)
                    
                    dataAdapter.update(with: updatingList, section: section)
                    
                    let insertionResult = rowChangeResult?.indexPaths(of: .insert)
                    let deletionResult = rowChangeResult?.indexPaths(of: .remove)
                    let currentList = dataAdapter.section(at: section).configurators
                    
                    expect(insertionResult) == [IndexPath(count-1, in: section)]
                    expect(deletionResult) == [IndexPath(count-1, in: section)]
                    expect(currentList.last as? Row<ImageTableViewCell>) == row
                    expect(currentList.map { $0.equatable }).notTo(contain(removedConfigurator.equatable))
                }
                
            }
            
            describe("its section change signal") {
                
                beforeEach {
                    sectionChangeResult = nil
                }
                
                it("should send a correct changeset information when appended") {
                    let section = Section(configurators: [self.makeImageRow()])
                    let count = dataAdapter.numberOfSections
                    dataAdapter.append([section])
                    let insertionResult = sectionChangeResult?.sections(of: .insert)
                    
                    expect(insertionResult) == IndexSet(integer: count)
                    expect(dataAdapter.sections.last) == section
                }
                
                it("should send a correct changeset information when updated") {
                    let section = Section(configurators: [self.makeImageRow()])
                    let count = dataAdapter.numberOfSections
                    var updatingList = dataAdapter.sections
                    let removedSection = updatingList.removeFirst()
                    updatingList.append(section)
                    
                    dataAdapter.update(with: updatingList)
                    
                    let insertionResult = sectionChangeResult?.sections(of: .insert)
                    let deletionResult = sectionChangeResult?.sections(of: .remove)
                    let currentList = dataAdapter.sections
                    
                    expect(insertionResult) == IndexSet(integer: count-1)
                    expect(deletionResult) == IndexSet(integer: 0)
                    expect(currentList.last) == section
                    expect(currentList).notTo(contain(removedSection))
                }
            }
            
        }
    }
    
    //MARK:- Private helpers
    
    private func makeImageRow(text: String = "image") -> Row<ImageTableViewCell> {
        return Row(ImageTableViewCell.self, item: ImageViewModel(text: text))
    }
    
}

extension Section: Equatable {
    
    public static func ==(lhs: Section, rhs: Section) -> Bool {
        return lhs === rhs
    }
    
}
