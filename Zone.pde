class Zone
{
  PVector loc;
  int triggerCount;
  boolean selected = false;
  int size;
  String id;
  ArrayList<PVector> pointsToIgnore = new ArrayList();
  int learningCounter = 20;
  int coolOffCounter;

  public Zone(String ident, int xpos, int ypos, int zpos, int s)
  {
    id = ident;
    loc = new PVector(xpos, ypos, zpos);
    size = s;
  }

  boolean contains(PVector point)
  {
    if ((loc.dist(point) < size) && (isNotInIgnoreList(point))) {
      if (learningCounter > 0) pointsToIgnore.add(point);
      return true;
    } else return false;
  }

  boolean isNotInIgnoreList(PVector point)
  {
    for (int i=0; i<pointsToIgnore.size(); i++) {
      PVector next = pointsToIgnore.get(i);
      if ((diff(next.x, point.x)<3) && (diff(next.y, point.y)<3) && (diff(next.z, point.z)<3)) return false;
    }
    return true;
  }

  void drawYourself()
  {
    if (coolOffCounter > 0) coolOffCounter--;
    if (learningCounter > 0) learningCounter--;
    int c;
    pushMatrix();
    if (triggerCount > 2) {
      if (coolOffCounter == 0) {
        sendZoneData(id, triggerCount);
        coolOffCounter = 20;
      }
      c = color(0, 255, 255);
      fill(0, 200, 200);
    } else {
      c = color(255, 0, 255);
      noFill();
    }
    stroke(c);
    if (selected) strokeWeight(3);
    else strokeWeight(1);
    triggerCount = 0;
    translate(loc.x, loc.y, loc.z);
    sphere(size);
    popMatrix();
  }

  void learnToIgnoreCurrentPixels()
  {
    pointsToIgnore = new ArrayList();
    learningCounter = 20;
  }

  float diff(float a, float b)
  {
    if (a>b) return a-b;
    else return b-a;
  }
}