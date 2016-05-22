class Grid
{
  String id;
  int size;
  PVector centrePoint;
  int centreY;
  Zone[][] zones;
  boolean selected = false;
  
  Grid(String ident, int s, int numRows, int numCols, int x, int y, int z)
  {
    id = ident;
    size = s;
    float spacing = (size * 2.0) * 0.8;
    centrePoint = new PVector(x,y,z);
    zones = new Zone[numRows][numCols];
    for(int row=0; row<zones.length ;row++) {
      for(int col=0; col<zones[row].length ;col++) {
        int xpos = x + int(col * spacing) - int(spacing*float(numCols-1)/2.0);
        int ypos = y + int(row * spacing) - int(spacing*float(numRows-1)/2.0);
        zones[row][col] = new Zone(ident, xpos, ypos, z, size);
      }
    }    
  }
  
  void drawYourself()
  {
    if (selected) strokeWeight(3);
    else strokeWeight(1);
    for(int row=0; row<zones.length ;row++) {
      for(int col=0; col<zones[row].length ;col++) {
        zones[row][col].drawYourself();
      }
    }
  }

  void checkForTrigger(PVector point)
  {
    for(int row=0; row<zones.length ;row++) {
      for(int col=0; col<zones[row].length ;col++) {
        if(zones[row][col].contains(point)) zones[row][col].triggerCount++;
      }
    }
  }

  void shiftX(int amount)
  {
    centrePoint.x += amount;
    for(int row=0; row<zones.length ;row++) {
      for(int col=0; col<zones[row].length ;col++) {
        zones[row][col].loc.x += amount;
      }
    }
  }

  void shiftY(int amount)
  {
    centrePoint.y += amount;
    for(int row=0; row<zones.length ;row++) {
      for(int col=0; col<zones[row].length ;col++) {
        zones[row][col].loc.y += amount;
      }
    }
  }

  void shiftZ(int amount)
  {
    centrePoint.z += amount;
    for(int row=0; row<zones.length ;row++) {
      for(int col=0; col<zones[row].length ;col++) {
        zones[row][col].loc.z += amount;
      }
    }
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