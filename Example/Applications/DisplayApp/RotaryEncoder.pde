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


class RotaryEncoder {
  
  protected PVector size;
  protected PVector pos;
  protected color cBorder = color(255);
  protected color cOn = color(64, 192, 192);
  protected color cOff = color(64, 0, 0);
  
  protected int stepPerTour = 32;
  protected boolean buttonState = false;
  protected int value = 0;
  
  public RotaryEncoder(PVector size, PVector pos) {
    this.size = size;
    this.pos = pos;
  }
  
  public void draw() {
    pushMatrix();
    pushStyle();
    translate(pos.x, pos.y);
    // display value
    fill(0);
    noStroke();
    rect(0, size.y * -0.5 - 28, size.x, 36);
    fill(255);
    textSize(28);
    textAlign(CENTER);
    text("" + value, 0, size.y * -0.5 - 20);
    // display reset
    if(mouseOverReset(new PVector(width/2, height/2))) fill(248);
    else fill(184);
    textSize(20);
    rect(0, size.y * 0.5 + 26, size.x, 32);
    fill(0);
    text("reset", 0, size.y * 0.5 + 32);
    // display encoder
    ellipseMode(CENTER);
    stroke(cBorder);
    strokeWeight(3);
    fill(buttonState? cOn : cOff);
    rotate(value * (TWO_PI / stepPerTour) - HALF_PI);
    ellipse(0, 0, size.x, size.y);
    ellipse(size.x*0.4, 0, size.x / 10, size.y /10);    
    popStyle();
    popMatrix();
  }
  
  public void setState(int s) {
    buttonState = s != 0;
  }
  
  public void setValue(int v) {
    value = v;
  }
  
  public boolean mouseOverReset(PVector origin) {
    return mouseX >= (origin.x + pos.x - size.x / 2) && mouseX <= (origin.x + pos.x + size.x / 2) &&
            mouseY >= (origin.y + pos.y + size.y *0.5 + 10) && mouseY <= (origin.y + pos.y + size.y *0.5 + 42);
  }
}
