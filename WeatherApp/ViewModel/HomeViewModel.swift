//
//  HomeViewModel.swift
//  WeatherApp
//
//  Created by Bob Yin on 9/28/25.
//

import Combine
import Foundation

class HomeViewModel: ObservableObject {
    private let apiManagerService: APIManagerServiceProtocol
    
    init(apiManagerService: APIManagerServiceProtocol) {
        self.apiManagerService = apiManagerService
    }
    
    @Published var displayItems: [WeatherDisplayItem] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    private func parseWeatherData(_ response: Weather) -> [WeatherDisplayItem] {
        var allItems: [WeatherDisplayItem] = []
        
        // 處理所有 locations
        for location in response.records.location {
            let items = parseLocationWeatherData(location)
            allItems.append(contentsOf: items)
        }
        
        return allItems
    }
    
    private func parseLocationWeatherData(_ location: Location) -> [WeatherDisplayItem] {
        var items: [WeatherDisplayItem] = []
        
        // 找到各種天氣元素
        let weatherElement = location.weatherElement.first {
            $0.elementName == "Wx" }
        let rainElement = location.weatherElement.first {
            $0.elementName == "PoP" }
        let minTempElement = location.weatherElement.first {
            $0.elementName == "MinT" }
        let maxTempElement = location.weatherElement.first {
            $0.elementName == "MaxT" }
        let comfortElement = location.weatherElement.first {
            $0.elementName == "CI" }
        
        // 以天氣時段為基準（因為所有元素的時段都一樣）
        guard let timeCount = weatherElement?.time.count else { return [] }
        
        for i in 0..<timeCount {
            let weather =
            weatherElement?.time[i].parameter.parameterName ?? ""
            let rain = rainElement?.time[i].parameter.parameterName ?? ""
            let minTemp = minTempElement?.time[i].parameter.parameterName ?? ""
            let maxTemp = maxTempElement?.time[i].parameter.parameterName ?? ""
            let comfort = comfortElement?.time[i].parameter.parameterName ?? ""
            let startTime = weatherElement?.time[i].startTime ?? ""
            let endTime = weatherElement?.time[i].endTime ?? ""
            
            let item = WeatherDisplayItem(
                startTime: startTime,
                endTime: endTime,
                weather: weather,
                temperature: "\(minTemp)-\(maxTemp)°C",
                rain: "\(rain)%",
                locationName: location.locationName
            )
            
            items.append(item)
        }
        
        return items
    }
    
    func load(_ locationName: String) {
        isLoading = true
        errorMessage = nil
        
        apiManagerService.fetchWeather(locationName) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let response):
                    if response.records.location.isEmpty {
                        self?.errorMessage =
                        """
                        找不到「\(locationName)」的天氣資料
                        輸入臺灣任一直轄市、縣、市
                        """
                        self?.displayItems = []
                    } else {
                        self?.displayItems = self?.parseWeatherData(response) ?? []
                    }
                case .failure(let error):
                    print("錯誤: \(error)")
                    self?.errorMessage = "載入天氣資料失敗：\(error.localizedDescription)"
                    self?.displayItems = []
                }
            }
        }
    }
}
