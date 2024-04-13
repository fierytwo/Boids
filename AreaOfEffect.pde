class areaOfEffect {
  PVector position;
  float radiusOfEffect = 100;
  boolean attract;

  areaOfEffect(PVector pos, boolean state) {
    position = pos;
    attract = state;
  }
  void render() {
    noFill();
    if (attract) {
      stroke(103, 82, 83);
    } else {
      stroke(0, 82, 83);
    }
    circle(position.x, position.y, radiusOfEffect * 2);
  }
  void update() {
   position = fixedMouse; 
  }
}
