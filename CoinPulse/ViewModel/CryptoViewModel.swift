//
//  CryptoViewModel.swift
//  CoinPulse
//
//  Created by Vitalii Tsiomenko on 2/8/25.
//

import RxSwift
import RxCocoa
import RxRelay
import Foundation

final class CryptoViewModel {
    private let coreDataService = CoreDataService.shared
    

    var isLoading = BehaviorRelay<Bool>(value: false)
    var currentPage = BehaviorRelay<Int>(value: 1)
    var currentCoins = BehaviorRelay<[CryptoCoin]>(value: [])
    
    let itemsPerPage = 20
    
    private let disposeBag = DisposeBag()
    
    func settings() {
        self.coreDataService.fetchUsers()
        
        Observable.merge(
        Observable.just(()),
        Observable<Int>.interval(.seconds(10), scheduler: MainScheduler.instance).map { _ in () })
            .flatMapLatest { _ in self.fetchCombinedData() }
            .subscribe(onNext: {
                self.coreDataService.allCoins.accept($0)
                self.coreDataService.save(coins: self.coreDataService.allCoins.value)
                    .subscribe(
                    onCompleted: { print("✅ Коины сохранены") },
                    onError: { error in print("❌ Ошибка: \(error)") }
                )
                .disposed(by: self.disposeBag)
            })
            .disposed(by: disposeBag)
        
        Observable.combineLatest(currentPage, coreDataService.allCoins)
            .subscribe(onNext: { page, coins in
                self.currentCoins.accept(Array(coins.prefix(page * self.itemsPerPage)))
            })
            .disposed(by: disposeBag)
    }
    
    private let geckoService = CryptoService<[CoinGeckoCoin]>(
        url: URL(string: "https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd")!  
    )  
    
    private let capService = CryptoService<CoinCapResponse>(  
        url: URL(string: "https://api.coincap.io/v2/assets")!  
    )
    
    func shouldLoadNextPage(currentIndex: Int) -> Bool {
        guard !isLoading.value else { return false }
        
        let totalLoaded = currentPage.value * itemsPerPage
        let shouldLoad = currentIndex >= totalLoaded - 5
        let hasMoreData = totalLoaded < coreDataService.allCoins.value.count
        
        return shouldLoad && hasMoreData
    }
    
    func fetchCombinedData() -> Observable<[CryptoCoin]> {
        return Observable.combineLatest(
            geckoService.fetchData(),
            capService.fetchData().map { $0.data }
        )
        .map { geckoCoins, capCoins in
          return self.mergeData(geckos: geckoCoins, caps: capCoins)
        }
        .retry(when: { errors in  
            errors.flatMap { _ in  
                Observable<Int>.timer(.seconds(15), scheduler: MainScheduler.instance)  
            }  
        })  
    }
    
    private func mergeData(geckos: [CoinGeckoCoin], caps: [CoinCapCoin]) -> [CryptoCoin] {
        let geckoSlice = geckos.sorted { $0.market_cap > $1.market_cap && $0.market_cap > 1_000_000_000 }
        let capSlice = caps.sorted { $0.marketCapUsd > $1.marketCapUsd && Double($0.marketCapUsd)! > 1_000_000_000 }
        
        return zip(geckoSlice,capSlice).map { geckos, cap in
            let avgPrice = (geckos.current_price + (Double(cap.priceUsd) ?? 0)) / 2
            let priceChange = (geckos.price_change_percentage_24h + (Double(cap.changePercent24Hr) ?? 0)) / 2
            
            return CryptoCoin(id: geckos.id,
                              symbol: geckos.symbol,
                              name: geckos.name,
                              avgPrice: avgPrice ,
                              marketCap: geckos.market_cap,
                              priceChange: priceChange,
                              lastUpdated: .now,
                              image: geckos.image)
        }
    }
}
