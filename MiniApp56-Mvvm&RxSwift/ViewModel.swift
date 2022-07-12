//
//  ViewModel.swift
//  MiniApp56-Mvvm&RxSwift
//
//  Created by 前田航汰 on 2022/07/12.
//

import Foundation
import RxSwift
import UIKit

class ViewModel {
    let validationText: Observable<String>
    let loadLabelColor: Observable<UIColor>

    init(idTextObservable: Observable<String?>,
         passwordTextObservable: Observable<String?>,
         model: ModelProtocol) {
        let event = Observable
            .combineLatest(idTextObservable, passwordTextObservable)
            .skip(1)
            .flatMapLatest{ idText, passwordText -> Observable<Event<Void>> in return model
                    .validate(idText: idText, passwordText: passwordText)
                    .materialize()
            }
            .share()

        self.validationText = event
            .flatMap { event -> Observable<String> in
                switch event {
                case .next: return .just("OK!!!")
                case let .error(error as ModelError):
                    return .just(error.errorText)
                case .error, .completed: return .empty()
                }
            }
            .startWith("ID と Password を入力してください。")

        self.loadLabelColor = event
            .flatMap { event -> Observable<UIColor> in
                switch event {
                case .next: return .just(.green)
                case .error: return .just(.red)
                case .completed: return .empty()
                }
            }
    }
}

extension ModelError {
    fileprivate var errorText: String {
        switch self {
        case .invalidIdAndPassword: return "ID と Password が未入力です。"
        case .invalidId: return "ID が未入力です。"
        case .invalidPassword: return "Password が未入力です。"
        }
    }
}
