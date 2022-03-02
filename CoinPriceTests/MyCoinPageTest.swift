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
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        myCoin = Coin(uuid: "123", symbol: "", name: "123", color: "", iconURL: "", marketCap: "", price: "123", listedAt: 1, tier: 1, change: "", rank: 1, sparkline: [""], lowVolume: false, coinrankingURL: "", the24HVolume: "", btcPrice: "")
        coinService = MockCoinService(coin: myCoin)
        myCoinPageViewModel = MyCoinPageViewModel(coinService: coinService)
        scheduler = TestScheduler(initialClock: 0, resolution: 1)
    }

    override func tearDownWithError() throws {
        myCoinPageViewModel = nil
        coinService = nil
        scheduler = nil
        disposeBag = nil
        myCoin = nil
        super.tearDown()
    }

    func testGetCoins() throws {
        coinService.coinStream.onNext([myCoin])
        let result = myCoinPageViewModel.getCoins()
        XCTAssertEqual(result[0].uuid, "123")
    }
    
    func testGetMyCoin() throws {
        myCoinPageViewModel.getMyCoin {}
    }
    
    func testSaveMyCoin() throws {
        myCoinPageViewModel.saveMyCoin(uuid: <#T##String#>, quantity: <#T##Decimal#>)
    }
}
