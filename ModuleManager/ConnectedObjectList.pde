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

/* 
 * A class extending ArrayList for connected objects.
 * @author : L. Vanden Bemden - Institut Numédiart - UMONS
 */
 
 
class ConnectedObjectList extends ArrayList<ConnectedObject> {
 
  public ConnectedObjectList() {
    super();
  }
  
  public ConnectedObjectList(JSONArray json, TypesList types) {
    for(int i = 0; i < json.size(); i++) {
     add(new ConnectedObject(json.getJSONObject(i), types));
    }
    Collections.sort(this);
  }
  
  /* GETTERS */
  public ConnectedObject getByMac(String mac) {
    for(int i=0; i < size(); i++) {
      if(get(i).getMac().equals(mac)) {
        return get(i);
      }
    }
    return null;
  }
  
  public ConnectedObject getByTypeId(String typeName, int id) {
    for(int i=0; i < size(); i++) {
      NamedSortedIntDict t = get(i).getType();
      if(t != null && t.getName().equals(typeName) && get(i).getId() == id) {
        return get(i);
      }
    }
    return null;
  }
  /* END OF GETTERS */
  
  public boolean add(ConnectedObject o) {
    boolean result = super.add(o);
    Collections.sort(this);
    return result;
  }
  
  public void add(int index, ConnectedObject o) {
    super.add(index, o);
    Collections.sort(this);
  }
  
  public void sort() {
    Collections.sort(this); 
  }
  
  /* PRINT */
  public String toString() {
    String print = "";
    for(int i=0; i < super.size(); i++) {
       print += super.get(i).toString() + "\n";
    }
    return print.substring(0, print.length() - 1);
  }
  
  public String toJSON() {
    JSONArray json = new JSONArray();
    for(int i = 0; i < size(); i++) {
      JSONObject elem = JSONObject.parse(get(i).toJSON());
      json.append(elem);
    }
    return json.toString();
  }
}
