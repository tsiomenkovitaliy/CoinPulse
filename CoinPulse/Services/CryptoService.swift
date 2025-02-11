//
//  CryptoService.swift
//  CoinPulse
//
//  Created by Vitalii Tsiomenko on 2/8/25.
//

import Foundation
import RxSwift

final class CryptoService<T> where T: Decodable {
    private let url: URL
    
    init(url: URL) {
        self.url = url
    }
    
    func fetchData() -> Observable<T> {
        return URLSession.shared.rx.data(request: URLRequest(url: url))
            .decode(type: T.self, decoder: JSONDecoder())
    }
}
