//
//  UserService.swift
//  CoinPulse
//
//  Created by Vitalii Tsiomenko on 2/10/25.
//
import RxSwift
import RxCocoa
import CoreData

final class CoreDataService {
    static let shared = CoreDataService()
    
    var allCoins = BehaviorRelay<[CryptoCoin]>(value: [])
    
    private let context = CoreDataManager.shared.context

    func updateAllAvgPrice(avgPrice: Double) -> Completable {
        return Completable.create { completable in
            let fetchRequest: NSFetchRequest<CryptoModel> = CryptoModel.fetchRequest()

            do {
                let users = try self.context.fetch(fetchRequest)
                users.forEach { $0.avgPrice = avgPrice }
                try self.context.save()
                completable(.completed)
            } catch {
                completable(.error(error))
            }

            return Disposables.create()
        }
    }
    
    func deleteAllCoins() -> Completable {
        return Completable.create { completable in
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = CryptoModel.fetchRequest()
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

            do {
                try self.context.execute(deleteRequest)
                try self.context.save()
                completable(.completed)
            } catch {
                completable(.error(error))
            }

            return Disposables.create()
        }
    }
    
    func fetchUsers()  {
        let fetchRequest: NSFetchRequest<CryptoModel> = CryptoModel.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "avgPrice", ascending: false)]
        do {
            let coinsModel = try self.context.fetch(fetchRequest)
            let coins =  coinsModel.map { coin in
                CryptoCoin(id: coin.id ?? "", symbol: coin.symbol ?? "", name: coin.name ?? "", avgPrice: coin.avgPrice, marketCap: coin.marketCap, priceChange: coin.priceChange, lastUpdated: coin.lastUpdated ?? .now, image: coin.image ?? "")
            }
            self.allCoins.accept(coins)
//                self.allCoins.onCompleted()
        } catch {
//                self.allCoins.onError(error)
        }
    }
    
    func save(coins: [CryptoCoin]) -> Completable {
        return Completable.create { completable in
            self.deleteAllCoins()
            for coin in coins {
                let cryptoModel = CryptoModel(context: self.context)
                cryptoModel.id = coin.id
                cryptoModel.name = coin.name
                cryptoModel.avgPrice = coin.avgPrice
                cryptoModel.symbol = coin.symbol
                cryptoModel.marketCap = coin.marketCap
                cryptoModel.priceChange = coin.priceChange
                cryptoModel.lastUpdated = coin.lastUpdated
                cryptoModel.image = coin.image
            }
            
            
            do {
                try self.context.save()
                completable(.completed)
            } catch {
                completable(.error(error))
            }
            
            return Disposables.create()
        }
    }
}
