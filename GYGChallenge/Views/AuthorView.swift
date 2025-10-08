//
// Copyright © 2024 GetYourGuide. All rights reserved.
//

import SwiftUI

struct AuthorView: View {
    let authorInfo: AuthorInfo?
    let reviewID: Int

    private let reviewLabel: String
    private let photoURL: URL?

    private var authorImage: UIImage? {
        if
            let photo = authorInfo?.photo(reviewID: reviewID),
            let data = try? Data(contentsOf: URL(string: photo)!)
        {
            UIImage(data: data)
        } else {
            nil
        }
    }

    init(authorInfo: AuthorInfo?, reviewID: Int) {
        self.authorInfo = authorInfo
        self.reviewID = reviewID

        var reviewedByContentText = authorInfo?.fullName ?? "Anonymous"
        if let country = authorInfo?.country {
            reviewedByContentText = "\(reviewedByContentText) - \(country)"
        }
        self.reviewLabel = reviewedByContentText

        let photo = authorInfo?.photo(reviewID: reviewID)
        self.photoURL = photo.map(URL.init) ?? nil
    }

    var body: some View {
        HStack(spacing: 10) {
            if let authorImage {
                Image(uiImage: authorImage)
                    .resizable()
                    .frame(width: 44, height: 44)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text("reviewed by")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text(reviewLabel)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}
