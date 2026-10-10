import '../sensors/demo_sensor.dart';

class DemoController {
  final DemoSensor sensor = DemoSensor();

  String movementStatus = 'Stopped';
  String safetyMessage = 'System ready';

  bool get isMoving => movementStatus != 'Stopped';
  bool get frontObstacle => sensor.frontObstacle;
  int get frontDistance => sensor.frontDistance;

  void stopMovement() {
    movementStatus = 'Stopped';
    safetyMessage = 'Movement stopped';
  }

  void issueCommand(String command) {
    if (command == 'STOP') {
      stopMovement();
      return;
    }

    if (command == 'Forward' && frontDistance <= 35) {
      movementStatus = 'Stopped';
      safetyMessage = 'Forward movement blocked';
      return;
    }

    movementStatus = command;
    safetyMessage = 'Demo command: $command';
  }

  void toggleObstacle(bool value) {
    sensor.setFrontObstacle(value);

    if (value && movementStatus == 'Forward') {
      movementStatus = 'Stopped';
      safetyMessage = 'Obstacle detected — movement stopped';
    } else {
      safetyMessage = value
          ? 'Front obstacle simulated'
          : 'Front path marked clear';
    }
  }
}
