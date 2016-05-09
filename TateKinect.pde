float pov = PI;
Zone[] zones;
int xoffset, yoffset, zoffset;
int selected = 0;
int increment = 10;
int skip = 2;
KinectAbstractionLayer kinect;
int baselinePixelCount;
int currentPixelCount;
boolean topDown = false;
boolean walkForwards = false;
boolean walkBackwards = false;

void setup()
{
  size(800, 600, P3D);
  colorMode(HSB);
  sphereDetail(8);
  initOSC();
  kinect = new KinectAbstractionLayer(this);
  resetView();
  
  String[] lines = loadStrings("data.txt");
  zones = new Zone[lines.length];
  for (int i=0; i<lines.length; i++) {
    String[] data = lines[i].split(" ");
    zones[i] = new Zone(data[0], int(data[1]), int(data[2]), int(data[3]), int(data[4]));
  }
  zones[selected].selected = true;
}

void draw()
{
  background(0);
  strokeWeight(2);
  int[] depth = kinect.getRawDepth();
  translate(xoffset, yoffset, zoffset);
  if (topDown) kinect.topDownTranslate();
  rotateY(pov);
  if(walkForwards) zoffset+=3;
  if(walkBackwards) zoffset-=3;
  currentPixelCount = 0;
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
        for (int i=0; i<zones.length; i++) {
          if (zones[i].contains(position)) zones[i].triggerCount++;
        }
      }
    }
  }
  for (int i=0; i<zones.length; i++) zones[i].drawYourself();
  if (frameCount % 50 == 0) sendSceneData((baselinePixelCount - currentPixelCount)/10);
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
  if (key == 'l') learnEverything();
  else if (key == 't') topDown = !topDown;
  else if (key == 'a') walkForwards = true;
  else if (key == 'z') walkBackwards = true;
  else if (key == 'r') resetView();
  else if (keyCode == SHIFT) increment = 1;
  else if (keyCode == UP) {
    if (topDown) zones[selected].loc.z+=increment;
    else zones[selected].loc.y-=increment;
  } else if (keyCode == DOWN) {
    if (topDown) zones[selected].loc.z-=increment;
    else  zones[selected].loc.y+=increment;
  } else if (keyCode == LEFT) zones[selected].loc.x+=increment;
  else if (keyCode == RIGHT) zones[selected].loc.x-=increment;
  else if ((key == '-') || (key == '_')) {
    if (topDown) zones[selected].loc.y-=increment;
    else zones[selected].loc.z-=increment;
  } else if ((key == '=') || (key == '+')) {
    if (topDown) zones[selected].loc.y+=increment;
    else zones[selected].loc.z+=increment;
  } else if (key == '\t') {
    zones[selected].selected = false;
    selected++;
    if (selected >= zones.length) selected = 0;
    zones[selected].selected = true;
  }
  saveData();
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
  if (keyCode == SHIFT) increment = 10;
  else if (key == 'a') walkForwards = false;
  else if (key == 'z') walkBackwards = false;
}

void saveData()
{
  String[] lines = new String[zones.length];
  for (int i=0; i<zones.length; i++) {
    lines[i] = zones[i].id + " " + zones[i].loc.x + " " + zones[i].loc.y + " " + zones[i].loc.z + " " + zones[i].size;
  }
  saveStrings("data.txt", lines);
}

void learnEverything()
{
  for (int i=0; i<zones.length; i++) zones[i].learnToIgnoreCurrentPixels();
  baselinePixelCount = currentPixelCount;
}