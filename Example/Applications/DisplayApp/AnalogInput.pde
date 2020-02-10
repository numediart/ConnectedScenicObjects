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


class AnalogInput {
  
  protected PVector size;
  protected PVector pos;
  protected color cBorder = color(255);
  protected color cGauge = color(64, 192, 192);
  
  protected float value = 0.0f;
  
  public AnalogInput(PVector size, PVector pos) {
    this.size = size;
    this.pos = pos;
  }
  
  public void draw() {
    pushMatrix();
    pushStyle();
    translate(pos.x, pos.y);
    ellipseMode(CENTER);
    
    // display gauge
    strokeWeight(20);
    strokeCap(PROJECT);
    noFill();
    stroke(0);
    arc(0, 0, size.x + 20, size.y + 20, - 1.25 * PI, 0.25 * PI);
    stroke(cGauge);
    arc(0, 0, size.x + 20, size.y + 20, -1.25 * PI, 0.25 * PI + (value - 1) * 1.5 * PI); 
    // display value
    textAlign(CENTER);
    textSize(20);
    text(nf(value, 1, 3), 0, 10);
    
    popMatrix();
    popStyle();
  }
  
  public void setValue(float v) {
    value = v;
    if(value < 0.01) value = 0;
    if(value > 0.99) value = 1;
  }
}
