//
//  CarPlaySceneDelegate.swift
//  NaviSync
//
//  Created for NaviSync App.
//

#if canImport(UIKit)
import UIKit
#endif

#if canImport(CarPlay)
import CarPlay

class CarPlaySceneDelegate: NSObject, CPTemplateApplicationSceneDelegate {
    func templateApplicationScene(
        _ templateApplicationScene: CPTemplateApplicationScene,
        didConnect interfaceController: CPInterfaceController
    ) {
        print("CarPlay connected successfully!")
        Task { @MainActor in
            let meetingStore = MeetingStore()
            CarPlayManager.shared.setupInterfaceController(interfaceController, meetingStore: meetingStore)
        }
    }
    
    func templateApplicationScene(
        _ templateApplicationScene: CPTemplateApplicationScene,
        didDisconnect interfaceController: CPInterfaceController
    ) {
        print("CarPlay disconnected.")
    }
}
#endif
