PVector GRAVITY = new PVector(0, -0.010, 0); // Acceleration due to Gravity
float AIR_SCALAR = 0; // Acceleration due to Air

int SCREEN_WIDTH = 500;
int SCREEN_HEIGHT = 800;

int ROCKET_SPAWN_SPACE = 50;
int ROCKET_TTL = 30;
int ROCKET_SPEED = (2*SCREEN_HEIGHT/3) / ROCKET_TTL;
int ROCKET_SIZE = 6;
color RocketColor = #DDDDDD;

int SPARK_TTL = 30;
int SPARK_BURST_SPEED = 4;
int SPARK_SIZE = 10;
int EXPLOSION_SIZE = 8;
color[] SparkPalette = {#B1EB00, #53BBF4, #FF85CB, #FF432E, #FFAC00, #982395, #0087CB, #ED1C24, #9C0F5F, #02D0AC};

int MAX_FLASH_SIZE = max(SCREEN_HEIGHT, SCREEN_WIDTH);
int FLASH_DIFFUSION = 25;
int FLASH_GROWTH = 25;

color BGCOL = #333333;

color randomVibrant() {
  return SparkPalette[int(random(0,SparkPalette.length))];
}


// perform vector math on xyz movement, only draw in the xy. Position declared as a vector, but drawn as xy coordinates

// calculate xy as normal xy plane where 0 is the ground, then transform y at draw level to account for processings interpreteation of line scanning
// (y' = -1*(y-SCREEN_HEIGHT+1))
int drawY(int y) {
  return -1 * (1 + y - SCREEN_HEIGHT);
}

//-------------------------------PARTICLE SYSTEM


public class Particle {

  protected PVector position;
  protected PVector velocity;
  protected PVector acceleration;
  protected float ttl; // time to live in frames
  protected float rotation;
  
  // Constructors
  Particle() {
    position = new PVector(0,0,0);
    velocity = new PVector(0,0,0);
    acceleration = new PVector(0,0,0);

    // rotation set to the angle of velocity
    rotation = PI/2 - (float) Math.atan2(velocity.y, velocity.x);

    ttl = 100;
  } // end Rocket()
  
  // takes input position(p) velocity(v) and acceleration(a)
  Particle(PVector p, PVector v, PVector a) {
    position.set(p);
    velocity.set(v);
    acceleration.set(a);

    // rotation set to the angle of velocity
    rotation = PI/2 - (float) Math.atan2(velocity.y, velocity.x);

    ttl = 100;
  } // end Rocket()
  

  // Refactor
  // equivilant to the constructor, resets an object taken from garbage
  void refactor(PVector p, PVector v, PVector a) {
    position.set(p);
    velocity.set(v);
    acceleration.set(a);
    rotation = PI/2 - (float) Math.atan2(velocity.y, velocity.x);
    ttl = 100;
  } // end Rocket()
  
  // physics math
  public void move() {
    // A' = A_g + V*R_air + A
    PVector tempAcceleration = PVector.mult(velocity, AIR_SCALAR);
    tempAcceleration.add(GRAVITY);
    tempAcceleration.add(acceleration); // base acceleration + environment

    // V' = V + A
    velocity.add(tempAcceleration);

    // update rotation
    rotation = PI/2 - (float) Math.atan2(velocity.y, velocity.x);

    // P' = P + V
    position.add(velocity);

  } // end Particle::move()
  
  public boolean update() {
    move();
    return true;
  }

}



public class Spawner<T extends Particle> {
  // Fields
  protected PVector PMax; // Max Position
  protected PVector PMin; // Min Position
  protected PVector VMax; // Max Velocity
  protected PVector VMin; // Min Velocity
  protected PVector AMax; // Max Acceleration
  protected PVector AMin; // Min Acceleration
  
  protected ArrayList<T> children;  // children spawned by Spawner
  protected ArrayList<T> garbage;  // linked to global Garbage type
  
  protected int tts;

  public Spawner() {
      PMin = new PVector(0,0,0);
      VMin = new PVector(-50, -50, -50);
      AMin = new PVector(-10, -10, -10);
        
      PMax = new PVector(SCREEN_WIDTH, SCREEN_HEIGHT, SCREEN_HEIGHT);
      VMax = new PVector(50, 50, 50);
      AMax = new PVector(10, 10, 10);
      
      children = new ArrayList<T>();
      garbage = new ArrayList<T>();
    }

    // rand functions take the Min/Max parameters and randomize vectors
    public PVector randPosition() {
      return new PVector(random(PMin.x, PMax.x), random(PMin.y, PMax.y), random(PMin.z, PMax.z));
    }
    public PVector randVelocity() {
      return new PVector(random(VMin.x, VMax.x), random(VMin.y, VMax.y), random(VMin.z, VMax.z));
    }
    public PVector randAcceleration() {
      return new PVector(random(AMin.x, AMax.x), random(AMin.y, AMax.y), random(AMin.z, AMax.z));
    }
    
    // Updates children and collects garbage particles
    public void collectGarbage() {
      for (T child : children) {
        if (!child.update()) {
          garbage.add(child); // if update returns false, particle is dead so add to garbage
        }
      }
      for (T g : garbage) {
          children.remove(g);
      }
    }

    // pops item from garbage if available, returns null otherwise
    public T recycle() {
      if(!garbage.isEmpty()) {
        return garbage.remove(0);
      }
      return null;
    }
    
    public void spawn(T child) {
      children.add(child);
    } //end SPawner::spawn()
    
}

//-------------------------------END PARTICLE SYSTEM


public class SparkSpawner extends Spawner<Spark> {

  // 
  protected PVector position;
  protected PVector velocity;
  protected color sparkColor1, sparkColor2;
  
  
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
  public void spawn(PVector p, PVector v, PVector a, color color1, color color2) {
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


public class Spark extends Particle {
  color from;
  color to;
  color[] lerpVector; // gradient for sparks
  
  
  Spark(PVector p, PVector v, PVector a, color color1, color color2) {
    position.set(p);
    velocity.set(v);
    acceleration.set(a);
    rotation = PI/2 - (float) Math.atan2(velocity.y, velocity.x);
    ttl = SPARK_TTL;
    from = color1;
    to = color2;
    
    lerpVector = new color[(int)ttl];
    float stepSize = 1.0 / ttl;
    for(int i = 0; i < ttl; i++) {
      lerpVector[i] = lerpColor(from, to, stepSize * i);
    }
  } // end Spark::Spark()

  public void refactor(PVector p, PVector v, PVector a, color color1, color color2) {
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
      ellipse(0, SPARK_SIZE + Math.abs(2 * velocity.y), SPARK_SIZE, SPARK_SIZE);

      // spawn tails after a defined interval
      if(ttl < SPARK_TTL - SPARK_BURST_SPEED){
        ellipse(0, SPARK_SIZE + Math.abs(2 * velocity.y)+3*SPARK_BURST_SPEED, 2*SPARK_SIZE/3, 2*SPARK_SIZE/3);
      }
      if(ttl < SPARK_TTL - 2*SPARK_BURST_SPEED){
        ellipse(0, SPARK_SIZE + Math.abs(2 * velocity.y)+5*SPARK_BURST_SPEED, SPARK_SIZE/3, SPARK_SIZE/3);
      }
      popMatrix();
    }
  }
}

public class FlashSpawner extends Spawner<Flash>{
  double TimeToFlash;
  
  public FlashSpawner(){
    PMin = new PVector(0,0,0);
    PMax = new PVector(SCREEN_WIDTH,SCREEN_HEIGHT/2,0);

    garbage = new ArrayList<Flash>();
    TimeToFlash = random(50,80);
    children = new ArrayList<Flash>();
  }  
  
  // choose new flash instance based on garbage
  public void spawn() {
    Flash newFlash = recycle();
    if (newFlash == null) {
      newFlash = new Flash(randPosition());
    } else {
      newFlash.refactor(randPosition());
    } 
    spawn(newFlash);
  }

  void update(){
    TimeToFlash--;

    if(TimeToFlash < 0){
      TimeToFlash = random(50,80);
      spawn();
    }
    
    collectGarbage();
  }

  void draw(){
    for(Flash f : children){
      f.draw(); 
    }
  }
  
}

public class Flash extends Particle{
  int size;
  int alpha;
 
  Flash(PVector p) {
    position.set(p);
    size = 0;
    alpha = 255;
  } // end Flash()

  public void refactor(PVector p) {
    position.set(p);
    size = 0;
    alpha = 255;
  } // end Flash::refactor()
  
  public boolean update(){

      size += FLASH_GROWTH;
      alpha -= FLASH_DIFFUSION;

      if(size >= MAX_FLASH_SIZE){
         return false;
      }
      return true;
  }
  
  public void draw(){
    //blendMode(ADD);
    fill(250, alpha);
    ellipse(position.x, drawY(int(position.y)), size, size);
  }
}

public class RocketSpawner extends Spawner<Rocket> {
  
  public RocketSpawner() {
    PMin = new PVector(250, 100, 0);
    VMin = new PVector(0, 0, 0);
    AMin = new PVector(0, 0, 0);
      
    PMax = new PVector(250, 100, 0);
    VMax = new PVector(0, ROCKET_SPEED, 0);
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
      rect(-ROCKET_SIZE/2, 0, ROCKET_SIZE, ROCKET_SIZE + Math.abs(3 * velocity.y),ROCKET_SIZE/2);

      //rounded edges
      ellipse(0, ROCKET_SIZE + Math.abs(2 * velocity.y) + 10, ROCKET_SIZE, ROCKET_SIZE);
      ellipse(0, ROCKET_SIZE + Math.abs(2 * velocity.y) + 20, ROCKET_SIZE/2, ROCKET_SIZE/2);

      popMatrix();
    }

    //if SS has been initialized, draw it
    if (SS != null) {
      SS.draw();
    }

  } // end Rocker::draw()
  
}



RocketSpawner RS;
FlashSpawner FS;

void setup() {
  size(SCREEN_WIDTH,SCREEN_HEIGHT);
  smooth();
  RS = new RocketSpawner();
  FS = new FlashSpawner();
}

void draw() {
  background(BGCOL);
  RS.update();
  RS.draw();
  FS.update();
  FS.draw();
}
