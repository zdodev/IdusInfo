import UIKit
import Combine

final class SearchBarDelegate: NSObject, UISearchBarDelegate {
    private let tapAction: PassthroughSubject<String, Never>
    
    init(tapAction: PassthroughSubject<String, Never>) {
        self.tapAction = tapAction
        
        super.init()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text else {
            return
        }
        tapAction.send(searchText)
    }
}
