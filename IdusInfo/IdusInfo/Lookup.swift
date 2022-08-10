struct Lookup: Codable {
    let resultCount: Int
    let results: [LookupDetail]
}

struct LookupDetail: Codable {
    let screenshotUrls: [String]
    let artworkUrl60: String
    let artworkUrl100: String
    let artworkUrl512: String
    let releaseNotes: String
    let sellerName: String
    let description: String
    let bundleId: String
    let trackCensoredName: String
}
