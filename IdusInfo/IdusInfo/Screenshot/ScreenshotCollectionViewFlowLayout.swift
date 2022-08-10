import UIKit

final class ScreenshotCollectionViewFlowLayout: UICollectionViewFlowLayout {
    override func prepare() {
        super.prepare()
        
        setLayout()
    }
    
    private func setLayout() {
        guard let collectionView = self.collectionView else {return}
        
        let itemWidth = collectionView.bounds.width * 0.8
        let itemHeight = collectionView.bounds.height
        itemSize = CGSize(
            width: itemWidth,
            height: itemHeight
        )
        
        let collectionViewSize = collectionView.bounds.size
        let xInset = (collectionViewSize.width - itemSize.width) / 2
        sectionInset = UIEdgeInsets(top: 0, left: xInset, bottom: 0, right: xInset)
        scrollDirection = .horizontal
    }
}
