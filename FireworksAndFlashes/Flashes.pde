/*
Camera Flash System
Classes:
  Flash extends Particle
  FlashSpawner extends Spawner<Flash>
Alex Hersh | Teddy Stodard | Nathan Holmes
*/

int MAX_FLASH_SIZE = max(SCREEN_HEIGHT, SCREEN_WIDTH);
int FLASH_DIFFUSION = 25;
int FLASH_GROWTH = 100;

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
