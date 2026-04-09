import Foundation

/// GitHub trending time window (aligned with `GhTrendDateRange`).
public enum GhTrendDateRange: String, Sendable, CaseIterable {
    case today
    case thisWeek
    case thisMonth

    /// URL query value: `daily`, `weekly`, or `monthly`.
    public var queryValue: String {
        switch self {
        case .today: return "daily"
        case .thisWeek: return "weekly"
        case .thisMonth: return "monthly"
        }
    }

    /// Short English label suitable for UI.
    public var displayLabel: String {
        switch self {
        case .today: return "Today"
        case .thisWeek: return "This week"
        case .thisMonth: return "This month"
        }
    }
}

/// Backward-compatible name with the Dart API `ghDateRangeLabel`.
public func ghDateRangeLabel(_ range: GhTrendDateRange) -> String {
    range.displayLabel
}

/// Backward-compatible name with the Dart internal `ghDateRangeValue`.
public func ghDateRangeValue(_ range: GhTrendDateRange) -> String {
    range.queryValue
}
