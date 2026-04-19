import Foundation

final public class HiTrending {
    
    private let scraper = HiTrendingScraper()
    public static var shared = HiTrending()
    
    init() { }
    
    public func developers(
        programmingLanguage: String = "",
        proxy: String = "",
        dateRange: HiTrendingRange = .daily,
        headers: [String: String] = [:]
    ) async -> [HiTrendingDeveloper] {
        await scraper.copyWith(base: "/developers").trendingDevelopers(
            programmingLanguage: programmingLanguage,
            proxy: proxy,
            dateRange: dateRange,
            headers: headers
        )
    }
    
    public func repositories(
        spokenLanguageCode: String = "",
        programmingLanguage: String = "",
        proxy: String = "",
        dateRange: HiTrendingRange = .daily,
        headers: [String: String] = [:]
    ) async -> [HiTrendingRepository] {
        await scraper.trendingRepositories(
            spokenLanguageCode: spokenLanguageCode,
            programmingLanguage: programmingLanguage,
            proxy: proxy,
            dateRange: dateRange,
            headers: headers
        )
    }
    
}
