//
//  RxSwiftExtension.swift
//  MVVMTemplate
//
//  Created by Thuỳ Nguyễn on 3/14/18.
//  Copyright © 2018 NUS Technology. All rights reserved.
//

import Foundation
import RxSwift

//extension PrimitiveSequence where TraitType == SingleTrait {
//    public func asMaybe() -> PrimitiveSequence<MaybeTrait, Element> {
//        return self.asObservable().asMaybe()
//    }
//
//    public func asCompletable() -> PrimitiveSequence<CompletableTrait, Never> {
//        return self.asObservable().flatMap { _ in Observable<Never>.empty() }.asCompletable()
//    }
//}
//extension PrimitiveSequenceType where Self: ObservableConvertibleType, Self.TraitType == SingleTrait {
//
////    func asCompletable() -> Completable {
////        return Completable.create(subscribe: { (completable) -> Disposable in
////            _ = self.subscribe(onSuccess: { (_) in
////                completable(.completed)
////            }, onError: { (error) in
////                completable(.error(error))
////            })
////            return Disposables.create()
////        })
////    }
//
////    func flatMapCompletable(_ selector: @escaping (E) -> Completable) -> Completable {
////        return self
////            .asObservable()
////            .flatMap { e -> Observable<Never> in
////                selector(e).asObservable()
////            }
////            .asCompletable()
////    }
//
//}
//extension PrimitiveSequence where TraitType == CompletableTrait, ElementType == Swift.Never {
//    public func asMaybe() -> PrimitiveSequence<MaybeTrait, Element> {
//        return self.asObservable().asMaybe()
//    }
//}

