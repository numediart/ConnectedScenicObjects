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

import netP5.*;
import java.util.Collection;

/* 
 * A class keeping bindings between MAC addresses and IP addresses.
 * @author : L. Vanden Bemden - Institut Numediart - UMONS
 */
class IPTable {
  private HashMap<String, NetAddress> mac2ip;
  private HashMap<String, String> ip2mac;
  
  IPTable() {
    mac2ip = new HashMap<String, NetAddress>();
    ip2mac = new HashMap<String, String>();
  }
  
  void clear() {
    mac2ip.clear();
    ip2mac.clear();
  }
  
  String getMac(NetAddress ip) {
    return ip2mac.get(ip.toString());
  }
  
  NetAddress getIp(String mac) {
    return mac2ip.get(mac);
  }
  
  boolean contains(NetAddress ip) {
     return ip2mac.containsKey(ip.toString());
  }
  
  boolean contains(String mac) {
    return mac2ip.containsKey(mac); 
  }
  
  void add(String mac, NetAddress ip) {
    //Entry already exists
    if(getIp(mac) != null && getIp(mac).toString().equals(ip.toString())) return;
    
    //Remove potentially old entry
    remove(mac);
    
    //Add new ones
    mac2ip.put(mac, ip);
    ip2mac.put(ip.toString(), mac);
  }
  
  void remove(String mac) {
    NetAddress ip = mac2ip.get(mac);
    if(ip == null) return;
    
    mac2ip.remove(mac);
    ip2mac.remove(ip.toString());
  }
  
  String[][] getTable() {
     String[][] table = new String[ip2mac.size()][2];
     Collection<String> macs = ip2mac.values();
     int i = 0;
     for(String mac : macs) {
       table[i][0] = mac;
       table[i][1] = getIp(mac).toString();
       i++;
     }
     return table;
  }
}
