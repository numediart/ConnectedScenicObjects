// Copyright (c) 2019 UMONS - numediart - CLICK'
// 
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License as published by the Free Software Foundation; either
// version 2.1 of the License, or (at your option) any later version.
// 
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// Lesser General Public License for more details.
// 
// You should have received a copy of the GNU Lesser General Public
// License along with this library; if not, write to the Free Software
// Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA


class Manager {
  private static final int ERROR_DEFAULT_CONFIG = -1;
  private static final int ERROR_COMPATIBLE_TYPE = -2;
  private static final int ERROR_EXISTING_ID = -3;
  private final static int ERROR_SENDING_PORTS = -4;
  
  private ConnectedObjectList objects;
  private TypesList types;
  private IPTable table;
  private GUI gui;
  private OscP5 oscP5;
  
  private int listeningPort;
  private int objectsPort;
  private NetAddress broadcast;
  private final String LOCAL_IP = "127.0.0.1";
  
  Manager(OscP5 oscP5, String ip, int listeningPort, int objectsPort, ConnectedObjectList objects, IPTable table, TypesList types, GUI gui) {
    this.listeningPort = listeningPort;
    this.objectsPort = objectsPort;
    this.oscP5 = oscP5;
    this.objects = objects;
    this.table = table;
    this.gui = gui;
    this.types = types;
    
    String broadcastIp = ip.substring(0, ip.lastIndexOf('.')) + ".255";
    broadcast = new NetAddress(broadcastIp, objectsPort);
  }
  
  Manager(OscP5 oscP5, int listeningPort, int objectsPort, ConnectedObjectList objects, IPTable table, TypesList types, GUI gui) {
    this(oscP5, oscP5.ip(), listeningPort, objectsPort, objects, table, types, gui);
  }
  
  void queryNetwork() {
    /*for(int ip = 1; ip < 255; ip++) {
      String[] broadElements = split(broadcast.address(), '.');
      broadElements[3] = "" + ip;
      String address = join(broadElements, '.');
      oscP5.send(new OscMessage("/who"), new NetAddress(address, objectsPort));
    }*/
    oscP5.send(new OscMessage("/who"), new NetAddress(broadcast));
  }
  
  void queryObject(NetAddress ip) { 
    OscMessage msg = new OscMessage("/who");
    oscP5.send(msg, ip);
  }
  
  void blink(String mac) {
    OscMessage msg = new OscMessage("/status_led/blink");
    msg.add(6);
    msg.add(color(255, 255, 255));
    NetAddress ip = table.getIp(mac);
    if(ip != null) {
      oscP5.send(msg, new NetAddress(ip));
    }
  }
  
  void networkAnswer(OscMessage msg) {
    if(!msg.checkAddrPattern("/iam")) return;
    
    //Message from a local app, not an object
    if(msg.netAddress().address().equals(LOCAL_IP)) return;
       
    String mac = msg.get(0).stringValue();    
    table.add(mac, msg.netAddress());
    
    ConnectedObject o = objects.getByMac(mac);
    String devices_tag = msg.typetag().substring(1);
    IntDict devices = new IntDict();
    for(int i = 0; i < devices_tag.length(); i+=2) {
      devices.add(msg.get(i+1).stringValue(), msg.get(i+2).intValue());
    }
        
    if(o != null) {   
      if(!o.equalsHardware(devices)) {
        System.err.println("Object " + mac + " had his hardware changed ! You should delete or update this object !");
      }
      if(gui != null) {
        gui.triggerUpdate();
      }      
      return;
    } else { //Else add and config new object
      println("New object detected !");
      
      o = new ConnectedObject(mac, devices);
      objects.add(o);
      if(gui != null) {
        gui.triggerUpdate();
      }
    }
  }
  
  void forwardMsg(OscMessage msg) {
    if(msg.checkAddrPattern("/iam")) {
      networkAnswer(msg);
    }
    else if(msg.checkAddrPattern("/knockknock")) {
      queryObject(new NetAddress(msg.netAddress().address(), objectsPort));
    } 
    // Msg coming from 3rd Apps
    else if (msg.netAddress().address().equals(LOCAL_IP)) {
      //println("Msg from app !");
      forwardToObjects(msg);
    } 
    // Msg coming from Connected Objects
    else {
      //println("Msg from object !");
      forwardToApps(msg);
    }
  }
  
