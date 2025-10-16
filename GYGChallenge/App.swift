//
// Copyright © 2025 GetYourGuide. All rights reserved.
//

import SwiftUI

@main
struct App: SwiftUI.App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ReviewsListView(activityId: 251502)
            }
            .navigationTitle("Reviews for Activity ID \(251502)")
        }
    }
}
