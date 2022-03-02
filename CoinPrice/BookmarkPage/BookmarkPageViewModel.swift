//
//  BookmarkPageViewModel.swift
//  CoinPrice
//
//  Created by Jason Wong on 1/3/2022.
//

import Foundation
import RxSwift

class BookmarkPageViewModel {
    let coinViewModels = BehaviorSubject<[CoinViewModel]>(value: [])
    let coinService: CoinServiceProtocol
    let userDefaults: UserDefaults
    
    init(coinService: CoinServiceProtocol, userDefaults: UserDefaults) {
        self.coinService = coinService
        self.userDefaults = userDefaults
    }
    
    func getUuids() -> [String] {
        guard let uuids: [String] = userDefaults.stringArray(forKey: "uuids") else {
            return []
        }
        return uuids
    }
    
    func getBookmark(completion: () -> Void) {
        let uuids = getUuids()
        if !uuids.isEmpty {
            do {
                let snapShotCoins = try coinService.coinStream.value()
                var cvm = [CoinViewModel]()
                for uuid in uuids {
                    for coin in snapShotCoins {
                        if coin.uuid == uuid {
                            cvm.append(CoinViewModel(coin: coin, isBookmarked: true))
                        }
                    }
                }
                
                coinViewModels.onNext(cvm)
                completion()
            } catch {
                print(error)
            }
        }
    }
}
