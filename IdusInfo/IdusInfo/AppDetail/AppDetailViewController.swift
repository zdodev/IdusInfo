import UIKit
import Combine

final class AppDetailViewController: UIViewController {
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    private let backgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private let screenshotCollectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: AppDetailCollectionViewFlowLayout()
        )
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    private let appInformationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let moreButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(
            nil,
            action: #selector(tappedMoreButton),
            for: .touchUpInside
        )
        return button
    }()
    
    private let viewModel: AppDetailViewModel
    private var cancellables = Set<AnyCancellable>()
    private let tapAction = PassthroughSubject<Void, Never>()
    
    init(viewModel: AppDetailViewModel, title: String) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
        
        self.title = title
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
        view.addSubview(scrollView)
        
        screenshotCollectionView.register(
            ImageCollectionViewCell.self,
            forCellWithReuseIdentifier: ImageCollectionViewCell.identifier
        )
        screenshotCollectionView.dataSource = self
        screenshotCollectionView.delegate = self
        
        scrollView.addSubview(backgroundView)
        backgroundView.addSubview(screenshotCollectionView)
        backgroundView.addSubview(appInformationLabel)
        backgroundView.addSubview(moreButton)
        
        appInformationLabel.text = viewModel.lookupDetail.description
        
        setLayout()
    }
    
    private func bind() {
        let input = AppDetailViewModel.Input(expandTap: tapAction.eraseToAnyPublisher())
        let output = viewModel.transform(input: input)
        
        output.buttonTitle
            .sink { [weak self] title in
                self?.moreButton.setTitle(title, for: .normal)
            }
            .store(in: &cancellables)
        output.numberOfLines
            .assign(to: \.numberOfLines, on: appInformationLabel)
            .store(in: &cancellables)
    }
    
    private func setLayout() {
        let safeArea = view.safeAreaLayoutGuide
        let scrollViewContentLayout = scrollView.contentLayoutGuide
        let scrollViewFrameLayout = scrollView.frameLayoutGuide
        let marginLayout = backgroundView.layoutMarginsGuide
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            
            backgroundView.topAnchor.constraint(equalTo: scrollViewContentLayout.topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: scrollViewContentLayout.bottomAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: scrollViewContentLayout.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: scrollViewContentLayout.trailingAnchor),
            backgroundView.widthAnchor.constraint(equalTo: scrollViewFrameLayout.widthAnchor),
            
            screenshotCollectionView.topAnchor.constraint(equalTo: marginLayout.topAnchor),
            screenshotCollectionView.leadingAnchor.constraint(equalTo: marginLayout.leadingAnchor),
            screenshotCollectionView.trailingAnchor.constraint(equalTo: marginLayout.trailingAnchor),
            screenshotCollectionView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.7),
            
            appInformationLabel.topAnchor.constraint(equalTo: screenshotCollectionView.bottomAnchor, constant: 20),
            appInformationLabel.leadingAnchor.constraint(equalTo: marginLayout.leadingAnchor),
            appInformationLabel.trailingAnchor.constraint(equalTo: marginLayout.trailingAnchor),

            moreButton.topAnchor.constraint(equalTo: appInformationLabel.bottomAnchor, constant: 20),
            moreButton.trailingAnchor.constraint(equalTo: appInformationLabel.trailingAnchor),
            moreButton.bottomAnchor.constraint(equalTo: marginLayout.bottomAnchor)
        ])
    }
    
    @objc private func tappedMoreButton() {
        tapAction.send()
    }
}

extension AppDetailViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.lookupDetail.screenshotUrls.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ImageCollectionViewCell.identifier,
            for: indexPath) as? ImageCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        cell.configureCell(viewModel.lookupDetail.screenshotUrls[indexPath.item])
        
        return cell
    }
}

extension AppDetailViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let screenshotViewController = ScreenshotViewController(screenshotUrls: viewModel.lookupDetail.screenshotUrls)
        present(screenshotViewController, animated: true)
    }
}
