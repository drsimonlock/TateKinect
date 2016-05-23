class Grid
{
  String id;
  int size;
  PVector centrePoint;
  int centreY;
  Zone[][] zones;
  boolean selected = false;
  float rotationX, rotationY, rotationZ;
  float spacing;
  
  Grid(String ident, int s, int numCols, int numRows, int x, int y, int z, float rotX, float rotY, float rotZ)
  {
    id = ident;
    size = s;
    spacing = (size * 2.0) * 0.8;
    centrePoint = new PVector(x,y,z);
    rotationX = rotX;
    rotationY = rotY;
    rotationZ = rotZ;
    zones = new Zone[numCols][numRows];
    for(int row=0; row<zones[0].length ;row++) {
      for(int col=0; col<zones.length ;col++) {
        // Create zone with inital position (will change after doLayout)
        zones[col][row] = new Zone(ident + "/" + col + "/" + row, x, y, z, size);
      }
    }
    doLayout();
  }
  
  void drawYourself()
  {
    translate(centrePoint.x,centrePoint.y,centrePoint.z);
    if(selected) drawBoundingBox();
    sphereDetail(2+(size/7));
    for(int row=0; row<zones[0].length ;row++) {
      for(int col=0; col<zones.length ;col++) {
        zones[col][row].drawYourself();
      }
    }
    translate(-centrePoint.x,-centrePoint.y,-centrePoint.z);
  }

  void drawBoundingBox()
  {
    rotateX(rotationX);
    rotateY(rotationY);
    rotateZ(rotationZ);
    fill(100,255,255);
    textAlign(CENTER);
    textSize(18);
    text("TOP",0,-spacing*zones[0].length/2 - 5);
    noFill();
    stroke(100,255,255);
    strokeWeight(3);
    box(spacing*zones.length,spacing*zones[0].length,size*2);
    strokeWeight(1);
    rotateZ(-rotationZ);
    rotateY(-rotationY);
    rotateX(-rotationX);
  }

  void checkForTrigger(PVector point)
  {
    PVector localPoint = new PVector(point.x-centrePoint.x,point.y-centrePoint.y,point.z-centrePoint.z);
    for(int row=0; row<zones[0].length ;row++) {
      for(int col=0; col<zones.length ;col++) {
        if(zones[col][row].contains(localPoint)) zones[col][row].triggerCount++;
      }
    }
  }

  void shiftX(int amount)
  {
    centrePoint.x += amount;
    doLayout();
  }

  void shiftY(int amount)
  {
    centrePoint.y += amount;
    doLayout();
  }

  void shiftZ(int amount)
  {
    centrePoint.z += amount;
    doLayout();
  }
  
  void rotX(float amount)
  {
    rotationX += amount;
    doLayout();
  }

  void rotY(float amount)
  {
    rotationY += amount;
    doLayout();
  }

  void rotZ(float amount)
  {
    rotationZ += amount;
    doLayout();
  }

  void doLayout()
  {
    pushMatrix();
    rotateX(rotationX);
    rotateY(rotationY);
    rotateZ(rotationZ);
    for(int row=0; row<zones[0].length ;row++) {
      for(int col=0; col<zones.length ;col++) {
        int xpos = int(col * spacing) - int(spacing*float(zones.length-1)/2.0);
        int ypos = int(row * spacing) - int(spacing*float(zones[0].length-1)/2.0);
        zones[col][row].loc.x = modelX(xpos,ypos,0);
        zones[col][row].loc.y = modelY(xpos,ypos,0);
        zones[col][row].loc.z = modelZ(xpos,ypos,0);
      }
    }
    popMatrix();
  }
  
  void learnToIgnoreCurrentPixels()
  {
    for(int row=0; row<zones[0].length ;row++) {
      for(int col=0; col<zones.length ;col++) {
        zones[col][row].learnToIgnoreCurrentPixels();
      }
    }
  }

}