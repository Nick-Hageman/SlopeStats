//
//  WeatherView.swift
//  SlopeStats
//
//  Created by Alex Hageman on 12/23/24.
//

import SwiftUI

struct WeatherView: View {
    @State private var isLoading = true
    @State private var weatherData: WeatherData?

    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Loading...")
                    .onAppear(perform: loadWeatherData)
            } else if let weather = weatherData {
                ScrollView {
//                    VStack(alignment: .leading, spacing: 0) {
//                        StatRowView(iconName: "mountain.2", label: "Altitude", value: "1500", unit: "m", iconColor: .blue, fontColor: .blue)
//                        StatRowView(iconName: "heart", label: "Heart Rate", value: "120", unit: "bpm", iconColor: .red, fontColor: .red)
//                        StatRowView(iconName: "speedometer", label: "Speed", value: "25", unit: "km/h", iconColor: .yellow, fontColor: .yellow)
//                        StatRowView(iconName: "hare", label: "Top Speed", value: "45", unit: "km/h", iconColor: .white, fontColor: .white)
//                    }
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                    .background(Color.black.opacity(0.8))
//                    .cornerRadius(15)
//                    .padding(.horizontal)

                    VStack(alignment: .leading, spacing: 10) {
                        WeatherRowView(iconName: "mappin.and.ellipse", label: "Location", value: "\(weather.location.name), \(weather.location.country)", unit: "", iconColor: .red, fontColor: .white)
                        WeatherRowView(iconName: "thermometer.snowflake", label: "Temperature", value: "\(weather.location.name), \(weather.current.temperature)", unit: "°C", iconColor: .teal, fontColor: .white)
                        WeatherRowView(iconName: "cloud.sleet", label: "Weather", value: "\(weather.location.name), \(weather.current.weatherDescriptions.joined(separator: ", "))", unit: "", iconColor: .gray, fontColor: .white)
                        WeatherRowView(iconName: "wind.snow", label: "Wind Speed", value: "\(weather.location.name), \(weather.current.windSpeed)", unit: "km/h", iconColor: .white, fontColor: .white)
                        WeatherRowView(iconName: "safari", label: "Wind Direction", value: "\(weather.location.name), \(weather.current.windDir)", unit: "", iconColor: .white, fontColor: .white)
                        WeatherRowView(iconName: "barometer", label: "Pressure", value: "\(weather.location.name), \(weather.current.pressure)", unit: "hPa", iconColor: .yellow, fontColor: .white)
                        WeatherRowView(iconName: "eye.fill", label: "Visibility", value: "\(weather.location.name), \(weather.current.visibility)", unit: "km", iconColor: .white, fontColor: .white)

//                        Text("Location: \(weather.location.name), \(weather.location.country)")
//                            .font(.headline)
//                        Text("Temperature: \(weather.current.temperature)°C")
//                        Text("Weather: \(weather.current.weatherDescriptions.joined(separator: ", "))")
//                        Text("Wind Speed: \(weather.current.windSpeed) km/h")
//                        Text("Wind Direction: \(weather.current.windDir)")
//                        Text("Pressure: \(weather.current.pressure) hPa")
//                        Text("Visibility: \(weather.current.visibility) km")
                    }
                    .padding()
                }
            } else {
                Text("Failed to load weather data.")
            }
        }
        .navigationTitle("Weather")
    }

    private func loadWeatherData() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            guard let url = Bundle.main.url(forResource: "weather", withExtension: "json"),
                  let data = try? Data(contentsOf: url),
                  let decodedData = try? JSONDecoder().decode(WeatherData.self, from: data) else {
                isLoading = false
                return
            }
            weatherData = decodedData
            isLoading = false
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

// Reusable stat row view with customizable colors
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

#Preview {
    WeatherView()
}
