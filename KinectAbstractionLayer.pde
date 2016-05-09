import org.openkinect.freenect.*;
import org.openkinect.processing.*;

class KinectAbstractionLayer
{
  Kinect kv1;
  Kinect2 kv2;
  int w, h, initialXoffset, initialYoffset, initialZoffset;

  KinectAbstractionLayer(PApplet parent)
  {
    kv1 = new Kinect(parent);
    if (kv1.numDevices() != 0) {
      kv1.initDepth();
      w = 640;
      h = 480;
      initialXoffset = 150;
      initialYoffset = 150;
      initialZoffset = 100;
    } else {
      kv2 = new Kinect2(parent);
      kv2.initDepth();
      kv2.initDevice();
      w = 512;
      h = 424;
      initialXoffset = 350;
      initialYoffset = 350;
      initialZoffset = 420;
    }
  }

  int[] getRawDepth()
  {
    if (kv2 != null) return kv2.getRawDepth();
    else return kv1.getRawDepth();
  }

  PVector calculateRealWorldPoint(int x, int y, int depthValue)
  {
    // Both the below were worked out by trial & error to get some level of consistency
    if (kv2 != null) return new PVector(x-w/2, y-h/2, pow(depthValue, 0.8));
    else {
      // 2047 is the "didn't see anything" value
      if (depthValue == 2047) return new PVector(-99999, -99999, -99999);
      else return new PVector(-(x*1.5)+w/2, (y*1.5)-h/2, depthValue - 280);
    }
  }

  void topDownTranslate()
  {
    rotateX(-HALF_PI);
    // Due to previous rotation, translation order is X Z Y
    if (kv2 != null) translate(0, 600, 400);
    else translate(100, 1000, 550);
  }
}