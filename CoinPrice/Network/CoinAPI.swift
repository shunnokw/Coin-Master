//
//  CoinAPI.swift
//  Wheelsales
//
//  Created by Jason Wong on 17/2/2022.
//

import Foundation

enum APIResponseError : Error {
    case network
    case parsing
    case request
}

class CoinAPI {
    let urlSession: URLSession
    
    init(urlSession: URLSession = URLSession.shared) {
      self.urlSession = urlSession
    }
    
    func fetchAPI(completion: @escaping (_ result: Result<CoinModel, Error>) -> Void) {
        let url = URL(string: "https://api.coinranking.com/v2/coins")
        let task = urlSession.dataTask(with: url!) {
            (data, response, error) in
            do {
                if let error = error {
                    throw error
                }
                
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    print("Error with the response, unexpected status code: \(response)")
                          completion(Result.failure(APIResponseError.network))
                          return
                }

                if let responseData = data, let object = try? JSONDecoder().decode(CoinModel.self, from: responseData) {
                  completion(Result.success(object))
                } else {
                  throw APIResponseError.parsing
                }
                
            } catch {
                completion(Result.failure(error))
            }
        }
        task.resume()
    }
}
