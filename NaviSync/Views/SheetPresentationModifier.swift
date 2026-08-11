//
//  SheetPresentationModifier.swift
//  NaviSync
//

import SwiftUI

#if canImport(UIKit)
import UIKit

struct SheetPresentationModifier: ViewModifier {
    @Binding var isHidden: Bool
    @Binding var selectedDetent: UISheetPresentationController.Detent.Identifier?
    
    func body(content: Content) -> some View {
        content
            .background(
                SheetPresentationControllerFinder(isHidden: $isHidden, selectedDetent: $selectedDetent)
            )
    }
}

private struct SheetPresentationControllerFinder: UIViewControllerRepresentable {
    @Binding var isHidden: Bool
    @Binding var selectedDetent: UISheetPresentationController.Detent.Identifier?
    
    func makeUIViewController(context: Context) -> UIViewController {
        return UIViewController()
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        DispatchQueue.main.async {
            guard let sheetController = findSheetPresentationController(for: uiViewController) else { return }
            
            // Apply hidden state via private API
            let hideSelector = NSSelectorFromString("_setHidden:")
            if sheetController.responds(to: hideSelector) {
                // Optional: we could check _isHidden to avoid redundant calls, but _setHidden: is usually safe to call
                sheetController.perform(hideSelector, with: isHidden)
            }
            
            // Apply selected detent with animation
            if let targetDetent = selectedDetent, sheetController.selectedDetentIdentifier != targetDetent {
                sheetController.animateChanges {
                    sheetController.selectedDetentIdentifier = targetDetent
                }
            }
        }
    }
    
    private func findSheetPresentationController(for vc: UIViewController) -> UISheetPresentationController? {
        var current: UIViewController? = vc
        while let currentVC = current {
            if let sheet = currentVC.sheetPresentationController {
                return sheet
            }
            current = currentVC.parent
        }
        return nil
    }
}

extension View {
    func mapSheetPresentation(isHidden: Binding<Bool>, selectedDetent: Binding<UISheetPresentationController.Detent.Identifier?>) -> some View {
        self.modifier(SheetPresentationModifier(isHidden: isHidden, selectedDetent: selectedDetent))
    }
}
#endif
