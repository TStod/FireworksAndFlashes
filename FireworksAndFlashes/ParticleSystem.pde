/*
Particle System generic classes
Classes:
  Particle
  Spawner<Particle>
Functions:
  randomVibrant
  drawY

Alex Hersh | Teddy Stodard | Nathan Holmes
*/


//-------------------------------useful functions

//build a palette of colors to choose from
int[] SparkPalette = {#B1EB00, #53BBF4, #FF85CB, #FF432E, #FFAC00, #982395, #0087CB, #ED1C24, #9C0F5F, #02D0AC};
int randomVibrant() {
  return SparkPalette[int(random(0,SparkPalette.length))];
}

// perform vector math on xyz movement, only draw in the xy. Position declared as a vector, but drawn as xy coordinates
// calculate xy as normal xy plane where 0 is the ground, then transform y at draw level to account for processings interpreteation of line scanning
// (y' = -1*(y-SCREEN_HEIGHT+1))
int drawY(int y) {
  return -1 * (1 + y - SCREEN_HEIGHT);
}

//-------------------------------PARTICLE SYSTEM

PVector GRAVITY = new PVector(0, -0.0, 0); // Acceleration due to Gravity (-y direction)
float AIR_RESIST = -0.03; // Air Resistance (proportional and opposite to velocity)


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
    PVector tempAcceleration = PVector.mult(velocity, AIR_RESIST);
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
