import Foundation
import SwiftSoup

struct HiTrendingScraper {
    var base: String = ""

    private let repoItemSelector = "div>div>div>article.Box-row"
    private let nameSelector = "article> h2> a"
    private let nameSelectorBak1 = "article> h1> a"
    private let descriptionSelector = "article> p"
    private let programmingLanguageMarker = "<span itemprop=\"programmingLanguage\">"
    private let starsSinceSelector = "article> div.f6.color-fg-muted.mt-2> span.d-inline-block.float-sm-right"
    private let starsSinceSelectorBak1 = "article> div.f6.color-text-secondary.mt-2> span.d-inline-block.float-sm-right"
    private let topContributorItemSelector = "span> a> img"

    private let devItemSelector = "div>div>div>article.Box-row"
    private let devAvatarSelector = "div.tmp-mx-3 > a > img"
    private let devAvatarSelectorBak1 = "div.mx-3 > a > img"
    private let devNameSelector = "div > div > div:nth-child(1) > h1 > a"
    private let devUsernameSelector = "div > div > div:nth-child(1) > p > a"
    private let devPopularRepoNameSelector = "div > div > div > div > article > h1 > a"
    
    private let devPopularRepoDescriptionMarker = "<div class=\"f6 color-fg-muted mt-1\">"
    private let devPopularRepoDescriptionMarkerBak1 = "<div class=\"f6 color-text-secondary mt-1\">"
    
    private let devOrganizationNameSelector = "div > div > div:nth-child(2) > div > p > span > span.Truncate-text"
    
    private let devJoinedDateSelector = "div > div > div:nth-child(2) > div > p.tmp-mb-3"

    func copyWith(base: String) -> HiTrendingScraper {
        var s = self
        s.base = base
        return s
    }

