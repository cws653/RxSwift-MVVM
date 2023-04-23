//
//  MenuListViewModel.swift
//  RxSwift+MVVM
//
//  Created by 최원석 on 2023/04/23.
//  Copyright © 2023 iamchiwon. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay

class MenuListViewModel {
    
    var menuObservable = BehaviorRelay<[Menu]>(value: [])
    
    lazy var itemCount = menuObservable.map {
        $0.map { $0.count }.reduce(0, +)
    }
    
    lazy var totalPrice = menuObservable.map {
        $0.map { $0.price * $0.count }.reduce(0, +)
    }
    
    init() {
        _ = APIService.fetchAllMenusRx()
            .map { data in
                struct Response: Decodable {
                    let menus: [MenuItem]
                }
                
                let response = try! JSONDecoder().decode(Response.self, from: data)
                
                return response.menus
                
            }
            .map { menuItems in
                var menus: [Menu] = []
                menuItems.enumerated().forEach { index, item in
                    let menu = Menu.fromMenuItems(id: index, item: item)
                    menus.append(menu)
                }
                return menus
            }
            .take(1)
            .bind(to: menuObservable)
    }
    
    func onOrder() {
        
    }
    
    func clearAllItemSelections() {
        _ = menuObservable
            .map { menus in
                menus.map { m in
                    Menu(id: m.id, name: m.name, price: m.price, count: 0)
                }
            }
            .take(1)
            .subscribe(onNext: {
                self.menuObservable.accept($0)
            })
    }
    
    func changeCount(item: Menu, increase: Int) {
        _ = menuObservable
            .map { menus in
                menus.map { m in
                    if m.id == item.id {
                        return Menu(id: m.id,
                                    name: m.name,
                                    price: m.price,
                                    count: max(m.count + increase, 0))
                    } else {
                        return Menu(id: m.id,
                                    name: m.name,
                                    price: m.price,
                                    count: m.count)
                    }
                }
            }
            .take(1)
            .subscribe(onNext: {
                self.menuObservable.accept($0)
            })
    }
}
