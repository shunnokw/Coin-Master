//
// Created by Jason Wong on 12/2/2022.
//

import Foundation
import RxSwift
import RxCocoa

protocol CoinListViewModelProtocol {
    var hideLoading: BehaviorRelay<Bool> { get }
    var coinViewModels: BehaviorSubject<[CoinViewModel]> { get }

    func fetchCoin()
    func sortAZ()
    func sortZA()
    func sortLow2High()
    func sortHigh2Low()
    func addRemoveBookmark(uuid: String)
}

final class CoinListViewModel: CoinListViewModelProtocol {
    let hideLoading: BehaviorRelay<Bool>
    private let coinService: CoinServiceProtocol
    let coinViewModels = BehaviorSubject<[CoinViewModel]>(value: [])
    private let bag = DisposeBag()

    // Unit testing viewModel
    init(coinService: CoinServiceProtocol) {
        self.coinService = coinService
        hideLoading = coinService.hideLoading

        coinService.coinStream.map {
                    $0.map {
                        CoinViewModel(coin: $0, isBookmarked: self.checkIsBookmarked(uuid: $0.uuid))
                    }
                }
                .bind(to: coinViewModels).disposed(by: bag)
    }

    func checkIsBookmarked(uuid: String) -> Bool {
        let userDefaults = UserDefaults.standard
        guard let uuids: [String] = userDefaults.stringArray(forKey: "uuids") else {
            return false
        }
        return uuids.contains(uuid)
    }

    func sortAZ() {
        do {
            let snapShot = try coinService.coinStream.value()
            let sortedCoins = snapShot.sorted {
                $0.name < $1.name
            }
            var cvm = [CoinViewModel]()
            for coin in sortedCoins {
                cvm.append(CoinViewModel(coin: coin, isBookmarked: self.checkIsBookmarked(uuid: coin.uuid)))
            }
            coinViewModels.onNext(cvm)
        } catch {
            print(error)
        }
    }

    func sortZA() {
        do {
            let snapShot = try coinService.coinStream.value()
            let sortedCoins = snapShot.sorted {
                $0.name > $1.name
            }
            var cvm = [CoinViewModel]()
            for coin in sortedCoins {
                cvm.append(CoinViewModel(coin: coin, isBookmarked: self.checkIsBookmarked(uuid: coin.uuid)))
            }
            coinViewModels.onNext(cvm)
        } catch {
            print(error)
        }
    }

    func sortLow2High() {
        do {
            let snapShot = try coinService.coinStream.value()
            let sortedCoins = snapShot.sorted {
                Decimal(string: $0.price, locale: .current)! < Decimal(string: $1.price, locale: .current)!
            }
            var cvm = [CoinViewModel]()
            for coin in sortedCoins {
                cvm.append(CoinViewModel(coin: coin, isBookmarked: self.checkIsBookmarked(uuid: coin.uuid)))
            }
            coinViewModels.onNext(cvm)
        } catch {
            print(error)
        }
    }

    func sortHigh2Low() {
        do {
            let snapShot = try coinService.coinStream.value()
            let sortedCoins = snapShot.sorted {
                Decimal(string: $0.price, locale: .current)! > Decimal(string: $1.price, locale: .current)!
            }
            var cvm = [CoinViewModel]()
            for coin in sortedCoins {
                cvm.append(CoinViewModel(coin: coin, isBookmarked: self.checkIsBookmarked(uuid: coin.uuid)))
            }
            coinViewModels.onNext(cvm)
        } catch {
            print(error)
        }
    }

    func addRemoveBookmark(uuid: String) {
        let userDefaults = UserDefaults.standard
        var uuids: [String] = userDefaults.stringArray(forKey: "uuids") ?? []
        if (checkIsBookmarked(uuid: uuid)) {
            let newuuids = uuids.filter {
                $0 != uuid
            }
            userDefaults.set(newuuids, forKey: "uuids")
        } else {
            uuids.append(uuid)
            userDefaults.set(uuids, forKey: "uuids")
        }

        do {
            let snapShotCoinModel = try coinViewModels.value()
            var cvm = [CoinViewModel]()
            for coinModel in snapShotCoinModel {
                var new = coinModel
                if (coinModel.uuid == uuid) {
                    new.isBookmarked = !coinModel.isBookmarked
                }
                cvm.append(new)
            }
            coinViewModels.onNext(cvm)
        } catch {
            print(error)
        }
    }

    func fetchCoin() {
        coinService.fetchCoins()
    }
}
