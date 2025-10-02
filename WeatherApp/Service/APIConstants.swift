//
//  APIConstants.swift
//  WeatherApp
//
//  Created by Bob Yin on 2025/10/2.
//

enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
}

enum APIError: Error {
    case invalidURL
    case invalidResponse
    case noData
    case decodingError(Error)
    case networkError(Error)
}

struct APIConstants {
    static let baseURL = "https://opendata.cwa.gov.tw/api/v1/rest/datastore"
}
