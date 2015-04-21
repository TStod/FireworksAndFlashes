int SCREEN_WIDTH = 500;
int SCREEN_HEIGHT = 800;

int BGCOL = #333333;

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
