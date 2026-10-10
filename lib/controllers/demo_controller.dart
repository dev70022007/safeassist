import '../sensors/demo_sensor.dart';

class DemoController {
  final DemoSensor sensor = DemoSensor();

  String movementStatus = 'Stopped';
  String safetyMessage = 'System ready';

  bool get isMoving => movementStatus != 'Stopped';
  bool get frontObstacle => sensor.frontObstacle;
  bool get rearObstacle => sensor.rearObstacle;
  bool get downwardHazard => sensor.downwardHazard;

  int get frontDistance => sensor.frontDistance;
  int get rearDistance => sensor.rearDistance;
  int get downwardDistance => sensor.downwardDistance;

  void stopMovement() {
    movementStatus = 'Stopped';
    safetyMessage = 'Movement stopped';
  }

  bool _isMovementBlocked(String command) {
    if (command == 'Forward' && frontDistance <= 35) {
      safetyMessage = 'Forward movement blocked';
      return true;
    }

    if (command == 'Forward' && downwardDistance <= 10) {
      safetyMessage = 'Forward movement blocked: downward hazard';
      return true;
    }

    if ((command == 'Backward' || command == 'Reverse') && rearDistance <= 35) {
      safetyMessage = 'Backward movement blocked: rear obstacle';
      return true;
    }

    return false;
  }

  void issueCommand(String command) {
    if (command == 'STOP') {
      stopMovement();
      return;
    }

    if (_isMovementBlocked(command)) {
      movementStatus = 'Stopped';
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

  void toggleRearObstacle(bool value) {
    sensor.setRearObstacle(value);

    if (value &&
        (movementStatus == 'Backward' || movementStatus == 'Reverse')) {
      movementStatus = 'Stopped';
      safetyMessage = 'Rear obstacle detected — backward movement stopped';
    } else {
      safetyMessage = value
          ? 'Rear obstacle simulated'
          : 'Rear path marked clear';
    }
  }

  void toggleDownwardHazard(bool value) {
    sensor.setDownwardHazard(value);

    if (value && movementStatus == 'Forward') {
      movementStatus = 'Stopped';
      safetyMessage = 'Downward hazard detected — forward movement stopped';
    } else {
      safetyMessage = value
          ? 'Downward hazard simulated'
          : 'Downward path marked clear';
    }
  }
}
