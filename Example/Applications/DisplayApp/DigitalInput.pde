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


public class DigitalInput {
  
  protected PVector size;
  protected PVector pos;
  protected color cBorder = color(255);
  protected color cOn = color(64, 192, 192);
  protected color cOnLong = color(255, 255, 255);
  protected color cOff = color(64, 0, 0);
  
  protected boolean state = false;
  protected int value = 0;
  
  public DigitalInput(PVector size, PVector pos) {
    this.size = size;
    this.pos = pos;
  }
  
  public void draw() {
    pushStyle();
    stroke(cBorder);
    strokeWeight(1);
    if(!state) {
      fill(cOff);
    }
    else {
      fill(lerpColor(cOn, cOnLong, (value-1) / 10.0));
    }
    rectMode(CENTER);
    rect(pos.x, pos.y, size.x, size.y);
    textAlign(CENTER);
    textSize(20);
    fill(0);
    if(value != 0) text(value, pos.x, pos.y + size.y / 8);
    popStyle();
  }
  
  public void setValue(int v) {
    state = v != 0;
    value = v;
  }
  
  public void setState(boolean s) {
    state = s;
  }
  
}
