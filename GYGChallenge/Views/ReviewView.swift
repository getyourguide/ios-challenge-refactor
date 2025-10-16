//
// Copyright © 2025 GetYourGuide. All rights reserved.
//

import SwiftUI

// MARK: - ReviewView

struct ReviewView: View {
    let review: Review

    private let formattedDate: String?

    init(review: Review) {
        self.review = review
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        formattedDate = review.created.map(dateFormatter.string(from:))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let formattedDate {
                Text(formattedDate)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            RatingView(ratingValue: review.rating)

            if let reviewMessage = review.message {
                Text(reviewMessage)
                    .font(.body)
                    .foregroundStyle(.primary)
            }

            AuthorView(
                authorInfo: review.author,
                reviewID: review.id
            )
        }
    }
}

// MARK: - Util views

private struct RatingView: View {
    let ratingValue: Int
    let maxRating: Int = 5

    var body: some View {
        HStack(spacing: 5) {
            ForEach(1...maxRating, id: \.self) {
                Image(uiImage: $0 <= ratingValue ? .iconStarYellow! : .iconStarGray!)
            }
        }
    }
}

// MARK: - Extensions

private extension UIImage {
    static let iconStarGray: UIImage? = {
        UIImage(named: "icon_star_gray")
    }()

    static let iconStarYellow: UIImage? = {
        UIImage(named: "icon_star_yellow")
    }()
}
