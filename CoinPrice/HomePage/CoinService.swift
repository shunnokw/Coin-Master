//
// Created by Jason Wong on 13/2/2022.
//

import Foundation
import RxSwift
import RxCocoa

protocol CoinServiceProtocol {
    var hideLoading: BehaviorRelay<Bool> { get }
    var coinStream: BehaviorSubject<[Coin]> { get }

    func fetchCoins()
}

class CoinService: CoinServiceProtocol {

    var hideLoading = BehaviorRelay<Bool>(value: false)
    var coinStream = BehaviorSubject<[Coin]>(value: [])

    func fetchCoins() {
        hideLoading.accept(false)
        
        let configuration = URLSessionConfiguration.default
        let urlSession = URLSession.init(configuration: configuration)
        let apiClient = CoinAPI(urlSession: urlSession)
        
        apiClient.fetchAPI{ (result) in
            switch result {
            case .success(let coinModel):
                self.coinStream.onNext(coinModel.data.coins ?? [])
                self.hideLoading.accept(true)
            case .failure(let error):
                self.coinStream.onError(error)
            }
        }
    }
}
