//
//  BookmarkPageTests.swift
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

class BookmarkPageTests: XCTestCase {

    private var bookmarkViewModel: BookmarkPageViewModel!
    private var coinService: MockCoinService!
    var myCoin: Coin!
    var scheduler: TestScheduler!
    var disposeBag: DisposeBag!
    private var userDefaults: UserDefaults!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        userDefaults = UserDefaults(suiteName: "Test")
        myCoin = Coin(uuid: "123", symbol: "", name: "123", color: "", iconURL: "", marketCap: "", price: "123", listedAt: 1, tier: 1, change: "", rank: 1, sparkline: [""], lowVolume: false, coinrankingURL: "", the24HVolume: "", btcPrice: "")
        coinService = MockCoinService(coin: myCoin)
        bookmarkViewModel = BookmarkPageViewModel(coinService: coinService, userDefaults: userDefaults)
        scheduler = TestScheduler(initialClock: 0, resolution: 1)
        
        userDefaults.set(["123"], forKey: "uuids")
    }

    override func tearDownWithError() throws {
        bookmarkViewModel = nil
        coinService = nil
        scheduler = nil
        disposeBag = nil
        myCoin = nil
        userDefaults.removePersistentDomain(forName: "Test")
        super.tearDown()
    }

    func testsBookmarkViewModel() throws {
        var to : TestableObserver<[CoinViewModel]>
        to = scheduler.createObserver([CoinViewModel].self)
        _ = bookmarkViewModel.coinViewModels.subscribe(to)
        scheduler.start()
        coinService.coinStream.onNext([myCoin])
        bookmarkViewModel.getBookmark {}
        XCTAssertEqual(to.events[1].value.element?.first!.displayText, [CoinViewModel(coin: myCoin, isBookmarked: false)].first?.displayText)
    }
}
