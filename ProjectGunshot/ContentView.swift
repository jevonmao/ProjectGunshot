//
//  ContentView.swift
//  ProjectGunshot
//
//  Created by Jevon Mao on 6/5/22.
//

import SwiftUI
import PermissionsSwiftUILocation
import MessageUI

struct ContentView: View {
    @State var showPermissionRequest = false
    @StateObject var locationManager = LocationManager()
    @StateObject var messageManager = MessageManager()

    var body: some View {
        ZStack {
            if let location = locationManager.location  {
                Button("Send SMS") {
                    messageManager.presentMessageCompose(recipient: "911",
                                          body: "\(location.latitude.formatted()), \(location.longitude.formatted())")
                }
            }
            else {
                VStack {
                    ProgressView()
                    Text("We are getting your GPS location...")
                }
            }

        }
        .JMAlert(showModal: $showPermissionRequest, for: [.location])
        .onAppear {
            locationManager.requestLocation()
            showPermissionRequest = true
        }
    }
}

extension ContentView {

    
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
