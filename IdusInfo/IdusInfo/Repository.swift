import Foundation
import Combine

enum APIError: LocalizedError {
    case error
    case invalidURL
    
    var errorDescription: String? {
        switch self {
        case .error:
            return "네트워크 에러가 발생하였습니다."
        case .invalidURL:
            return "잘못된 URL 요청입니다."
        }
    }
}

struct Repository {
    private let baseURL = Constants.baseURL
    
    func loadAppLookup(_ appID: String) -> AnyPublisher<Lookup, APIError> {
        if let url = URL(string: baseURL + "/lookup?id=\(appID)") {
            return URLSession.shared.dataTaskPublisher(for: url)
                .tryMap { data, response in
                    guard let httpURLResponse = response as? HTTPURLResponse else {
                        throw APIError.error
                    }
                    guard (200..<300).contains(httpURLResponse.statusCode) else {
                        throw APIError.error
                    }
                    
                    return data
                }
                .decode(type: Lookup.self, decoder: JSONDecoder())
                .mapError { _ in .error }
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        }
        
        return Fail<Lookup, APIError>(error: .invalidURL)
            .eraseToAnyPublisher()
    }
}
