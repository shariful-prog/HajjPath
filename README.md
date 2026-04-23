# FamilyPath - Hajj Tracking & Safety Companion

FamilyPath is a premium Flutter-based Android application designed to provide live tracking, safety monitoring, and ritual assistance for pilgrims during Hajj. 

Developed and maintained by **Techgic**, the app focuses on simplicity, reliability, and modern design standards (inspired by the Noor Guide).

## ✨ Key Features

- **📍 Real-Time Location Dashboard**: Live GPS tracking and reverse geocoding to show the pilgrim's exact address (e.g., Masjid al-Haram) with update timestamps.
- **🛡️ Safety & Tracking Status**: Visual indicators ensuring family members are "Active" and "Safe" in the crowded pilgrimage environment.
- **🆘 Emergency SOS**: One-tap emergency alert system for elderly-friendly safety.
- **🏮 Hajj Assistance Hub**: Integrated access to ritual guides, daily duas, and the Holy Quran.
- **🌐 Embedded Resource Viewer**: In-app WebView integration for viewing guides (PDF) and websites without leaving the application.
- **🌓 Premium Design System**: Modern typography using **Plus Jakarta Sans** and **Lexend**, following a professional Hajj-themed color palette.
- **🔐 Role-Based Access**: Specialized interfaces for both Pilgrims (Users) and Monitors (Admins).

## 🛠️ Technology Stack

- **Framework**: Flutter
- **Database**: Firebase Realtime Database
- **Location**: Geolocator & Geocoding
- **Navigation**: Persistent Bottom Navigation with Role-based routing.
- **Resources**: WebView Flutter
- **Styling**: Google Fonts (Plus Jakarta Sans, Lexend)

## 🚀 Getting Started

Follow these instructions to get a copy of the project up and running on your local machine for development and testing purposes.

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Latest Stable)
- [Android Studio](https://developer.android.com/studio) or VS Code
- A [Firebase Account](https://console.firebase.google.com/)

---

## 🛠️ Firebase Configuration

This app uses Firebase Realtime Database and Anonymous Authentication. Follow these steps to set up your backend:

### 1. Create a Firebase Project
1. Go to the [Firebase Console](https://console.firebase.google.com/).
2. Click **Add project** and follow the setup wizard.

### 2. Enable Realtime Database
1. In the Firebase Sidebar, go to **Build > Realtime Database**.
2. Click **Create Database**.
3. Select your location (Recommended: **Asia Southeast 1** for proximity to Hajj regions).
4. Start in **Locked Mode** (we will update rules next).

### 3. Set Database Rules
To allow the app to read user data and write location updates, set your rules to the following (or customize for production):
```json
{
  "rules": {
    ".read": "auth != null",
    ".write": "auth != null"
  }
}
```

### 4. Enable Anonymous Authentication
1. Go to **Build > Authentication**.
2. Click the **Sign-in method** tab.
3. Click **Add new provider** and select **Anonymous**.
4. Enable it and save.

---

## 🔧 Local Setup & Connection

### 1. Register Android App
1. In your Firebase Project Overview, click the **Android** icon.
2. Enter your package name (found in `android/app/build.gradle` -> `applicationId`, usually `com.techgic.familypath`).
3. Download `google-services.json` and place it in the `android/app/` directory.

### 2. Configure Connection URL
1. Copy your Realtime Database URL from the Firebase Console (e.g., `https://your-db-id.firebasedatabase.app/`).
2. Open [lib/core/config/app_config.dart](file:///d:/Tools/Flutter/Project/familypath/lib/core/config/app_config.dart).
3. Update the `firebaseDatabaseUrl` constant:
   ```dart
   static const String firebaseDatabaseUrl = 'YOUR_DATABASE_URL_HERE';
   ```

---

## 👥 Adding Users

The app uses a custom authentication logic based on predefined users in the database.

1. Locate the [seekdata/users.json](file:///d:/Tools/Flutter/Project/familypath/seekdata/users.json) file.
2. In the Firebase Realtime Database dashboard, click the **Data** tab.
3. Click the three dots (menu) in the top-right and select **Import JSON**.
4. Upload `users.json`. This will create the `users` node with default credentials:
   - **Admin**: `admin` / `admin`
   - **User**: `shaon` / `123`

---

## 🏃 Building & Running

1. **Clone the repository**:
   ```bash
   git clone https://github.com/YOUR_USERNAME/familypath.git
   cd familypath
   ```
2. **Install dependencies**:
   ```bash
   flutter pub get
   ```
3. **Run the app**:
   ```bash
   flutter run
   ```

*Note: Since the app uses background location services and WebViews, it is recommended to test on a physical Android device.*

---

## 🏢 Developed By

**Techgic**
*Powering safe and connected journeys.*

---
*Note: This app is optimized for elderly users with large tactile touch targets and high-readability typography.*
