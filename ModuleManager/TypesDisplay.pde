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
 
 
class TypesDisplay {
 private final color TABLE_COLOR = color(205, 120, 120);
 private final color TEXT_COLOR = color(64);
 private final PVector OFFSET = new PVector(10,10);
 
 private PVector origin, size;
 private int textSize;
 private String[] infos;
 
 TypesDisplay(PVector origin, PVector size) {
   this.origin = origin;
   this.size = size;
   
   infos = new String[1];
   infos[0] = "";
   
   textSize = 14;
 }
 
 void setDisplay(String[] table) {
   infos = table; 
 }
 
 void draw() {   
   pushStyle();
   pushMatrix();
   fill(TABLE_COLOR);
   rect(origin.x, origin.y, size.x, OFFSET.y + (1 + infos.length) * (textSize + OFFSET.y));
   
   textSize(textSize);
   textAlign(LEFT, TOP);
   fill(TEXT_COLOR);
   translate(origin.x, origin.y);
   
   text("NAME - DEVICES (Quantity)", OFFSET.x, OFFSET.y/2);
   line(OFFSET.x, OFFSET.y + textSize, size.x - OFFSET.x, OFFSET.y + textSize);
   for(int i = 0; i < infos.length; i++) {
     textAlign(LEFT, TOP);
     text(infos[i], OFFSET.x, (i+2) * OFFSET.y + (i+1) * textSize, size.x - 2*OFFSET.x, textSize + OFFSET.y);
   }
   popMatrix();
   popStyle();
 }
}
