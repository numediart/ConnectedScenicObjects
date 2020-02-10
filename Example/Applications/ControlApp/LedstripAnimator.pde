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


class LedstripAnimator {
  
  private String[] animations = {"none", "rainbow", "glitter", "sky", "hue"};
  private final int RAINBOW[] = {0xff0021ff, 0xff0e6bb9, 0xff1cb573, 0xff2aff2d,
                                 0xff2aff2d, 0xff71ff1e, 0xffb8ff0f, 0xffffff00,
                                 0xffffff00, 0xffffbc00, 0xffff7900, 0xffff3700,
                                 0xffff3700, 0xffff1b00, 0xffff0000, 0xffff00ff };
  private final int SKY[] = {0xff046dff, 0xff0a79f8, 0xff1185f2, 0xff1791ec,
                             0xff1e9de6, 0xff1e9de6, 0xff5bd5ff, 0xff5bd5ff,
                             0xffa1e9ff, 0xffffffff, 0xffa1e9ff, 0xff5bd5ff, 
                             0xff1e9de6, 0xff158dee, 0xff0c7df6, 0xff046dfe };
  private int animId;
  private float animSpeed;
  private int lastAnimT0;
  private boolean clearCalled = false;
  
  private int leds[];
  private int nbLeds;
  private int firstLedIndex = 0;
  private int tourCount = 0;
  
  private PVector center;
  private float size;
  
  public LedstripAnimator(int nbLeds, PVector center, float size) {
    this.nbLeds = nbLeds;
    this.center = center;
    this.size = size;
    
    leds = new int[nbLeds];
    for(int i = 0; i < nbLeds; i++) leds[i] = color(0);
    animId = -1;
    animSpeed = 10;
  }
  
  public void changeAnimation(int newAnimId) {
    if(newAnimId >= 0 && newAnimId < animations.length) {
      clear();
      animId = newAnimId;
      firstLedIndex = 0;
    }
  }
  
  public void clear() {
    clearCalled = true;
    animId = -1;
    for(int i = 0 ; i < nbLeds; i++) {
      leds[i] = color(0);
    }
  }
  
  public String[] getAnimationNames() {
    return animations;
  }
  
  public void setAnimationSpeed(float s) {
    animSpeed = s;
  }
  
  public void draw() {
    pushMatrix();
    pushStyle();
    translate(center.x, center.y);
    rectMode(CENTER);
    ellipseMode(CENTER);
    rotate(-PI);
    for(int c : leds) {
      fill(0, 0);
      stroke(128);
      strokeWeight(1);
      rect(0, size/2 - size/16, size/8, size/8);
      noStroke();
      fill(c);
      ellipse(0, size/2 - size/16, size/8-4, size/8-4);
      rotate(TWO_PI / nbLeds);
    }
    popStyle();
    popMatrix();
  }
  
  public OscMessage update(String prefix, int ledStripId) {
    if(clearCalled) {
      clearCalled = false;
      OscMessage msg = new OscMessage(prefix + "/device/ledstrip/clear");
      msg.add(ledStripId);
      return msg;  
    }
    
    boolean hasChanged = false;
    if(millis() - lastAnimT0 > 1000 / animSpeed && animId >= 1 && animId < animations.length) {
      hasChanged = true;
      lastAnimT0 = millis();
      if(animations[animId].equals("rainbow")) { // rainbow
        for(int i = 0; i < nbLeds; i++) {
          leds[(i + firstLedIndex) % nbLeds] = RAINBOW[i];
        }
        firstLedIndex = (firstLedIndex + 1) % nbLeds;
      }
      else if(animations[animId].equals("glitter")) { // glitter
        leds[firstLedIndex] = color(0);
        firstLedIndex = floor(random(nbLeds));
        leds[firstLedIndex] = color(255);
      }
      else if(animations[animId].equals("sky")) { // sky
        for(int i = 0; i < nbLeds; i++) {
          leds[(i + firstLedIndex) % nbLeds] = SKY[i];
        }
        firstLedIndex = (firstLedIndex + 1) % nbLeds;
      }
      else if(animations[animId].equals("hue")) { // hue
        for(int i = 0 ; i < nbLeds; i++) {
          leds[i] = color(0);
        }
        int c = lerpColor(RAINBOW[tourCount], RAINBOW[(tourCount + 1) % nbLeds], (float) firstLedIndex / nbLeds);
        for(int i = 0; i < nbLeds/2; i++) {
          leds[(i + firstLedIndex) % nbLeds] = lerpColor(0, c, (float)(i+1) / (nbLeds / 2));
        }
        firstLedIndex++;
        if(firstLedIndex >= nbLeds) {
          firstLedIndex = 0;
          tourCount = (tourCount + 1) % nbLeds;
        }
      }
    }
    
    if(hasChanged) {
      OscMessage msg = new OscMessage(prefix + "/device/ledstrip/set_color");
      msg.add(ledStripId);
      msg.add(0);
      for(int c : leds) {
        msg.add(c);
      }
      return msg;  
    }
    else 
      return null;
  }
}
