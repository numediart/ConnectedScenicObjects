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


import java.util.Collections;

 
public class TypesList extends ArrayList<NamedSortedIntDict>{ 
  
  public TypesList() {
    super();
  }
  
  public TypesList(JSONArray json) {
    for(int i = 0; i < json.size(); i++) {
      JSONObject elem = json.getJSONObject(i);
      NamedSortedIntDict dict = new NamedSortedIntDict(elem);
      add(dict);
    }
    Collections.sort(this);
  }
  
  public boolean add(NamedSortedIntDict d) {
    boolean result = super.add(d);
    Collections.sort(this);
    return result;
  }
  
  public void add(int index, NamedSortedIntDict d) {
    super.add(index, d);
    Collections.sort(this);
  }
    
  public NamedSortedIntDict get(String name) {
    Collections.sort(this);
    for(int i = 0; i < size(); i++) {
      if(get(i).name.equals(name)) return get(i);
    }
    return null;
  }
    
  /*
   * Return a new list containing only elements that are included in 'dict'.
   * In other terms, the new list contains only the subDicts of 'dict'.
   */
  public TypesList getAllIncludedIn(IntDict dict) {
    TypesList list = new TypesList();
    for(int i = 0; i < this.size(); i++) {
      if(this.get(i).includedIn(dict)) {
        list.add(this.get(i));
      }
    }
    
    return list;    
  }
  
  public String toString() {
    String text = "";
    for(int i = 0; i < this.size(); i++) {
      text += get(i).toString() + "\n";
    }
    text = text.substring(0, text.length()-1);
    return text;
  }
  
  public String toJSON() {
    JSONArray json = new JSONArray();
    for(int i = 0; i < size(); i++) {
      JSONObject elem = JSONObject.parse(this.get(i).toJSON());
      json.append(elem);
    }
    return json.toString();
  }
  
}
