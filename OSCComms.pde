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