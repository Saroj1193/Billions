# Billions iOS App

Billions is an iOS application built with UIKit and Storyboards, following a clean, modular architecture.  
The project is designed for scalability and easy feature expansion, including chat UI components and future integration with services like Firebase.


## 🚀 Features
- UIKit + Storyboards architecture
- Reusable UI components
- Organized folder structure for maintainability
- Chat-specific views and cells
- CocoaPods support for external libraries


## 📁 Project Structure
BillionsApp/
│
├─ App/                 → AppDelegate, SceneDelegate, core setup
├─ Model/               → Data models
├─ Viewcontrollers/     → Screens and UI logic
├─ View/Chat/           → Chat UI components
├─ Storyboard/          → Interface Builder layouts
├─ Common/              → Helpers, extensions & reusable utilities
├─ Support Files/       → Info.plist, Assets
├─ Pods/                → Third-party dependencies (auto-generated)


## 🛠️ Requirements
| Tool | Version |
|------|---------|
| Xcode | 15.0+ |
| iOS Deployment Target | 14.0+ |
| Swift | 5+ |
| CocoaPods | Installed locally |

**Install CocoaPods:**

sudo gem install cocoapods

## ▶️ Getting Started

**Clone the repository**
git clone https://github.com/Saroj1193/Billions.git
cd Billions

**Install dependencies**
pod install

**Open the project**
open BillionsApp.xcworkspace

**Run the app**

Select a simulator or device in Xcode and press:

⌘ + R

## 🔐 Optional: Firebase Integration

If you want to enable backend support:

Download GoogleService-Info.plist from Firebase Console

Add it to Xcode under the BillionsApp target

Add to AppDelegate:

import FirebaseCore
FirebaseApp.configure()

## 📌 Notes

Always open the .xcworkspace file (not .xcodeproj)

Pods/ is currently included — can be removed and regenerated if needed
```bash
