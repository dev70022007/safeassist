class DemoController {
  String movementStatus = 'Stopped';
  String safetyMessage = 'System ready';
  bool frontObstacle = false;

  bool get isMoving => movementStatus != 'Stopped';

  int get frontDistance => frontObstacle ? 22 : 120;

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
    frontObstacle = value;

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
