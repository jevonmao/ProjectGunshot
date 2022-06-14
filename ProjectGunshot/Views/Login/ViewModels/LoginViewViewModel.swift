//
//  LoginViewViewModel.swift
//  ProjectGunshot
//
//  Created by Jevon Mao on 6/13/22.
//

import Combine
import FirebaseAuth

class LoginViewViewModel: ObservableObject {
    @Published var phoneNumber: String = ""
    @Published var verificationCode: String = ""

    
}
