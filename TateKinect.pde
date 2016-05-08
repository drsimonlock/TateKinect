import oscP5.*;
import netP5.*;
import java.net.*;
import org.openkinect.freenect.*;
import org.openkinect.processing.*;

float pov = PI;
Zone[] zones;
int selected = 0;
int increment = 10;
int skip = 2;
int xoffset = 150;
int yoffset = 150;
OscP5 osc;
NetAddress recipient;
KinectAbstractionLayer kinect;
String machineID;
int baselinePixelCount;
int currentPixelCount;
boolean topDown = false;

void setup()
{
  size(800, 600, P3D);
  colorMode(HSB);
  sphereDetail(8);
  osc = new OscP5(this, 8000);
  machineID = getMachineID();
  recipient = new NetAddress("127.0.0.1", 8888);
  kinect = new KinectAbstractionLayer(this);

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
  strokeWeight(1);
  int[] depth = kinect.getRawDepth();
  translate(xoffset, yoffset, 100);
  if (topDown) {
    rotateX(-HALF_PI);
    translate(100, 1000, 550);
  }
  rotateY(pov);
  currentPixelCount = 0;
  for (int x=0; x<kinect.w; x+=skip) {
    for (int y=0; y<kinect.h; y+=skip) {
      int rawDepth = depth[x+y*kinect.w];
      if (rawDepth != 0) {
        PVector position = kinect.calculateRealWorldPoint(x, y, rawDepth);
        if (position.z > 0) currentPixelCount++;
        translate(position.x, position.y, position.z);
        stroke(position.z/3, 255, 255);
        strokeWeight(2.0 + (position.z/2000.0));
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
      xoffset += mouseX-pmouseX;
      yoffset += mouseY-pmouseY;
    } else {
      pov += (mouseX-pmouseX)/100.0;
    }
  }
}

void keyPressed()
{
  if (key == 'l') learnEverything();
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
  } else if (key == 't') topDown = !topDown;
  else if (key == 'r') {
    xoffset = 150;
    yoffset = 150;
    pov = PI;
  } else if (key == '\t') {
    zones[selected].selected = false;
    selected++;
    if (selected >= zones.length) selected = 0;
    zones[selected].selected = true;
  }
  saveData();
}

void keyReleased()
{
  if (keyCode == SHIFT) increment = 10;
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

String getMachineID()
{
  try {
    NetworkInterface inter = NetworkInterface.getNetworkInterfaces().nextElement();
    byte[] bytes = inter.getHardwareAddress();
    String mac = "";
    for (int i=0; i<bytes.length; i++) mac = mac + String.format("%02X:", bytes[i]);
    mac = mac.substring(0, mac.length()-1);
    mac = mac.toLowerCase();    
    if (mac.endsWith("34:36:3b:78:19:5c")) return "S";
    else if (mac.endsWith("AAA")) return "A";
    else if (mac.endsWith("BBB")) return "B";
    else if (mac.endsWith("CCC")) return "C";
    else {
      println(mac + " is an unknown machine");
      return "X";
    }
  } 
  catch (SocketException se) {
    return "X";
  }
}