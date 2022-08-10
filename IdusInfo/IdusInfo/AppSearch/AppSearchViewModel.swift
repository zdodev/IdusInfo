import Foundation
import Combine

final class AppSearchViewModel {
    struct Input {
        let searchTap: AnyPublisher<String, Never>
    }
    
    struct Output {
        let lookup: AnyPublisher<Lookup, Error>
    }
    
    private let repository = Repository()
    private var cancellables = Set<AnyCancellable>()
    private let lookupSubject = PassthroughSubject<Lookup, Error>()
    
    func transform(input: Input) -> Output {
        input.searchTap
            .setFailureType(to: APIError.self)
            .flatMap { [repository] appID in
                repository.loadAppLookup(appID)
            }
            .sink(receiveCompletion: { [lookupSubject] completion in
                switch completion {
                case .failure(let error):
                    lookupSubject.send(completion: .failure(error))
                case .finished:
                    lookupSubject.send(completion: .finished)
                }
            }, receiveValue: { [lookupSubject] lookup in
                lookupSubject.send(lookup)
            })
            .store(in: &cancellables)
        

        return Output(lookup: lookupSubject.eraseToAnyPublisher())
    }
}
