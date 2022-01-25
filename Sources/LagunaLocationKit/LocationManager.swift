//
//  LocationManager.swift
//  
//
//  Created by Justin Honda on 1/23/22.
//

import CoreLocation

public enum LocationManagerError: Error {
    case unknown
    case locationServicesNotEnabled
}

// MARK: - Location Manager Delegate

public protocol LocationManagerDelegate: AnyObject {
    
    /// Receives error from `CLLocationmanagerDelegate` method `didFailWithError`
    func locationManager(didFailWithError error: Error)
    
    /// Receives new locations as they come in through the `CLLocationManagerDelegate` method `didUpdateLocations`
    func locationManager(didReceiveLocations locations: [CLLocation])
}


// MARK: - Location Manager

public final class LocationManager: NSObject, ObservableObject {
    
    // MARK: - Private Properties
    
    /// add description
    private let locationManager: CLLocationManager
    
    private let configuration: LocationManagerConfiguration
    
    
    // MARK: - Public Delegate Property
    
    /// add description
    public weak var delegate: LocationManagerDelegate?
    
    
    // MARK: - Public Properties
    
    /// add description
    @Published public var authorizationStatus: CLAuthorizationStatus
    
    /// add description
    @Published public var accuracyAuthorization: CLAccuracyAuthorization
    
    
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

extension LocationManager: CLLocationManagerDelegate {
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        accuracyAuthorization = manager.accuracyAuthorization
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        delegate?.locationManager(didReceiveLocations: locations)
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        delegate?.locationManager(didFailWithError: error)
    }
}
