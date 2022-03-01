//
// Created by Jason Wong on 13/2/2022.
//

import Foundation

struct CoinViewModel {

    private let coin: Coin
    var isBookmarked: Bool

    var displayText: String {
        coin.name
    }

    var priceText: String {
        "$\(coin.price) USD"
    }

    var uuid: String {
        coin.uuid
    }

    init(coin: Coin, isBookmarked: Bool) {
        self.coin = coin
        self.isBookmarked = isBookmarked
    }

    func copy(with zone: NSZone? = nil) -> Any {
        let copy = CoinViewModel(coin: coin, isBookmarked: isBookmarked)
        return copy
    }
}
