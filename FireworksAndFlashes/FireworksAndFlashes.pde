/*
Setup/Draw file

Alex Hersh | Teddy Stodard | Nathan Holmes
*/

int SCREEN_WIDTH = 500;
int SCREEN_HEIGHT = 800;

int BGCOL = #333333;

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
