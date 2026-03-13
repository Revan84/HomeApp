# HomeApp

HomeApp is a **Flutter mobile application** designed to monitor and control smart home devices.

The application communicates with the HomeApp backend API written in Go.

---

## Features

* Manage connected devices
* Monitor power consumption
* View historical device metrics
* Control smart plugs
* Organize devices by home and room
* Automation rules (planned)

---

## Tech Stack

* **Flutter**
* **Dart**
* **REST API**
* **Material UI**

Backend API:

https://github.com/Revan84/HomeApp-backend

---

## Screens

Planned interface sections:

* Home dashboard
* Rooms and devices
* Equipment details
* Statistics
* Automations
* User profile

---

## Project Structure

```
lib/
 ├─ core/
 │   ├─ theme
 │   ├─ widgets
 │   └─ utils
 │
 ├─ features/
 │   ├─ home
 │   ├─ equipments
 │   ├─ stats
 │   ├─ automation
 │   └─ profile
 │
 └─ main.dart
```

---

## Getting Started

### Requirements

* Flutter ≥ 3.x
* Dart ≥ 3.x

---

### Install dependencies

```
flutter pub get
```

---

### Run the application

```
flutter run
```

---

## Backend

This app communicates with the HomeApp backend:

https://github.com/Revan84/HomeApp-backend

---

## Project Status

🚧 **Work in progress**

The application is currently under development.

The goal is to build a complete home automation platform capable of managing multiple IoT devices.

---

## Author

Quentin Ellt

