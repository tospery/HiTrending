import Foundation

/// A contributor avatar row on the trending repository card.
public struct GithubUserItem: Equatable, Hashable, Codable, Sendable {
    public var name: String
    public var avatar: String

    public init(name: String, avatar: String) {
        self.name = name
        self.avatar = avatar
    }
}

/// One trending repository row from https://github.com/trending
public struct GithubRepoItem: Equatable, Hashable, Codable, Sendable {
    public var owner: String
    public var repoName: String
    public var description: String
    public var programmingLanguage: String
    public var programmingLanguageColor: String?
    public var totalStars: Int
    public var starsSince: String
    public var totalForks: Int
    public var topContributors: [GithubUserItem]

    public init(
        owner: String,
        repoName: String,
        description: String,
        programmingLanguage: String,
        programmingLanguageColor: String?,
        totalStars: Int,
        starsSince: String,
        totalForks: Int,
        topContributors: [GithubUserItem]
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

/// One trending developer row from https://github.com/trending/developers
public struct GithubDeveloperItem: Equatable, Hashable, Codable, Sendable {
    public var avatar: String
    public var name: String
    public var username: String
    public var popularRepoName: String
    public var popularRepoDescription: String

    public init(
        avatar: String,
        name: String,
        username: String,
        popularRepoName: String,
        popularRepoDescription: String
    ) {
        self.avatar = avatar
        self.name = name
        self.username = username
        self.popularRepoName = popularRepoName
        self.popularRepoDescription = popularRepoDescription
    }
}
