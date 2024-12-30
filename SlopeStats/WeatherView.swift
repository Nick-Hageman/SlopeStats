//
//  WeatherView.swift
//  SlopeStats
//
//  Created by Alex Hageman on 12/27/24.
//
import SwiftUI
import UIKit
import CoreLocation

struct WeatherView: View {
    @State private var isLoading = true
    @State private var weatherData: WeatherData?
    @StateObject private var locationManagerDelegate = LocationManagerDelegate()

    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Loading...")
                    .onAppear(perform: fetchWeather)
            } else if let weather = weatherData {
                ScrollView {
                    VStack {
                        WeatherRowView(iconName: "mappin.and.ellipse", label: "Location", value: "\(weather.location.name), \(weather.location.country)", unit: "", iconColor: .red, fontColor: .black)
                        WeatherRowView(iconName: "thermometer.snowflake", label: "Temperature", value: "\(weather.current.temperature)", unit: "°C", iconColor: .teal, fontColor: .black)
                        WeatherRowView(iconName: "cloud.sleet", label: "Weather", value: "\(weather.current.weatherDescriptions.joined(separator: ", "))", unit: "", iconColor: .gray, fontColor: .black)
                        WeatherRowView(iconName: "wind.snow", label: "Wind Speed", value: "\(weather.current.windSpeed)", unit: "km/h", iconColor: .black, fontColor: .black)
                        WeatherRowView(iconName: "safari", label: "Wind Direction", value: "\(weather.current.windDir)", unit: "", iconColor: .black, fontColor: .black)
                        WeatherRowView(iconName: "barometer", label: "Pressure", value: "\(weather.current.pressure)", unit: "hPa", iconColor: .yellow, fontColor: .black)
                        WeatherRowView(iconName: "eye.fill", label: "Visibility", value: "\(weather.current.visibility)", unit: "km", iconColor: .black, fontColor: .black)
                    }
                    .padding()
                }
            } else {
                Text("Failed to load weather data.")
            }
        }
    }

    private func fetchWeather() {
        locationManagerDelegate.requestLocation { latitude, longitude in
            if let latitude = latitude, let longitude = longitude {
                getWeather(latitude: latitude, longitude: longitude)
            } else {
                isLoading = false
            }
        }
    }

    private func getWeather(latitude: Double, longitude: Double) {
        if let apiKey = ProcessInfo.processInfo.environment["WEATHER_API_KEY"] {
            let urlString = "https://api.weatherstack.com/current?access_key=\(apiKey)&query=\(latitude),\(longitude)"

            guard let url = URL(string: urlString) else {
                isLoading = false
                return
            }

            URLSession.shared.dataTask(with: url) { data, response, error in
                DispatchQueue.main.async {
                    isLoading = false
                }

                if let error = error {
                    print("Error: \(error.localizedDescription)")
                    return
                }

                guard let data = data else {
                    return
                }

                if let decodedData = try? JSONDecoder().decode(WeatherData.self, from: data) {
                    DispatchQueue.main.async {
                        weatherData = decodedData
                    }
                } else {
                    print("Failed to parse weather data.")
                }
            }.resume()
        } else {
            print("API Key is not set.")
        }
    }
}

struct WeatherData: Codable {
    struct Location: Codable {
        let name: String
        let country: String
    }

    struct Current: Codable {
        let temperature: Int
        let weatherDescriptions: [String]
        let windSpeed: Int
        let windDir: String
        let pressure: Int
        let visibility: Int

        enum CodingKeys: String, CodingKey {
            case temperature
            case weatherDescriptions = "weather_descriptions"
            case windSpeed = "wind_speed"
            case windDir = "wind_dir"
            case pressure
            case visibility
        }
    }

    let location: Location
    let current: Current
}

struct WeatherRowView: View {
    let iconName: String
    let label: String
    let value: String
    let unit: String
    let iconColor: Color
    let fontColor: Color

    var body: some View {
        VStack {
            HStack {
                Image(systemName: iconName)
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundColor(iconColor)
                Text(label)
                    .font(.headline)
                    .foregroundColor(fontColor)
            }
            Text("\(value) \(unit)")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 4)
    }
}

class LocationManagerDelegate: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    private var completion: ((Double?, Double?) -> Void)?

    override init() {
        super.init()
        locationManager.delegate = self
    }

    func requestLocation(completion: @escaping (Double?, Double?) -> Void) {
        self.completion = completion
        locationManager.requestWhenInUseAuthorization()

        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestLocation()
        } else {
            completion(nil, nil)
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            completion?(location.coordinate.latitude, location.coordinate.longitude)
        } else {
            completion?(nil, nil)
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
        completion?(nil, nil)
    }
}
