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
 
 
interface ObjectDisplayIF {
  
  /*
   * Move and resize the button based on arguments
   */
  public void setBox(PVector origin, PVector size);
  
  public void draw();
  
  /*
   * Return true if mouse in the box
   */
  public boolean mouseHover();
  
  /*
   * Update the button as selected or not
   */
  public void select(boolean isSelected);
  
  /*
   * Update variables and display that are based on user interactions (like mouse) 
   */
  public void updateGUI();
  
  /*
   * Set all the texts of the object to textSize
   */
  public void setTextSize(int textSize);
  
}
