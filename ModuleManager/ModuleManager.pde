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


import oscP5.*;

int listeningPort = 9001;
int objectsPort = 9000;
String myIp = "192.168.137.1";
String fileTypesPath = "data/types.json";
String fileObjectsPath = "data/objects.json";

PImage IMG_CONNECTED, IMG_DISCONNECTED, IMG_WARNING;
IPTable table;
GUI gui;
Manager manager;
boolean pingNetworkRegularly = true;
int lastPing;



void setup() {
  size(920, 720);
  frameRate(25);
  int objByLine = width / 350;
  
  IMG_CONNECTED = loadImage("data/connected.png");
  IMG_DISCONNECTED = loadImage("data/disconnected.png");
  IMG_WARNING = loadImage("data/warning.png");
  
  OscP5 oscP5 = new OscP5(this, listeningPort);
  TypesList types = new TypesList(loadJSONArray(fileTypesPath));
  ConnectedObjectList objects = new ConnectedObjectList(loadJSONArray(fileObjectsPath), types);
  table = new IPTable();
  gui = new GUI(table, objects, types, objByLine);
  manager = new Manager(oscP5, myIp, listeningPort, objectsPort, objects, table, types, gui);
  
  gui.setManager(manager);
  gui.update();
  
  manager.queryNetwork();
}



void draw() {
  gui.draw();
  if(pingNetworkRegularly && millis() - lastPing >= 30000) {
    pingNetwork();
    lastPing = millis();
  }
}



void pingNetwork() {
  //println("Ping network !");
  if(manager != null) {
    table.clear();
    manager.queryNetwork();
    gui.triggerUpdate();
  }
}

void oscEvent(OscMessage msg) {
  println("### received an osc message from " + msg.netAddress());
  msg.print();
  manager.forwardMsg(msg);
}

void mousePressed() {
  gui.mousePressed();
}

void mouseWheel(MouseEvent event) {
  gui.mouseWheel(event); 
}

void keyPressed() {
  gui.keyPressed(); 
}
