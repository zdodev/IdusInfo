import UIKit

final class AppDetailCollectionViewFlowLayout: UICollectionViewFlowLayout {
    override func prepare() {
        super.prepare()
        
        setLayout()
    }
    
    private func setLayout() {
        guard let collectionView = collectionView else {
            return
        }
        
        let itemWidth = collectionView.bounds.width * 0.7
        let itemHeight = collectionView.bounds.height
        itemSize = CGSize(
            width: itemWidth,
            height: itemHeight
        )
        scrollDirection = .horizontal
    }
}
