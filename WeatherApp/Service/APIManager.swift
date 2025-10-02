//
//  APIManager.swift
//  WeatherApp
//
//  Created by Bob Yin on 9/28/25.
//

import Foundation

protocol APIManagerServiceProtocol: AnyObject {
    func fetchWeather(_ text: String, completion: @escaping (Result<Weather, APIError>) -> Void)
}

class APIManager: APIManagerServiceProtocol {
    
    private func performRequest<T: Codable>(url: URL,
                                            method: HTTPMethod = .GET,
                                            headers: [String: String]? = nil,
                                            responseType: T.Type,
                                            completion: @escaping (Result<T, APIError>) -> Void) {
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        if let headers = headers {
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in

            if let error = error {
                print("Network Error: \(error)")
                completion(.failure(.networkError(error)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid response")
                completion(.failure(.invalidResponse))
                return
            }
            
            print("Status Code: \(httpResponse.statusCode)")
            
            guard let data = data else {
                print("No data received")
                completion(.failure(.noData))
                return
            }
            
            do {
                let decodedObject = try JSONDecoder().decode(responseType, from: data)
                print("API 請求成功")
                completion(.success(decodedObject))
            } catch {
                print("JSON 解析錯誤: \(error)")
                completion(.failure(.decodingError(error)))
            }
        }
        
        task.resume()
    }
    
    private func getAPIKey() -> String? {
        guard let path = Bundle.main.path(forResource: "APIKey", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: path),
              let apiKey = plist["apiKey"] as? String else {
            print("API Key 未設定或檔案遺失")
            return nil
        }
        return apiKey
    }

    private func buildURL(endpoint: String, parameters: [String: String]? = nil) -> URL? {
        guard var urlComponents = URLComponents(string: APIConstants.baseURL + "/" + endpoint) else {
            return nil
        }
        
        guard let apiKey = getAPIKey() else {
            print("無法取得 API Key")
            return nil
        }

        var queryItems = [
            URLQueryItem(name: "Authorization", value: apiKey),
            URLQueryItem(name: "format", value: "JSON")
        ]

        if let parameters = parameters {
            for (key, value) in parameters {
                queryItems.append(URLQueryItem(name: key, value: value))
            }
        }

        urlComponents.queryItems = queryItems
        return urlComponents.url
    }

    func fetchWeather(_ locationName: String, completion: @escaping (Result<Weather, APIError>) -> Void) {
        let parameters = ["locationName": locationName]

        guard let url = buildURL(endpoint: "F-C0032-001", parameters: parameters) else {
            completion(.failure(.invalidURL))
            return
        }

        performRequest(url: url, method: .GET, responseType: Weather.self, completion: completion)
    }
}
