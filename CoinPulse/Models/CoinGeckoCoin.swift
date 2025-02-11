//
//  CoinGeckoCoin.swift
//  CoinPulse
//
//  Created by Vitalii Tsiomenko on 2/8/25.
//

struct CoinGeckoCoin: Codable {  
    let id: String  
    let symbol: String  
    let name: String  
    let current_price: Double  
    let price_change_percentage_24h: Double  
    let market_cap: Double
    let image: String
}
