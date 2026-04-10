import Foundation

public enum HiTrendingRange: String, Sendable, CaseIterable {
    case daily
    case weekly
    case monthly

//    /// URL query value: `daily`, `weekly`, or `monthly`.
//    public var queryValue: String {
//        switch self {
//        case .daily: return "daily"
//        case .weekly: return "weekly"
//        case .monthly: return "monthly"
//        }
//    }

//    /// Short English label suitable for UI.
//    public var displayLabel: String {
//        switch self {
//        case .daily: return "Today"
//        case .weekly: return "This week"
//        case .monthly: return "This month"
//        }
//    }
}

///// Backward-compatible name with the Dart API `ghDateRangeLabel`.
//public func ghDateRangeLabel(_ range: HiTrendingRange) -> String {
//    range.displayLabel
//}

///// Backward-compatible name with the Dart internal `ghDateRangeValue`.
//public func ghDateRangeValue(_ range: HiTrendingRange) -> String {
//    range.rawValue
//}

enum HiTrendingConstant {
    static let baseURLString = "https://github.com/trending"
}

func trendingRepositoriesPath(
    _ base: String,
    spokenLanguageCode: String = "",
    programmingLanguage: String = "",
    dateRange: HiTrendingRange = .daily
) -> String {
    var path = base
    var queries: [String] = []
    if !programmingLanguage.isEmpty {
        path += "/\(programmingLanguage)"
    }
    if !spokenLanguageCode.isEmpty {
        queries.append("spoken_language_code=\(spokenLanguageCode)")
    }
    queries.append("since=\(dateRange.rawValue))")
    path += "?" + queries.joined(separator: "&")
    return path
}
