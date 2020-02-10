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
 * A class to show the different panels and interact with them.
 * It allows the user to see the state of the objects, edit them or save the configurations.
 * @author : L. Vanden Bemden - Institut Numediart - UMONS
 */
 
 
class GUI {
  TypesList types;
  ConnectedObjectList objects;
  IPTable table;
  Manager manager;
  Scrollbar bar;
  ArrayDisplay commandsWindow, objectsWindow;
  IPTableDisplay ipWindow;
  EditDisplay editWindow;
  TypesDisplay typesWindow;
  boolean showIp, showEdit, showTypes, askUpdate;
  int menuHeight, barHeight;
  
  //Warning : adapt switch case in mousePressed !
  String[] commandsText = {"Scan network", "Show IpTable", "Show Types", "Blink object", "Edit object", "Remove object", "Save config"};
  
  GUI(IPTable table, ConnectedObjectList objects, TypesList types, int objByLine) {
    this.types = types;
    this.objects = objects;
    this.table = table;
    
    menuHeight = 50;
    commandsWindow = new ArrayDisplay(new PVector(0, 0), menuHeight, 1, 27.0/commandsText.length, false);
    for(String comText : commandsText) {
      commandsWindow.add(new ButtonDisplay(comText)); 
    }
    commandsWindow.setTextSize(12);
    
    objectsWindow = new ArrayDisplay(new PVector(0, 50), width-40, objByLine, 32/9.0, true);
    objectsWindow.setUnselect(true);
    for(int i = 0; i < objects.size(); i++) {
      objectsWindow.add(new ConnectedObjectDisplay());
    }
    
    ipWindow = new IPTableDisplay(new PVector(30, 100), new PVector(400, 200));
    editWindow = new EditDisplay(new PVector(50, 120), new PVector(700, 450), types);
    
    typesWindow = new TypesDisplay(new PVector(30, 100), new PVector(700, 400));
    
    barHeight = height - (menuHeight + 1);
    bar = new Scrollbar(width-20, menuHeight+1, 16, barHeight, 5, true); 
    
    showIp = false;
    showEdit = false;
    showTypes = false;
    askUpdate = false;
  }
  
  void setManager(Manager manager) {
    this.manager = manager;
    editWindow.setManager(manager);
  }
  
  void triggerUpdate() {
    askUpdate = true; 
  }
  
  void update() {
    updateObjects();
    updateIPTable();
    updateTypesTable();
  }
  
  void updateIPTable() {
    ipWindow.setDisplay(table.getTable()); 
  }
  
  void updateTypesTable() {
    typesWindow.setDisplay(split(types.toString(), "\n")); 
  }
  
  void updateObjects() {
    while(objectsWindow.size() > objects.size()) {
      objectsWindow.remove(objectsWindow.size() - 1);
    }
    while(objects.size() > objectsWindow.size()) {
      objectsWindow.add(new ConnectedObjectDisplay());
    }
    objectsWindow.update();
    for(int i = 0; i < objects.size(); i++) {
      ConnectedObject o = objects.get(i);
      ConnectedObjectDisplay objDisplay = (ConnectedObjectDisplay) objectsWindow.get(i);
      
      String typeName = o.getType() != null ? o.getType().getName() : "";
      objDisplay.setDisplay(typeName, o.getId(), o.getPorts().toString(), o.getMac(), table.contains(o.getMac()), o.hasErrors());
    }
  }
  
  void draw() {
    if(askUpdate) {
      update();
      askUpdate = false;
    }
    
    float objectsWindowOffset = bar.getPos() / barHeight * objectsWindow.getVariableDim();
    
    background(0);
    if(!showEdit) {
      commandsWindow.updateGUI();
    }
    if(!showEdit && !showIp && !showTypes) {
      mouseY -= (int) objectsWindowOffset;
      objectsWindow.updateGUI();
      mouseY += (int) objectsWindowOffset;
      bar.changeSlider((int) ((barHeight*barHeight) / objectsWindow.getVariableDim()));
      bar.update();
    }
    bar.draw();
    
    pushMatrix();
    translate(0, objectsWindowOffset);
    objectsWindow.draw();
    popMatrix();
    
    fill(commandsWindow.BACKGROUND_COLOR);
    rect(0,0,width, menuHeight+1);
    commandsWindow.draw();
    
    if(showIp) ipWindow.draw();
    if(showTypes) typesWindow.draw();
    if(showEdit) {
      editWindow.updateGUI();
      editWindow.draw();
    }
  }
  
  void keyPressed() {
   if(showEdit) {
     editWindow.keyPressed(); 
   }
  }
  
  void mousePressed() {
     if(mouseButton == LEFT) {
       
       if(showEdit && editWindow.mouseHover()) {
         editWindow.mousePressed();
         showEdit = !editWindow.isDone();
         if(!showEdit) {
           objectsWindow.select(-1); 
         }
       } else if(commandsWindow.mouseHover()) {
         commandsWindow.mousePressed();
         int val = objectsWindow.getSelected();
         switch(commandsWindow.getSelected()) {
            case 0: //Scan
              println("Scan network !");
              if(manager != null) {
                table.clear();
                manager.queryNetwork();
                triggerUpdate();
              }
              break;
            case 1: //IpTable
              showIp = !showIp;
              break;
            case 2: //Types
              showTypes = !showTypes;
              break;
            case 3: //Blink
              if(val != -1) {
                manager.blink(objects.get(val).getMac());
              }
              objectsWindow.select(-1);
              break;
            case 4: //Edit Window
              if(val != -1) {
                showEdit = true;
                editWindow.setDisplay(objects.get(val));
              }
              break;
            case 5: //Remove object
              if(val != -1) {
                if(manager != null) {
                  manager.deleteObject(objectsWindow.getSelected());
                }
              }
              break;
            case 6: //Save config
              println("Saved !");
              saveJSONArray(JSONArray.parse(objects.toJSON()), fileObjectsPath);
              break;
            default:
              break;
         }
     }
     else if(objectsWindow.mouseHover()) {
         objectsWindow.mousePressed();
     }
    }
  }
  
  void mouseWheel(MouseEvent event) {
    bar.mouseWheel(event); 
  }
}
