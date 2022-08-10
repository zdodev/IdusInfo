import Foundation
import Combine

final class AppDetailViewModel {
    struct Input {
        let expandTap: AnyPublisher<Void, Never>
    }
    
    struct Output {
        let buttonTitle: AnyPublisher<String, Never>
        let numberOfLines: AnyPublisher<Int, Never>
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    private let isExpandSubject = CurrentValueSubject<Bool, Never>(false)
    
    let lookupDetail: LookupDetail
    
    init(lookupDetail: LookupDetail) {
        self.lookupDetail = lookupDetail
    }
    
    func transform(input: Input) -> Output {
        input.expandTap
            .combineLatest(isExpandSubject)
            .map { _, value in
                !value
            }
            .assign(to: \.value, on: isExpandSubject)
            .store(in: &cancellables)
        
        let buttonTitle = isExpandSubject
            .map { $0 ? "접기" : "더 보기" }
            .eraseToAnyPublisher()
        
        let numberOfLines = isExpandSubject
            .map { $0 ? 0 : 3 }
            .eraseToAnyPublisher()
        
        return Output(
            buttonTitle: buttonTitle,
            numberOfLines: numberOfLines
        )
    }
}
