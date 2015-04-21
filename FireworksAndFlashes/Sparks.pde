int SPARK_TTL = 70;
int SPARK_BURST_SPEED = 5;
int SPARK_SIZE = 8;
int EXPLOSION_SIZE = 8;

public class Spark extends Particle {
  int from;
  int to;
  int[] lerpVector; // gradient for sparks
  
  
  Spark(PVector p, PVector v, PVector a, int color1, int color2) {
    position.set(p);
    velocity.set(v);
    acceleration.set(a);
    rotation = PI/2 - (float) Math.atan2(velocity.y, velocity.x);
    ttl = SPARK_TTL;
    from = color1;
    to = color2;
    
    lerpVector = new int[(int)ttl];
    float stepSize = 1.0 / ttl;
    for(int i = 0; i < ttl; i++) {
      lerpVector[i] = lerpColor(from, to, stepSize * i);
    }
  } // end Spark::Spark()

  public void refactor(PVector p, PVector v, PVector a, int color1, int color2) {
    position.set(p);
    velocity.set(v);
    acceleration.set(a);
    rotation = PI/2 - (float) Math.atan2(velocity.y, velocity.x);
    ttl = SPARK_TTL;
    from = color1;
    to = color2;

    float stepSize = 1.0 / ttl;
    for(int i = 0; i < ttl; i++) {
      lerpVector[i] = lerpColor(from, to, stepSize * i);
    }
} // end Spark::Spark()
  
  public boolean update() {
    ttl--;
    if (ttl > 0) {
      move();
      return true;
    }
    return false;
  }
  public void draw() {
    // Draw the spark at p
    if (ttl > 0) {

      noStroke();
      fill(lerpVector[(int)ttl]);
      
      pushMatrix();
      translate(position.x, drawY(int(position.y)));
      rotate(rotation);

      //body
      rect(-SPARK_SIZE/2, 0, SPARK_SIZE, SPARK_SIZE + Math.abs(5 * velocity.mag()),SPARK_SIZE/2);
      
      // spawn tails after an interval proportional to speed
      if(ttl < SPARK_TTL - velocity.mag()){
        ellipse(0, SPARK_SIZE + Math.abs(5 * velocity.mag())+10, (int) ((3.0/4.0) * SPARK_SIZE), (int) ((3.0/4.0) * SPARK_SIZE));
      }
      if(ttl < SPARK_TTL - 2*velocity.mag()){
        ellipse(0, SPARK_SIZE + Math.abs(5 * velocity.mag())+20, (int) ((1.0/2.0) * SPARK_SIZE), (int) ((1.0/2.0) * SPARK_SIZE));
      }
      popMatrix();
    }
  }
}


public class SparkSpawner extends Spawner<Spark> {

  // 
  protected PVector position;
  protected PVector velocity;
  protected int sparkColor1, sparkColor2;
  
  
  // Methods
  SparkSpawner(PVector p, PVector v) {
    // creates sparks and adds to arraylist of sparks
    position = new PVector(0,0,0);
    position.set(p);
    
    velocity = new PVector(0,0,0);
    velocity.set(v);
    velocity.setMag(0.001); // input velocity is mainly for direction here, remove 

    // pick two colors to pass into children
    sparkColor1 = randomVibrant();
    sparkColor2 = randomVibrant();
    
    children = new ArrayList<Spark>();
    garbage = new ArrayList<Spark>();
    
    explode(); // on construct, explode
  } // end SparkSpawner()


  // separate spawn function for garbage handling
  public void spawn(PVector p, PVector v, PVector a, int color1, int color2) {
    Spark newSpark = recycle();
    if (newSpark == null) {
      newSpark = new Spark(p, v, a, color1, color2);
    } else {
      newSpark.refactor(p, v, a, color1, color2);
    }
    spawn(newSpark);
  }
  
  
  public void explode() {

    // angle between sparks
    float spark_angle = 2*3.14159/EXPLOSION_SIZE;

    // set initial angle relative to rocket velocity
    float rocket_angle = (float) Math.atan2(velocity.y, velocity.x);

    Spark newSpark;
    for (int i = 0; i < EXPLOSION_SIZE; i++) {
      PVector initV = PVector.fromAngle(i*spark_angle + spark_angle/2 + rocket_angle); // velocity in direction of angle
      initV.setMag(SPARK_BURST_SPEED);    // normalize to desired burst speed
      
      if (velocity != null) {
        initV.add(velocity); // add spawners velocity if it exists
      }

      PVector accel = new PVector(0,0,0);

      spawn(position, initV, accel, sparkColor1, sparkColor2);
    }
  } // end explode()
  
  public boolean update() {
    collectGarbage();
    return children.size() > 0;
  } // end SparkSpawner::update()
  
  public void draw() {
    for (Spark s : children) {
      s.draw();
    }
  } // end SparkSpawner::draw()
}
