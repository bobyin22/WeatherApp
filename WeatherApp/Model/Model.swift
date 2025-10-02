//
//  Model.swift
//  WeatherApp
//
//  Created by Bob Yin on 9/28/25.
//

struct Weather: Codable {
    let success: String
    let result: APIResult
    let records: Records
}

struct Records: Codable {
    let datasetDescription: String
    let location: [Location]
}

struct Location: Codable {
    let locationName: String
    let weatherElement: [WeatherElement]
}

struct WeatherElement: Codable {
    let elementName: String
    let time: [Time]
}

struct Time: Codable {
    let startTime: String
    let endTime: String
    let parameter: Parameter
}

struct Parameter: Codable {
    let parameterName: String
    let parameterValue, parameterUnit: String?
}

struct APIResult: Codable {
    let resourceID: String
    let fields: [Field]

    enum CodingKeys: String, CodingKey {
        case resourceID = "resource_id"
        case fields
    }
}

struct Field: Codable {
    let id, type: String
}


// MARK: API 的 Weather 資料轉換成 UI 顯示用的結構
struct WeatherDisplayItem {
    let startTime: String
    let endTime: String
    let weather: String
    let temperature: String
    let rain: String
    let locationName: String
    
    var displayText: String {
        return "\(startTime):\n\(weather) \(temperature) 降雨\(rain)"
    }
}
