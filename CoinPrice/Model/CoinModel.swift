// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let coinModel = try? newJSONDecoder().decode(CoinModel.self, from: jsonData)

import Foundation

// MARK: - CoinModel
class CoinModel: Codable {
    let status: String
    let data: DataClass

    init(status: String, data: DataClass) {
        self.status = status
        self.data = data
    }
}

// MARK: - DataClass
class DataClass: Codable {
    let stats: Stats
    let coins: [Coin]?

    init(stats: Stats, coins: [Coin]) {
        self.stats = stats
        self.coins = coins
    }
}

// MARK: - Coin
class Coin: Codable {
    let uuid, symbol, name: String
    let color: String?
    let iconURL: String
    let marketCap, price: String
    let listedAt, tier: Int
    let change: String
    let rank: Int
    let sparkline: [String]
    let lowVolume: Bool
    let coinrankingURL: String
    let the24HVolume, btcPrice: String

    enum CodingKeys: String, CodingKey {
        case uuid, symbol, name, color
        case iconURL = "iconUrl"
        case marketCap, price, listedAt, tier, change, rank, sparkline, lowVolume
        case coinrankingURL = "coinrankingUrl"
        case the24HVolume = "24hVolume"
        case btcPrice
    }

    init(uuid: String, symbol: String, name: String, color: String?, iconURL: String, marketCap: String, price: String, listedAt: Int, tier: Int, change: String, rank: Int, sparkline: [String], lowVolume: Bool, coinrankingURL: String, the24HVolume: String, btcPrice: String) {
        self.uuid = uuid
        self.symbol = symbol
        self.name = name
        self.color = color
        self.iconURL = iconURL
        self.marketCap = marketCap
        self.price = price
        self.listedAt = listedAt
        self.tier = tier
        self.change = change
        self.rank = rank
        self.sparkline = sparkline
        self.lowVolume = lowVolume
        self.coinrankingURL = coinrankingURL
        self.the24HVolume = the24HVolume
        self.btcPrice = btcPrice
    }
}

// MARK: - Stats
class Stats: Codable {
    let total, totalCoins, totalMarkets, totalExchanges: Int
    let totalMarketCap, total24HVolume: String

    enum CodingKeys: String, CodingKey {
        case total, totalCoins, totalMarkets, totalExchanges, totalMarketCap
        case total24HVolume = "total24hVolume"
    }

    init(total: Int, totalCoins: Int, totalMarkets: Int, totalExchanges: Int, totalMarketCap: String, total24HVolume: String) {
        self.total = total
        self.totalCoins = totalCoins
        self.totalMarkets = totalMarkets
        self.totalExchanges = totalExchanges
        self.totalMarketCap = totalMarketCap
        self.total24HVolume = total24HVolume
    }
}
