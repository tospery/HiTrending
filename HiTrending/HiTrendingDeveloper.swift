import Foundation

public struct HiTrendingBaseDeveloper: Equatable, Hashable, Codable, Sendable {
    public var username: String
    public var avatar: String?

    public init(username: String, avatar: String?) {
        self.username = username
        self.avatar = avatar
    }
}

public struct HiTrendingDeveloper: Equatable, Hashable, Codable, Sendable {
    public var avatar: String
    public var name: String
    public var username: String
    public var repo: HiTrendingBaseRepository
    public var organizationName: String
    public var joinedDateString: String

    public init(
        avatar: String,
        name: String,
        username: String,
        popularRepoName: String,
        popularRepoDescription: String,
        organizationName: String,
        joinedDateString: String
    ) {
        self.avatar = avatar
        self.name = name
        self.username = username
        self.organizationName = organizationName
        self.joinedDateString = joinedDateString
        self.repo = .init(name: popularRepoName, url: nil, description: popularRepoDescription)
    }
}
