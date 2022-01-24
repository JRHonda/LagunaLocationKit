//
//  LocationManager.swift
//  
//
//  Created by Justin Honda on 1/23/22.
//

import CoreLocation

public final class LocationManager: ObservableObject {
    
    private let locationManager = CLLocationManager()
    
    @Published var authorizationStatus: CLAuthorizationStatus
    @Published var accuracyAuthorization: CLAccuracyAuthorization
    
    public init(_ configuration: LocationManagerConfiguration,
                _ delegate: CLLocationManagerDelegate,
                requestAuthorization: () -> Void,
                shouldStartUpdatingLocationsNow: Bool = false) {
        
        self.authorizationStatus = locationManager.authorizationStatus
        self.accuracyAuthorization = locationManager.accuracyAuthorization
        self.locationManager.delegate = delegate
        requestAuthorization()
        
        if shouldStartUpdatingLocationsNow {
            locationManager.startUpdatingLocation()
        }
    }
}

public struct LocationManagerConfiguration {
    public let desiredAccuracy: CLLocationAccuracy
    public let activityType: CLActivityType
}
