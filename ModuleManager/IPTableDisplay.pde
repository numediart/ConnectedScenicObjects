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
 * A class to show all the matching between MAC and IP in a table.
 * @author : L. Vanden Bemden - Institut Numediart - UMONS
 */
class IPTableDisplay {
 private final color TABLE_COLOR = color(205, 120, 120);
 private final color TEXT_COLOR = color(64);
 private final PVector OFFSET = new PVector(10,10);
 
 private PVector origin, size;
 private int textSize;
 private String[][] infos;
 
 IPTableDisplay(PVector origin, PVector size) {
   this.origin = origin;
   this.size = size;
   
   infos = new String[1][2];
   infos[0][0] = "";
   infos[0][1] = "";
   
   pushStyle();
   textSize = 20;
   String text = "DD:DD:DD:DD:DD:DD -> 255.255.255.255:65535";
   boolean textFitsInRect;
   do {
     textSize(textSize);
     textFitsInRect = textWidth(text) < size.x - 2 * OFFSET.x;
      
     textSize--;
   } while(!textFitsInRect && textSize > 8);
   popStyle();
 }
 
 void setDisplay(String[][] newTable) {
   infos = newTable; 
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
   
   text("MAC ADDRESS", OFFSET.x, OFFSET.y/2);
   text(" -> IP ADDRESS : PORT", textWidth("DD:DD:DD:DD:DD:DD") + OFFSET.x, OFFSET.y/2);
   line(OFFSET.x, OFFSET.y + textSize, size.x - OFFSET.x, OFFSET.y + textSize);
   for(int i = 0; i < infos.length; i++) {
     textAlign(LEFT, TOP);
     text(infos[i][0], OFFSET.x, (i+2) * OFFSET.y + (i+1) * textSize);
     text(" -> " + infos[i][1], textWidth("DD:DD:DD:DD:DD:DD") + OFFSET.x, (i+2) * OFFSET.y + (i+1) * textSize);
   }
   popMatrix();
   popStyle();
 }
}
