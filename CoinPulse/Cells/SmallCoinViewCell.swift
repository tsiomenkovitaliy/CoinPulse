//
//  SmallCoinViewCell.swift
//  CoinPulse
//
//  Created by Vitalii Tsiomenko on 2/9/25.
//

import UIKit
import Kingfisher

final class SmallCoinViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var priceChangeLbl: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.cornerRadius = 16
        self.layer.masksToBounds = true
    }
    
    func configCell(with coin: CryptoCoin) {
        titleLbl.text = coin.name
        priceChangeLbl.backgroundColor = coin.priceChange > 0 ? .green : .red
        priceChangeLbl.text = String(format: "%.2f", coin.priceChange)  + "%"
        priceChangeLbl.layer.cornerRadius = 8
        priceChangeLbl.clipsToBounds = true
        imageView.kf.setImage(with: URL(string: coin.image)!)
        priceLbl.text = String(format: "%.2f", coin.avgPrice)
    }

}
