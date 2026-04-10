import Foundation

public struct HiTrendingBaseDeveloper: Equatable, Hashable, Codable, Sendable {
    public var name: String
    public var avatar: String

    public init(name: String, avatar: String) {
        self.name = name
        self.avatar = avatar
    }
}

public struct HiTrendingDeveloper: Equatable, Hashable, Codable, Sendable {
    public var avatar: String
    public var name: String
    public var username: String
    public var popularRepoName: String
    public var popularRepoDescription: String
    public var organizationName: String
    public var joinedDate: String

    public init(
        avatar: String,
        name: String,
        username: String,
        popularRepoName: String,
        popularRepoDescription: String,
        organizationName: String,
        joinedDate: String
    ) {
        self.avatar = avatar
        self.name = name
        self.username = username
        self.popularRepoName = popularRepoName
        self.popularRepoDescription = popularRepoDescription
        self.organizationName = organizationName
        self.joinedDate = joinedDate
    }
}
