//
// Copyright © 2024 GetYourGuide. All rights reserved.
//

import Foundation

struct ReviewsResponse: Codable {
    var averageRating: Float
    var pagination: Pagination?
    var reviews: [Review]
    var totalCount: Int
}

/// A review is always attached to an Activity. Each activity can have multiple reviews
struct Review: Codable, Equatable, Hashable {
    /// A unique identifier for the activity that is reviewed
    var activityId: Int

    /// A unique identifier, guaranteed to identify a review uniquely
    var id: Int

    var author: AuthorInfo?
    var created: Date?
    var enjoyment: String?
    var message: String?
    var rating: Int

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct AuthorInfo: Codable, Equatable {
    var fullName: String
    var country: String?
}

extension AuthorInfo {
    func photo(reviewID: Int) -> String? {
        reviewID % 2 == 0
        ? "https://picsum.photos/300/300?lock=\(reviewID)"
        : nil
    }
}

struct Pagination: Codable, Equatable {
    var limit: Int?
    var offset: Int?
}
