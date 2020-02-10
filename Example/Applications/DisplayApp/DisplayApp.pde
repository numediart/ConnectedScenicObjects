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


import netP5.*;
import oscP5.*;


final int listeningPort = 12002;
final int managerPort = 9001;


OscP5 oscP5;
NetAddress moduleManager;

PFont font;
String zoneName[][] = {{"Digital Input", "Touch Input"}, {"Analog Input", "Rotary Encoder"}};
int zoneBorder = 24;
int zoneH;
int zoneW;

DigitalInput digitalInputs[];
TouchInput touchInputs[];
AnalogInput analogInputs[];
RotaryEncoder rotaryEncoder;



void setup() {
  size(480, 640);
  zoneH = height / 2 - 2 * zoneBorder;
  zoneW = width / 2 - 2 * zoneBorder;
  int zoneMinDim = min(zoneH, zoneW);
  
  // Create and configure inputs display
  digitalInputs = new DigitalInput[4];
  touchInputs = new TouchInput[4];
  int x = zoneBorder + zoneW / 4;
  int y = zoneBorder + zoneH / 4;
  for(int i = 0; i < 4; i++) {
    digitalInputs[i] = new DigitalInput(new PVector(zoneMinDim * 0.30, zoneMinDim * 0.30), new PVector(x, y));
    touchInputs[i] = new TouchInput(new PVector(zoneMinDim * 0.30, zoneMinDim * 0.30), new PVector(x, y));
    if(i % 2 == 0) x += zoneW / 2;
    else x = zoneBorder + zoneW / 4;
    if(i == 1) y += zoneH / 2;
  }
  analogInputs = new AnalogInput[2];
  if(width >= height) {
    x = zoneBorder + zoneW / 4;
    y = zoneBorder + zoneH / 2;
  }
  else {
    x = zoneBorder + zoneW / 2;
    y = zoneBorder + zoneH / 4;
  }
  for(int i = 0; i < 2; i++) {
    analogInputs[i] = new AnalogInput(new PVector(zoneMinDim * 0.40, zoneMinDim * 0.40), new PVector(x, y));
    if(width >= height) x += zoneW / 2;
    else y += zoneH / 2;
  }
  rotaryEncoder = new RotaryEncoder(new PVector(zoneMinDim * 0.6, zoneMinDim * 0.6), new PVector(width/4, height/4));
  
  // open OSC connection
  oscP5 = new OscP5(this, listeningPort);
  moduleManager = new NetAddress("localhost", managerPort);
  // redirect OSC messages to handlers
  oscP5.plug(this,"digitaInputHandler","/ControllerTestModule/0/digital_input");
  oscP5.plug(this,"touchInputHandler","/ControllerTestModule/0/touch_input");  
  oscP5.plug(this,"analogInputHandler","/ControllerTestModule/0/analog_input");
  oscP5.plug(this,"rotaryEncoderValueHandler","/ControllerTestModule/0/rotary_encoder/value");  
  oscP5.plug(this,"rotaryEncoderButtonHandler","/ControllerTestModule/0/rotary_encoder/button"); 
  
  font = createFont("MonospaceTypewriter.ttf", 18);
  stroke(255);
  strokeWeight(3);
  rectMode(CENTER);
  textAlign(CENTER);
  textFont(font);
}


////// OSC handlers //////
public void digitaInputHandler(int id, int value) {
  digitalInputs[id].setValue(value);
}
public void touchInputHandler(int id, int state) {
  touchInputs[id].setState(state != 0);
}
public void analogInputHandler(int id, float value) {
  analogInputs[id].setValue(value);
}
public void rotaryEncoderValueHandler(int id, int value) {
  if(id == 0) rotaryEncoder.setValue(value);
}
public void rotaryEncoderButtonHandler(int id, int state) {
  if(id == 0) rotaryEncoder.setState(state);
} 



void draw() {
  background(0);

  // draw inputs zones and names
  int y = height / 4;
  for(String[] line : zoneName) {
    int x = width / 4;
    for(String name : line) {
      fill(64);
      rect(x, y, zoneW, zoneH);
      fill(255);
      text(name, x, y - height/4 + 18);
      x += width / 2;
    }
    y += height /2;
  }
  // draw inputs
  translate(0, 0);
  for(DigitalInput d : digitalInputs) {
    d.draw();
  }
  translate(width / 2, 0);
  for(TouchInput t : touchInputs) {
    t.draw();
  }
  translate(-width / 2, height / 2);
  for(AnalogInput a : analogInputs) {
    a.draw();
  }
  translate(width / 2, 0);
  rotaryEncoder.draw();
}



void mouseClicked() {
  if(mouseButton == LEFT && rotaryEncoder.mouseOverReset(new PVector(width / 2, height / 2))) {
    println("reset encoder");
    // the messsage will reset the encoder on the module of type "ControllerTestModule" and id = 0 in the Module Manager
    // start of the message : 
    // '/ControllerTestModule' -> type of the target module
    // '/0'                    -> id of the target module in the Module Manager
    // '/device'               -> will modify a device on the target module
    // '/rotary_encoder'       -> type of device on the module
    // '/reset'                -> action to perform, in this case, reset expects 2 arguments : the id of the rotary encoder to reset and the initial value
    OscMessage rst_msg = new OscMessage("/ControllerTestModule/0/device/rotary_encoder/reset");
    rst_msg.add(0); // reset encoder 0
    rst_msg.add(0); // reset to value = 0
    oscP5.send(rst_msg, moduleManager);
    rotaryEncoder.setValue(0);
  }
}


void oscEvent(OscMessage msg) {
  //println("### received an osc message from " + msg.netAddress());
  //msg.print();
}
