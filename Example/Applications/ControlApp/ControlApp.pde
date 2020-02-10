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
import controlP5.*;

final int listeningPort = 12001;
final int managerPort = 9001;


OscP5 oscP5;
NetAddress moduleManager;

ControlP5 cp5;

PFont font;
int zoneBorder = 24;
int topZoneWidth;
int topZoneHeight;
int botZoneWidth;
int botZoneHeight;
color zoneBackground = color(32);
color zoneForeground = color(248);


int[] digitalOutputsState = {0, 0, 0, 0};

LedstripAnimator ledAnimator;

RadioButton waveformRadio;
String waveformNames[] = {"sine", "triangle", "sawtooth", "square"};
Knob waveformFreqKnob;
Toggle constantLevel;
Knob constantLevelKnob;


void setup() {
  size(480, 640);
  
  topZoneWidth = width - 2 * zoneBorder;
  topZoneHeight = height / 4 - 2 * zoneBorder;
  botZoneWidth = width / 2 - 2 * zoneBorder;;
  botZoneHeight = height / 2 - 2 * zoneBorder;
  
  font = createFont("MonospaceTypewriter.ttf", 14);
  stroke(zoneForeground);
  strokeWeight(3);
  textAlign(CENTER);
  textFont(font);
  textSize(18);
  
  oscP5 = new OscP5(this, listeningPort);
  moduleManager = new NetAddress("localhost", managerPort);
  
  cp5 = new ControlP5(this);
  // change the original colors and fonts
  cp5.setColorBackground(color(104)); // default
  cp5.setColorForeground(color(196, 152, 0)); // over
  cp5.setColorActive(color(255, 216, 0)); // active
  cp5.setFont(font);
  
  // add toogles to control DigitalOutput
  cp5.addCheckBox("digitalOutputs")
      .setPosition((width - (4*40 + 3*40)) / 2, zoneBorder + topZoneHeight / 2 - 20)
      .setSize(40, 40)
      .setItemsPerRow(4)
      .setSpacingColumn(40)
      .setSpacingRow(0)
      .addItem("0", 0)
      .addItem("1", 1)
      .addItem("2", 2)
      .addItem("3", 3)
      ;
          
   // add knobs to control PWM outputs
   int knobRadius = (height / 4 - 2 * zoneBorder) / 2 - 6;
   cp5.addKnob("PWM0")
       .setLabel("")
       .setRange(0.0f, 1.0f)
       .setValue(0.0f)
       .setPosition(width / 4 - knobRadius, height / 4 + zoneBorder + 6)
       .setRadius(knobRadius)
       .setDragDirection(Knob.HORIZONTAL)
       ;
  cp5.addKnob("PWM1")
       .setLabel("")
       .setRange(0.0f, 1.0f)
       .setValue(0.0f)
       .setPosition(3 * width / 4 - knobRadius, height / 4 + zoneBorder + 6)
       .setRadius(knobRadius)
       .setDragDirection(Knob.HORIZONTAL)
       ;
       
  // add Ledstrip control
  float ledAnimatorSize = min(botZoneWidth, botZoneHeight) - 16;
  ledAnimator = new LedstripAnimator(
                    16, 
                    new PVector(width / 4, height - 8 - ledAnimatorSize / 2 - zoneBorder),
                    ledAnimatorSize);
  float speedRadius = ledAnimatorSize * 0.24;
  cp5.addKnob("speed")
       .setRange(1.0f, 50.0f)
       .setValue(10.0f)
       .setPosition(width / 4 - speedRadius, height - 8 - ledAnimatorSize / 2 - zoneBorder - speedRadius)
       .setRadius(speedRadius)
       .setDragDirection(Knob.HORIZONTAL)
       ;
  cp5.addScrollableList("animation")
       .setPosition(width / 4 - (botZoneWidth - 16) / 2, height / 2 + zoneBorder + 8)
       .setSize(int(botZoneWidth - 16), int(botZoneHeight - 24))
       .setItems(ledAnimator.getAnimationNames())
       .setBarHeight(36)
       .setItemHeight(36)
       .setType(ScrollableList.DROPDOWN)
       ;

  // add Analog out control (DAC)
  waveformRadio = cp5.addRadioButton("waveformSelect")
         .setPosition(width / 2 + zoneBorder + 16, height / 2 + zoneBorder + 16)
         .setSize(48, 32)
         .setItemsPerRow(1)
         .setSpacingRow(10)
         .addItem("sine", 0)
         .addItem("triangle", 1)
         .addItem("sawtooth", 2)
         .addItem("square", 3)
         ;
  waveformRadio.setValue(-1);
  // load and resize images
  String iconState[] = {"_default", "_active", "_over"};
  for(int i = 0; i < waveformNames.length; i++) {
    PImage waveformIcons[] = new PImage[iconState.length];
    for(int s = 0; s < iconState.length; s++) {
      waveformIcons[s] = loadImage(waveformNames[i] + iconState[s] + ".png");
      waveformIcons[s].resize(48, 32);
    }
    waveformRadio.getItem(i).setImages(waveformIcons);
  }
  float freqRadius = (botZoneWidth - 48 - 3 * 16) /2;
  waveformFreqKnob = cp5.addKnob("frequency")
       .setRange(10.0f, 60.0f)
       .setValue(10.0f)
       .setPosition(width/2 + zoneBorder + 48 + 2 * 16, height / 2 + zoneBorder + 74 - freqRadius)
       .setRadius(freqRadius)
       .setDragDirection(Knob.HORIZONTAL)
       ;
  constantLevel = cp5.addToggle("constant")
        .setPosition(width / 2 + zoneBorder + 16, height - 2 * zoneBorder - 32)
        .setSize(48, 32)
        ;
  float levRadius = (botZoneHeight - 158 - zoneBorder - 16) /2;
  constantLevelKnob = cp5.addKnob("level")
       .setRange(0.0f, 1.0f)
       .setValue(0.0f)
       .setPosition(width - 2 * zoneBorder - 2 * levRadius , height - 2 * zoneBorder - 2 * levRadius)
       .setRadius(levRadius)
       .setDragDirection(Knob.HORIZONTAL)
       ;
}



