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
 * A class to show button with a label. The button is clickable.
 * @author : L. Vanden Bemden - Institut Numédiart - UMONS
 */
 
class ButtonDisplay implements ObjectDisplayIF {
  
  public color BUTTON_COLOR = color(196);
  public color TEXT_COLOR = color(64);
  
  public color HOVER_BUTTON_COLOR = color(255);
  public color HOVER_TEXT_COLOR = color(0);
  
  public color SELECTED_COLOR = color(0);
  
  public int SELECTED_STROKE_WEIGHT = 3;
  
  private static final int MINIMUM_TEXT_SIZE = 8;
  
  private String label;
  private PVector origin, size;
  private boolean mouseHover, selected;
  private int textSize;

  public ButtonDisplay(String label, PVector origin, PVector size) {
    this.label = label;
    mouseHover = false;
    selected = false;
    textSize = 20;
    
    if(origin != null && size != null) setBox(origin, size);
  }
  
  public ButtonDisplay(String text) {
    this(text, null, null); 
  }
  
  /*
   * Move and resize the button based on arguments
   */
  public void setBox(PVector origin, PVector size) {
    this.origin = origin;
    this.size = size;
  }
  
  /*
   * This function set textSize to fit in the box vertically and horizontally 
   * with a minimum of MINIMUM_TEXT_SIZE as value
   */
  public void maximizeTextSize() {
    
    textSize = (int) (size.y - textAscent() - textDescent());
    textSize = textSize > MINIMUM_TEXT_SIZE ? textSize : MINIMUM_TEXT_SIZE;
    
    pushStyle();
    boolean textFitsInRect;
    do {
      textSize(textSize);
      textFitsInRect = textWidth(label) < size.x;
      
      textSize--;
    } while(!textFitsInRect && textSize > MINIMUM_TEXT_SIZE);
    popStyle();
  }
  
  public void select(boolean isSelected) {
    selected = isSelected;
  }
  
  public void setTextSize(int textSize) {
    this.textSize = textSize; 
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
    
    if(mouseHover) fill(HOVER_BUTTON_COLOR);
    else fill(BUTTON_COLOR);
    
    if(!selected) stroke(0);
    else stroke(SELECTED_COLOR);
    
    strokeWeight(SELECTED_STROKE_WEIGHT);
    
    rectMode(CORNER);
    rect(origin.x, origin.y, size.x, size.y);
    
    textAlign(CENTER, CENTER);
    textSize(textSize);
    
    if(mouseHover) fill(HOVER_TEXT_COLOR);
    else fill(TEXT_COLOR);
    text(label, origin.x + size.x / 2, origin.y + size.y / 2);
    
    popStyle();
  }
}
