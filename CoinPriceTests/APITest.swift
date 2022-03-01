//
//  APITest.swift
//  WheelsalesTests
//
//  Created by Jason Wong on 17/2/2022.
//

import XCTest
@testable import CoinPrice

class APITest: XCTestCase {
    
    var coinAPI: CoinAPI!
    var expectation: XCTestExpectation!
    let apiURL = URL(string: "https://api.coinranking.com/v2/coins")!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        super.setUp()
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [MockURLProtocol.self]
        let urlSession = URLSession.init(configuration: configuration)
        
        coinAPI = CoinAPI(urlSession: urlSession)
        expectation = expectation(description: "Expectation")
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testSuccessfulResponse() {
      // Prepare mock response.
      let name = "Bitcoin"
      let totalCoins = 13297
      let price = "43935.4159133033"
      let jsonString = """
                       {
                           "status": "success",
                           "data": {
                               "stats": {
                                   "total": 13297,
                                   "totalCoins": \(totalCoins),
                                   "totalMarkets": 26452,
                                   "totalExchanges": 185,
                                   "totalMarketCap": "2112815152950",
                                   "total24hVolume": "65288516766"
                               },
                               "coins": [
                                   {
                                       "uuid": "Qwsogvtv82FCd",
                                       "symbol": "BTC",
                                       "name": "\(name)",
                                       "color": "#f7931A",
                                       "iconUrl": "https://cdn.coinranking.com/bOabBYkcX/bitcoin_btc.svg",
                                       "marketCap": "833033323495",
                                       "price": "\(price)",
                                       "listedAt": 1330214400,
                                       "tier": 1,
                                       "change": "-0.67",
                                       "rank": 1,
                                       "sparkline": [
                                           "44232.6253090432614112120000",
                                           "44160.5452452731025211240000",
                                           "44019.6637636754757315080000",
                                       ],
                                       "lowVolume": false,
                                       "coinrankingUrl": "https://coinranking.com/coin/Qwsogvtv82FCd+bitcoin-btc",
                                       "24hVolume": "18303821691",
                                       "btcPrice": "1"
                                   }
                               ]
                           }
                       }
                       """
      let data = jsonString.data(using: .utf8)
      
      MockURLProtocol.requestHandler = { request in
        guard let url = request.url, url == self.apiURL else {
          throw APIResponseError.request
        }
        
        let response = HTTPURLResponse(url: self.apiURL, statusCode: 200, httpVersion: nil, headerFields: nil)!
        return (response, data)
      }
      
      // Call API.
      coinAPI.fetchAPI { (result) in
        switch result {
        case .success(let coinModel):
            XCTAssertEqual(coinModel.data.coins?.first?.price, price, "Incorrect price")
            XCTAssertEqual(coinModel.data.coins?.first?.name,  name, "Incorrect name")
            XCTAssertEqual(coinModel.data.stats.totalCoins, totalCoins, "Incorrect total number of coin")
//          XCTAssertEqual(post.body, body, "Incorrect body.")
        case .failure(let error):
          XCTFail("Error was not expected: \(error)")
        }
        self.expectation.fulfill()
      }
      wait(for: [expectation], timeout: 1.0)
    }
    
    
    func testParsingFailure() {
        // Prepare response
        let data = Data()
        MockURLProtocol.requestHandler = { request in
          let response = HTTPURLResponse(url: self.apiURL, statusCode: 200, httpVersion: nil, headerFields: nil)!
          return (response, data)
        }
        
        // Call API.
        coinAPI.fetchAPI { (result) in
          switch result {
          case .success(_):
            XCTFail("Success response was not expected.")
          case .failure(let error):
            guard let error = error as? APIResponseError else {
              XCTFail("Incorrect error received.")
              self.expectation.fulfill()
              return
            }
            
            XCTAssertEqual(error, APIResponseError.parsing, "Parsing error was expected.")
          }
          self.expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
      }
}

class MockURLProtocol: URLProtocol {
  
  override class func canInit(with request: URLRequest) -> Bool {
    // To check if this protocol can handle the given request.
    return true
  }

  override class func canonicalRequest(for request: URLRequest) -> URLRequest {
    // Here you return the canonical version of the request but most of the time you pass the orignal one.
    return request
  }
    
  static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data?))?

  override func startLoading() {
    // This is where you create the mock response as per your test case and send it to the URLProtocolClient.
      guard let handler = MockURLProtocol.requestHandler else {
          fatalError("Handler is unavailable.")
        }
          
        do {
          // 2. Call handler with received request and capture the tuple of response and data.
          let (response, data) = try handler(request)
          
          // 3. Send received response to the client.
          client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
          
          if let data = data {
            // 4. Send received data to the client.
            client?.urlProtocol(self, didLoad: data)
          }
          
          // 5. Notify request has been finished.
          client?.urlProtocolDidFinishLoading(self)
        } catch {
          // 6. Notify received error.
          client?.urlProtocol(self, didFailWithError: error)
        }
  }

  override func stopLoading() {
    // This is called if the request gets canceled or completed.
  }
}
