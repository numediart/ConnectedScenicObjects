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


#ifndef CONNECTED_SCENIC_OBJECT_H
#define CONNECTED_SCENIC_OBJECT_H

#define CONNECTED_SCENIC_OBJECT_VERSION "0.1.0"

#if defined (ESP_PLATFORM) && not defined (ESP8266)
  #include "esp_system.h"
#endif
#include <ArduinoOSC.h>   
#define FASTLED_INTERNAL // Disable version number message in FastLED library (looks like an error)
#include <FastLED.h>     //https://github.com/FastLED/FastLED
#include <map>

#include "AvailableDevicePins.h"

#include "GenericDevice.h"
#include "DigitalInputDevice.h"
#include "AnalogInputDevice.h"
#include "TouchInputDevice.h"
#include "RotaryEncoderDevice.h"
#include "DigitalOutputDevice.h"
#include "PwmOutputDevice.h"
#include "AnalogOutputDevice.h"
#include "LedStripDevice.h"
#include "AccelGyroDevice.h"
#include "StatusLedDevice.h"


#define COLOR_BOOT            CRGB::Blue
#define COLOR_WIFI_CONNECTED  CRGB::Purple
#define COLOR_SETUP_OK        CRGB::White
#define COLOR_OSC_CONNECTED   CRGB::Chartreuse
#define COLOR_WARNING         CRGB::OrangeRed
#define COLOR_ERROR           CRGB::Red



typedef enum DeviceType {
  DIGITAL_INPUT,
  ANALOG_INPUT,
  TOUCH_INPUT,
  ROTARY_ENCODER,
  DIGITAL_OUTPUT,
  PWM_OUTPUT,
  ANALOG_OUTPUT,
  LED_STRIP,
  ACCEL_GYRO,
  STATUS_LED,
  NB_DEVICE_TYPES
} DeviceType;

struct ConnectedScenicObjectError {
  int code;
  String message;

  ConnectedScenicObjectError(int c = 0, String m = "");
  ConnectedScenicObjectError& operator+=(const ConnectedScenicObjectError& other){
      this->code |= other.code;
      if(other.code)
        this->message += other.message + "\n";
      return *this;
  }
};



class ConnectedScenicObject {
  protected:
    static std::multimap<DeviceType, GenericDevice*> _devices;
    static std::map<uint8_t, String> _pinUsed;

    static String _host;
    static int _hostPort;
    static OscWiFi _osc;

    static StatusLedDevice* _statusLed;
	
	static bool _sendIam;
	static bool _knockSent;
	static bool _connected;

    String checkPinAvailable(uint8_t pin);
  
  public:
    static String deviceTypeNames[NB_DEVICE_TYPES];
    static int deviceTypeMaxInstances[NB_DEVICE_TYPES];
  
    ConnectedScenicObject();
    void init(int statusLedPin = -1, int nbLedsToDeclare = 1);
    void startOSC(uint16_t listeningPort);
    ConnectedScenicObjectError addDevice(DeviceType type, GenericDevice* device);    
    void update();
	
	static bool isConnected() {return _connected;}

	static void sendMessage(OscMessage& m);
    static void setHost(const String& host, const int& hostPort);
    static void setStatusLed(const CRGB& color);
	static void processOSC(OscMessage& m) ;
    static void printMessage(OscMessage& m);
    static String getMacAddress();
};

#endif // CONNECTED_SCENIC_OBJECT_H
