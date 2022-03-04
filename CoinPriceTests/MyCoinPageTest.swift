//
//  MyCoinPageTest.swift
//  CoinPriceTests
//
//  Created by Jason Wong on 2/3/2022.
//

import XCTest
import RxBlocking
import RxTest
import RxCocoa
import RxSwift

@testable import CoinPrice

class MyCoinPageTest: XCTestCase {

    private var myCoinPageViewModel: MyCoinPageViewModel!
    private var coinService: MockCoinService!
    var myCoin: Coin!
    var scheduler: TestScheduler!
    var disposeBag: DisposeBag!
    private var userDefaults: UserDefaults!

    override func setUpWithError() throws {
        try super.setUpWithError()
        
        myCoin = Coin(uuid: "123", symbol: "", name: "123", color: "", iconURL: "", marketCap: "", price: "123", listedAt: 1, tier: 1, change: "", rank: 1, sparkline: [""], lowVolume: false, coinrankingURL: "", the24HVolume: "", btcPrice: "")
        coinService = MockCoinService(coin: myCoin)
        userDefaults = UserDefaults(suiteName: "Test")
        myCoinPageViewModel = MyCoinPageViewModel(coinService: coinService, userDefaults: userDefaults)
        scheduler = TestScheduler(initialClock: 0, resolution: 1)
        userDefaults.set(["123":"11"], forKey: "MyCoins")
    }

    override func tearDownWithError() throws {
        myCoinPageViewModel = nil
        coinService = nil
        scheduler = nil
        disposeBag = nil
        myCoin = nil
        userDefaults.removePersistentDomain(forName: "Test")
        super.tearDown()
    }

    func testGetCoins() throws {
        coinService.coinStream.onNext([myCoin])
        let result = myCoinPageViewModel.getCoins()
        XCTAssertEqual(result[0].uuid, "123")
    }
    
    func testSaveMyCoin() throws {
        myCoinPageViewModel.saveMyCoin(uuid: "123", quantity: 11)
        let dict = userDefaults.object(forKey: "MyCoins") as! [String : String]
        XCTAssertEqual(dict, ["123": "11"])
    }
    
    func testGetMyCoin() throws {
        var to : TestableObserver<[MyCoinViewModel]>
        to = scheduler.createObserver([MyCoinViewModel].self)
        _ = myCoinPageViewModel.coinViewModels.subscribe(to)
        scheduler.start()
        coinService.coinStream.onNext([myCoin])
        myCoinPageViewModel.getMyCoin {}
        XCTAssertEqual(to.events[1].value.element?.first!.displayText, [CoinViewModel(coin: myCoin, isBookmarked: false)].first?.displayText)
        XCTAssertEqual(to.events[1].value.element?.first!.quantityString, "11")
    }
}
