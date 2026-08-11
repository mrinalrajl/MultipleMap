# 🗺️ NaviSync

NaviSync is a highly polished iOS application designed to revolutionize the way friends meet up. Send a single invite link, and effortlessly track everyone's real-time journey to a shared meeting location.

## ✨ Key Features

- **Real-Time Tracking**: See exactly where your friends are as they navigate to the meeting spot.
- **Apple Maps-Like Interface**: A native, dynamic bottom sheet powered by `UISheetPresentationController` that declutters the map UI when you need to focus on navigation.
- **Live Activities & Dynamic Island**: Keep an eye on ETA and participant status directly from your lock screen or Dynamic Island.
- **CarPlay Integration**: Includes full CarPlay support with map templates for tracking friends right from your dashboard.
- **App Clips & Deep Links**: Seamlessly share meeting links. If a friend doesn't have the app installed, they can join instantly via an App Clip.
- **Micro-Interactions**: Profile avatars replacing map pins, interactive statistics, and smooth animations throughout the experience.

## 🚀 Getting Started

This repository is a standard Xcode project targeting iOS 17+.

### Prerequisites
- macOS Sonoma or later
- Xcode 15+ 

### Installation
1. Clone the repository to your local machine.
2. Open `NaviSync.xcodeproj` in Xcode.
3. Select an **iOS Simulator** (e.g., iPhone 15 Pro) from the top target menu.
4. Press `Cmd + R` (Run) to launch the app!

## 🛠️ Technology Stack
- **Framework**: SwiftUI (iOS 17+) & UIKit bridging
- **Map Integration**: MapKit (Native Apple Maps)
- **CarPlay**: CarPlay framework with `CPMapTemplate`
- **Widgets**: ActivityKit for Live Activities
- **Architecture**: MVVM
