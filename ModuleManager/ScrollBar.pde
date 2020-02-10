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


class Scrollbar {
  public color BAR_COLOR = color(204, 204, 204);
  public color HOVER_SLIDER_COLOR = color(150, 150, 150);
  public color SLIDER_COLOR = color(172, 172, 172);
  
  int swidth, sheight;    // width and height of bar
  int sliderDim;
  float xpos, ypos;       // x and y position of bar
  float spos, newspos;    // x position of slider
  int fixedDimSlider;
  float sposMin, sposMax; // max and min values of slider
  int loose;              // how loose/heavy
  boolean over;           // is the mouse over the slider?
  boolean locked;
  boolean isVerticalScrollbar;
  float ratio;

  Scrollbar (float xp, float yp, int sw, int sh, int l, boolean vertical) {
    swidth = sw;
    sheight = sh;
    xpos = xp;
    ypos = yp;
    isVerticalScrollbar = vertical;
    if(!isVerticalScrollbar) {
      spos = xpos;
      newspos = spos;
      sposMin = xpos;
      sposMax = xpos + swidth;
      sliderDim = sheight;
    } else {
      spos = ypos;
      newspos = spos;
      sposMin = ypos;
      sposMax = ypos + sheight;
      sliderDim = swidth;
    }
    loose = l;
  }

  void update() {
    if (overEvent()) {
      over = true;
    } else {
      over = false;
    }
    if (mousePressed && over) {
      locked = true;
    }
    if (!mousePressed) {
      locked = false;
    }
    if (locked) {
      if(!isVerticalScrollbar) {
        move(mouseX);
      } else {
        move(mouseY);
      }
    }
    if (abs(newspos - spos) > 0) {
      spos = spos + (newspos-spos)/loose;
    }
  }
  
  void move(float val) {
    newspos = constrain(val-sliderDim/2, sposMin, sposMax - sliderDim);
  }

  float constrain(float val, float minv, float maxv) {
    return min(max(val, minv), maxv);
  }
  
  public void changeSlider(int val) {
    if(!isVerticalScrollbar) {
      sliderDim = min(val, swidth);
    } else {
      sliderDim = min(val, sheight);
    }
  }

  boolean overEvent() {
    if (mouseX > xpos && mouseX < xpos+swidth &&
       mouseY > ypos && mouseY < ypos+sheight) {
      return true;
    } else {
      return false;
    }
  }

  void draw() {
    noStroke();
    fill(BAR_COLOR);
    rect(xpos, ypos, swidth, sheight);
    if (over || locked) {
      fill(HOVER_SLIDER_COLOR);
    } else {
      fill(SLIDER_COLOR);
    }
    if(!isVerticalScrollbar) {
      rect(spos, ypos, sliderDim, sheight);
    } else {
      rect(xpos, spos, swidth, sliderDim);
    }
  }
  
  void mouseWheel(MouseEvent event){
    float val = spos + sliderDim/2 + event.getCount() * 250 / loose;
    move(val);
  }

  float getPos() {
    // Convert spos to be values between
    // 0 and the total width of the scrollbar
    return -(spos - sposMin);
  }
}
