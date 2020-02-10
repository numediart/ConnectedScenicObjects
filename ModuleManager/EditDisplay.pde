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
 * A class to show the edit panel.
 * It allows the user to edit the configuration for each object and send this back to the manager.
 * @author : L. Vanden Bemden - Institut Numediart - UMONS
 */
 
 
class EditDisplay {
  private final color TABLE_COLOR = color(205, 120, 120);
  private final color TEXT_COLOR = color(64);
  private final color HINT_COLOR = color(255);
  private final color ERROR_COLOR = color(105, 0, 0);
  private final PVector OFFSET = new PVector(10,10);
  
  private PVector origin, size;
  private int textSize;
  private boolean mouseHover, editing, isError, showTypes;
  private Manager manager;
  private String temp, hint;

  private ArrayDisplay confirmButtons, editButtons, typesButtons;
  private float widthEditButtons, heightEditButtons, widthTypeButtons;
  
  private String[] confirmText = {"Confirm", "Cancel"};
  private String[] editText = {"Type", "ID", "Ports"};
  private String[] hintText = {"Hint: Click on the type you want to select.", "Hint: Enter ID number then press ENTER.", 
    "Hint: Enter a port number followed by ENTER. If the port is already in the list, it will be removed."};
  private String[] errorText = {"Error: Object isn't fully configured.", "Error: Type isn't compatible with hardware.", 
    "Error: ID already exists with current type.", "Error: Some ports are already used for listening and sending messages to objects."};
  
  private String typeName, mac;
  private SortedIntList ports;
  private int id;
  
  private TypesList availableTypes, types;
  private IntDict hardware;
  
  EditDisplay(PVector origin, PVector size, TypesList types) {
    this.origin = origin;
    this.size = size;
    textSize = 20;
    mouseHover = false;
    hint = "";
    isError = false;
    showTypes = false;
    this.types = types;
    
    // Set confirmation buttons
    int heightConfirmButtons = 50;
    confirmButtons = new ArrayDisplay(new PVector(origin.x + 10, origin.y + size.y - 60), heightConfirmButtons, 1, 6.0, false);
    confirmButtons.BACKGROUND_COLOR = TABLE_COLOR;
    for(String comText : confirmText) {
      confirmButtons.add(new ButtonDisplay(comText)); 
    }
    
    // Set edit buttons
    widthEditButtons = 125.0;
    heightEditButtons = 50.0;
    editButtons = new ArrayDisplay(new PVector(origin.x + 10, origin.y + 40), (int) widthEditButtons, 1, (widthEditButtons - 20)/heightEditButtons, true);
    editButtons.setUnselect(true);
    editButtons.BACKGROUND_COLOR = TABLE_COLOR;
    for(String editLabel : editText) {
      ButtonDisplay button = new ButtonDisplay(editLabel);
      button.SELECTED_COLOR = color(0, 255, 0);
      editButtons.add(button); 
    }
    editButtons.setTextSize(18);
    
    // Set additional types panel
    widthTypeButtons = 150.0;
    float heightTypeButtons = (size.y - 2 * OFFSET.y - heightConfirmButtons) / types.size();
    heightTypeButtons = heightTypeButtons >= heightEditButtons ? heightEditButtons : heightTypeButtons;
    typesButtons = new ArrayDisplay(new PVector(origin.x + size.x - widthTypeButtons, origin.y + 40), (int) widthTypeButtons, 1, (widthTypeButtons - 20)/heightTypeButtons, true);
    typesButtons.BACKGROUND_COLOR = color(255);
    typesButtons.setTextSize(18);
           
    clearWindow();
 }
 
 void setDisplay(ConnectedObject object) {
   if(object == null) return;
   
   typeName = object.getType() != null ? object.getType().getName() : "";
   id = object.getId();
   ports = object.getPorts();
   mac = object.getMac();
   hardware = object.getHardware();
   editing = true;
   availableTypes = types.getAllIncludedIn(hardware);
   typesButtons.clear();
   for(NamedSortedIntDict t : availableTypes) {
     ObjectDisplayIF obj = new ButtonDisplay(t.getName());
     typesButtons.add(obj);
   }
   typesButtons.update();
 }
 
 void setManager(Manager manager) {
    this.manager = manager;
  }
 
 void clearWindow() {
   typeName = "";
   id = -1;
   ports = null;
   mac = "";
   temp = "";
   editing = false;
   isError = false;
   showTypes = false;
   editButtons.select(-1);
   availableTypes = null;
   typesButtons.clear();
   typesButtons.update();
 }
 
