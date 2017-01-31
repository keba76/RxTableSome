 //
 //  Example4Different.swift
 //  RxTableSome
 //
 //  Created by Ievgen Keba on 1/30/17.
 //  Copyright © 2017 Harman Inc. All rights reserved.
 //
 import Foundation
 import UIKit
 import RxDataSources
 import RxCocoa
 import RxSwift
 
 class ImageTitleTableViewCell: UITableViewCell {
    
    @IBOutlet weak var cellImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
 }
 
 class TitleSwitchTableViewCell: UITableViewCell {
    
    @IBOutlet weak var switchControl: UISwitch!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitTast = super.hitTest(point, with: event)
        let rect = CGRect(x: self.switchControl.frame.minX, y: self.switchControl.frame.minY, width: self.switchControl.bounds.width, height: self.switchControl.bounds.height)
        if rect.contains(point) {
            let dis = DisposeBag()
            switchControl.rx.value.asObservable().bindNext{self.titleLabel.text = $0 ? "Off" : "On"}.addDisposableTo(dis)
            return hitTast
        }else {
            return nil
        }
    }
 }
 
 class TitleSteperTableViewCell: UITableViewCell {
    
    @IBOutlet weak var stepper: UIStepper!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitTast = super.hitTest(point, with: event)
        let rect = CGRect(x: self.stepper.frame.minX, y: self.stepper.frame.minY, width: self.stepper.bounds.width, height: self.stepper.bounds.height)
        if rect.contains(point) {
            let dis = DisposeBag()
            stepper.rx.value.asObservable().map{String(Int($0))}.bindNext{self.titleLabel.text = $0}.addDisposableTo(dis)
            return hitTast
        }else {
            return nil
        }
    }
 }
 
 class Example4Different: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let sections: [MultipleSectionModel] = [
            .ImageProvidableSection(title: "Section 1",
                                    items: [.ImageSectionItem(image: UIImage(named: "settings")!, title: "General")]),
            .ToggleableSection(title: "Section 2",
                               items: [.ToggleableSectionItem(title: "On", enabled: true)]),
            .StepperableSection(title: "Section 3",
                                items: [.StepperSectionItem(title: "0")])
        ]
        let dataSource = RxTableViewSectionedReloadDataSource<MultipleSectionModel>()
        
        skinTableViewDataSource(dataSource)
        
        Observable.just(sections)
            .bindTo(tableView.rx.items(dataSource: dataSource))
            .addDisposableTo(disposeBag)
    }
    
    func skinTableViewDataSource(_ dataSource: RxTableViewSectionedReloadDataSource<MultipleSectionModel>) {
        dataSource.configureCell = { (dataSource, table, idxPath, _) in
            switch dataSource[idxPath] {
            case let .ImageSectionItem(image, title):
                let cell: ImageTitleTableViewCell = table.dequeueReusableCell(forIndexPath: idxPath)
                cell.titleLabel.text = title
                cell.cellImageView.image = image
                return cell
            case let .StepperSectionItem(title):
                let cell: TitleSteperTableViewCell = table.dequeueReusableCell(forIndexPath: idxPath)
                cell.titleLabel.text = title
                return cell
            case let .ToggleableSectionItem(title, enabled):
                let cell: TitleSwitchTableViewCell = table.dequeueReusableCell(forIndexPath: idxPath)
                cell.switchControl.isOn = enabled
                cell.titleLabel.text = title
                return cell
            }
        }
        dataSource.titleForHeaderInSection = { dataSource, index in
            let section = dataSource[index]
            return section.title
        }
    }
 }
 // MultipleSectionModel
 
 enum MultipleSectionModel {
    case ImageProvidableSection(title: String, items: [SectionItem])
    case ToggleableSection(title: String, items: [SectionItem])
    case StepperableSection(title: String, items: [SectionItem])
 }
 
 enum SectionItem {
    case ImageSectionItem(image: UIImage, title: String)
    case ToggleableSectionItem(title: String, enabled: Bool)
    case StepperSectionItem(title: String)
 }
 
 extension MultipleSectionModel: SectionModelType {
    typealias Item = SectionItem
    
    var items: [SectionItem] {
        switch  self {
        case .ImageProvidableSection(title: _, items: let items):
            return items.map {$0}
        case .StepperableSection(title: _, items: let items):
            return items.map {$0}
        case .ToggleableSection(title: _, items: let items):
            return items.map {$0}
        }
    }
    init(original: MultipleSectionModel, items: [Item]) {
        switch original {
        case let .ImageProvidableSection(title: title, _):
            self = .ImageProvidableSection(title: title, items: items)
        case let .StepperableSection(title, _):
            self = .StepperableSection(title: title, items: items)
        case let .ToggleableSection(title, _):
            self = .ToggleableSection(title: title, items: items)
        }
    }
 }
 
 extension MultipleSectionModel {
    var title: String {
        switch self {
        case .ImageProvidableSection(title: let title, items: _):
            return title
        case .StepperableSection(title: let title, items: _):
            return title
        case .ToggleableSection(title: let title, items: _):
            return title
        }
    }
 }
