//
//  MenuItemTableViewCell.swift
//  RxSwift+MVVM
//
//  Created by iamchiwon on 07/08/2019.
//  Copyright © 2019 iamchiwon. All rights reserved.
//

import UIKit
import RxSwift

class MenuItemTableViewCell: UITableViewCell {
    static let identifier = "MenuItemTableViewCell"
    
    private var onCountChanged: ((Int) -> Void)
    private let cellDisposeBag = DisposeBag()
    
    var disposeBag = DisposeBag()
    let onData: AnyObserver<ViewMenu>
    let onChanged: Observable<Int>
    
    @IBOutlet var title: UILabel!
    @IBOutlet var count: UILabel!
    @IBOutlet var price: UILabel!
    
    required init?(coder: NSCoder) {
        let data = PublishSubject<ViewMenu>()
        let changing = PublishSubject<Int>()
        onCountChanged = { changing.onNext($0) }
        
        onData = data.asObserver()
        onChanged = changing
        
        super.init(coder: coder)
        
        data.observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] menu in
                self?.title.text = menu.name
                self?.price.text = "\(menu.price)"
                self?.count.text = "\(menu.count)"
            })
            .disposed(by: cellDisposeBag)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    @IBAction func onIncreaseCount() {
        onCountChanged(1)
    }

    @IBAction func onDecreaseCount() {
        onCountChanged(-1)
    }
}
