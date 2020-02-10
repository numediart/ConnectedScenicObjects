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


class SortedIntList extends IntList{
  
  public SortedIntList() {
    super();
  }
  
  public SortedIntList(int[] array) {
    super(array);
    this.sort();
  }
  
  public void append(int value) {
    super.append(value);
    this.sort();
  }
  
  public void append(int[] values) {
    super.append(values);
    this.sort();
  }
  
  public void append(IntList values) {
    super.append(values);
    this.sort();
  }
  
  public void append(SortedIntList values) {
    super.append(values);
    this.sort();
  }
  
  public int find(int value) {
    if(!this.hasValue(value)) {
     return -1; 
    }
    
    this.sort();
    int minIndex = 0;
    int maxIndex = this.size();
    while(maxIndex != minIndex) {
      int middle = (minIndex + maxIndex)/2;
      if(this.get(middle) < value) {
        minIndex = middle + 1; 
      } else {
        maxIndex = middle;
      }
    }
    
    return minIndex;
  }
  
  public String toString() {
    String p = "";
    for(int i = 0; i < this.size(); i++) {
      p += this.get(i) + ", ";
    }
    if(p.length() >= 2) {
      p = p.substring(0, p.length() -2);
    }
    return p;
  }
  
  public SortedIntList copy() {
    return new SortedIntList(this.array()); 
  }
}
