//
//  RootViewController.swift
//  ProjectGunshotTests
//
//  Created by Jevon Mao on 6/12/22.
//

import UIKit
import MessageUI

protocol MFMessageComposeViewControllerMock: UIViewController {
    var body: String? {get set}
    var recipients: [String]? {get set}
    static func canSendText() -> Bool
    var messageComposeDelegate: MFMessageComposeViewControllerDelegate? {get set}
}

protocol MFMessagePresentable {
    func present(_ viewControllerToPresent: MFMessageComposeViewControllerMock,
                 animated flag: Bool,
                 completion: (() -> Void)?)
}

protocol MFMessagePresentableMock: MFMessagePresentable {
    var animatedExpectedTrue: Bool {get set}
    var expectedViewController: MFMessageComposeViewControllerMock? {get set}
}

extension UIViewController: MFMessagePresentable {
    func present(_ viewControllerToPresent: MFMessageComposeViewControllerMock,
                 animated flag: Bool,
                 completion: (() -> Void)?) {
        self.present(viewControllerToPresent as UIViewController,
                     animated: flag,
                     completion: completion)
    }
}

extension MFMessageComposeViewController: MFMessageComposeViewControllerMock {}

class MockRootViewController: MFMessagePresentableMock {
    var animatedExpectedTrue: Bool = false
    var expectedViewController: MFMessageComposeViewControllerMock? = nil

    func present(_ viewControllerToPresent: MFMessageComposeViewControllerMock,
                 animated flag: Bool,
                 completion: (() -> Void)? = nil) {
        animatedExpectedTrue = flag
        expectedViewController = viewControllerToPresent
    }
}

class MockMFMessageComposeViewController: UIViewController, MFMessageComposeViewControllerMock {
    static func canSendText() -> Bool { true }

    var body: String?
    var recipients: [String]?
    var messageComposeDelegate: MFMessageComposeViewControllerDelegate?
}
