class Grid
{
  String id;
  int size;
  PVector centrePoint;
  int centreY;
  Zone[][] zones;
  boolean selected = false;
  float rotationX, rotationY, rotationZ;
  
  Grid(String ident, int s, int numRows, int numCols, int x, int y, int z, float rotX, float rotY, float rotZ)
  {
    id = ident;
    size = s;
    centrePoint = new PVector(x,y,z);
    rotationX = rotX;
    rotationY = rotY;
    rotationZ = rotZ;
    zones = new Zone[numRows][numCols];
    for(int row=0; row<zones.length ;row++) {
      for(int col=0; col<zones[row].length ;col++) {
        // Create zone with inital position (will change after doLayout)
        zones[row][col] = new Zone(ident, x, y, z, size);
      }
    }
    doLayout();
  }
  
  void drawYourself()
  {
    translate(centrePoint.x,centrePoint.y,centrePoint.z);    
    if (selected) strokeWeight(3);
    else strokeWeight(1);
    for(int row=0; row<zones.length ;row++) {
      for(int col=0; col<zones[row].length ;col++) {
        zones[row][col].drawYourself();
      }
    }
    translate(-centrePoint.x,-centrePoint.y,-centrePoint.z);
  }

  void checkForTrigger(PVector point)
  {
    PVector localPoint = new PVector(point.x-centrePoint.x,point.y-centrePoint.y,point.z-centrePoint.z);
    for(int row=0; row<zones.length ;row++) {
      for(int col=0; col<zones[row].length ;col++) {
        if(zones[row][col].contains(localPoint)) zones[row][col].triggerCount++;
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
    float spacing = (size * 2.0) * 0.8;
    for(int row=0; row<zones.length ;row++) {
      for(int col=0; col<zones[row].length ;col++) {
        int xpos = int(col * spacing) - int(spacing*float(zones[row].length-1)/2.0);
        int ypos = int(row * spacing) - int(spacing*float(zones.length-1)/2.0);
        zones[row][col].loc.x = modelX(xpos,ypos,0);
        zones[row][col].loc.y = modelY(xpos,ypos,0);
        zones[row][col].loc.z = modelZ(xpos,ypos,0);
      }
    }
    popMatrix();
  }
  
  void learnToIgnoreCurrentPixels()
  {
    for(int row=0; row<zones.length ;row++) {
      for(int col=0; col<zones[row].length ;col++) {
        zones[row][col].learnToIgnoreCurrentPixels();
      }
    }
  }

}