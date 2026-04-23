# HajjPath 🕋 — The Ultimate Pilgrim Tracking & Safety Companion

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)

**HajjPath** is a premium, high-performance Flutter application designed to ensure the safety, connectivity, and spiritual focus of pilgrims during the **Hajj and Umrah** journeys. Integrating **real-time GPS tracking**, **emergency SOS alerts**, and **interactive ritual guidance**, it serves as the ultimate digital companion for pilgrims navigating the holy cities of **Makkah and Madinah**.

---

## 📖 Table of Contents
- [🌟 Why HajjPath?](#-why-hajjpath)
- [📸 Screenshots](#-screenshots)
- [✨ Key Features](#-key-features)
- [🛠️ Tech Stack](#️-tech-stack)
- [🚀 Getting Started](#-getting-started)
- [🔥 Firebase Configuration](#-firebase-configuration)
- [🔧 Local Setup](#-local-setup)
- [👥 Adding Users](#-adding-users)
- [🏃 Building & Running](#-building--running)
- [📄 License](#-license)

---

## 🌟 Why HajjPath?
Navigating the holy sites of **Makkah**, **Madinah**, **Mina**, and **Arafat** can be overwhelming, especially in the massive crowds of the annual Hajj pilgrimage. **HajjPath** bridges the gap between technology and spirituality by providing:
- **Peace of Mind:** Real-time tracking allows families to monitor their loved ones' location across the holy sites.
- **Elderly-Friendly Design:** Optimized for senior pilgrims with large touch targets and high-contrast typography.
- **Offline Reliability:** Critical ritual guides and Duas accessible without a constant internet connection.

---

## 📸 Screenshots
*(Add your app screenshots here to boost engagement and SEO quality score)*

| Home Screen | Live Tracking | Ritual Guide |
| :---: | :---: | :---: |
| ![Screen 1](https://via.placeholder.com/200x400?text=Dashboard) | ![Screen 2](https://via.placeholder.com/200x400?text=Tracking) | ![Screen 3](https://via.placeholder.com/200x400?text=Guides) |

---

## ✨ Key Features

### 📍 Real-Time Location Dashboard
- **Live GPS Tracking:** Accurate location updates synced to Firebase.
- **Smart Geocoding:** Automatically translates coordinates into readable addresses (e.g., *"Near Gate 79, Masjid al-Haram"*).
- **Status Indicators:** Instantly see if a pilgrim is "Active" or has been stationary for too long.

### 🛡️ Safety & Emergency Tools
- **One-Tap SOS:** Dedicated emergency button that alerts all monitors instantly.
- **Safety Status:** High-visibility visual cues for "Safe" vs "At Risk" status.
- **Background Persistence:** Tracking continues even when the app is in the background.

### 🏮 Hajj Assistance Hub
- **Ritual Guide:** Step-by-step interactive walkthroughs for Hajj stages.
- **Daily Duas & Quran:** Integrated library of spiritual resources.
- **Embedded Resource Viewer:** View PDF guides and official websites within the app via a seamless WebView.

---

## 🛠️ Tech Stack
HajjPath is built using modern, industry-standard technologies:
- **Framework:** [Flutter](https://flutter.dev) (Dart)
- **Backend:** [Firebase Realtime Database](https://firebase.google.com/)
- **Auth:** Firebase Anonymous Authentication
- **Location Services:** Geolocator & Background Fetch
- **Maps & Geocoding:** Google Maps API / Geocoding Package
- **Typography:** Google Fonts (Plus Jakarta Sans, Lexend)

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Latest Stable Version)
- [Android Studio](https://developer.android.com/studio) / VS Code
- A [Firebase Project](https://console.firebase.google.com/)

---

## 🔥 Firebase Configuration

### 1. Project Setup
1. Create a project in the [Firebase Console](https://console.firebase.google.com/).
2. Enable **Realtime Database** (Suggested region: **Belgium** or **Singapore** for optimal latency in KSA).

### 2. Security Rules
Set these rules in the Realtime Database tab to ensure authenticated access:
```json
{
  "rules": {
    ".read": "auth != null",
    ".write": "auth != null"
  }
}
```

### 3. Enable Anonymous Auth
Enable **Anonymous** as a sign-in provider under the **Authentication > Sign-in method** tab.

---

## 🔧 Local Setup

### 1. Android Registration
1. Register your app in Firebase using your `applicationId` (located in `android/app/build.gradle`).
2. Download your `google-services.json` and place it in the `android/app/` folder.

### 2. Configure App Connection
1. Open [`lib/core/config/app_config.dart`](file:///d:/Side%20Hustle/familypath/lib/core/config/app_config.dart).
2. Replace the `firebaseDatabaseUrl` with your actual Firebase URL:
   ```dart
   static const String firebaseDatabaseUrl = 'https://your-project-id.firebaseio.com/';
   ```

---

## 👥 Adding Users
HajjPath uses a role-based system. To populate your database:
1. Go to the **Realtime Database** tab in Firebase.
2. Click the Three Dots (top right) > **Import JSON**.
3. Upload the [`seekdata/users.json`](file:///d:/Side%20Hustle/familypath/seekdata/users.json) provided in this repo.
   - **Admin Login:** `admin` / `admin`
   - **User Login:** `user1` / `123`

---

## 🏃 Building & Running

1. **Clone the Repo:**
   ```bash
   git clone https://github.com/YOUR_USERNAME/hajjpath.git
   cd hajjpath
   ```
2. **Install Deps:**
   ```bash
   flutter pub get
   ```
3. **Run on Device:**
   ```bash
   flutter run
   ```

---

## 📄 License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---
*Developed with ❤️ for the Ummah. Powering safe and connected journeys.*

