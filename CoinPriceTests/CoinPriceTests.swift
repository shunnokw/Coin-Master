//
//  WheelsalesTests.swift
//  WheelsalesTests
//
//  Created by Jason Wong on 16/2/2022.
//

import XCTest
import RxBlocking
import RxTest
import RxCocoa
import RxSwift

@testable import CoinPrice

// Refresh function should also be tested

class CoinPriceTests: XCTestCase {
    
    private var coinListViewModel: CoinListViewModel!
    private var coinService: MockCoinService!
    var scheduler: TestScheduler!
    var disposeBag: DisposeBag!
    var myCoin: Coin!

    override func setUpWithError() throws {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        myCoin = Coin(uuid: "123", symbol: "", name: "123", color: "", iconURL: "", marketCap: "", price: "123", listedAt: 1, tier: 1, change: "", rank: 1, sparkline: [""], lowVolume: false, coinrankingURL: "", the24HVolume: "", btcPrice: "")
        coinService = MockCoinService(coin: myCoin)
        coinListViewModel = CoinListViewModel(coinService: coinService)
        scheduler = TestScheduler(initialClock: 0, resolution: 1)
        disposeBag = DisposeBag()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        coinListViewModel = nil
        coinService = nil
        scheduler = nil
        disposeBag = nil
        myCoin = nil
        super.tearDown()
    }
    
    func testListView() throws {
        let mockVM = MockCoinListViewModel(coin: myCoin)
        let view = HomeViewController(viewModel: mockVM)
        view.bindTableData()
        let cell0 = view.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? MyTableCell
        XCTAssertEqual(cell0?.titleLabel.text, "Name: 123\nPrice: 123")
    }

    func testCoinListViewModel() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
        
        var to : TestableObserver<[CoinViewModel]>
        to = scheduler.createObserver([CoinViewModel].self)
        _ = coinListViewModel.coinViewModels().subscribe(to)
        scheduler.start()
        coinListViewModel.fetchCoin()
        XCTAssertEqual(to.events.first?.value.element?.first!.displayText, [CoinViewModel(coin: myCoin)].first?.displayText)
    }

//    func testPerformanceExample() throws {
//        // This is an example of a performance test case.
//        measure {
//            // Put the code you want to measure the time of here.
//        }
//    }

}

class MockCoinService: CoinServiceProtocol {
    var hideLoading = BehaviorRelay<Bool>(value: false)
    var coinStream = PublishSubject<[Coin]>()
    
    var myCoin : Coin
    
    init(coin: Coin) {
        self.myCoin = coin
    }
    
    func fetchCoins() {
        coinStream.onNext([myCoin])
    }
}

class MockCoinListViewModel : CoinListViewModelProtocol {
    var hideLoading = BehaviorRelay<Bool>(value: false)
    
    private var coinStream = PublishSubject<[Coin]>()
    private var myCoin: Coin

    init(coin: Coin) {
        self.myCoin = coin
    }

    func fetchCoin() {
        coinStream.onNext([myCoin])
    }

    func coinViewModels() -> Observable<[CoinViewModel]> {
        coinStream.map {
            $0.map {
                CoinViewModel(coin: $0)
            }
        }
    }
}
