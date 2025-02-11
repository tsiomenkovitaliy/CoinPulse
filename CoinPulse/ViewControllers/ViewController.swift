//
//  ViewController.swift
//  CoinPulse
//
//  Created by Vitalii Tsiomenko on 2/8/25.
//

import UIKit
import RxSwift
import RxCocoa
import RxRelay

enum Section { case horizontal, vertical }

final class ViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    private let viewModel = CryptoViewModel()
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, CryptoCoin>!
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionViewDataSource()
        settingsCollectionView()
        viewModel.settings()
        
        viewModel.currentCoins
            .map { (coins) -> NSDiffableDataSourceSnapshot<Section, CryptoCoin> in
                var snapshot = NSDiffableDataSourceSnapshot<Section, CryptoCoin>()
                snapshot.appendSections([.horizontal, .vertical])
                snapshot.appendItems(Array(coins.prefix(3)), toSection: .horizontal)
                snapshot.appendItems(Array(coins.dropFirst(3)), toSection: .vertical)
                return snapshot
            }
        .observe(on: MainScheduler.instance)
        .subscribe(onNext: { [dataSource] snapshot in
            dataSource!.apply(snapshot, animatingDifferences: false) {
                self.animateCollectionViewCells()
            }
        })
        .disposed(by: disposeBag)
        
        collectionView.rx.willDisplayCell
            .filter { [weak self] _, indexPath in
                guard let self = self else { return false }
                
                return self.viewModel.shouldLoadNextPage(currentIndex: indexPath.item)
            }
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                
                viewModel.currentPage.accept(viewModel.currentPage.value + 1)
            })
            .disposed(by: disposeBag)
        
        collectionView.rx.didScroll
            .subscribe(onNext: {
                UIView.setAnimationsEnabled(false)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    UIView.setAnimationsEnabled(true)
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func calculateIndexPaths(_ newItems: [CryptoCoin]) -> [IndexPath] {
        let startIndex = dataSource.accessibilityElementCount()
        let endIndex = startIndex + newItems.count
        return (startIndex..<endIndex).map {
            IndexPath(item: $0, section: 0)
        }
    }
    
    private func setupCollectionViewDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, CryptoCoin>(collectionView: collectionView, cellProvider: { (collectionView, indexPath, model) -> UICollectionViewCell? in
            
            if indexPath.section == 0 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier:  String(describing: CoinViewCell.self), for: indexPath) as! CoinViewCell
                cell.configCell(with: model)
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier:  String(describing: SmallCoinViewCell.self), for: indexPath) as! SmallCoinViewCell
                cell.configCell(with: model)
                return cell
            }
        })
    }
    
    private func settingsCollectionView() {
        collectionView.register(UINib(nibName: String(describing: CoinViewCell.self), bundle: nil), forCellWithReuseIdentifier: String(describing: CoinViewCell.self))
        collectionView.register(UINib(nibName: String(describing: SmallCoinViewCell.self), bundle: nil), forCellWithReuseIdentifier: String(describing: SmallCoinViewCell.self))
        
        collectionView.collectionViewLayout = createLayout()
    }
    
    private func with<T>(_ value: T, _ fn: (inout T) -> Void) -> T {
        var temp = value
        fn(&temp)
        return temp
    }
    
    private func animateCollectionViewCells() {
        collectionView.visibleCells.forEach { cell in
            let indexPath = collectionView.indexPath(for: cell)!
            cell.transform = CGAffineTransform(translationX: 0, y: 100)
            
            UIView.animate(
                withDuration: 0.7,
                delay: 0.05 * Double(indexPath.row),
                usingSpringWithDamping: 0.7,
                initialSpringVelocity: 0.8,
                animations: {
                    cell.transform = .identity
                }
            )
        }
    }
    
    private func createLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment in
            if sectionIndex == 0 {
                // Горизонтальная секция с тремя ячейками
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .fractionalHeight(1.0)
                )
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(0.9),
                    heightDimension: .absolute(120)
                )
                let group = NSCollectionLayoutGroup.horizontal(
                    layoutSize: groupSize,
                    repeatingSubitem: item,
                    count: 1
                )
                
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .groupPaging
                section.interGroupSpacing = 10
                section.contentInsets = .init(top: 0, leading: 16, bottom: 20, trailing: 16)
                return section
            } else {
                // Вертикальная секция
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .estimated(60)
                )
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .estimated(60)
                )
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 12
                section.contentInsets = .init(top: 0, leading: 16, bottom: 0, trailing: 16)
                return section
            }
        }
    }
}
