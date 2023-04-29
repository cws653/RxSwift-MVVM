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

protocol MenuViewModelType {
    var fetchMenus: AnyObserver<Void> { get }
    var clearSelections: AnyObserver<Void> { get }
    var makeOrder: AnyObserver<Void> { get }
    var increaseMenuCount: AnyObserver<(menu: ViewMenu, inc: Int)> { get }
    
    var activated: Observable<Bool> { get }
    var errorMessage: Observable<NSError> { get }
    var allMenus: Observable<[ViewMenu]> { get }
    var totoalSelectedCountText: Observable<String> { get }
    var totalPriceText: Observable<String> { get }
    var showOrderPage: Observable<[ViewMenu]> { get }
}

class MenuViewModel: MenuViewModelType {
    
    let disposeBag = DisposeBag()
    
    // INPUT
    var fetchMenus: AnyObserver<Void>
    var clearSelections: AnyObserver<Void>
    var makeOrder: AnyObserver<Void>
    var increaseMenuCount: AnyObserver<(menu: ViewMenu, inc: Int)>
    
    // OUTPUT
    var activated: Observable<Bool>
    var errorMessage: Observable<NSError>
    var allMenus: Observable<[ViewMenu]>
    var totoalSelectedCountText: Observable<String>
    var totalPriceText: Observable<String>
    var showOrderPage: Observable<[ViewMenu]>
    
    init(domain: MenuFetchable = MenuStore()) {
        let fetching = PublishSubject<Void>()
        let clearing = PublishSubject<Void>()
        let ordering = PublishSubject<Void>()
        let increasing = PublishSubject<(menu: ViewMenu, inc: Int)>()
        
        let menus = BehaviorSubject<[ViewMenu]>(value: [])
        let activating = BehaviorSubject<Bool>(value: false)
        let error = PublishSubject<Error>()
        
        // INPUT
        fetchMenus = fetching.asObserver()
        
        fetching
            .do(onNext: { _ in activating.onNext(true) })
            .flatMap(domain.fetchMenus)
            .map { $0.map { ViewMenu($0) } }
            .do(onNext: { _ in activating.onNext(false) })
            .do(onError: { err in error.onNext(err) })
            .subscribe(onNext: menus.onNext)
            .disposed(by: disposeBag)
        
        clearSelections = clearing.asObserver()

        clearing.withLatestFrom(menus)
            .map { $0.map { $0.countUpdated(0) }}
            .subscribe(onNext: menus.onNext)
            .disposed(by: disposeBag)
        
        makeOrder = ordering.asObserver()
        
        increaseMenuCount = increasing.asObserver()
        
        increasing.map { $0.menu.countUpdated(max(0, $0.menu.count + $0.inc)) }
            .withLatestFrom(menus) { (updated, originals) -> [ViewMenu] in
                originals.map {
                    guard $0.name == updated.name else { return $0 }
                    return updated
                }
            }
            .subscribe(onNext: menus.onNext)
            .disposed(by: disposeBag)
        
        // OUTPUT
        allMenus = menus
        
        activated = activating.distinctUntilChanged()
        
        errorMessage = error.map { $0 as NSError }
        
        totoalSelectedCountText = menus
            .map { $0.map { $0.count }.reduce(0,+) }
            .map { "\($0)" }
        
        totalPriceText = menus
            .map { $0.map { $0.price * $0.count }.reduce(0,+) }
            .map { $0.currencyKR() }
        
        showOrderPage = ordering.withLatestFrom(menus)
            .map { $0.filter { $0.count > 0 }}
            .do(onNext: { items in
                if items.count == 0 {
                    let err = NSError(domain: "NO Orders", code: -1, userInfo: nil)
                    error.onNext(err)
                }
            })
            .filter { $0.count > 0 }
    }
}
