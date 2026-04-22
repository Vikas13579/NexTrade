# 🚀 NexTrade

NexTrade is a Flutter-based stock trading simulation app that mimics real-world trading behavior using local storage (Hive).

This project focuses on **data-driven architecture**, not just UI — including wallet-based trading, portfolio calculation, and persistent state.

---

## 📱 Features

### 🔐 Authentication

* OTP-based login (local simulation)
* Persistent login using Hive

### 👤 Profile

* Edit profile (name, email, phone)
* Profile image upload (camera/gallery)
* Data stored locally using Hive

### 💰 Wallet System

* Add funds to wallet
* Balance persistence
* Real-time updates

### 📊 Portfolio

* Dynamic portfolio value
* Real-time PnL calculation
* Invested amount tracking
* Auto UI updates using Hive listeners

### 📈 Trading (Simulation)

* Buy stocks using wallet balance
* Average price calculation
* Holdings stored in Hive
* Portfolio updates instantly

### 💾 Local Storage

* Fully offline support
* Hive used for:

  * Profile
  * Wallet
  * Holdings

---

## 🛠️ Tech Stack

* Flutter
* Hive (Local Database)
* ValueListenableBuilder
* Image Picker

---

## 🧠 Architecture

```
Hive (Storage)
   ↓
Models (Profile, Wallet, Holdings)
   ↓
Business Logic (Buy, Portfolio Calculation)
   ↓
UI (Reactive via ValueListenableBuilder)
```

---

## 📂 Project Structure

```
lib/
├── data/
│   └── datasources/
│       └── hive_service.dart
│
├── models/
│   ├── profile_model.dart
│   ├── wallet_model.dart
│   ├── holding_model.dart
│
├── screens/
│   ├── home_screen.dart
│   ├── edit_profile_screen.dart
│   ├── otp_screen.dart
│
├── widgets/
```

---

## 🚀 Getting Started

### Install dependencies

```
flutter pub get
```

### Run app

```
flutter run
```

---

## ⚠️ Notes

* Stock data is currently mocked
* Portfolio, wallet, and trading logic are real and persistent
* No backend/API integration yet

---

## 🔮 Future Improvements

* Sell stock functionality
* Transaction history
* Real stock API integration
* Wallet withdrawal system
* Backend authentication

---

## 👨‍💻 Author

Vikas Shetty
Flutter Developer
