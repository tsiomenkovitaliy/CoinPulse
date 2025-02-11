//
//  CryptoCoin.swift
//  CoinPulse
//
//  Created by Vitalii Tsiomenko on 2/10/25.
//

import Foundation

struct CryptoCoin: Hashable {
    let id: String  
    let symbol: String  
    let name: String  
    let avgPrice: Double  
    let marketCap: Double  
    let priceChange: Double  
    let lastUpdated: Date
    let image: String
}
