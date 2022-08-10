import Foundation
import Combine

final class ImageCache {
    static let shared = ImageCache()
    private init() {}
    
    private let cache = NSCache<NSString, NSData>()
    
    func loadImage(_ key: String) -> AnyPublisher<Data, APIError> {
        if let data = cache.object(forKey: NSString(string: key)) {
            return Just(Data(referencing: data))
                .setFailureType(to: APIError.self)
                .eraseToAnyPublisher()
        }
        
        if let url = URL(string: key) {
            return URLSession.shared.dataTaskPublisher(for: url)
                .tryMap { data, response in
                    guard let httpURLResponse = response as? HTTPURLResponse else {
                        throw APIError.error
                    }
                    guard (200..<300).contains(httpURLResponse.statusCode) else {
                        throw APIError.error
                    }
                    
                    ImageCache.shared.storeImage(key, data)
                    return data
                }
                .mapError { _ in .error }
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        }
        
        return Fail<Data, APIError>(error: .error)
            .eraseToAnyPublisher()
    }
    
    func storeImage(_ key: String, _ data: Data) {
        cache.setObject(NSData(data: data), forKey: NSString(string: key))
    }
}
