//
//  ViewController.swift
//  RxSwift+MVVM
//
//  Created by iamchiwon on 05/08/2019.
//  Copyright © 2019 iamchiwon. All rights reserved.
//

import RxSwift
import SwiftyJSON
import UIKit

let MEMBER_LIST_URL = "https://my.api.mockaroo.com/members_with_avatar.json?key=44ce18f0"

class 나중에생기는데이터<T> {
    private let task: (@escaping (T) -> Void) -> Void

    init(task: @escaping (@escaping (T) -> Void) -> Void) {
        self.task = task
    }

    func 나중에오면(_ f: @escaping (T) -> Void) {
        task(f)
    }
}

class ViewController: UIViewController {
    @IBOutlet var timerLabel: UILabel!
    @IBOutlet var editView: UITextView!

    var disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.timerLabel.text = "\(Date().timeIntervalSince1970)"
        }
    }

    private func setVisibleWithAnimation(_ v: UIView?, _ s: Bool) {
        guard let v = v else { return }
        UIView.animate(withDuration: 0.3, animations: { [weak v] in
            v?.isHidden = !s
        }, completion: { [weak self] _ in
            self?.view.layoutIfNeeded()
        })
    }

    // Observable의 생명주기
    // 1. Create
    // 2. Subscribe
    // 3. onNext
    // ------ 끝 ------
    // 4. onCompleted / onError
    // 5. Disposed

    func downloadJson(_ url: String) -> Observable<String> {
        // 1. 비동기로 생기는 데이터를 Observable로 감싸서 리턴하는 방법
        return Observable.create { emitter in
            let url = URL(string: url)!
            let task = URLSession.shared.dataTask(with: url) { (data, _, err) in
                guard err == nil else {
                    emitter.onError(err!)
                    return
                }

                if let data = data, let json = String(data: data, encoding: .utf8) {
                    emitter.onNext(json)
                }

                emitter.onCompleted()
            }

            task.resume()

            return Disposables.create() {
                task.cancel()
            }
        }
    }

    //    func downloadJson(_ url: String) -> Observable<String?> {
    //        return Observable.create { f in
    //            DispatchQueue.global().async {
    //                let url = URL(string: url)!
    //                let data = try! Data(contentsOf: url)
    //                let json = String(data: data, encoding: .utf8)
    //
    //                DispatchQueue.main.async {
    //                    f.onNext(json)
    //                }
    //            }
    //            return Disposables.create()
    //        }
    //    }
    //    return 나중에생기는데이터() { f in
    //        DispatchQueue.global().async {
    //            let url = URL(string: url)!
    //            let data = try! Data(contentsOf: url)
    //            let json = String(data: data, encoding: .utf8)
    //            DispatchQueue.main.async {
    //                f(json)
    //            }
    //        }
    //    }

    //    func downloadJson(_ url: String) -> 나중에생기는데이터<String?> {
    //        return 나중에생기는데이터() { f in
    //            DispatchQueue.global().async {
    //                let url = URL(string: url)!
    //                let data = try! Data(contentsOf: url)
    //                let json = String(data: data, encoding: .utf8)
    //                DispatchQueue.main.async {
    //                    f(json)
    //                }
    //            }
    //        }
    //    }

    // MARK: SYNC

    @IBOutlet var activityIndicator: UIActivityIndicatorView!

    @IBAction func onLoad() {
        editView.text = ""
        self.setVisibleWithAnimation(self.activityIndicator, true)

        // 2. Observable로 오는 데이터를 받아서 처리하는 방법
        let jsonObservable = downloadJson(MEMBER_LIST_URL)
        let helloObservable = Observable.just("Hello World")

        Observable.zip(jsonObservable, helloObservable) { $1 + "\n" + $0}
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { json in
                self.editView.text = json
                self.setVisibleWithAnimation(self.activityIndicator, false)
            })
            .disposed(by: disposeBag)

//        downloadJson(MEMBER_LIST_URL)
////            .debug()
//            .map { json in json?.count ?? 0 } // operator
//            .filter { cnt in cnt > 0 } // operator
//            .map { "\($0)" } // operator
//            .observeOn(MainScheduler.instance) // Dispatchqueue.main.async 를 대체해준다.
//        // obervable과 subscribe 사이에서 데이터를 조작할 때 사용하는 suger API를 operator 라고 한다.
//            .subscribe(onNext: { json in
//                self.editView.text = json
//                self.setVisibleWithAnimation(self.activityIndicator, false)
//            })

//            .subscribe { event in
//                switch event {
//                case let .next(json):
//                    DispatchQueue.main.async {
//                         self.editView.text = json
//                        self.setVisibleWithAnimation(self.activityIndicator, false)
//                    }
//                case .completed: break
//                case .error: break
//                }
//            }


        //        let json: 나중에생기는데이터<String?> = downloadJson(MEMBER_LIST_URL)

        //        json.나중에오면 { json in
        //                        self.editView.text = json
        //                        self.setVisibleWithAnimation(self.activityIndicator, false)
        //        }


        //        downloadJson(MEMBER_LIST_URL) { json in
        //            self.editView.text = json
        //            self.setVisibleWithAnimation(self.activityIndicator, false)
        //        }
    }
}
