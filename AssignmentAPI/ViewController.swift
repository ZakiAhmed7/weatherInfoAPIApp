//
//  ViewController.swift
//  AssignmentAPI
//
//  Created by ZakiAhmedSyed on 11/16/23.
//

import UIKit
import CoreLocation
import Foundation

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet var cityNameLabel : UILabel!
    @IBOutlet var whetherConditionLabel : UILabel!
    @IBOutlet var tempLabel : UILabel!
    @IBOutlet var humidityLabel : UILabel!
    @IBOutlet var windLabel : UILabel!
    @IBOutlet var imageView : UIImageView!
    
//    let apiURL = "https://api.openweathermap.org/data/2.5/weather?q=Waterloo,CA&appid=f37ff61254cea47efa9b35584609d346"
    
    var locManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        locManager.desiredAccuracy = kCLLocationAccuracyBest
        locManager.delegate = self
        // Asking Permission
        locManager.requestWhenInUseAuthorization()
        
        locManager.startUpdatingLocation()

    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let loc = locations.first {
            print(loc.coordinate.latitude)
            print(loc.coordinate.longitude)
            getWeatherInformation(coordinates : loc)
            
            locManager.stopUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Manager Error: \(error.localizedDescription)")
    }
    
    func getWeatherInformation(coordinates : CLLocation) {
        let latitude = coordinates.coordinate.latitude
        let longtitude = coordinates.coordinate.longitude
        
        // lat = 43.466667
        //lon = -80.51667
        
        let apiURL = "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longtitude)&appid=f37ff61254cea47efa9b35584609d346"
        
        print(apiURL)
        guard let url = URL(string: apiURL) else {
            print("Invalid URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let data = data {
                do {
                    let weatherInfo = try JSONDecoder().decode(WeatherData.self, from: data)
                    // Update UI on the main thread
                    DispatchQueue.main.async {
                               self.displayInformation(with: weatherInfo)
                           }
                       } catch let decodingError {
                           print("Error decoding JSON: \(decodingError)")
                       }
                   } else if let networkError = error {
                       print("Error fetching weather data: \(networkError)")
                   }
               }.resume()
        
    }
    
    func displayInformation(with weatherData: WeatherData) {
        cityNameLabel.text = weatherData.name

        if let weather = weatherData.weather.first {
            whetherConditionLabel.text = weather.description

            // Convert temperature to degrees Celsius
            let temperatureInCelsius = Int(weatherData.main.temp - 273.15)
            tempLabel.text = "\(temperatureInCelsius)°C"

            // Display humidity in percentage
            humidityLabel.text = "Humidity: \(weatherData.main.humidity) %"

            // Convert wind speed to km/h
            let windSpeedInKMH = weatherData.wind.speed * 3.6
            windLabel.text = "Wind: \(String(format: "%.1f", windSpeedInKMH)) km/h"

            if let iconName = weather.icon {
                // Assuming you have appropriate images for the weather icons
                imageView.image = UIImage(named: iconName)
            }
        }
    }
    
}

struct WeatherData: Decodable {
    let name: String
    let main: Main
    let weather: [Weather]
    let wind: Wind
}

struct Main: Decodable {
    let temp: Double
    let humidity: Double
}

struct Weather: Decodable {
    let description: String
    let icon: String?
}

struct Wind: Decodable {
    let speed: Double
}
