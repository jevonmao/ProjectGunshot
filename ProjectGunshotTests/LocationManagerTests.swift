//
//  LocationManagerTests.swift
//  ProjectGunshotTests
//
//  Created by Jevon Mao on 6/13/22.
//

import XCTest
import CoreLocation
@testable import ProjectGunshot

final class LocationManagerTests: XCTestCase, CLLocationManagerDelegate {
    typealias c = Constants.UnitTests
    var testCoordinate: CLLocationCoordinate2D?
    var expectedError: Error?

    let successExpectation = XCTestExpectation(description: "")
    let failureExpectation = XCTestExpectation(description: "")

    func testRequestLocationSetup() {
        let locationManager = LocationManager()
        let clLocationManager = CLLocationManager()
        clLocationManager.delegate = self
        locationManager.requestLocation(_manager: clLocationManager)
        
        XCTAssertEqual(clLocationManager.desiredAccuracy, kCLLocationAccuracyNearestTenMeters)
    }

    func testRequestLocationSuccess() throws {
        let locationManager = LocationManager()
        let clLocationManager = MockCLLocationManager()
        clLocationManager.delegate = self
        locationManager.requestLocation(_manager: clLocationManager as CLLocationManager)

        wait(for: [successExpectation], timeout: 5)
        let expectedCoordinates = try XCTUnwrap(testCoordinate)
        XCTAssertEqual(Int(expectedCoordinates.latitude), c.latitude)
        XCTAssertEqual(Int(expectedCoordinates.longitude), c.longtitude)

    }

    func testRequestLocationFailure() throws {
        let locationManager = LocationManager()
        let clLocationManager = MockCLLocationManager(fail: true)
        clLocationManager.delegate = self
        locationManager.requestLocation(_manager: clLocationManager)

        wait(for: [failureExpectation], timeout: 5)
        let error = try XCTUnwrap(expectedError)
        XCTAssertEqual((error as NSError).code, c.errorCode)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.first?.coordinate
        testCoordinate = location
        successExpectation.fulfill()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        expectedError = error
        failureExpectation.fulfill()
    }
}
