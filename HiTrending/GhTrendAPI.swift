import Foundation

private let _ghTrendScraper = GithubTrendScraper()

/// Fetches trending repositories from GitHub (Swift port of [gh_trend](https://pub.dev/packages/gh_trend) `ghTrendingRepositories`).
///
/// - Parameters:
///   - spokenLanguageCode: Keys from ``GhTrendSpokenLanguages/ghSpokenLanguages`` (e.g. `"en"`).
///   - programmingLanguage: Slug keys from ``GhTrendProgrammingLanguages/ghProgrammingLanguages`` (e.g. `"swift"`).
///   - proxy: Optional URL prefix prepended before `https://github.com/trending` (same as Dart `proxy`).
///   - dateRange: Time window; use ``ghDateRangeLabel(_:)`` for UI text.
///   - headers: Extra HTTP headers for the GET request.
/// - Returns: Parsed rows; empty if the request fails or HTML does not match (same resilience as the Dart package).
public func ghTrendingRepositories(
    spokenLanguageCode: String = "",
    programmingLanguage: String = "",
    proxy: String = "",
    dateRange: GhTrendDateRange = .today,
    headers: [String: String] = [:]
) async -> [GithubRepoItem] {
    await _ghTrendScraper.ghTrendingRepositories(
        spokenLanguageCode: spokenLanguageCode,
        programmingLanguage: programmingLanguage,
        proxy: proxy,
        dateRange: dateRange,
        headers: headers
    )
}

/// Fetches trending developers from GitHub (Swift port of `ghTrendingDevelopers`).
///
/// - Parameters:
///   - programmingLanguage: Slug from ``GhTrendProgrammingLanguages/ghProgrammingLanguages``.
///   - proxy: Optional URL prefix before `https://github.com/trending`.
///   - dateRange: Time window.
///   - headers: Extra HTTP headers.
public func ghTrendingDevelopers(
    programmingLanguage: String = "",
    proxy: String = "",
    dateRange: GhTrendDateRange = .today,
    headers: [String: String] = [:]
) async -> [GithubDeveloperItem] {
    await _ghTrendScraper.copyWith(base: "/developers").ghTrendingDevelopers(
        programmingLanguage: programmingLanguage,
        proxy: proxy,
        dateRange: dateRange,
        headers: headers
    )
}
