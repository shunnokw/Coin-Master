//
//  MyCoinPageViewModel.swift
//  CoinPrice
//
//  Created by Jason Wong on 2/3/2022.
//

import Foundation
import RxSwift

final class MyCoinPageViewModel {
    
    let coinViewModels = BehaviorSubject<[MyCoinViewModel]>(value: [])
    
    let coinService: CoinServiceProtocol
    
    let userDefaults: UserDefaults

    
    init(coinService: CoinServiceProtocol, userDefaults: UserDefaults) {
        self.coinService = coinService
        self.userDefaults = userDefaults
    }
    
    func getCoins() -> [Coin] {
        var result = [Coin]()
        do {
            let snapShotCoins = try coinService.coinStream.value()
            for coin in snapShotCoins {
                result.append(coin)
            }
        } catch {
            print(error)
        }
        return result
    }
    
    func saveMyCoin(uuid: String, quantity: Decimal) {
        var dict = [
            uuid: "\(quantity)"
        ]
        
        if userDefaults.object(forKey: "MyCoins") == nil {
            userDefaults.setValue(dict, forKey: "MyCoins")
        } else {
            dict = userDefaults.object(forKey: "MyCoins") as! [String : String]
            dict[uuid] = "\(quantity)"
            userDefaults.setValue(dict, forKey: "MyCoins")
        }
    }
    
    func getMyCoin(completion: () -> Void) {
        if userDefaults.object(forKey: "MyCoins") != nil {
            let dict = userDefaults.object(forKey: "MyCoins") as! [String : String]
            var cvm = [MyCoinViewModel]()
            do {
                let snapShotCoins = try coinService.coinStream.value()
                for (key,value) in dict {
                    for coin in snapShotCoins {
                        if key == coin.uuid {
                            cvm.append(MyCoinViewModel(coin: coin, quantityString: value))
                        }
                    }
                }
            } catch {
                print(error)
            }
            coinViewModels.onNext(cvm)
        }
    }
}
