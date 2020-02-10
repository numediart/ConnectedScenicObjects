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

/* 
 * A class to show ConnectedObject information which are clickable.
 * @author : L. Vanden Bemden - Institut Numediart - UMONS
 */
 
 
class ConnectedObjectDisplay implements ObjectDisplayIF {
  private final color BUTTON_COLOR = color(196);
  private final color TEXT_COLOR = color(64);
  
  private final color HOVER_BUTTON_COLOR = color(255);
  private final color HOVER_TEXT_COLOR = color(0);
  
  private final color SELECTED_COLOR = color(0, 255, 0);
  private final static int SELECTED_STROKE_WEIGHT = 3;
  
  private final PVector OFFSET = new PVector(10, 10);
  
  // These variables have been moved to main class to avoid loading images multiple times !
  //private PImage IMG_CONNECTED = loadImage("data/connected.png");
  //private PImage IMG_DISCONNECTED = loadImage("data/disconnected.png");
  //private PImage IMG_WARNING = loadImage("data/warning.png");
    
  private PVector writable, size, origin;
  private String[] infos;
  private boolean isConnected, mouseHover, selected, warning;
  private int textSize;
  
  public ConnectedObjectDisplay() {
    mouseHover = false;
    isConnected = false;
    selected = false;
    warning = false;
    infos = new String[4];
    for(int i = 0; i < infos.length; i++) {
      infos[i] = ""; 
    }
  }
  
  public void setBox(PVector position, PVector size) {
    this.origin = position;
    this.size = size;
    
    textSize = ((int) size.y - (int) OFFSET.y) / infos.length - (int) OFFSET.y;
    writable = new PVector(size.x - 2 * OFFSET.x - textSize, (size.y - OFFSET.y) / infos.length);
  }
  
  public void select(boolean selected) {
    this.selected = selected; 
  }
  
  public void setTextSize(int textSize) {
    this.textSize = textSize; 
  }
  
  public void setDisplay(String typename, int id, String ports, String mac, boolean isConnected, boolean hasErrors) {
    infos[0] = "Type: "+ typename;
    infos[1] = "Id: " + id;
    infos[2] = "Ports: " + ports;
    infos[3] = mac;
    
    this.isConnected = isConnected;
    warning = hasErrors;
    
    pushStyle();
    textSize(textSize);
    for(int i = 0; i < infos.length; i++) {
      if(textWidth(infos[i]) >= writable.x) {
          while(textWidth(infos[i] + "...") >= writable.x && infos[i].length() > 0) {
            infos[i] = infos[i].substring(0, infos[i].length() - 1);
          }
          infos[i] = infos[i] + "...";
        }
    }
    popStyle();
  }
  
  public boolean mouseHover() {
    return mouseHover;
  }
  
  public void updateGUI() {
    mouseHover = mouseX > origin.x && mouseX < origin.x + size.x
                && mouseY > origin.y && mouseY < origin.y + size.y;
  }
  
  public void draw() {
    pushStyle();
    pushMatrix();
    
    if(mouseHover) fill(HOVER_BUTTON_COLOR);
    else fill(BUTTON_COLOR);
    
    if(!selected) stroke(0);
    else stroke(SELECTED_COLOR);
    
    strokeWeight(SELECTED_STROKE_WEIGHT);
    
    rectMode(CORNER);
    rect(origin.x, origin.y, size.x, size.y);
       
    translate(origin.x, origin.y);   
   
    if(mouseHover) fill(HOVER_TEXT_COLOR);
    else fill(TEXT_COLOR);
    
    textSize(textSize);
    textAlign(LEFT);
    
    for(int i = 0; i < infos.length; i++) {
      float yPos = OFFSET.y + i * (size.y - OFFSET.y) / infos.length;
      text(infos[i], OFFSET.x, yPos, writable.x, writable.y);
    }
    
    if(isConnected) {
      image(IMG_CONNECTED, writable.x + OFFSET.x/2, OFFSET.y, textSize, textSize);
    } else {
      image(IMG_DISCONNECTED, writable.x + OFFSET.x/2, OFFSET.y, textSize, textSize);
    }
    
    if(warning) {
      image(IMG_WARNING, writable.x + OFFSET.x/2, OFFSET.y + (size.y - OFFSET.y) / infos.length, textSize, textSize);
    }
    
    popMatrix();
    popStyle();
  }
}
