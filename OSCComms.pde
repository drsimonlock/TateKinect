import oscP5.*;
import netP5.*;
import java.net.*;

OscP5 osc;
NetAddress recipient;
String machineID;

void initOSC()
{
  machineID = getMachineID();
  osc = new OscP5(this, 8000);
  recipient = new NetAddress("127.0.0.1", 8888);
}

void sendZoneData(String id, int count)
{
  OscMessage message = new OscMessage("/" + machineID + "/zone/" + id);
  message.add(count);
  osc.send(message, recipient);
}

void sendSceneData(int count)
{
  OscMessage message = new OscMessage("/" + machineID + "/scene");
  message.add(count);
  osc.send(message, recipient);
}

void oscEvent(OscMessage message)
{
  if(message.addrPattern().endsWith("learn")) learnEverything();
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
    else if (mac.endsWith("52:5a:2e:22:59:08")) return "A";
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