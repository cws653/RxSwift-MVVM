//
//  Menu.swift
//  RxSwift+MVVM
//
//  Created by 최원석 on 2022/06/16.
//  Copyright © 2022 iamchiwon. All rights reserved.
//

import Foundation

// ViewModel: View를 위한 모델
struct Menu {
    var id: Int
    var name: String
    var price: Int
    var count: Int
}

extension Menu {
    static func fromMenuItems(id: Int, item: MenuItem) -> Menu {
        return Menu(id: id, name: item.name, price: item.price, count: 0)
    }
}
