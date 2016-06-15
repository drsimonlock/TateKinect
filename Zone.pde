class Zone
{
  PVector loc;
  int col;
  int row;
  int triggerCount;
  int size;
  String id;
  ArrayList<PVector> pointsToIgnore = new ArrayList();
  int learningCounter = 20;
  int coolOffCounter;

  public Zone(String ident, int c, int r, int xpos, int ypos, int zpos, int s)
  {
    id = ident;
    col = c;
    row = r;
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
    if (triggerCount > size/3) {
      if (coolOffCounter == 0) {
        sendZoneData(id, col, row, triggerCount);
        coolOffCounter = 20;
      }
      c = color(0, 255, 255);
      fill(0, 200, 200);
    } else {
      c = color(255, 0, 255);
      noFill();
    }
    stroke(c);
    triggerCount = 0;
    translate(loc.x, loc.y, loc.z);
    sphere(size);
    translate(-loc.x, -loc.y, -loc.z);
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