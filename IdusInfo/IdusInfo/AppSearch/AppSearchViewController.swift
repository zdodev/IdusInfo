import UIKit
import Combine

final class AppSearchViewController: UIViewController {
    private let searchBarDelegate: SearchBarDelegate
    
    private var viewModel = AppSearchViewModel()
    private var cancellables = Set<AnyCancellable>()
    private let tapAction = PassthroughSubject<String, Never>()
    
    init() {
        searchBarDelegate = SearchBarDelegate(tapAction: tapAction)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViews()
        bind()
    }
    
    private func configureViews() {
        view.backgroundColor = .systemBackground
        title = "⭐️Store"
        
        configureSearchBar()
    }
    
    private func configureSearchBar() {
        let searchController = UISearchController()
        searchController.searchBar.delegate = searchBarDelegate
        searchController.searchBar.placeholder = "Search APP_ID"
        searchController.searchBar.text = Constants.idusAppID
        navigationItem.searchController = searchController
    }
    
    private func bind() {
        let input = AppSearchViewModel.Input(searchTap: tapAction.eraseToAnyPublisher())
        let output = viewModel.transform(input: input)
        
        output.lookup
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    self?.alertViewController(error.localizedDescription)
                case .finished:
                    print("finished")
                }
            }, receiveValue: { [weak self] lookup in
                if lookup.resultCount == .zero {
                    self?.alertViewController("검색 결과가 없습니다.")
                    return
                }
                if let lookupDetail = lookup.results.first {
                    let appDetailViewModel = AppDetailViewModel(lookupDetail: lookupDetail)
                    let appDetailViewController = AppDetailViewController(
                        viewModel: appDetailViewModel,
                        title: lookupDetail.trackCensoredName
                    )
                    self?.navigationController?.pushViewController(appDetailViewController, animated: true)
                }
            })
            .store(in: &cancellables)
    }
}

extension AppSearchViewController {
    private func alertViewController(_ message: String) {
        let alertViewController = UIAlertController(title: "에러 발생", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "확인", style: .default)
        alertViewController.addAction(action)
        present(alertViewController, animated: true)
    }
}
