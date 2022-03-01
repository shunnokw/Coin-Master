//
//  MyCoinViewModel.swift
//  CoinPrice
//
//  Created by Jason Wong on 2/3/2022.
//

import Foundation

struct MyCoinViewModel {
    private let coin: Coin
    let quantityString: String
    
    var displayText: String {
        coin.name
    }
    
    private var price: Decimal {
        Decimal(string: coin.price, locale: .current)!
    }
    
    private var quantity: Decimal {
        Decimal(string: quantityString, locale: .current)!
    }
    
    var worth: String {
        "\(price * quantity) USD"
    }
    
    var priceText: String {
        "$\(coin.price) USD"
    }
    
    var uuid: String {
        coin.uuid
    }
    
    init(coin: Coin, quantityString: String) {
        self.coin = coin
        self.quantityString = quantityString
    }
}
