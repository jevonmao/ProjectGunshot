//
//  MessageManager.swift
//  ProjectGunshot
//
//  Created by Jevon Mao on 6/12/22.
//

import Foundation
import MessageUI

/// Delegate for view controller as `MFMessageComposeViewControllerDelegate`
class MessageManager: NSObject, ObservableObject, MFMessageComposeViewControllerDelegate {
    var rootViewController: UIViewController? {
        UIApplication.shared.keyWindow?.rootViewController
    }

    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        // Customize here
        controller.dismiss(animated: true)
    }

    /// Present an message compose view controller modally in UIKit environment
    func presentMessageCompose (recipient: String,
                                          body: String,
                                _rootVC: MFMessagePresentable? = nil,
                                _messageComposeVC: MFMessageComposeViewControllerMock? = nil) {
        let rootVC = _rootVC ?? rootViewController
        let messageComposeVC = _messageComposeVC ?? MFMessageComposeViewController()

        guard type(of: messageComposeVC).canSendText() else {
            debugPrint("Failed to send text because canSendText() is false")
            return
        }

        messageComposeVC.body = body
        messageComposeVC.recipients = [recipient]
        messageComposeVC.messageComposeDelegate = self
        rootVC?.present(messageComposeVC, animated: true, completion: nil)
    }
}