  private void forwardToObjects(OscMessage msg) {
    String addr = msg.addrPattern();
    String[] parts = split(addr, "/");
    
    //First part (parts[0]) is a null string
    String typeMsg = parts[1];
    int idMsg = Integer.parseInt(parts[2]);
    
    String newAddr = addr.substring(parts[1].length() + parts[2].length() + 2);
    msg.setAddrPattern(newAddr);
    
    ConnectedObject o = objects.getByTypeId(typeMsg, idMsg);
    
    if(o == null) {
      System.err.println("Message to unknown object: " + typeMsg + " - " + idMsg);
      return;
    }
    
    String mac = o.getMac();
    NetAddress sendIp = table.getIp(mac);
    
    if(sendIp == null) {
      System.err.println("Message to an object not connected: " + typeMsg + " - " + idMsg + " - " + mac);
      return;
    }
    
    oscP5.send(msg, new NetAddress(sendIp));
  }
  
  private void forwardToApps(OscMessage msg) {
    String mac = table.getMac(msg.netAddress());
    
    if(mac == null) {
        System.err.println("Message from a newly connected object: " + msg.netAddress());
        //To do : nothing better than discard msg?
        return;
    }
    
    ConnectedObject o = objects.getByMac(mac);
    
    if(o == null || o.getType() == null) {
        System.err.println("Message from an object not configured: " + mac);
        //To Do : nothing better than discard msg?
        return;
    }
    
    String typeMsg = o.getType().getName();
    int idMsg = o.getId();
    String addr = msg.addrPattern();
    msg.setAddrPattern("/" + typeMsg + "/" + idMsg + addr);
    
    IntList portsToSend = o.getPorts();        
    for(int i = 0; i < portsToSend.size(); i++) {
       oscP5.send(msg, new NetAddress(LOCAL_IP, portsToSend.get(i)));
    }
  }
  
  /*
   * Return true if the following conditions are ok :
   *     - None of the arguments has been let to default
   *     - 'type' exists and is compatible with the hardware of 'mac'
   *     - 'id' is unique for this type
   *     - 'ports' doesn't contain the sending and listening ports
   */
  public int checkConfiguration(String mac, String type_name, int id, SortedIntList ports) {
    ConnectedObject o = objects.getByMac(mac);

    //Config isn't fully set
    if(type_name == "" || type_name == null || id == ConnectedObject.DEFAULT_ID) {
      System.err.println("Config isn't fully set");  
      return ERROR_DEFAULT_CONFIG;
    }
    
    NamedSortedIntDict t = types.get(type_name);
     
    //Check if type is good
    if(!t.includedIn(o.getHardware())) {
      System.err.println("Hardware isn't compatible with selected Type");  
      return ERROR_COMPATIBLE_TYPE;
    }
    
    //Check if id is good for future type
    if(!(objects.getByTypeId(t.getName(), id) == null || objects.getByTypeId(t.getName(), id).getMac().equals(o.getMac()))) {
      System.err.println("Id already exists with selected Type");  
      return ERROR_EXISTING_ID;
    }
    
    //Check if ports are good
    if(ports.hasValue(listeningPort) || ports.hasValue(objectsPort)) {
      return ERROR_SENDING_PORTS; 
    }
    
    return 0;
  }
  
  /* 
   * Check configuration and if it's good, set 'mac' to the given args
   * Ports list is replaced by given arg
   * Return true if object has been modified
   */  
  public int configureObject(String mac, String type_name, int id, SortedIntList ports) {   
    ConnectedObject o = objects.getByMac(mac);
    int result = checkConfiguration(mac, type_name, id, ports);
    if(result == 0) {
      o.setId(id);
      o.setType(types.get(type_name));
      o.setPorts(ports.array());
      objects.sort();
      if(gui != null) {
        gui.triggerUpdate(); 
      }
    }
    
    return result;
  }
  
  void deleteObject(int index) {
    String mac = objects.get(index).getMac();
    objects.remove(index);
    table.remove(mac);
    if(gui != null) {
      gui.triggerUpdate();
    }
  }  
}
