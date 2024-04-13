ArrayList<areaOfEffect> aoe = new ArrayList<areaOfEffect>();
ArrayList<Obstacle> obstacles = new ArrayList<Obstacle>();
PVector fixedMouse;
float alignmentFactor = 0.45;
float cohesionFactor = 0.34;
float seperationFactor = 0.3;
float obstacleStrengthFactor = 0.5;
float areaOfEffectFactor = 0.45;
int totalBoidNumber = 300;
int numberOfFlocks = 7;
float globalMaxSpeed = 5;
float globalMinSpeed = 2;
float globalMaxForce = 1.5;
boolean displayHelp = false;
int padding = 25;
Boid[] Boids = new Boid[totalBoidNumber];

void setup() {
  fullScreen();
  colorMode(HSB, 360, 100, 100, 100);
  randomBoids();
}
void draw() {
  noStroke();
  background(0);
  translate(width / 2, height / 2);
  fixedMouse = new PVector(mouseX - width / 2, mouseY - height / 2);
  for (int i =0; i < Boids.length; i++) {
    Boid current = Boids[i];
    current.render();
    current.update();
  }
  for (int o = 0; o < obstacles.size(); o++) {
    Obstacle obstacle = obstacles.get(o);
    obstacle.render();
  }
  if (!mousePressed) {
    aoe.clear();
  }
  for (int a = 0; a < aoe.size(); a++) {
    aoe.get(a).render();
    aoe.get(a).update();
  }

  fill(255);
  textSize(15);
  if (displayHelp) {
    text("Z/X to +/- alignment factor", - width/2 + padding, - height/2 + padding);
    text( Float.toString(alignmentFactor), width/2 - (padding*2), - height/2 + padding);
    text("C/V to +/- cohesion factor", - width/2 + padding, - height/2 + padding*2);
    text( Float.toString(cohesionFactor), width/2 - (padding*2), - height/2 + padding*2);
    text("B/N to +/- seperation factor", - width/2 + padding, - height/2 + padding*3);
    text( Float.toString(seperationFactor), width/2 - (padding*2), - height/2 + padding*3);
    text("A/S to +/- number of flocks (will reset)", - width/2 + padding, - height/2 + padding*4);
    text( Float.toString(numberOfFlocks), width/2 - (padding*2), - height/2 + padding*4);

    text("R to reset all boids", - width/2 + padding, - height/2 + padding*6);
    
    text("LMB to create attract AOE", - width/2 + padding, height/2 - padding*4);
    text("RMB to create repel AOE", - width/2 + padding, height/2 - padding*3);
    text("CMB to create obstacle", - width/2 + padding, height/2 - padding*2);
    text("{space} to clear obstacle list", - width/2 + padding, height/2 - padding);
  }
}

void mousePressed() {
  switch (mouseButton) {
  case CENTER:  //middle
    Obstacle o = new Obstacle(fixedMouse);
    obstacles.add(o);
    break;

  case LEFT: //left
    aoe.add(new areaOfEffect(fixedMouse, true));
    break;

  case RIGHT:  //right
    aoe.add(new areaOfEffect(fixedMouse, false));
    break;
  }
}

void keyPressed() {
  switch (key) {
  case ' ':
    obstacles.clear();
    break;

  case '/':
    displayHelp = !displayHelp;
    break;
  case 'z':
    alignmentFactor += 0.02;
    break;
  case 'x':
    alignmentFactor -= 0.02;
    break;
  case 'c':
    cohesionFactor += 0.02;
    break;
  case 'v':
    cohesionFactor -= 0.02;
    break;
  case 'b':
    seperationFactor += 0.02;
    break;
  case 'n':
    seperationFactor -= 0.02;
    break;

  case 's':
    numberOfFlocks -= 1;
    if ( numberOfFlocks <=0) {
      numberOfFlocks = 1;
    }
    resetBoidArray();
    break;
  case 'a':
    numberOfFlocks += 1;
    resetBoidArray();
    break;
  case 'r':
    resetBoidArray();
    break;
  }
}

void resetBoidArray() {
  for (int i = 0; i < Boids.length; i++) {
    Boids[i] = null;
  }
  randomBoids();
}

void randomBoids() {
  for (int b = 0; b < Boids.length; b++) {
    Boids[b] = new Boid( new PVector(random(-width / 2, width / 2), random(-height / 2, height / 2)), new PVector(random(-10, 10), random(-10, 10)));
    Boids[b].flockID = floor(random(0, numberOfFlocks));
  }
}

void lineOfBirds() {
  float spacing = height / Boids.length;
  for (int b = 0; b < Boids.length; b++) {
    PVector pos = new PVector(0.0, (-height / 2) + b * spacing);
    Boids[b] = new Boid(pos, new PVector(10, 0));
  }
}

float dist(Boid i, Boid j) {
  return dist(i.position.x, i.position.y, j.position.x, j.position.y);
}
