# SafeAssist

SafeAssist is a Flutter companion app for an ESP32-based smart wheelchair project. It is being developed as part of a college multidisciplinary project (MDP).

The app is intended to provide a user interface for movement commands, wheelchair status, and obstacle-related alerts, with future Bluetooth communication with an ESP32 controller.

## Planned Features

- Dashboard for wheelchair status and alerts
- Manual movement controls
- Voice-based movement commands
- Obstacle detection and safety-status display
- Demo Mode for testing without hardware
- Future Bluetooth communication with an ESP32 controller
- Clear indication of connection status and controller responses

## Development Status

SafeAssist is under active development.

The initial version will use Demo Mode so that the user interface and command-handling flow can be developed before the hardware is available.

Demo Mode uses simulated movement states and sensor readings. Simulated values must not be interpreted as real sensor measurements or evidence of hardware safety.

Bluetooth communication and hardware-dependent functionality will be implemented and tested when the ESP32 controller and required sensors are available.

## Technology Stack

- Flutter
- Dart
- ESP32 for planned hardware integration
- Bluetooth for planned app-to-controller communication

## Project Structure

The application will be organized into separate screens, models, widgets, and controller services as development progresses. Demo and hardware communication will be kept separate to make testing and future integration easier.

## Getting Started

### Prerequisites

- Flutter SDK
- Dart SDK included with Flutter
- Android Studio or another configured Android development environment
- An Android emulator or compatible Android device

### Run the App

1. Clone the repository.
2. Open a terminal in the project directory.
3. Fetch the Flutter dependencies:

   ```bash
   flutter pub get
   ```

4. Check available devices:

   ```bash
   flutter devices
   ```

5. Run the application:

   ```bash
   flutter run
   ```

## Safety Notice

SafeAssist is a student prototype and is not a certified wheelchair safety system. Do not use the prototype to transport a person.

The mobile application must not be the sole safety mechanism. Actual movement limits, obstacle handling, emergency stopping, and fault responses must be implemented and tested at the controller and hardware level before any real-world use.

## Contributions

This project is being developed as part of a college MDP. Suggestions and contributions are welcome.

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.