    func trendingRepositories(
        spokenLanguageCode: String = "",
        programmingLanguage: String = "",
        proxy: String = "",
        dateRange: HiTrendingRange = .daily,
        headers: [String: String] = [:]
    ) async -> [HiTrendingRepository] {
        let path = trendingRepositoriesPath(
            base,
            spokenLanguageCode: spokenLanguageCode,
            programmingLanguage: programmingLanguage,
            dateRange: dateRange
        )
        guard let body = await requestHTMLString(proxy: proxy, path: path, headers: headers) else {
            return []
        }
        let rawHtml = body.replacingOccurrences(of: programmingLanguageMarker, with: "<span id=\"programmingLanguage\">")
        do {
            let doc = try SwiftSoup.parse(rawHtml)
            let htmlItems = try doc.select(repoItemSelector)
            var result: [HiTrendingRepository] = []
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

    func trendingDevelopers(
        programmingLanguage: String = "",
        proxy: String = "",
        dateRange: HiTrendingRange = .daily,
        headers: [String: String] = [:]
    ) async -> [HiTrendingDeveloper] {
        let path = trendingRepositoriesPath(base, programmingLanguage: programmingLanguage, dateRange: dateRange)
        guard let body = await requestHTMLString(proxy: proxy, path: path, headers: headers) else {
            return []
        }
        var rawHtml = body.replacingOccurrences(of: devPopularRepoDescriptionMarker, with: "<div id=\"repoDescription\">")
        rawHtml = rawHtml.replacingOccurrences(of: devPopularRepoDescriptionMarkerBak1, with: "<div id=\"repoDescription\">")
        do {
            let doc = try SwiftSoup.parse(rawHtml)
            let htmlItems = try doc.select(devItemSelector)
            var result: [HiTrendingDeveloper] = []
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

    private func parseRepoRow(_ htmlItem: Element) -> HiTrendingRepository? {
        do {
            var nameLink = try htmlItem.select(nameSelector).first()
            if nameLink == nil {
                nameLink = try htmlItem.select(nameSelectorBak1).first()
            }
            if nameLink == nil {
                return nil
            }
            let nameParts = try nameLink!.text().trimmingCharacters(in: .whitespacesAndNewlines).split(separator: "/").map {
                String($0).trimmingCharacters(in: .whitespacesAndNewlines)
            }
            let owner = nameParts.count > 0 ? nameParts[0] : ""
            let repoName = nameParts.count > 1 ? nameParts[1] : ""

            let from = "href=\"/\(owner)/\(repoName)/stargazers\""
            let fromMembers = "href=\"/\(owner)/\(repoName)/forks\""
            let fromMembersBak1 = "href=\"/\(owner)/\(repoName)/network/members.\(repoName)\""
            let rawItem = try htmlItem.outerHtml()
                .replacingOccurrences(of: from, with: "\(from) id=\"stargazersCount\" ")
                .replacingOccurrences(of: fromMembers, with: "\(fromMembers) id=\"forkCount\" ")
                .replacingOccurrences(of: fromMembersBak1, with: "\(fromMembers) id=\"forkCount\" ")
            let item = try Parser.parseBodyFragment(rawItem, "")

            let description = (try? item.select(descriptionSelector).first()?.text())?
                .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let programmingLanguage = (try? item.select("#programmingLanguage").first()?.text())?
                .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let programmingLanguageColor = HiTrendingLanguage.colors[programmingLanguage]

            let totalStars = parseInt(try? item.select("#stargazersCount").first()?.text())
            var starsSince = (try? item.select(starsSinceSelector).first()?.text())?
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .replacingOccurrences(of: ",", with: "") ?? ""
            if starsSince.isEmpty {
                starsSince = (try? item.select(starsSinceSelectorBak1).first()?.text())?
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    .replacingOccurrences(of: ",", with: "") ?? ""
            }
            let totalForks = parseInt(try? item.select("#forkCount").first()?.text())

            var topContributors: [HiTrendingBaseDeveloper] = []
            if let contribElements = try? item.select(topContributorItemSelector) {
                for contrib in contribElements {
                    let avatar = (try? contrib.attr("src"))
                    let alt = ((try? contrib.attr("alt")) ?? "").replacingOccurrences(of: "@", with: "")
                    topContributors.append(HiTrendingBaseDeveloper(username: alt, avatar: avatar))
                }
            }

            return HiTrendingRepository(
                owner: owner,
                name: repoName,
                description: description,
                language: programmingLanguage.isEmpty ? nil : programmingLanguage,
                languageColor: programmingLanguageColor,
                stars: totalStars,
                starsSince: starsSince,
                forks: totalForks,
                builtBy: topContributors
            )
        } catch {
            return nil
        }
    }

    private func parseDeveloperRow(_ htmlItem: Element) -> HiTrendingDeveloper? {
        var avatar = (try? htmlItem.select(devAvatarSelector).first()?.attr("src")) ?? ""
        if avatar.isEmpty {
            avatar = (try? htmlItem.select(devAvatarSelectorBak1).first()?.attr("src")) ?? ""
        }
        var name = (try? htmlItem.select(devNameSelector).first()?.text())?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        var username = (try? htmlItem.select(devUsernameSelector).first()?.text())?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if username.isEmpty {
            username = name
            name = ""
        }
        let popularRepoName = (try? htmlItem.select(devPopularRepoNameSelector).first()?.text())?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let popularRepoDescription = (try? htmlItem.select("#repoDescription").first()?.text())?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        let organizationName = (try? htmlItem.select(devOrganizationNameSelector).first()?.text())?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        let joinedDateString = (try? htmlItem.select(devJoinedDateSelector).first()?.text())?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        return HiTrendingDeveloper(
            avatar: avatar,
            name: name,
            username: username,
            popularRepoName: popularRepoName,
            popularRepoDescription: popularRepoDescription,
            organizationName: organizationName,
            joinedDateString: joinedDateString
        )
    }

    private func parseInt(_ text: String?) -> Int {
        guard let text else { return 0 }
        let cleaned = text.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: ",", with: "")
        return Int(cleaned) ?? 0
    }
    
    private func requestHTMLString(proxy: String, path: String, headers: [String: String]) async -> String? {
        let urlString = proxy + HiTrendingConstant.baseURLString + path
        guard let url = URL(string: urlString) else { return nil }
#if DEBUG
        print("抓取网页: ", urlString)
#endif
        var request = URLRequest(url: url)
        for (k, v) in headers {
            request.setValue(v, forHTTPHeaderField: k)
        }
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            return String(data: data, encoding: .utf8)
        } catch {
            return nil
        }
    }
    
}
