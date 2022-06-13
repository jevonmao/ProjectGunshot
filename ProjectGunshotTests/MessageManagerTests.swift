//
//  MessageManagerTests.swift
//  MessageManagerTests
//
//  Created by Jevon Mao on 6/5/22.
//

import XCTest
@testable import ProjectGunshot

class MessageManagerTests: XCTestCase {
    typealias c = Constants.UnitTests
    var messageManager = MessageManager()

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testPresentMessageCompose() {
        let mockRootVC = MockRootViewController()
        let mockMFMessageVC = MockMFMessageComposeViewController()
        messageManager.presentMessageCompose(recipient: c.phoneNumber,
                                             body: c.smsMessage,
                                             _rootVC: mockRootVC as MFMessagePresentable, _messageComposeVC: mockMFMessageVC)
        

        XCTAssertTrue(mockRootVC.animatedExpectedTrue)
        XCTAssertEqual(mockRootVC.expectedViewController?.recipients, [c.phoneNumber])
        XCTAssertEqual(mockRootVC.expectedViewController?.body, c.smsMessage)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
