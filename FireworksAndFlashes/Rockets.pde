
// how long the rocket will be alive
int ROCKET_TTL = 60;

// speed is proprtional to height and the time you want the rocket to be alive, play with numbers to get range you want (air resistance makes calculation difficult)
int MAX_ROCKET_SPEED = (int) (1.8 * (SCREEN_HEIGHT) / ROCKET_TTL); 
int MIN_ROCKET_SPEED = (int) (1.3 * (SCREEN_HEIGHT) / ROCKET_TTL); 

// time between launches
int ROCKET_SPAWN_SPACE = 50;


int ROCKET_SIZE = 6;
int RocketColor = #DDDDDD;

public class Rocket extends Particle {
  protected SparkSpawner SS;
  
    
  Rocket() {
    position = new PVector(random(0,SCREEN_WIDTH), random(0,SCREEN_HEIGHT), 0);
    velocity = new PVector(0,0,0);
    acceleration = new PVector(0,0,0);
    rotation = PI/2 - (float) Math.atan2(velocity.y, velocity.x);
    
    SS = null;
   
    ttl = ROCKET_TTL;
  } // end Rocket()  
  
  Rocket(PVector p, PVector v, PVector a) {
    
    position = new PVector(0,0,0);
    velocity = new PVector(0,0,0);
    acceleration = new PVector(0,0,0);
    
    position.set(p);
    velocity.set(v);
    acceleration.set(a);
    rotation = PI/2 - (float) Math.atan2(velocity.y, velocity.x);
    
    SS = null;
    
    ttl = ROCKET_TTL;
  } // end Rocket()  

  public void refactor(PVector p, PVector v, PVector a) {
    position.set(p);
    velocity.set(v);
    acceleration.set(a);
    
    SS = null;
    
    ttl = ROCKET_TTL;
  } // end Rocket()
  
  public boolean update() {

    ttl--;

    // explode at apex or at timeout
    if (velocity.y <= 0 || ttl <= 0) {

      // initializing spark spawner starts explosion
      if (SS == null) {
        SS = new SparkSpawner(position, velocity);
      }
      return SS.update();
    }

    else {
      this.move();
      return true;
    }
  } // end Rocker::update()
  
  public void draw() {

    if (ttl >= 0) {

      noStroke();
      fill(RocketColor);

      pushMatrix();

      // XY position (translate Y)
      translate(position.x, drawY(int(position.y)));

      //rotate
      rotate(rotation);

      //body
      rect(-ROCKET_SIZE/2, 0, ROCKET_SIZE, ROCKET_SIZE + Math.abs(4 * velocity.mag()),ROCKET_SIZE/2);

      //tail dot
      // distance from body determined by speed+magic numbers for spacing
      ellipse(0, ROCKET_SIZE + Math.abs(4 * velocity.mag()) + 5, ROCKET_SIZE, ROCKET_SIZE);
      ellipse(0, ROCKET_SIZE + Math.abs(4 * velocity.mag()) + 15, ROCKET_SIZE/2, ROCKET_SIZE/2);

      popMatrix();
    }

    //if SS has been initialized, draw it
    if (SS != null) {
      SS.draw();
    }
  } // end Rocker::draw() 
}

public class RocketSpawner extends Spawner<Rocket> {
  
  public RocketSpawner() {
    PMin = new PVector(SCREEN_WIDTH / 3, 0, 0);
    VMin = new PVector(0, MIN_ROCKET_SPEED, 0);
    AMin = new PVector(0, 0, 0);
      
    PMax = new PVector(2 * SCREEN_WIDTH / 3, 0, 0);
    VMax = new PVector(0, MAX_ROCKET_SPEED, 0);
    AMax = new PVector(0, 0, 0);
    
    children = new ArrayList<Rocket>();
    garbage = new ArrayList<Rocket>();
    
    tts = 0;
  }
  // Methods
  public void update() {
    // if time to spawn new one, spawn new 
    tts--;
    if (tts <= 0) {
      tts = ROCKET_SPAWN_SPACE;

      // rockets spawn from same loc
      PVector p = randPosition();

      // rocket shoots upward 
      PVector v = randVelocity();

      // randomize angle
      PVector vr = PVector.random2D();
      vr.setMag(1);
      v.add(vr);

      PVector a = randAcceleration();
      
      Rocket newRocket = recycle();
      if (newRocket == null) {
        newRocket = new Rocket(p,v,a);
      } else {
        newRocket.refactor(p,v,a);
      }
      spawn(newRocket);

    }
    collectGarbage();
  } // end RocketSpawner::update()
 
  
  public void  draw() {
    for (Rocket r : children) {
      r.draw();
    }
  } // end RocketSpawner::draw() 
}
