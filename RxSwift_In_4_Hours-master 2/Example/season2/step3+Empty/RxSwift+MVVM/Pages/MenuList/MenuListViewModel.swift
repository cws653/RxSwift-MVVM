//
//  MenuListViewModel.swift
//  RxSwift+MVVM
//
//  Created by 최원석 on 2022/06/16.
//  Copyright © 2022 iamchiwon. All rights reserved.
//

import Foundation
import RxSwift

class MenuListViewModel {

    var menuObservable = BehaviorSubject<[Menu]>(value: [])

    lazy var itemCount = menuObservable.map {
        $0.map { $0.count }.reduce(0, +)
    }

    lazy var totalPrice = menuObservable.map {
        $0.map { $0.price * $0.count }.reduce(0, +)
    }

    init() {
        let menu: [Menu] = [
            Menu(id: 0, name: "튀김", price: 100, count: 0),
            Menu(id: 1, name: "튀김", price: 100, count: 0),
            Menu(id: 2, name: "튀김", price: 100, count: 0),
            Menu(id: 3, name: "튀김", price: 100, count: 0)
        ]

        menuObservable.onNext(menu)
    }

    func clearAllItemSelections() {
        _ = menuObservable
            .map { menu in
                menu.map { m in
                    Menu(id: m.id, name: m.name, price: m.price, count: 0)
                }
            }
            .take(1) // 한번만 실행할 때 적용하는 오퍼레이터
            .subscribe(onNext: {
                self.menuObservable.onNext($0)
            })
    }

    func chageCount(item: Menu, increase: Int) {
        _ = menuObservable
            .map { menu in
                menu.map { m in
                    if m.id == item.id {
                        return Menu(id: m.id, name: m.name, price: m.price, count: m.count + increase)
                    } else {
                        return Menu(id: m.id,  name: m.name, price: m.price, count: m.count)
                    }
                }
            }
            .take(1) // 한번만 실행할 때 적용하는 오퍼레이터
            .subscribe(onNext: {
                self.menuObservable.onNext($0)
            })
    }
}
// 2:51:12
