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
        _ = APIService.fetchAllMenusRx()
            .map { data -> [MenuItem] in
                struct Response: Decodable {
                    let menus: [MenuItem]
                }
                let response = try! JSONDecoder().decode(Response.self, from: data)
                return response.menus
            }
            .map { menuItems in
                var menus: [Menu] = []
                menuItems.enumerated().forEach { (index, item) in
                    let menu = Menu.fromMenuItems(id: index, item: item)
                    menus.append(menu)
                }
                return menus
            }
            .take(1)
            .bind(to: menuObservable)
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

    func onOrder() {
        
    }

    func chageCount(item: Menu, increase: Int) {
        _ = menuObservable
            .map { menu in
                menu.map { m in
                    if m.id == item.id {
                        return Menu(id: m.id, name: m.name, price: m.price, count: max(m.count + increase, 0))
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