 boolean isDone() {
   return !editing; 
 }
 
 void setErrorMessage(String text) {
   hint = text;
   isError = true;
 }
 
 void draw() {
   pushStyle();
   pushMatrix();
   fill(TABLE_COLOR);
   stroke(255);
   strokeWeight(3);
   rect(origin.x, origin.y, size.x, size.y);   
   
   textSize(textSize);
   textAlign(LEFT, CENTER);
   fill(TEXT_COLOR);
   translate(origin.x, origin.y);
   
   text("Editing object with mac address '" + mac + "' ...", OFFSET.x, OFFSET.y + 10);
   text(typeName, OFFSET.x + widthEditButtons, (heightEditButtons + OFFSET.y) + OFFSET.y);
   text(id, OFFSET.x + widthEditButtons, 2 * (heightEditButtons + OFFSET.y) + OFFSET.y);
   text(ports.toString(), OFFSET.x + widthEditButtons, 3*(heightEditButtons + OFFSET.y) + OFFSET.y);
   
   textAlign(LEFT, TOP);
   String hwStr = "Hardware: ";
   for(String keyValue : hardware.keyArray()) {
      hwStr += keyValue + " (" + hardware.get(keyValue) + "), ";
   }
   hwStr = hwStr.substring(0, hwStr.length()-2);
   text(hwStr, 2 * OFFSET.x, 4*(heightEditButtons + OFFSET.y), size.x - widthTypeButtons - 4 * OFFSET.x, heightEditButtons + OFFSET.y);
   if(isError) {
     fill(ERROR_COLOR);
   } else {
     fill(HINT_COLOR); 
   }
   text(hint, 2 * OFFSET.x, 5*(heightEditButtons + OFFSET.y) + OFFSET.y, size.x - widthTypeButtons - 4 * OFFSET.x, heightEditButtons + OFFSET.y);
      
   popMatrix();
   popStyle();
   if(showTypes) {
     typesButtons.draw();
   }
   
   editButtons.draw();
   confirmButtons.draw();
 }
 
 boolean mouseHover() {
   return mouseHover;
 }
 
 void updateGUI() {
   mouseHover = mouseX > origin.x && mouseX < origin.x + size.x
                && mouseY > origin.y && mouseY < origin.y + size.y;
   confirmButtons.updateGUI();
   editButtons.updateGUI();
   if(showTypes) {
     typesButtons.updateGUI();
   }
 }
 
 void mousePressed() {
   if(showTypes && typesButtons.mouseHover()) {
      typesButtons.mousePressed();
      int result = typesButtons.getSelected();
      if(result != -1) {
        typeName = availableTypes.get(result).getName();
        showTypes = false;
        typesButtons.select(-1);
        editButtons.select(-1);
      }
   }
   else if(editButtons.mouseHover()) {
     int previous = editButtons.getSelected();
     editButtons.mousePressed();
     int current = editButtons.getSelected();
     if(previous != current) {
       temp = ""; 
     }
     hint = current != -1 ? hintText[current] : "";
     isError = false;
     //Type :
     if(current == 0) {
       showTypes = true;
     } else {
       showTypes = false; 
     }
   }
   else if(confirmButtons.mouseHover()) {
     confirmButtons.mousePressed();
     int button = confirmButtons.getSelected();
     switch(button) {
       case 0:
         int result = manager.configureObject(mac, typeName, id, ports);
         if(result == 0) {
           clearWindow();
         } else {
            int error = -result - 1;
            if(error < errorText.length && error >= 0) {
              hint = errorText[error];
            } else {
              hint = "Error Code: " + result;
            }
            isError = true;
         }
         break;
       case 1:
         clearWindow();
         break;
       default:
         break;
     }
   }
 }
 void keyPressed() {
   if(editButtons.getSelected() == -1) return;
   if(key == ENTER) {
     //println(temp);
     store();
   } else if (keyCode >= 96 && keyCode <= 105) { //Numbers
     //println(keyCode);
     temp += key;
   } else {
     //println("nop");
   }
 }
 
 void store() {
   int val = editButtons.getSelected();
   switch(val) {
     case 0: //Type
       //Nothing : clickable buttons
     break;
     case 1: //ID
       id = Integer.parseInt(temp);
     break;
     case 2: //Ports
       int tempPort = Integer.parseInt(temp);
       int index = ports.find(tempPort);
       if(index == -1) {
         ports.append(tempPort); 
       } else {
         ports.remove(index);
       }
       ports.sort();
     break;
     default:
     break;
   }
   temp = "";
   editButtons.select(-1);
 }
}
