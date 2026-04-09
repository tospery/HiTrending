import Foundation
import SwiftSoup

/// Mirrors the selector layout and HTML workarounds from `GithubTrendScraper`.
struct GithubTrendScraper {
    var base: String = ""

    private let repoItemSelector = "div>div>div>article.Box-row"
    private let nameSelector = "article> h1> a"
    private let descriptionSelector = "article> p"
    private let programmingLanguageMarker = "<span itemprop=\"programmingLanguage\">"
    private let starsSinceSelector = "article> div.f6.color-text-secondary.mt-2> span.d-inline-block.float-sm-right"
    private let topContributorItemSelector = "span> a> img"

    private let devItemSelector = "div>div>div>article.Box-row"
    private let devAvatarSelector = "div.mx-3 > a > img"
    private let devNameSelector = "div > div > div:nth-child(1) > h1 > a"
    private let devUsernameSelector = "div > div > div:nth-child(1) > p > a"
    private let devPopularRepoNameSelector = "div > div > div > div > article > h1 > a"
    private let devPopularRepoDescriptionMarker = "<div class=\"f6 color-text-secondary mt-1\">"

    func copyWith(base: String) -> GithubTrendScraper {
        var s = self
        s.base = base
        return s
    }

    func ghTrendingRepositories(
        spokenLanguageCode: String = "",
        programmingLanguage: String = "",
        proxy: String = "",
        dateRange: GhTrendDateRange = .today,
        headers: [String: String] = [:]
    ) async -> [GithubRepoItem] {
        let path = repoTrendPath(
            base,
            spokenLanguageCode: spokenLanguageCode,
            programmingLanguage: programmingLanguage,
            dateRange: dateRange
        )
        guard let body = await GhTrendHTTP.getString(proxy: proxy, path: path, headers: headers) else {
            return []
        }
        let rawHtml = body.replacingOccurrences(of: programmingLanguageMarker, with: "<span id=\"programmingLanguage\">")
        do {
            let doc = try SwiftSoup.parse(rawHtml)
            let htmlItems = try doc.select(repoItemSelector)
            var result: [GithubRepoItem] = []
            for htmlItem in htmlItems {
                if let item = parseRepoRow(htmlItem) {
                    result.append(item)
                }
            }
            return result
        } catch {
            return []
        }
    }

    func ghTrendingDevelopers(
        programmingLanguage: String = "",
        proxy: String = "",
        dateRange: GhTrendDateRange = .today,
        headers: [String: String] = [:]
    ) async -> [GithubDeveloperItem] {
        let path = repoTrendPath(base, programmingLanguage: programmingLanguage, dateRange: dateRange)
        guard let body = await GhTrendHTTP.getString(proxy: proxy, path: path, headers: headers) else {
            return []
        }
        let rawHtml = body.replacingOccurrences(of: devPopularRepoDescriptionMarker, with: "<div id=\"repoDescription\">")
        do {
            let doc = try SwiftSoup.parse(rawHtml)
            let htmlItems = try doc.select(devItemSelector)
            var result: [GithubDeveloperItem] = []
            for htmlItem in htmlItems {
                if let item = parseDeveloperRow(htmlItem) {
                    result.append(item)
                }
            }
            return result
        } catch {
            return []
        }
    }

    private func parseRepoRow(_ htmlItem: Element) -> GithubRepoItem? {
        do {
            guard let nameLink = try htmlItem.select(nameSelector).first() else { return nil }
            let nameParts = try nameLink.text().trimmingCharacters(in: .whitespacesAndNewlines).split(separator: "/").map {
                String($0).trimmingCharacters(in: .whitespacesAndNewlines)
            }
            let owner = nameParts.count > 0 ? nameParts[0] : ""
            let repoName = nameParts.count > 1 ? nameParts[1] : ""

            let from = "href=\"/\(owner)/\(repoName)/stargazers\""
            let fromMembers = "href=\"/\(owner)/\(repoName)/network/members.\(repoName)\""
            let rawItem = try htmlItem.outerHtml()
                .replacingOccurrences(of: from, with: "\(from) id=\"stargazersCount\" ")
                .replacingOccurrences(of: fromMembers, with: "\(fromMembers) id=\"forkCount\" ")
            let item = try Parser.parseBodyFragment(rawItem, "")

            let description = (try? item.select(descriptionSelector).first()?.text())?
                .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let programmingLanguage = (try? item.select("#programmingLanguage").first()?.text())?
                .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let programmingLanguageColor = GhTrendProgrammingLanguageColors.colorHex(forDisplayName: programmingLanguage)

            let totalStars = parseInt(try? item.select("#stargazersCount").first()?.text())
            let starsSince = (try? item.select(starsSinceSelector).first()?.text())?
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .replacingOccurrences(of: ",", with: "") ?? ""
            let totalForks = parseInt(try? item.select("#forkCount").first()?.text())

            var topContributors: [GithubUserItem] = []
            if let contribElements = try? item.select(topContributorItemSelector) {
                for contrib in contribElements {
                    let avatar = (try? contrib.attr("src")) ?? ""
                    let alt = ((try? contrib.attr("alt")) ?? "").replacingOccurrences(of: "@", with: "")
                    topContributors.append(GithubUserItem(name: alt, avatar: avatar))
                }
            }

            return GithubRepoItem(
                owner: owner,
                repoName: repoName,
                description: description,
                programmingLanguage: programmingLanguage,
                programmingLanguageColor: programmingLanguageColor,
                totalStars: totalStars,
                starsSince: starsSince,
                totalForks: totalForks,
                topContributors: topContributors
            )
        } catch {
            return nil
        }
    }

    private func parseDeveloperRow(_ htmlItem: Element) -> GithubDeveloperItem? {
        let avatar = (try? htmlItem.select(devAvatarSelector).first()?.attr("src")) ?? ""
        let name = (try? htmlItem.select(devNameSelector).first()?.text())?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let username = (try? htmlItem.select(devUsernameSelector).first()?.text())?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let popularRepoName = (try? htmlItem.select(devPopularRepoNameSelector).first()?.text())?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let popularRepoDescription = (try? htmlItem.select("#repoDescription").first()?.text())?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return GithubDeveloperItem(
            avatar: avatar,
            name: name,
            username: username,
            popularRepoName: popularRepoName,
            popularRepoDescription: popularRepoDescription
        )
    }

    private func parseInt(_ text: String?) -> Int {
        guard let text else { return 0 }
        let cleaned = text.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: ",", with: "")
        return Int(cleaned) ?? 0
    }
}

private enum GhTrendHTTP {
    static func getString(proxy: String, path: String, headers: [String: String]) async -> String? {
        let urlString = proxy + GhTrendConstants.githubBase + path
        guard let url = URL(string: urlString) else { return nil }
        var request = URLRequest(url: url)
        for (k, v) in headers {
            request.setValue(v, forHTTPHeaderField: k)
        }
//        if request.value(forHTTPHeaderField: "User-Agent") == nil {
//            request.setValue("SwiftTrending/1.1 (iOS; +https://pub.dev/packages/gh_trend)", forHTTPHeaderField: "User-Agent")
//        }
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            return String(data: data, encoding: .utf8)
        } catch {
            return nil
        }
    }
}
