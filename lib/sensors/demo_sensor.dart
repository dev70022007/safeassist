class DemoSensor {
  bool frontObstacle = false;

  int get frontDistance => frontObstacle ? 22 : 120;

  void setFrontObstacle(bool value) {
    frontObstacle = value;
  }
}
