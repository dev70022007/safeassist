class DemoSensor {
  bool frontObstacle = false;
  bool rearObstacle = false;
  bool downwardHazard = false;

  int get frontDistance => frontObstacle ? 22 : 120;
  int get rearDistance => rearObstacle ? 20 : 100;
  int get downwardDistance => downwardHazard ? 5 : 50;

  void setFrontObstacle(bool value) {
    frontObstacle = value;
  }

  void setRearObstacle(bool value) {
    rearObstacle = value;
  }

  void setDownwardHazard(bool value) {
    downwardHazard = value;
  }
}
