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
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        // Customize here
        controller.dismiss(animated: true)
    }

    /// Present an message compose view controller modally in UIKit environment
    func presentMessageCompose(recipient: String, body: String) {
        guard MFMessageComposeViewController.canSendText() else {
            debugPrint("Failed to send text because canSendText() is false")
            return
        }
        let vc = UIApplication.shared.keyWindow?.rootViewController

        let composeVC = MFMessageComposeViewController()
        composeVC.body = body
        composeVC.recipients = [recipient]
        composeVC.messageComposeDelegate = self


        vc?.present(composeVC, animated: true)
    }
}


