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

import java.util.Iterator;

/* 
 * A class that extends IntDict to stay always sorted and store a proper name to the dict.
 * It also implements Comparable to match dict together.
 * There is then a particularly usefull method : includedIn that can say if the instance is a subDict of the argument
 * @author : L. Vanden Bemden - Institut Numediart - UMONS
 */
 
 
public class NamedSortedIntDict extends IntDict implements Comparable {  
  private String name;
  
  public NamedSortedIntDict(String name) {
    super();
    this.name = name;
  }
  
  public NamedSortedIntDict(String name, IntDict devices) {
    super();
    this.increment(devices);
    this.name = name;
    this.sortKeys();
  }
  
  public NamedSortedIntDict(JSONObject json) {
    name = json.getString("name");
    JSONObject json_entries = json.getJSONObject("dict");
    Iterator it = json_entries.keyIterator();
    while(it.hasNext()) {
      String keyDict = (String) it.next();
      this.set(keyDict, json_entries.getInt(keyDict));
    }
  }
  
  public void add(String key, int amount) {
    super.add(key, amount);
    this.sortKeys();
  }
  
  public String getName() {
    return name; 
  }
    
  /*
   * Return true if the current IntDict is included in the 'dict' argument
   * In other terms, all this.key() exists in argument and all corresponding values are lower than those in the argument
   */
  public boolean includedIn(IntDict dict) {
    if(dict == null) return false;
    for(int i = 0; i < this.size(); i++) {
      if(!dict.hasKey(this.key(i)) || this.value(i) > dict.get(this.key(i))) {
        return false;
      }
    }
    return true;
  }
  
  /*
   * Order by name, then by ordered items name (and then quantity)
   */
  public int compareTo(Object o) {
    NamedSortedIntDict t = (NamedSortedIntDict) o;
    
    int value = name.compareTo(t.getName());
    if(value != 0) return value;
    
    for(int i = 0; i < this.size() && i < t.size(); i++) {
      //Compare devices name
      value = this.key(i).compareTo(t.key(i));
      if(value != 0) return value;
      
      //Compare devices quantity
      value = this.value(i) - t.value(i);
      if(value != 0) return value;
    }
    //Finally compare additional devices
    return this.size() - t.size();
  }
  
  public boolean equals(Object o) {
    return compareTo(o) == 0; 
  }
  
  public String toString() {
    return name +": " + super.toJSON();
  }
  
  public String toJSON() {
     return "{ \"name\" : " + "\"" + name + "\", \"dict\": " + super.toJSON() + "}";
  }
  
  public NamedSortedIntDict copy() {
    return new NamedSortedIntDict(name, super.copy());
  }
}
