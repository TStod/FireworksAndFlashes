// include ArrayList

// perform vector math on xyz movement, only draw in the xy. Position declared as a vector, but drawn as xy coordinates

// calculate xy as normal xy plane where 0 is the ground, then transform y at draw level to account for processings interpreteation of line scanning
// (y' = -1*(y-SCREEN_HEIGHT))

PVector GRAVITY = new PVector(0,-0.01,0); // Acceleration due to Gravity
float AIR_SCALAR = (-0.025); // Acceleration due to Air

int SCREEN_WIDTH = 500;
int SCREEN_HEIGHT = 500;

int ROCKET_TTL = 100;
int SPARK_TTL = 75;
int FLASH_TTL = 100;
int SPARK_BURST_SPEED = 2;
int EXPLOSION_SIZE = 300;

int MAX_FLASH_SIZE = 50;
int BGCOL = 1;

color RocketColor = #DDDDDD;

color randomVibrant() {
  float rgb[] = {random(150, 255), random(150, 255), random(150, 255)};
  for (int i = 0; i < rgb.length; i++) {
      if(rgb[i] < 175) {
          rgb[i] = 0;
      }
  }
  return color(rgb[0], rgb[1], rgb[2]);
  
}

protected class Spawner<T> {
  // Fields
  protected PVector PMax; // Max Position
  protected PVector PMin; // Min Position
  protected PVector VMax; // Max Velocity
  protected PVector VMin; // Min Velocity
  protected PVector AMax; // Max Acceleration
  protected PVector AMin; // Min Acceleration
  
  protected ArrayList<T> children;  // children spawned by Spawner
  
  protected int tts;
  
  public Spawner() {
    PMin = new PVector(0, 0, 0);
    VMin = new PVector(-50, -50, -50);
    AMin = new PVector(-10, -10, -10);
      
    PMax = new PVector(SCREEN_WIDTH, SCREEN_HEIGHT, SCREEN_HEIGHT);
    VMax = new PVector(50, 50, 50);
    AMax = new PVector(10, 10, 10);
    
    children = new ArrayList<T>();
  }
  
  public void spawn(T child) {
    children.add(child);
  } //end SPawner::spawn()
  
}

protected class RocketSpawner extends Spawner<Rocket> {
  
  public RocketSpawner() {
    PMin = new PVector(0, 1, 0);
    VMin = new PVector(-50, -50, -50);
    AMin = new PVector(-10, -10, -10);
      
    PMax = new PVector(SCREEN_WIDTH, 1, SCREEN_WIDTH);
    VMax = new PVector(50, 50, 0);
    AMax = new PVector(10, 10, 0);
    
    children = new ArrayList<Rocket>();
    
    tts = 0;
  }
  // Methods
  public void update() {
    // if time to spawn new one, spawn new 
    tts--;
    if (tts <= 0) {
      tts = 25;
      PVector p = new PVector(250, 100, 0);
      PVector vr = PVector.random2D();
      vr.mult(1);
      PVector v = new PVector(0, 9, 0);
      v.add(vr);
      PVector a = new PVector(0, 0, 0);
      Rocket newRocket = new Rocket(p, v, a);
      spawn(newRocket);
    }
    // for each rocket in rockets r.update();
    ArrayList<Rocket> garbage = new ArrayList<Rocket>();
    for (Rocket r : children) {
      if (!r.update()) { //update
        garbage.add(r);
      }
    }
    for (Rocket g : garbage) {
        children.remove(g);
    }
  } // end RocketSpawner::update()
  
  
  public void  draw() {
    for (Rocket r : children) {
      r.draw();
    }
  } // end RocketSpawner::draw()
  
  
}

protected class SparkSpawner extends Spawner<Spark> {
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
    sparkColor1 = randomVibrant();
    sparkColor2 = randomVibrant();
    
    children = new ArrayList<Spark>();
    
    explode();
  } // end SparkSpawner()
  
  SparkSpawner(PVector p) {
    // creates sparks and adds to arraylist of sparks
    position = new PVector(0,0,0);
    position.set(p);
    sparkColor1 = randomVibrant();
    sparkColor2 = randomVibrant();
    
    velocity = null;
    
    children = new ArrayList<Spark>();
    
    explode();
  } // end SparkSpawner()
  
  public void explode() {
    for (int i = 0; i < EXPLOSION_SIZE; i++) {
      
      PVector initV = PVector.random3D(); // randomize initial velocity 
      initV.setMag(SPARK_BURST_SPEED);    // normalize to desired burst speed
      
      if (velocity != null) {
        initV.add(velocity); // add spawners velocity if it exists
      }
      PVector a = new PVector(0, 0, 0);
      Spark newSpark = new Spark(position, initV, a, sparkColor1, sparkColor2);
      spawn(newSpark);
    }
  } // end explode()
  
  public boolean update() {
    ArrayList<Spark> garbage = new ArrayList<Spark>();
    for (Spark s : children) {
      if (!s.update()) { //update
        garbage.add(s);
      }
    }
    for (Spark g : garbage) {
        children.remove(g);
    }
    return children.size() > 0;
  } // end SparkSpawner::update()
  
  public void draw() {
    for (Spark s : children) {
      s.draw();
    }
  } // end SparkSpawner::draw()
}

