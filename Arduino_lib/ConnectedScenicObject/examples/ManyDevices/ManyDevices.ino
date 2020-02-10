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


#include <FS.h>
#include <SPIFFS.h>
#include <WiFi.h>
#include <DNSServer.h>
#include <WebServer.h>
#include <WiFiMulti.h>
#include <ConnectedScenicObject.h>


#define FASTLED_MAX_BRIGHTNESS 24
#define STATUS_LED_PIN 16

const int NB_WIFI_NETWORKS = 2;
const String WIFI_SSIDS[]  = {"NUMEDIART_WAP", "C******"};
const String WIFI_PWDS[] = {"JSLNUMEDIARTROOMWIFI", "d******"};
WiFiMulti WiFiMulti;

/************************************************************/
/*                OSC parameters                            */
/************************************************************/
String host; // will be set to broadcast when connected to local wifi network
uint16_t hostPort = 9001; // port on wich we expect the master to be listening OSC
uint16_t recvPort = 9000; // port to listen OSC on this module
ConnectedScenicObject cso;




/************************************************************/
/*                  utilities functions                     */
/************************************************************/
void WiFiEvent(WiFiEvent_t event)
{
  String toTell = "";
  switch (event) {
      case SYSTEM_EVENT_STA_DISCONNECTED:
          toTell = "Disconnected from WiFi access point";
          cso.setStatusLed(COLOR_ERROR);
          break;
      case SYSTEM_EVENT_STA_LOST_IP:
          toTell = "Lost IP address and IP address is reset to 0";
          cso.setStatusLed(COLOR_ERROR);
          break;
      default:
        break;
  }
  if(toTell != "") {
    Serial.println(toTell);
    delay(500);
    ESP.restart();
  }
}



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

  // SPIFFS needed only to load calibration file
  // for accelerometer / gyroscope device (MPU6050)
  if(!SPIFFS.begin(true)){
     Serial.println("An Error has occurred while mounting SPIFFS");
     cso.setStatusLed(COLOR_WARNING);
     delay(2000);
  }

  // init WiFi
  WiFi.onEvent(WiFiEvent);
  for(int i = 0; i < NB_WIFI_NETWORKS; i++) {
    Serial.printf("Add WiFi network (SSID : %s)\n", WIFI_SSIDS[i].c_str());
    WiFiMulti.addAP(WIFI_SSIDS[i].c_str(), WIFI_PWDS[i].c_str());
  }
  int i = 0;
  while (WiFiMulti.run() != WL_CONNECTED) {
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
  err += cso.addDevice(DIGITAL_INPUT, new DigitalInputDevice(17));
  err += cso.addDevice(TOUCH_INPUT, new TouchInputDevice(4));
  err += cso.addDevice(ROTARY_ENCODER, new RotaryEncoderDevice(22, 21, 26));
  err += cso.addDevice(LED_STRIP, new LedStripDevice(27, 5));
  err += cso.addDevice(ACCEL_GYRO, new AccelGyroDevice(SPIFFS, "/mpu.calib", 19, 23));
  err += cso.addDevice(ANALOG_OUTPUT, new AnalogOutputDevice(25));
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
