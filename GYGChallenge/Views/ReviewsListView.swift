//
// Copyright © 2025 GetYourGuide. All rights reserved.
//

import SwiftUI

// MARK: - ReviewsListView

public struct ReviewsListView: View {
    init(activityId: Int) {
        self.activityId = activityId
    }

    @State private var reviews: [Review] = []

    private let activityId: Int
    private var networkClient: NetworkClient = {
        let networkClient = NetworkClient()

        let jsonDecoder = JSONDecoder()
        jsonDecoder.dateDecodingStrategy = .iso8601
        networkClient.jsonDecoder = jsonDecoder

        return networkClient
    }()

    private func fetchReviews() {
        let url = URL(
            string: "https://travelers-api.getyourguide.com/activities/\(activityId)/reviews?offset=\(reviews.count)"
        )!

        _ = networkClient.run(
            URLRequest(url: url)
        ) { (result: Result<ReviewsResponse, NetworkError>) in
            self.reviews.removeAll()
            switch result {
            case let.success(response):
                self.reviews.append(contentsOf: response.reviews)
                // Due to a bug in the API, duplicated reviews can be returned.
                self.reviews = self.reviews.uniqued()
            case let .failure(error):
                print(error)
            }
        }
    }

    public var body: some View {
        List(reviews, id: \.activityId) { review in
            ReviewView(review: review)
        }
        .onAppear {
            fetchReviews()
        }
    }
}

// MARK: - Util views

private struct LoadingView: View {
    var body: some View {
        ProgressView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct ErrorView: View {
    var message: String

    var body: some View {
        Text(message)
            .font(.body)
            .frame(maxWidth: .infinity)
            .padding()
            .foregroundStyle(Color.white)
            .background(Color.red.opacity(0.9))
    }
}