////// ControlP5 callbacks //////////

// digital outputs
void digitalOutputs(float[] states) {
  int i = 0;
  for(int s : int(states)) {
    if(s != digitalOutputsState[i]) {
      digitalOutputsState[i] = s;
      OscMessage msg = new OscMessage("/ActivatorTestModule/0/device/digital_output/set");
      msg.add(i);
      msg.add(s);
      oscP5.send(msg, moduleManager);
    }
    i++;
  }
}

// PWM outputs
void PWM0(float value) {
  sendPwmMessage(0, value);
}
void PWM1(float value) {
  sendPwmMessage(1, value);
}
void sendPwmMessage(int id, float v) {
  OscMessage msg = new OscMessage("/ActivatorTestModule/0/device/pwm_output/set");
  msg.add(id);
  msg.add(v);
  oscP5.send(msg, moduleManager);
}

// Ledstrip
void speed(float value) {
  ledAnimator.setAnimationSpeed(value);
}
void animation(int n) {
  ledAnimator.changeAnimation(n);
}
// Analog output
void waveformSelect(int value) {
  if(value >= 0) {
    constantLevel.setState(false);
    sendWaveformMessage();
  }
}
void frequency(float value) {
  if(waveformRadio.getValue() >= 0)
    sendWaveformMessage();
}
void sendWaveformMessage() {
  OscMessage msg = new OscMessage("/ActivatorTestModule/0/device/analog_output/waveform");
  msg.add(0);
  msg.add(waveformNames[int(waveformRadio.getValue())]);
  msg.add(waveformFreqKnob.getValue());
  oscP5.send(msg, moduleManager);
}
void constant(boolean value) {
  if(value) {
    if(waveformRadio.getValue() >= 0) {
      waveformRadio.getItem(int(waveformRadio.getValue())).setValue(0);
      waveformRadio.setValue(-1);
    }
    sendConstantLevelMessage();
  }
  else {
    constantLevelKnob.setValue(0.0f);
    sendConstantLevelMessage();
  }
}
void level(float value) {
  if(constantLevel.getBooleanValue())
    sendConstantLevelMessage();
}
void sendConstantLevelMessage() {
  OscMessage msg = new OscMessage("/ActivatorTestModule/0/device/analog_output/set");
  msg.add(0);
  msg.add(constantLevelKnob.getValue());
  oscP5.send(msg, moduleManager);
}



void draw() {
  background(0);
  
  OscMessage msg = ledAnimator.update("/ActivatorTestModule/0", 0);
  if(msg != null) {
    oscP5.send(msg, moduleManager);
  }
  
  // draw Digital Outputs zone
  int x = zoneBorder;
  int y = zoneBorder;
  fill(zoneBackground);
  rect(x, y, topZoneWidth, topZoneHeight);
  fill(zoneForeground);
  text("Digital Outputs", width/2, 18);
  y += height / 4;
  
  // draw PWM Outputs zone
  fill(zoneBackground);
  rect(x, y, topZoneWidth, topZoneHeight);
  fill(zoneForeground);
  text("PWM Outputs", width/2, y - 6);
  y += height / 4;
  
  // draw Led Strip zone
  fill(zoneBackground);
  rect(x, y, botZoneWidth, botZoneHeight);
  fill(zoneForeground);
  text("LED Strip", width/4, y - 6);
  x += width / 2;
  ledAnimator.draw();
  
  // draw Analog output zone
  fill(zoneBackground);
  rect(x, y, botZoneWidth, botZoneHeight);
  fill(zoneForeground);
  text("Analog Outputs", 3 * width/4, y - 6);
}
