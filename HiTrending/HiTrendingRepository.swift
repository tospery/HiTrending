import Foundation

public struct HiTrendingBaseRepository: Equatable, Hashable, Codable, Sendable {
    public var name: String
    public var url: String?
    public var description: String?

    public init(name: String, url: String?, description: String?) {
        self.name = name
        self.url = url
        self.description = description
    }
}

public struct HiTrendingRepository: Equatable, Hashable, Codable, Sendable {
    public var owner: HiTrendingBaseDeveloper
    public var name: String
    public var description: String
    public var language: String?
    public var languageColor: String?
    public var stars: Int
    public var starsSince: String
    public var forks: Int
    public var builtBy: [HiTrendingBaseDeveloper]

    public init(
        owner: String,
        name: String,
        description: String,
        language: String?,
        languageColor: String?,
        stars: Int,
        starsSince: String,
        forks: Int,
        builtBy: [HiTrendingBaseDeveloper]
    ) {
        self.owner = .init(username: owner, avatar: nil)
        self.name = name
        self.description = description
        self.language = language
        self.languageColor = languageColor
        self.stars = stars
        self.starsSince = starsSince
        self.forks = forks
        self.builtBy = builtBy
    }
}

