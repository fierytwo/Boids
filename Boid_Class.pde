class Boid {
  PVector position;
  PVector velocity = new PVector(0, 0);
  PVector acceleration = new PVector(0, 0);
  float size = 5;
  float perceptionRadius = 40;
  float maxSpeed = globalMaxSpeed;
  float minSpeed = globalMinSpeed;
  float maxForce = globalMaxForce;
  int flockID;

  Boid( float x, float y) {
    position = new PVector(x, y);
  }

  Boid(PVector position_, PVector acceleration_) {
    position = position_;
    acceleration = acceleration_;
  }

  void render() {
    float hue = map(flockID, 0, numberOfFlocks, 0, 360);
    fill(hue, 95, 100, 95);
    //circle(position.x, position.y, size);
    push();
    float theta = this.velocity.heading() + radians(90);
    translate(this.position.x, this.position.y);
    rotate(theta);
    beginShape();
    vertex(0, -this.size);
    vertex(-this.size / 2, this.size);
    vertex(this.size / 2, this.size);
    endShape(CLOSE);
    pop();
  }


  void update() {
    position = position.add(velocity);
    velocity.add(acceleration);
    acceleration.mult(0);
    this.containSpeed(minSpeed, maxSpeed);
    this.applyBoidForces(Boids);
    this.wrapAround();
    //this.bounce();
    //this.debug();
  }

  void applyForce(PVector force) {
    this.acceleration.add(force);
  }

  void wrapAround() {
    if ( position.x >= width/2) {
      position.x = -width / 2;
    }
    if ( position.x < -width / 2) {
      position.x = width / 2;
    }
    if ( position.y >= height/2) {
      position.y = -height / 2;
    }
    if (position.y < -height / 2) {
      position.y = height/ 2;
    }
  }
  
  void bounce() {
    if ( position.x >= width/2) {
      this.velocity.mult(-1);
    }
    if ( position.x < -width / 2) {
      this.velocity.mult(-1);
    }
    if ( position.y >= height/2) {
      this.velocity.mult(-1);
    }
    if (position.y < -height / 2) {
      this.velocity.mult(-1);
    }
    
  }

  void applyBoidForces( Boid[] flock) {
    PVector boidForce = new PVector();
    PVector alignmentForce = this.alignment(flock);
    PVector cohesionForce = this.cohesion(flock);
    PVector seperationForce = this.seperation(flock);
    PVector ObstacleAvoidanceForce = this.avoidObstacles();
    PVector areaOfEffectForce = this.checkAreaOfEffects();

    boidForce.add(alignmentForce.mult(alignmentFactor));
    boidForce.add(cohesionForce.mult(cohesionFactor));
    boidForce.add(seperationForce.mult(seperationFactor));
    boidForce.add(ObstacleAvoidanceForce.mult(obstacleStrengthFactor));
    boidForce.add(areaOfEffectForce.mult(areaOfEffectFactor));

    this.acceleration.add(boidForce);
  }

  PVector avoidObstacles() {
    PVector steering = new PVector();
    int total = 0;
    for (int i = 0; i < obstacles.size(); i++) {
      Obstacle o = obstacles.get(i);
      float d = dist(this.position.x, this.position.y, o.position.x, o.position.y);
        if (d < o.radiusOfEffect) {
        PVector diff = PVector.sub(this.position, o.position);
        diff.div(d * d);
        steering.add(diff);
        total++;
      }
    }
    if (total > 0) {
      steering.div(total);
      steering.setMag(this.maxSpeed);
      steering.sub(this.velocity);
      steering.limit(this.maxForce);
    }
    return steering;
  }
  
  PVector checkAreaOfEffects() {
    PVector steering = new PVector();
    int total = 0;
    for (int i = 0 ; i< aoe.size(); i++) {
      areaOfEffect a = aoe.get(i);
      float d = dist(this.position.x, this.position.y, a.position.x, a.position.y);
        if (d < a.radiusOfEffect) {
        PVector diff = PVector.sub(this.position, a.position);
        if (a.attract) {
         diff.mult(-1); 
        }
        diff.div(d * d);
        steering.add(diff);
        total++;
      }
    }
    if (total > 0) {
      steering.div(total);
      steering.setMag(this.maxSpeed);
      steering.sub(this.velocity);
      steering.limit(this.maxForce);
    }
     return steering; 
    }



  PVector seperation(Boid[] boids) {
    // this - other
    PVector steering = new PVector();
    int total = 0;
    for (Boid other : boids) {
      float d = dist(this.position.x, this.position.y, other.position.x, other.position.y);
      if (isVisible(other)) {
        PVector diff = PVector.sub(this.position, other.position);
        diff.div(d * d);
        steering.add(diff);
        total++;
      }
    }
    if (total > 0) {
      steering.div(total);
      steering.setMag(this.maxSpeed);
      steering.sub(this.velocity);
      steering.limit(this.maxForce);
    }
    return steering;
  }

  PVector alignment(Boid[] boids) {
    PVector steering = new PVector();
    int total = 0;
    for (Boid other : boids) {
      if (isVisible(other) && this.flockID == other.flockID) {
        steering.add(other.velocity);
        total++;
      }
    }
    if (total > 0) {
      steering.div(total);
      steering.setMag(this.maxSpeed);
      steering.sub(this.velocity);
      steering.limit(this.maxForce);
    }
    return steering;
  }

  PVector cohesion(Boid[] boids) {
    PVector steering = new PVector();
    int total = 0;
    for (Boid other : boids) {
      if (isVisible(other) && this.flockID == other.flockID) {
        steering.add(other.position);
        total++;
      }
    }
    if (total > 0) {
      steering.div(total);
      steering.sub(this.position);
      steering.setMag(this.maxSpeed);
      steering.sub(this.velocity);
      steering.limit(this.maxForce);
    }
    return steering;
  }

  boolean isVisible(Boid other) {
    float d = dist(this.position.x, this.position.y, other.position.x, other.position.y);
    boolean visible = (other != this && d < perceptionRadius);
    visible = visible && (PVector.angleBetween(this.velocity, PVector.sub(this.position, other.position)) < radians(135));
    return visible;
  }

  boolean isVisible(Obstacle o) {
    float d = dist(this.position.x, this.position.y, o.position.x, o.position.y);
    boolean visible = (d < perceptionRadius);
    visible = visible && (PVector.angleBetween(this.velocity, PVector.sub(this.position, o.position)) < radians(135));

    return visible;
  }



  void containSpeed(float min, float max) {
    if (this.velocity.mag() < min) {
      this.velocity.setMag(min);
    }

    if (this.velocity.mag() > max) {
      this.velocity.setMag(max);
    }
  }

  void debug() {
    stroke(255, 50);
    line(position.x, position.y, position.x + velocity.x, position.y + velocity.y);
    noFill();
    circle(position.x, position.y, perceptionRadius);
  }
}
