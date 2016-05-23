float pov = PI;
Grid[] grids;
int xoffset, yoffset, zoffset;
int selected = 0;
int increment = 10;
int skip = 3;
KinectAbstractionLayer kinect;
int baselinePixelCount;
int currentPixelCount;
boolean topDown = false;
boolean walkForwards = false;
boolean walkBackwards = false;
int coolOffCountdown;
int cycleDirection = 1;
boolean analysePointcloud = true;

void setup()
{
  size(800, 600, P3D);
  colorMode(HSB);
  initOSC();
  kinect = new KinectAbstractionLayer(this);
  resetView();
  loadData();
  grids[selected].selected = true;
}

void draw()
{
  if (keyPressed) checkKeysPressed();
  if (coolOffCountdown > 0) coolOffCountdown--;
  background(0);
  pushMatrix();
  translate(xoffset, yoffset, zoffset);
  if (topDown) kinect.topDownTranslate();
  rotateY(pov);
  if (walkForwards) zoffset+=3;
  if (walkBackwards) zoffset-=3;
  if (analysePointcloud) {
    int[] depth = kinect.getRawDepth();
    currentPixelCount = 0;
    strokeWeight(2);
    for (int x=0; x<kinect.w; x+=skip) {
      for (int y=0; y<kinect.h; y+=skip) {
        int rawDepth = depth[x+y*kinect.w];
        if (rawDepth != 0) {
          PVector position = kinect.calculateRealWorldPoint(x, y, rawDepth);
          if (position.z > 0) currentPixelCount++;
          translate(position.x, position.y, position.z);
          stroke(position.z/2.8, 255, 255);
          point(0, 0);
          translate(-position.x, -position.y, -position.z);
          for (int i=0; i<grids.length; i++) grids[i].checkForTrigger(position);
        }
      }
    }
  }
  strokeWeight(1);
  for (int i=0; i<grids.length; i++) grids[i].drawYourself();
  if (frameCount % 50 == 0) sendSceneData((baselinePixelCount - currentPixelCount)/10);
  popMatrix();
}

void mouseDragged()
{
  if ((pmouseX > 0) && (pmouseY > 0)) {
    if (keyPressed) {
      pov -= (mouseX-pmouseX)/200.0;
    } else {
      xoffset += mouseX-pmouseX;
      yoffset += mouseY-pmouseY;
    }
  }
}

void keyPressed()
{
  if (keyCode == SHIFT) {
    increment = 1;
    cycleDirection = -cycleDirection;
  }
  checkKeysPressed();
  if(analysePointcloud) coolOffCountdown = 10;
}

void checkKeysPressed()
{
  if (coolOffCountdown == 0) {
    if(analysePointcloud) coolOffCountdown = 5;
    if (key == 'l') learnEverything();
    else if (key == 't') topDown = !topDown;
    else if (key == 'p') analysePointcloud = !analysePointcloud;
    else if (key == 'x') grids[selected].rotX(-0.025);
    else if (key == 'X') grids[selected].rotX(0.025);
    else if (key == 'y') grids[selected].rotY(-0.025);
    else if (key == 'Y') grids[selected].rotY(0.025);
    else if (key == 'z') grids[selected].rotZ(-0.025);
    else if (key == 'Z') grids[selected].rotZ(0.025);
    else if (key == 'q') walkForwards = true;
    else if (key == 'a') walkBackwards = true;
    else if (key == 'r') resetView();
    else if (keyCode == UP) {
      if (topDown) grids[selected].shiftZ(increment);
      else grids[selected].shiftY(-increment);
    } else if (keyCode == DOWN) {
      if (topDown) grids[selected].shiftZ(-increment);
      else  grids[selected].shiftY(increment);
    } else if (keyCode == LEFT) grids[selected].shiftX(increment);
    else if (keyCode == RIGHT) grids[selected].shiftX(-increment);
    else if ((key == '-') || (key == '_')) {
      if (topDown) grids[selected].shiftY(-increment);
      else grids[selected].shiftZ(-increment);
    } else if ((key == '=') || (key == '+')) {
      if (topDown) grids[selected].shiftY(increment);
      else grids[selected].shiftZ(increment);
    } else if (key == '\t') {
      grids[selected].selected = false;
      selected+=cycleDirection;
      if (selected >= grids.length) selected = 0;
      if (selected < 0) selected = grids.length-1;
      grids[selected].selected = true;
    }
    saveData();
  }
}

void resetView()
{
  xoffset = kinect.initialXoffset;
  yoffset = kinect.initialYoffset;
  zoffset = kinect.initialZoffset;
  pov = PI;
}

void keyReleased()
{
  if (keyCode == SHIFT) {
    increment = 10;
    cycleDirection = -cycleDirection;
  } else if (key == 'q') walkForwards = false;
  else if (key == 'a') walkBackwards = false;
}

void loadData()
{
  String[] lines = loadStrings("data.txt");
  grids = new Grid[lines.length];
  for (int i=0; i<lines.length; i++) {
    String[] data = lines[i].split(" ");
    grids[i] = new Grid(data[0], int(data[1]), int(data[2]), int(data[3]), 
      int(data[4]), int(data[5]), int(data[6]), 
      float(data[7]), float(data[8]), float(data[9]));
  }
}

void saveData()
{
  String[] lines = new String[grids.length];
  for (int i=0; i<grids.length; i++) {
    lines[i] = grids[i].id + " " + grids[i].size + " " + grids[i].zones.length + " " + grids[i].zones[0].length + " " +
      grids[i].centrePoint.x + " " + grids[i].centrePoint.y + " " + grids[i].centrePoint.z + " " +
      grids[i].rotationX + " " + grids[i].rotationY + " " + grids[i].rotationZ;
  }
  saveStrings("data.txt", lines);
}

void learnEverything()
{
  for (int i=0; i<grids.length; i++) grids[i].learnToIgnoreCurrentPixels();
  baselinePixelCount = currentPixelCount;
}