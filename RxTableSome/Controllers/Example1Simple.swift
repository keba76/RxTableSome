//
//  Example1Simple.swift
//  RxTableSome
//
//  Created by Ievgen Keba on 1/30/17.
//  Copyright © 2017 Harman Inc. All rights reserved.
//
import Foundation
import UIKit
import RxDataSources
import RxSwift
import RxCocoa

struct MySection {
    var header: String
    var items: [Item]
}
extension MySection : AnimatableSectionModelType {
    typealias Item = Int
    var identity: String {
        return header
    }
    init(original: MySection, items: [Item]) {
        self = original
        self.items = items
    }
}

class Example1Simple: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    let disposeBag = DisposeBag()
    var dataSource: RxTableViewSectionedAnimatedDataSource<MySection>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        let dataSource = RxTableViewSectionedAnimatedDataSource<MySection>()
        
        dataSource.configureCell = { ds, tv, ip, item in
            let cell = tv.dequeueReusableCell(withIdentifier: "Cell") ?? UITableViewCell(style: .default, reuseIdentifier: "Cell")
            cell.textLabel?.text = "Item \(item)"
            return cell
        }
        
        dataSource.titleForHeaderInSection = { ds, index in
            return ds.sectionModels[index].header
        }
        
        let sections = [
            MySection(header: "First section", items: [1, 2]),
            MySection(header: "Second section", items: [3, 4])
        ]
        
        Observable.just(sections)
            .bindTo(tableView.rx.items(dataSource: dataSource))
            .addDisposableTo(disposeBag)
        
        tableView.rx.setDelegate(self).addDisposableTo(disposeBag)
        self.dataSource = dataSource
    }
}

extension Example1Simple: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        guard let item = dataSource?[indexPath],
            // .. or section and customize what you like
            let _ = dataSource?[indexPath.section]
            else {
                return 0.0
        }
        return CGFloat(40 + item)
    }
}
