//
//  LCLLocationManager.swift
//  
//
//  Created by Justin Honda on 1/23/22.
//

import CoreLocation
#if !os(macOS)
import HealthKit
#endif


public enum LocationManagerError: Error {
    case unknown
    case locationServicesNotEnabled
}

public final class LCLLocationManager: NSObject, ObservableObject {
    
    // MARK: - Private Properties
    
    /// add description
    private let locationManager: CLLocationManager
    private let configuration: LocationManagerConfiguration

    // MARK: - Public Properties
    
    @Published public var authorizationStatus: CLAuthorizationStatus
    @Published public var accuracyAuthorization: CLAccuracyAuthorization
    
    /// raw value in meters per second
    @Published private(set) public var speed: CLLocationSpeed = 0
    /// raw value in meters
    @Published private(set) public var distance: Double = 0
    /// used to calculate distance from a newer location
    @Published private(set) public var previousLocation: CLLocation?
    
#if !os(macOS)
    public weak var routeBuilder: HKWorkoutRouteBuilder?
#endif
    
    // MARK: - Public Init
    
    public init(_ configuration: LocationManagerConfiguration) {
        self.configuration = configuration
        
        let locationManager: CLLocationManager = {
            let lm = CLLocationManager()
            lm.desiredAccuracy = configuration.desiredAccuracy
#if os(iOS) || os(macOS)
            lm.pausesLocationUpdatesAutomatically = configuration.canPauseLocationUpdatesAutomatically
#endif
            lm.allowsBackgroundLocationUpdates = configuration.allowsBackgroundLocationUpdates
            lm.activityType = configuration.activityType
            lm.distanceFilter = configuration.distanceFilter
            return lm
        }()
        
        self.locationManager = locationManager
        self.authorizationStatus = locationManager.authorizationStatus
        self.accuracyAuthorization = locationManager.accuracyAuthorization
        
        super.init()
        
        self.locationManager.delegate = self
    }
    
    // MARK: - Public Methods
    
    /// Depending on the `authorizationMode` configured in the `LocationManagerConfiguration`, this method will
    /// call the appropriate permissions request method.
    ///
    /// Reminder to developer. Your app's `Info.plist` must include the correct privacy key-value pair corresponding to the
    /// type of permissions your app requires.
    public func requestAuthorization() throws {
        guard CLLocationManager.locationServicesEnabled() else {
            throw LocationManagerError.locationServicesNotEnabled
        }
        
        switch configuration.authorizationMode {
            case .whenInUse:
                locationManager.requestWhenInUseAuthorization()
            case .always:
                locationManager.requestAlwaysAuthorization()
        }
    }
    
    public func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
    
    public func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
}

// MARK: - CLLocationManagerDelegate

extension LCLLocationManager: CLLocationManagerDelegate {
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        accuracyAuthorization = manager.accuracyAuthorization
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        #if !os(macOS)
        routeBuilder?.insertRouteData(locations) { (success, error) in
            if let error = error {
                // NOTE: - There is an error with watchOS simulators above Series 5.
                debugPrint("Error inserting route data for workout route builder:", error)
            }
            // NOTE: - When using simulator, use Series 5 for successful route building.
            debugPrint("Adding locations to workout route builder:", locations)
        }
        #endif
        guard let location = locations.first,
              location.timestamp.timeIntervalSinceNow < 3.1,
              location.horizontalAccuracy < 20,
              location.speed > 0.35
        else { return }

        speed = location.speed
        
        if let previousLocation = previousLocation {
            distance += location.distance(from: previousLocation)
        }
        
        previousLocation = location
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        debugPrint("******* Location Manager failed with error ******* \n \(error.localizedDescription)")
    }
}
