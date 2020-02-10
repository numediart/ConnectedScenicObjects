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


#include <WiFi.h>
#include <ConnectedScenicObject.h>


#define FASTLED_MAX_BRIGHTNESS 24
#define STATUS_LED_PIN 16


const char* ssid = "NUMEDIART_WAP";
const char* pwd = "JSLNUMEDIARTROOMWIFI";



/************************************************************/
/*                OSC parameters                            */
/************************************************************/
String host; // will be set to broadcast when connected to local wifi network
uint16_t hostPort = 9001; // port on wich we expect the master to be listening OSC
uint16_t recvPort = 9000; // port to listen OSC on this module
ConnectedScenicObject cso;



/************************************************************/
/*                Program main functions                    */
/************************************************************/
void setup() {
  Serial.begin(115200);
  Serial.println(F("\nBoot..."));
  delay(20);
  Serial.println("Code version : " + String(CONNECTED_SCENIC_OBJECT_VERSION));
  delay(20);
  // Init scenic object before calling setStatusLed!
  cso.init(STATUS_LED_PIN);
  host.reserve(16);

  // init statusLed
  FastLED.setBrightness(FASTLED_MAX_BRIGHTNESS);
  cso.setStatusLed(COLOR_BOOT);

  // init WiFi
  WiFi.begin(ssid, pwd);
  int i = 0;
  while (WiFi.status() != WL_CONNECTED) {
	  Serial.print(".");
	  delay(500);
	  i++;
	  if (i >= 20) {
		  ESP.restart();
	  }
  }
  //if you get here you have connected to the WiFi
  cso.setStatusLed(COLOR_WIFI_CONNECTED);
  delay(500);
  IPAddress myIp = WiFi.localIP();
  host = String(myIp[0]) + "." + String(myIp[1]) + "." + String(myIp[2]) + ".255";
  Serial.println(F("#########################"));
  Serial.println("connected to " + WiFi.SSID() + ", local IP : " + WiFi.localIP().toString() +
                    ", OSC host : " + host + ":" + String(hostPort));

  // begin to listen OSC
  cso.startOSC(recvPort);
  // set host (currently broadcast, will be updated to master's ip when receiving /who message from master)
  // and host port
  cso.setHost(host, hostPort);
  // add several devices
  // you should always check if addDevice returns an error
  ConnectedScenicObjectError err;
  err += cso.addDevice(DIGITAL_INPUT, new DigitalInputDevice(18));
  // if error occured when creating devices, set the status led orange for 5 seconds
  if(err.code) {
    Serial.println(err.message);
    cso.setStatusLed(COLOR_WARNING);
    delay(5000);
  }

  cso.setStatusLed(COLOR_SETUP_OK);
  Serial.println(F("########   Setup OK   #########"));
}



void loop() {
  cso.update(); 
}