protected class Particle {

  protected PVector position;
  protected PVector velocity;
  protected PVector acceleration;
  protected int ttl; // time to live
  
  /*
  protected float transparency;
  protected float size;
  color Color;
  */
  
  Particle() {
    position = new PVector(random(0,SCREEN_WIDTH), random(0,SCREEN_HEIGHT), 0);
    velocity = new PVector(0,0,0);
    acceleration = new PVector(0,0,0);
   
    ttl = ROCKET_TTL;
  } // end Rocket()  
  
  Particle(PVector p, PVector v, PVector a) {
    position.set(p);
    velocity.set(v);
    acceleration.set(a);
    ttl = ROCKET_TTL;
  } // end Rocket()
  
  public void move() {
    // A' = A_g + V*R_air + A
    PVector tempAcceleration = PVector.mult(velocity, AIR_SCALAR);
    tempAcceleration.add(GRAVITY);
    tempAcceleration.add(acceleration); // base acceleration + environment
    velocity.add(tempAcceleration);
    position.add(velocity);
  } // end Particle::move()
  

}

protected class Rocket extends Particle {
  protected SparkSpawner SS;
  
    
  Rocket() {
    position = new PVector(random(0,SCREEN_WIDTH), random(0,SCREEN_HEIGHT), 0);
    velocity = new PVector(0,0,0);
    acceleration = new PVector(0,0,0);
    
    SS = null;
   
    ttl = ROCKET_TTL;
  } // end Rocket()  
  
  Rocket(PVector p, PVector v, PVector a) {
    
    position = new PVector(0, 0, 0);
    velocity = new PVector(0,0,0);
    acceleration = new PVector(0,0,0);
    
    position.set(p);
    velocity.set(v);
    acceleration.set(a);
    
    SS = null;
    
    ttl = ROCKET_TTL;
  } // end Rocket()
  
  public boolean update() {
    ttl--;
    if (velocity.y <= 0) {
      ttl = 0;
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
    /*
    int flicker = 0;
    if(ttl % 2 == 0) {
      flicker++;
    }
    noStroke();
    fill(RocketColor);
    int new_y = -1 * int(position.y - SCREEN_HEIGHT);
    ellipse(int(position.x), new_y, 3+flicker, 3+flicker);
    */
    if (ttl > 0) {
      int new_y = -1 * int(position.y - SCREEN_HEIGHT);
      fill(RocketColor);
      noStroke();
      ellipse(int(position.x), new_y, 4, 4);
    }
    if (SS != null) {
      SS.draw();
    }
  } // end Rocker::draw()
  
}

protected class Spark extends Particle {
  color from, to;
  color[] lerpVector; // gradient for sparks
  
  
  Spark(PVector p, PVector v, PVector a, color color1, color color2) {
    position.set(p);
    velocity.set(v);
    acceleration.set(a);
    ttl = SPARK_TTL;
    
    lerpVector = new color[ttl];
    from = color1;
    to = color2;
    float stepSize = 1.0 / SPARK_TTL;
    float tempStep;
    for(int i = 0; i < SPARK_TTL; i++) {
      tempStep = stepSize * i;
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
      fill(lerpVector[ttl - 1]);
      fill(from);
      int new_y = -1 * int(position.y - SCREEN_HEIGHT);
      ellipse(int(position.x), new_y, 2, 2);
    }
  }
}


protected class FlashSpawner extends Spawner<Flash>{
  double TimeToFlash;
  
  public FlashSpawner(){
    TimeToFlash = Math.random() * 30 + 50;
    this.children = new ArrayList<Flash>();
  }  
  
  void update(){
    TimeToFlash--;
    if(TimeToFlash < 0){
      TimeToFlash = Math.random() * 30 + 50;
      spawn(new Flash());
      
    }
    
    ArrayList<Flash> garbage = new ArrayList<Flash>();
    for(Flash f : children){
       if(!f.update()) {
          garbage.add(f);     
       } 
    }
    
    for (Flash g : garbage) {
        children.remove(g);
    }
    
  }
  void draw(){
    for(Flash f : children){
      f.draw(); 
    }
  }
  
}

class Flash extends Particle{
  int size;
  int alpha;
  boolean growing;
 
  Flash() {
    position = new PVector(random(0,SCREEN_WIDTH), random(0,SCREEN_HEIGHT), 0);
    size = 0;
    alpha = 50;
    growing = true;
  } // end Flash()
  
  public boolean update(){
    if(growing){
       alpha+=30;
       if(size < MAX_FLASH_SIZE){
          size += 10;
       }else{
          growing = false;
       }  
       return true;
    }else if(size > 0){
      alpha -= 30;
      size -= 10;
      return true;   
    }else{
      return false;
    }  
  }
  
  public void draw(){
    //blendMode(ADD);
    fill(250, alpha);
    ellipse(position.x, position.y, size, size);
  }
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
