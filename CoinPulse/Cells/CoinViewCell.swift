//
//  CoinViewCell.swift
//  CoinPulse
//
//  Created by Vitalii Tsiomenko on 2/8/25.
//

import UIKit
import Kingfisher

final class CoinViewCell: UICollectionViewCell {
    @IBOutlet private weak var nameLbl: UILabel!
    @IBOutlet private weak var avgPriceLbl: UILabel!
    @IBOutlet private weak var priceChangeLbl: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.cornerRadius = 16
        self.clipsToBounds = true
    }
    
    func configCell(with coin: CryptoCoin) {
        nameLbl.text = coin.name
        priceChangeLbl.backgroundColor = coin.priceChange > 0 ? .green : .red
        priceChangeLbl.text = String(format: "%.2f", coin.priceChange) + "%"
        priceChangeLbl.layer.cornerRadius = 8
        priceChangeLbl.clipsToBounds = true
        imageView.kf.setImage(with: URL(string: coin.image)!)
        avgPriceLbl.text = String(format: "%.2f", coin.avgPrice)
    }
}
