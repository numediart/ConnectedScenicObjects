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

 
class ArrayDisplay extends ArrayList<ObjectDisplayIF> {
  private final PVector OFFSET = new PVector(10, 10);
  public color BACKGROUND_COLOR = color(0);
  
  private PVector origin, objectSize, arraySize;
  private int objByDim, selected, textSize;
  private boolean isHorizontalDim, mouseHover, unselectable; 
    
  ArrayDisplay(PVector origin, int dim, int objByDim, float objectAspectRatio, boolean isHorizontalDim) {
    this.origin = origin;
    this.objByDim = objByDim;
    this.isHorizontalDim = isHorizontalDim;
    arraySize = new PVector(dim, 0);
    selected = -1;
    mouseHover = false;
    unselectable = false;
    textSize = -1;
    
    int xSize, ySize;
    if(isHorizontalDim) {
      xSize = (dim - (int) OFFSET.x) / objByDim - (int) OFFSET.x;
      ySize = (int) (xSize / objectAspectRatio);
      arraySize = new PVector(dim, 0);
    } else {
      ySize = (dim - (int) OFFSET.y) / objByDim - (int) OFFSET.y;
      xSize = (int) (ySize * objectAspectRatio);
      arraySize = new PVector(0, dim);
    }
    objectSize = new PVector(xSize, ySize);
    update();
    updateGUI();
  }
   
  void draw() {
    pushStyle();
    
    fill(BACKGROUND_COLOR);
    stroke(BACKGROUND_COLOR);
        
    rect(origin.x, origin.y, arraySize.x, arraySize.y);
    
    for(ObjectDisplayIF o : this) {
      o.draw();
    }
    
    popStyle();
  }
  
  void updateGUI() {
    mouseHover = mouseX > origin.x && mouseX < origin.x + arraySize.x
                && mouseY > origin.y && mouseY < origin.y + arraySize.y;
    for(ObjectDisplayIF o : this) {
      o.updateGUI();
    }
  }
  
  boolean add(ObjectDisplayIF obj) {
    add(size(), obj);
    return true;
  }
  
  void add(int index, ObjectDisplayIF obj) {
    super.add(index, obj);
    if(textSize != -1) {
      obj.setTextSize(textSize);
    }
    if(selected != -1) {
        select(-1);
    }
    update();
  }
  
  boolean remove(ObjectDisplayIF obj) {
    int index = indexOf(obj);
    if(index != -1) {
      remove(index);
      return true;
    }
    return false;
  }
  
  ObjectDisplayIF remove(int index) {
    ObjectDisplayIF value = super.remove(index);
    if(selected != -1) {
        select(-1);
    }
    update();
    return value;
  }
  
  void update() {
    for(int i = 0; i < size(); i++) {
      int wPos, hPos;
      if(isHorizontalDim) {
        wPos = i / objByDim;
        hPos = i % objByDim;
      } else {
        wPos = i % objByDim;
        hPos = i / objByDim;
      }
      int yPos = (int) origin.y + (int) OFFSET.y * (wPos+1) + (int) objectSize.y * wPos;
      int xPos = (int) origin.x + (int) OFFSET.x * (hPos+1) + (int) objectSize.x * hPos;
        
      PVector objectPos = new PVector(xPos, yPos);
      get(i).setBox(objectPos, objectSize);
      if(textSize != -1) {
        get(i).setTextSize(textSize);
      }
    }
    
    int objByOtherDim = size() / objByDim;
    if(size() % objByDim != 0) objByOtherDim++;
    if(isHorizontalDim) {
      arraySize.y = (int) (objByOtherDim * (objectSize.y + OFFSET.y) + OFFSET.y);
    } else {
      arraySize.x = (int) (objByOtherDim * (objectSize.x + OFFSET.x) + OFFSET.x);
    }
  }
  
  boolean mouseHover() {
    return mouseHover;
  }
  
  void setUnselect(boolean unselectable) {
    this.unselectable = unselectable;
  }
  
  void mousePressed() {
    for(int i = 0; i < size(); i++) {
      if(get(i).mouseHover()) {
        if(unselectable) {
          select(selected == i ? -1 : i); 
        } else {
          select(i);
        }
      }
    }
  }
  
  public float getVariableDim() {
    if(isHorizontalDim) {
      return arraySize.y;
    } else {
      return arraySize.x; 
    }
  }
  
  public void setTextSize(int textSize) {
    this.textSize = textSize;
    for(int i = 0; i < size(); i++) {
      get(i).setTextSize(textSize);
    }
  }
  
  void select(int i) {
    if(selected >= 0 && selected < size()) {
      get(selected).select(false);
    }
    selected = i;
    if(selected >= 0 && selected < size()) {
      get(selected).select(true);
    }
  }
  
  int getSelected() {
    return selected; 
  }
  
}
