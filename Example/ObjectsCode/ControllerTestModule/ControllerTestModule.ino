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


#define SERIAL_DEBUG

#include <WiFi.h>
#include "WifiCredentials.h"
#include <WiFiMulti.h>
#include <ConnectedScenicObject.h>


#define FASTLED_MAX_BRIGHTNESS 24
#define STATUS_LED_PIN 15

#define SW_0_PIN 17
#define SW_1_PIN 5
#define BUT_2_PIN 16
#define BUT_3_PIN 4

#define TOUCH_0_PIN 13
#define TOUCH_1_PIN 12
#define TOUCH_2_PIN 14
#define TOUCH_3_PIN 27

#define ANALOG_0_PIN 32
#define ANALOG_1_PIN 35

#define ROT_ENC_PIN_1 21
#define ROT_ENC_PIN_2 19
#define ROT_BUT_PIN 18


WiFiMulti WiFiMulti;
  
/************************************************************/
/*                OSC parameters                            */
/************************************************************/
String host; // will be set to broadcast when connected to local wifi network
const uint16_t hostPort = 9001; // port on wich we expect the master to be listening OSC
const uint16_t recvPort = 9000; // port to listen OSC on this module
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
    #ifdef SERIAL_DEBUG
    Serial.println(toTell);
    #endif
    delay(500);
    ESP.restart();
  }
}



/************************************************************/
/*                Program main functions                    */
/************************************************************/
void setup() {
  #ifdef SERIAL_DEBUG
  Serial.begin(115200);
  Serial.println(F("\nBoot..."));
  delay(20);
  Serial.println("Code version : " + String(CONNECTED_SCENIC_OBJECT_VERSION));
  delay(20);
  #endif
  // Init scenic object before calling setStatusLed!
  cso.init(STATUS_LED_PIN);
  host.reserve(16);

  // init statusLed
  FastLED.setBrightness(FASTLED_MAX_BRIGHTNESS);
  cso.setStatusLed(COLOR_BOOT);

  // init WiFi
  WiFi.onEvent(WiFiEvent);
  for(int i = 0; i < NB_WIFI_NETWORKS; i++) {
    #ifdef SERIAL_DEBUG
    Serial.printf("Add WiFi network (SSID : %s)\n", WIFI_SSIDS[i].c_str());
    #endif
    WiFiMulti.addAP(WIFI_SSIDS[i].c_str(), WIFI_PWDS[i].c_str());
  }
  int i = 0;
  while (WiFiMulti.run() != WL_CONNECTED) {
    #ifdef SERIAL_DEBUG
    Serial.print(".");
    #endif
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
  #ifdef SERIAL_DEBUG
  Serial.println(F("#########################"));
  Serial.println("connected to " + WiFi.SSID() + ", local IP : " + WiFi.localIP().toString() +
                    ", OSC host : " + host + ":" + String(hostPort));
  #endif

  cso.startOSC(recvPort);
  // set host (currently broadcast, will be updated to master's ip when receiving /who message from master)
  // and host port
  cso.setHost(host, hostPort);
  // add several devices
  // you should always check if addDevice returns an error
  ConnectedScenicObjectError err;
  // add some buttons
  err += cso.addDevice(DIGITAL_INPUT, new DigitalInputDevice(SW_0_PIN));
  err += cso.addDevice(DIGITAL_INPUT, new DigitalInputDevice(SW_1_PIN));
  err += cso.addDevice(DIGITAL_INPUT, new DigitalInputDevice(BUT_2_PIN));
  err += cso.addDevice(DIGITAL_INPUT, new DigitalInputDevice(BUT_3_PIN));
  // add touch inputs
  err += cso.addDevice(TOUCH_INPUT, new TouchInputDevice(TOUCH_0_PIN, 0.45, 5));
  err += cso.addDevice(TOUCH_INPUT, new TouchInputDevice(TOUCH_1_PIN, 0.45, 5));
  err += cso.addDevice(TOUCH_INPUT, new TouchInputDevice(TOUCH_2_PIN, 0.45, 5));
  err += cso.addDevice(TOUCH_INPUT, new TouchInputDevice(TOUCH_3_PIN, 0.45, 5));
  // add Analog inputs
  err += cso.addDevice(ANALOG_INPUT, new AnalogInputDevice(ANALOG_0_PIN, 0.01, 5));
  err += cso.addDevice(ANALOG_INPUT, new AnalogInputDevice(ANALOG_1_PIN, 0.01, 5));
  // add a rotary encoder
  err += cso.addDevice(ROTARY_ENCODER, new RotaryEncoderDevice(ROT_ENC_PIN_1, ROT_ENC_PIN_2, ROT_BUT_PIN));
  // if error occured when creating devices, set the status led orange for 5 seconds
  if(err.code) {
    #ifdef SERIAL_DEBUG
    Serial.println(err.message);
    #endif
    cso.setStatusLed(COLOR_WARNING);
    delay(5000);
  }

  cso.setStatusLed(COLOR_SETUP_OK);
  #ifdef SERIAL_DEBUG
  Serial.println(F("########   Setup OK   #########"));
  #endif 
}



void loop() {
  cso.update(); 
}
