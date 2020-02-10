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
 * A class representing a real connected object.
 * @author : L. Vanden Bemden - Institut Numédiart - UMONS
 */
 
 
class ConnectedObject implements Comparable {
  private final static int DEFAULT_ID = -1;
  
  private String mac;
  private int id;
  private NamedSortedIntDict type;
  private IntDict hardware;
  private SortedIntList ports;
  
  public ConnectedObject(String mac, IntDict hardware) {
   this.mac = mac;
   this.id = DEFAULT_ID;
   this.hardware = hardware;
   this.type = null;
   this.ports = new SortedIntList();
  }
  
  public ConnectedObject(JSONObject json, TypesList types) {
    this.mac = json.getString("mac");
    this.id = json.getInt("id");    
    this.hardware = parseJSONHardware(json.getJSONObject("hardware"));
    
    String typeName = json.getString("type");
    NamedSortedIntDict t = types.get(typeName);
    if(t == null) {
      System.err.println("Error Missing type : " + typeName);
      t = new NamedSortedIntDict(typeName);
    }
    this.type = t;
    
    this.ports = new SortedIntList(json.getJSONArray("ports").getIntArray());
  }
  
  private IntDict parseJSONHardware(JSONObject json) {
    IntDict dict = new IntDict();
    Iterator it = json.keyIterator();
    while(it.hasNext()) {
      String keyDict = (String) it.next();
      dict.set(keyDict, json.getInt(keyDict));
    }
    return dict;
  }
  
  /* SETTERS */
  public void setId(int id) {
   this.id = id; 
  }
  
  public void setType(NamedSortedIntDict type) {
   this.type = type; 
  }
  
  public void setPorts(int[] portsList) {
    ports = new SortedIntList(portsList);
  }
  
  public void setDefaultConfig() {
    type = null;
    id = DEFAULT_ID;
    ports.clear();
  }  
  /* END OF SETTERS */
  
  /* GETTERS */
  public String getMac() {
    return mac; 
  }
  
  public int getId() {
   return id; 
  }
  
  public NamedSortedIntDict getType() {
    return type; 
  }
  
  public IntDict getHardware() {
    return hardware; 
  }
    
  public SortedIntList getPorts() {
    return ports.copy();
  }
  /* END OF GETTERS */
       
  //Return true if the type of this object can be set to 't'
  public boolean hasCompatibleHardware(NamedSortedIntDict t) {
    return t.includedIn(hardware); 
  }
  
  public boolean hasErrors() {
    return type == null || id == DEFAULT_ID || !hasCompatibleHardware(type);
  }
  
  /* COMPARABLE */
  public int compareTo(Object o) {
    ConnectedObject obj = (ConnectedObject) o;
    
    //Order by Type name
    String typeName = (type != null) ? type.getName() : "";
    String obj_typeName = (obj.getType() != null) ? obj.getType().getName() : "";
    int answer = typeName.compareTo(obj_typeName);
    
    // ! Special case : Put unset typename at the end
    if(typeName == "" || obj_typeName == "") {
      answer = - answer;
    }
    
    if(answer != 0) {
      return answer;
    }
    
    //If names are equal, order by Id
    return id - obj.getId();    
  }
  
  public boolean equals(Object o) {
    return compareTo(o) == 0; 
  }
  
  /*
   * Return true if 'h' is strictly equals to the current hardware
   */
  public boolean equalsHardware(IntDict h) {
    this.hardware.sortKeys();
    h.sortKeys();
    
    if(h.size() != this.hardware.size()) return false;
    
    for(String keyValue : h.keyArray()) {
      if(h.get(keyValue) != this.hardware.get(keyValue)) return false;
    }
    
    return true;
  }  
  
  /* PRINT */
  public String toString() {
    String strPorts = "";
    for(int i = 0; i < ports.size(); i++) {
      strPorts += ports.get(i) + ",";
    }
    if(ports.size() > 0) {
      strPorts = strPorts.substring(0, strPorts.length() - 1);
    }
    String typeName = type == null ? "" : type.getName();
    return mac + "; " + typeName + "; " + id + "; " + strPorts;
  }
  
  public String toJSON() {
    JSONObject elem = new JSONObject();
     
    elem.setString("mac", mac);
    elem.setInt("id", id);
     
    String typeName = (type != null) ? type.getName() : "";
    elem.setString("type", typeName);
    
    elem.setJSONArray("ports", JSONArray.parse(ports.toJSON()));
    elem.setJSONObject("hardware", JSONObject.parse(hardware.toJSON()));
    
    return elem.toString();
  }
}
