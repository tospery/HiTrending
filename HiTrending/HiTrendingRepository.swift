import Foundation

public struct HiTrendingRepository: Equatable, Hashable, Codable, Sendable {
    public var owner: String
    public var repoName: String
    public var description: String
    public var programmingLanguage: String
    public var programmingLanguageColor: String?
    public var totalStars: Int
    public var starsSince: String
    public var totalForks: Int
    public var topContributors: [HiTrendingBaseDeveloper]

    public init(
        owner: String,
        repoName: String,
        description: String,
        programmingLanguage: String,
        programmingLanguageColor: String?,
        totalStars: Int,
        starsSince: String,
        totalForks: Int,
        topContributors: [HiTrendingBaseDeveloper]
    ) {
        self.owner = owner
        self.repoName = repoName
        self.description = description
        self.programmingLanguage = programmingLanguage
        self.programmingLanguageColor = programmingLanguageColor
        self.totalStars = totalStars
        self.starsSince = starsSince
        self.totalForks = totalForks
        self.topContributors = topContributors
    }
}

