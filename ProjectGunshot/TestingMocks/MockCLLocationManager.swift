//
//  MockCLLocationManager.swift
//  ProjectGunshot
//
//  Created by Jevon Mao on 6/13/22.
//

import CoreLocation

//protocol CLLocationManagerMock: CLLocationMan
class MockCLLocationManager: CLLocationManager {
    typealias c = Constants.UnitTests
    var fail: Bool

    init(fail: Bool = false) {
        self.fail = fail
        super.init()
    }

    override func requestLocation() {
        if fail {
            let error = NSError(domain: "", code: c.errorCode)
            self.delegate?.locationManager?(self, didFailWithError: error)
        }
        else {

        }
        self.delegate?.locationManager?(self, didUpdateLocations: [.init(latitude: .init(integerLiteral: Int64(c.latitude)), longitude: .init(integerLiteral: Int64(c.longtitude)))])
    }
}
