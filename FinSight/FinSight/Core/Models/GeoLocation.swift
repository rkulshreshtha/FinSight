import Foundation
import CoreLocation

public struct GeoLocation: Codable, Hashable {
    public var latitude: Double
    public var longitude: Double
    public var placeName: String?
    public var address: String?
    
    public init(latitude: Double, longitude: Double, placeName: String? = nil, address: String? = nil) {
        self.latitude = latitude
        self.longitude = longitude
        self.placeName = placeName
        self.address = address
    }
    
    public var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
