
//
// Copyright © 2024 GetYourGuide. All rights reserved.
//

import Foundation

enum NetworkError: Error, Equatable {
    case cancelled
    case noData
    case noInternet
    case notFound
    case timeout
    case underlying(_ error: NSError)
    case unknown
}

protocol NetworkTask {
    func resume()
    func suspend()
    func cancel()
}

extension URLSessionTask: NetworkTask { }

protocol NetworkClientProtocol {
    @discardableResult
    func run<ResponseBody: Decodable>(
        _ request: URLRequest,
        completion: @escaping (Result<ResponseBody, NetworkError>) -> Void
    ) -> NetworkTask

    func run<ResponseBody: Decodable>(
        _ request: URLRequest
    ) async -> Result<ResponseBody, NetworkError>
}

protocol URLSessionProtocol {
    func dataTask(
        with request: URLRequest,
        completionHandler: @Sendable @escaping (Data?, URLResponse?, Error?) -> Void
    ) -> URLSessionDataTask
}

extension URLSession: URLSessionProtocol {}

class NetworkClient: NetworkClientProtocol {
    var jsonDecoder = JSONDecoder()
    var urlSession: URLSessionProtocol = URLSession.shared

    @discardableResult
    func run<ResponseBody: Decodable>(
        _ request: URLRequest,
        completion: @escaping (Result<ResponseBody, NetworkError>) -> Void
    ) -> NetworkTask {
        // NB: Debugging purpose only
        print("\nHTTP Request: \(request.debugDescription)")

        let task = urlSession.dataTask(with: request) { (data, response, error) in
            guard
                let _ = (response as? HTTPURLResponse)?.statusCode
            else {
                completion(.failure(.unknown))
                return
            }

            do {
                if let data = data {
                    // NB: Debugging purpose only
                    data.prettyPrintedJSONString.map {
                        print("\nHTTP Response: \($0)")
                    }
                    let decodedResponse = try self.jsonDecoder.decode(
                        ResponseBody.self,
                        from: data
                    )
                    completion(.success(decodedResponse))
                } else {
                    completion(.failure(.noData))
                }
            } catch let error {
                completion(.failure(.underlying(error as NSError)))
            }
        }
        task.resume()

        return task
    }

    func run<ResponseBody>(_ request: URLRequest) async -> Result<ResponseBody, NetworkError> where ResponseBody : Decodable {
        await withCheckedContinuation { continuation in
            run(request) { (result: Result<ResponseBody, NetworkError>) in
                continuation.resume(returning: result)
            }
        }
    }
}

private extension Data {
    /// Helper property for debugging purpose only
    var prettyPrintedJSONString: String? {
        guard
            let jsonObject = try? JSONSerialization.jsonObject(with: self, options: []) as? [String: Any],
            let data = try? JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted])
        else {
            return nil
        }

        return String(data: data, encoding: .utf8)
    }
}
