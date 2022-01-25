//
//  LocationManagerConfiguration.swift
//  
//
//  Created by Justin Honda on 1/24/22.
//

import CoreLocation

public struct LocationManagerConfiguration {
    
    // MARK: - Public Properties
    
    /// Designed to be passed to the `pausesLocationUpdatesAutomatically` property on a `CLLocationManager` instance
    public let canPauseLocationUpdatesAutomatically: Bool
    
    /// Designed to be passed to the `allowsBackgroundLocationUpdates` property on a `CLLocationManager` instance
    public let allowsBackgroundLocationUpdates: Bool
    
    /// Designed to be passed to the `activityType` property on a `CLLocationManager` instance
    public let activityType: CLActivityType
    
    /// Designed to be passed to the `desiredAccuracy` property on a `CLLocationManager` instance
    public let desiredAccuracy: CLLocationAccuracy
    
    /// add description
    public let authorizationMode: AuthorizationMode
    
    /// add description
    public let distanceFilter: CLLocationDistance
    
    
    // MARK: - Public Init
    
    public init(canPauseLocationUpdatesAutomatically: Bool,
                allowsBackgroundLocationUpdates: Bool,
                activityType: CLActivityType,
                desiredAccuracy: CLLocationAccuracy,
                authorizationMode: AuthorizationMode,
                distanceFilter: CLLocationDistance) {
        self.canPauseLocationUpdatesAutomatically = canPauseLocationUpdatesAutomatically
        self.allowsBackgroundLocationUpdates = allowsBackgroundLocationUpdates
        self.activityType = activityType
        self.desiredAccuracy = desiredAccuracy
        self.authorizationMode = authorizationMode
        self.distanceFilter = distanceFilter
    }
}
