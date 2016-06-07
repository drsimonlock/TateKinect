import oscP5.*;
import netP5.*;
import java.net.*;

OscP5 osc;
NetAddress recipient;

void initOSC()
{
  osc = new OscP5(this, 8000);
  recipient = new NetAddress("127.0.0.1", 8888);  
}

void sendZoneData(String gridID, int col, int row, int count)
{  
  JSONObject json = new JSONObject();
  json.setString("machine", machineID);
  json.setString("grid", gridID);
  json.setInt("column",col);
  json.setInt("row",row);
  json.setInt("count",count);
  OscMessage message = new OscMessage("/tiwwa/zone/"); 
  message.add(json.toString());
  osc.send(message, recipient);
}

void sendSceneData(int count)
{
  JSONObject json = new JSONObject();
  json.setString("machine", machineID);
  json.setInt("count",count);
  OscMessage message = new OscMessage("/tiwwa/scene/");
  message.add(json.toString());
  osc.send(message, recipient);
}

void oscEvent(OscMessage message)
{
  if(message.addrPattern().indexOf("learn") != -1) learnEverything();
}