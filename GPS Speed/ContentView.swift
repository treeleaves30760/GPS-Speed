//
//  ContentView.swift
//  GPS Speed
//
//  Created by 許博翔 on 2024/8/27.
//

import SwiftUI
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var location: CLLocation?
    @Published var speed: CLLocationSpeed = 0
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.location = location
        self.speed = location.speed > 0 ? location.speed : 0
    }
}

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    
    var body: some View {
        VStack(spacing: 20) {
            Text(speedString(mps: locationManager.speed))
                .font(.system(size: 48, weight: .bold))
                .padding()
            
            if let location = locationManager.location {
                Group {
                    Text(formatCoordinate(location.coordinate.latitude, type: "latitude"))
                    Text(formatCoordinate(location.coordinate.longitude, type: "longitude"))
                    Text("海拔: \(location.altitude, specifier: "%.2f") 公尺")
                }
                .font(.system(size: 16))
            } else {
                Text("正在獲取位置...")
            }
        }
        .padding()
    }
    
    func speedString(mps: CLLocationSpeed) -> String {
        let kph = max(0, mps * 3.6)
        return String(format: "%.1f km/h", kph)
    }
    
    func formatCoordinate(_ coordinate: CLLocationDegrees, type: String) -> String {
        let absCoordinate = abs(coordinate)
        let degrees = Int(absCoordinate)
        let minutes = Int((absCoordinate - Double(degrees)) * 60)
        let seconds = (absCoordinate - Double(degrees) - Double(minutes) / 60) * 3600
        
        let directionSuffix: String
        let coordinateType: String
        
        switch type {
        case "latitude":
            directionSuffix = coordinate >= 0 ? "北緯" : "南緯"
            coordinateType = "緯度"
        case "longitude":
            directionSuffix = coordinate >= 0 ? "東經" : "西經"
            coordinateType = "經度"
        default:
            return "Invalid coordinate type"
        }
        
        return String(format: "%@: %@ %d° %d' %.2f\"", coordinateType, directionSuffix, degrees, minutes, seconds)
    }
}

#Preview {
    ContentView()
}
