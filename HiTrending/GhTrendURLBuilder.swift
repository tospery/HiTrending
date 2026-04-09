import Foundation

/// Builds the path and query string appended to `https://github.com/trending`
func repoTrendPath(
    _ base: String,
    spokenLanguageCode: String = "",
    programmingLanguage: String = "",
    dateRange: GhTrendDateRange = .today
) -> String {
    var path = base
    var queries: [String] = []
    if !programmingLanguage.isEmpty {
        path += "/\(programmingLanguage)"
    }
    if !spokenLanguageCode.isEmpty {
        queries.append("spoken_language_code=\(spokenLanguageCode)")
    }
    queries.append("since=\(ghDateRangeValue(dateRange))")
    path += "?" + queries.joined(separator: "&")
    return path
}
