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
        mockVM.fetchCoin()
        let cell0 = view.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? MyTableCell
        XCTAssertEqual(cell0?.titleLabel.text, "Name: 123\nPrice: $123 USD")
    }
    
    func testCoinListViewModel() throws {
        var to : TestableObserver<[CoinViewModel]>
        to = scheduler.createObserver([CoinViewModel].self)
        _ = coinListViewModel.coinViewModels.subscribe(to)
        scheduler.start()
        coinListViewModel.fetchCoin()
        XCTAssertEqual(to.events[1].value.element?.first!.displayText, [CoinViewModel(coin: myCoin, isBookmarked: false)].first?.displayText)
    }
}

class MockCoinService: CoinServiceProtocol {
    var hideLoading = BehaviorRelay<Bool>(value: false)
    var coinStream = BehaviorSubject<[Coin]>(value: [])
    
    var myCoin : Coin
    
    init(coin: Coin) {
        self.myCoin = coin
    }
    
    func fetchCoins() {
        coinStream.onNext([myCoin])
    }
}

class MockCoinListViewModel : CoinListViewModelProtocol {
    
    func sortAZ() {
        
    }
    
    func sortZA() {
        
    }
    
    func sortLow2High() {
        
    }
    
    func sortHigh2Low() {
        
    }
    
    func addRemoveBookmark(uuid: String) {
        
    }
    
    var hideLoading = BehaviorRelay<Bool>(value: false)
    var coinViewModels = BehaviorSubject<[CoinViewModel]>(value: [])
    private var coinStream = BehaviorSubject<[Coin]>(value: [])
    private var myCoin: Coin
    private let bag = DisposeBag()
    
    init(coin: Coin) {
        self.myCoin = coin
    }
    
    func fetchCoin() {
//        coinStream.onNext([myCoin])
        coinViewModels.onNext([CoinViewModel(coin: myCoin, isBookmarked: false)])
    }
}
