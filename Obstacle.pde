class Obstacle {
  PVector position;
  float radiusOfEffect = 100;
  Obstacle( PVector pos) {
    position = pos;
  }

  void render() {
    stroke(255);
    fill(34, 100, 75);
    circle(position.x, position.y, radiusOfEffect * 1/4.0);
  }
  
}
