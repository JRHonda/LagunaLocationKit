//
//  LocationManager.swift
//  
//
//  Created by Justin Honda on 1/23/22.
//

import CoreLocation

public enum AuthorizationMode {
    case whenInUse
    case always
}

public final class LocationManager: NSObject, ObservableObject {
    
    // MARK: - Private Properties
    
    /// add description
    private let locationManager: CLLocationManager = {
        let lm = CLLocationManager()
        // lm.pausesLocationUpdatesAutomatically = true // not yet supporting - need to test to see if this makes sense in the context of a PFT running session.
        lm.allowsBackgroundLocationUpdates = true // must be a capability set in project settings
        lm.activityType = .fitness
        lm.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        return lm
    }()
    
    /// add description
    public weak var delegate: LocationManagerDelegate?
    
    
    // MARK: - Public Properties
    
    /// add description
    @Published public var authorizationStatus: CLAuthorizationStatus
    
    /// add description
    @Published public var accuracyAuthorization: CLAccuracyAuthorization
    
    
    // MARK: - Public Override Init
    
    public override init() {
        self.authorizationStatus = locationManager.authorizationStatus
        self.accuracyAuthorization = locationManager.accuracyAuthorization
        
        super.init()
        
        self.locationManager.delegate = self
    }
    
    
    // MARK: - Public Methods
    
    
    /// add description
    /// - Parameter authorizationMode: add description
    public func requestAuthorization(_ authorizationMode: AuthorizationMode) {
        switch authorizationMode {
            case .whenInUse:
                locationManager.requestWhenInUseAuthorization()
            case .always:
                locationManager.requestAlwaysAuthorization()
        }
    }
}


// MARK: - CLLocationManagerDelegate

extension LocationManager: CLLocationManagerDelegate {
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        accuracyAuthorization = manager.accuracyAuthorization
        
        switch manager.authorizationStatus {
            case .authorizedWhenInUse, .authorized, .authorizedAlways:
                locationManager.startUpdatingLocation()
            default:
                return
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        delegate?.locationManager(didReceiveLocations: locations)
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        delegate?.locationManager(didFailWithError: error)
    }
}

// MARK: - Location Manager

public protocol LocationManagerDelegate: AnyObject {
    
    /// Receives error from `CLLocationmanagerDelegate` method `didFailWithError`
    func locationManager(didFailWithError error: Error)
    
    /// Receives new locations as they come in through the `CLLocationManagerDelegate` method `didUpdateLocations`
    func locationManager(didReceiveLocations locations: [CLLocation])
}

// MARK: - Optional CLLocationManager Configuration (not yet implemented)

public struct LocationManagerConfiguration {
    
    // MARK: - Public Properties
    
    /// Designed to be passed to the `pausesLocationUpdatesAutomatically` property on a `CLLocationManager` instance
    public let canPauseLocationUpdatesAutomatically: Bool
    
    /// Designed to be passed to the `allowsBackgroundLocationUpdates` property on a `CLLocationManager` instance
    public let allowsBackgroundLocationUpdates: Bool
    
    
    // MARK: - Public Init
    
    public init(canPauseLocationUpdatesAutomatically: Bool, allowsBackgroundLocationUpdates: Bool) {
        self.canPauseLocationUpdatesAutomatically = canPauseLocationUpdatesAutomatically
        self.allowsBackgroundLocationUpdates = allowsBackgroundLocationUpdates
    }
}
