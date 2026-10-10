import 'package:flutter_test/flutter_test.dart';
import 'package:safeassist/controllers/demo_controller.dart';

void main() {
  late DemoController controller;

  setUp(() {
    controller = DemoController();
  });

  test('initial state is stopped', () {
    expect(controller.movementStatus, 'Stopped');
    expect(controller.safetyMessage, 'System ready');
    expect(controller.frontObstacle, false);
    expect(controller.isMoving, false);
  });

  test('forward movement works when path is clear', () {
    controller.issueCommand('Forward');

    expect(controller.movementStatus, 'Forward');
    expect(controller.isMoving, true);
  });

  test('forward movement is blocked when obstacle is present', () {
    controller.toggleObstacle(true);
    controller.issueCommand('Forward');

    expect(controller.movementStatus, 'Stopped');
    expect(controller.safetyMessage, 'Forward movement blocked');
  });

  test('movement stops when obstacle appears while moving forward', () {
    controller.issueCommand('Forward');
    controller.toggleObstacle(true);

    expect(controller.movementStatus, 'Stopped');
    expect(controller.safetyMessage, 'Obstacle detected — movement stopped');
  });

  test('stop command stops movement', () {
    controller.issueCommand('Forward');
    controller.issueCommand('STOP');

    expect(controller.movementStatus, 'Stopped');
    expect(controller.isMoving, false);
  });
}
