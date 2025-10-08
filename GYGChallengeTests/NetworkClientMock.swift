//
// Copyright © 2025 GetYourGuide. All rights reserved.
//

import Foundation
import XCTest

@testable import GYGChallenge

final class NetworkClientMock: NetworkClientProtocol {
    init(
        resultToReturn: Any? = nil,
        errorToReturn: NetworkError? = nil,
        lastRequest: URLRequest? = nil,
        runCalled: Bool = false
    ) {
        self.resultToReturn = resultToReturn
        self.errorToReturn = errorToReturn
        self.lastRequest = lastRequest
        self.runCalled = runCalled
    }

    var resultToReturn: Any?
    var errorToReturn: NetworkError?

    var lastRequest: URLRequest?
    var runCalled = false
    var runCallCount = 0

    @discardableResult
    func run<ResponseBody: Decodable>(
        _ request: URLRequest,
        completion: @escaping (Result<ResponseBody, NetworkError>) -> Void
    ) -> NetworkTask {
        runCalled = true
        runCallCount += 1
        lastRequest = request

        DispatchQueue.global().async {
            if let error = self.errorToReturn {
                completion(.failure(error))
            } else if let result = self.resultToReturn as? ResponseBody {
                completion(.success(result))
            } else {
                XCTFail("No return type mocked")
            }
        }
        return NetworkTaskMock()
    }

    func run<ResponseBody: Decodable>(
        _ request: URLRequest
    ) async -> Result<ResponseBody, NetworkError> {
        runCalled = true
        runCallCount += 1
        lastRequest = request

        if let error = errorToReturn {
            return .failure(error)
        } else if let result = resultToReturn as? ResponseBody {
            return .success(result)
        } else {
            XCTFail("No return type mocked")
            return .failure(.unknown)
        }
    }
}

final class NetworkTaskMock {
    private(set) var isCancelled: Bool = false
    private(set) var cancelCallsCount: Int = 0

    private(set) var resumeCallsCount: Int = 0
    private(set) var suspendCallsCount: Int = 0

    private let completion: (() -> Void)?

    init(completion: (() -> Void)? = nil) {
        self.completion = completion
    }
}

extension NetworkTaskMock: NetworkTask {
    public func resume() {
        resumeCallsCount += 1
        completion?()
    }
    public func suspend() {
        suspendCallsCount += 1
    }
    public func cancel() {
        isCancelled = true
        cancelCallsCount += 1
    }
}
