# ConnectedScenicObject - Object code

## Supported Platform
This library is tested for ESP32 platform only. Please install ESP32 support for Arduino IDE 1.8.5 (or above) by following the instructions on the [official page](https://github.com/espressif/arduino-esp32).

It is assumed that you have [already installed](../Readme.md) *ConnectedScenicObject* and third party libraries.


## Devices
Here are presented the type of devices you can instantiate with the library. You can also create your own by inheriting
from one of those presented here or directly from *GenericDevice*.

Some basic pin checking is performed at device declaration and errors can be reported 
in the *ConnectedScenicObjectError* returned by the *addDevice* function. Print the error to the Serial port 
to have hints on what's wrong with your wiring.
however, before connecting any device, we strongly advise to refer to 
the [ESP32 pinout reference](https://randomnerdtutorials.com/esp32-pinout-reference-gpios/) 
to avoid wiring to a non-compatible pin.

### DigitalInputDevice
Limited to 16 on a single object

Examples of physical devices you can connect to :
- Push button
- Switch / limit switch
- Relay
- Magnetic switch
- Interrupt pin on another chip

Constructor :
```
DigitalInputDevice(uint8_t pin, int mode = INPUT_PULLUP, uint16_t filterSize = 15, uint32_t longPressTime = 1000);
```

- `pin` is the physical pin for the input. All available pins are suitable for Digital input
- `mode` can be INPUT_PULLUP to use the internal pull-up resistor (default) or only INPUT if you plan to wire
a pull-down resitor yourself
- `filterSize` is the size (in number of samples) of the running median filter
- `longPressTime` is the time in milliseconds before incrementing the counter and sending 
the OSC message with the new value

Declaration and adding it to a ConnectedScenicObject : 
```cpp
ConnectedScenicObjectError err;
err += cso.addDevice(DIGITAL_INPUT, new DigitalInputDevice(5));
```

### AnalogInputDevice
Limited to 6 on a single object

Examples of physical devices you can connect to :
- Potentiometer
- SoftPot
- Contrain Gauge

Constructor :
```
AnalogInputDevice(uint8_t pin, float threshold = 0.005, uint16_t filterSize = 15);
```

- `pin` must be between 32 and 39 included
- `threshold` is the min delta value to reach before sending OSC message to avoid jittering
- `filterSize` is the size (in number of samples) of the running median filter

Declaration and adding it to a ConnectedScenicObject : 
```cpp
ConnectedScenicObjectError err;
err += cso.addDevice(ANALOG_INPUT, new AnalogInputDevice(ANALOG_0_PIN, 0.01, 5));
```

### TouchInputDevice
Limited to 10 on a single object

This type of input require only a wire and will change state when the wire is touched by someone.

Constructor :
```
TouchInputDevice(uint8_t pin, float threshold = 0.4, uint16_t filterSize = 15);
```

- `pin` is the physical pin for the input. Must be one of the Touch input compatible pins. 
- `threshold` is the value above which the touch input is considered active
- `filterSize` is the size (in number of samples) of the running median filter

Declaration and adding it to a ConnectedScenicObject : 
```cpp
ConnectedScenicObjectError err;
err += cso.addDevice(TOUCH_INPUT, new TouchInputDevice(TOUCH_0_PIN, 0.45, 5));
```

### RotaryEncoderDevice
Limited to 4 on a single object

This type of device is intended to read rotary encoders inputs

![Rotary Encoders](https://i1.wp.com/www.how2electronics.com/wp-content/uploads/2019/03/Rotary-Encoder.png?ssl=1)

*Rotary encoders wiring, image from [this great tutorial](https://www.how2electronics.com/construction-working-rotary-encoder/)*

Constructor :
```
RotaryEncoderDevice(uint8_t pinA, uint8_t pinB, uint8_t pinButton, int mode = INPUT_PULLUP);
```

- `pinA` and `pinB` are connected to OutA and OutB on the rotary encoder 
- `pinButton` is connected to Switch pin on the rotary encoder
- `mode` can be INPUT_PULLUP to use the internal pull-up resistor (default) or only INPUT if you plan to wire
a pull-down resitor yourself or using a module already wired this way

Declaration and adding it to a ConnectedScenicObject : 
```cpp
ConnectedScenicObjectError err;
err += cso.addDevice(ROTARY_ENCODER, new RotaryEncoderDevice(ROT_ENC_PIN_1, ROT_ENC_PIN_2, ROT_BUT_PIN));
```

### DigitalOutputDevice
Limited to 16 on a single object

Examples of physical devices you can connect to :
- Relay
- LED
- Enable input on DC motor driver

Constructor :
```
DigitalOutputDevice(uint8_t pin, int startState = LOW);
```

- `pin` is the physical pin for the output. All available pins are suitable for Digital output
- `startState` can be either LOW or HIGH. It is the initial state of the output when instancing the device.

Declaration and adding it to a ConnectedScenicObject : 
```cpp
ConnectedScenicObjectError err;
err += cso.addDevice(DIGITAL_OUTPUT, new DigitalOutputDevice(5));
```


### PwmOutputDevice
Limited to 8 on a single object

Examples of physical devices you can connect to :
- DC motor driver
- LED

Constructor :
```
PwmOutputDevice(uint8_t pin, uint32_t freq, uint32_t initVal = 0);
```

- `pin` is the physical pin for the output. All available pins are suitable for PWM output
- `freq` is given in Hertz and must be set between 10 and 40 000 000 (stability issues have been noticed above 300 000 Hz)
- `initVal` must be set between 0 (default) and 1023

Declaration and adding it to a ConnectedScenicObject : 
```cpp
ConnectedScenicObjectError err;
err += cso.addDevice(PWM_OUTPUT, new PwmOutputDevice(12, 4000));
```


### AnalogOutputDevice
Limited to 2 on a single object

DAC output of the ESP32. It can output stable voltage output or waveforms limited to some tens of Hz. 
Doesn't get along with LedStripDevice.

Constructor :
```
AnalogOutputDevice(uint8_t pin, uint8_t initVal = 0);
```

- `pin` must be 25 or 26
- `initVal` is the initial value to apply to the DAC (0 to 255)

Declaration and adding it to a ConnectedScenicObject : 
```cpp
ConnectedScenicObjectError err;
err += cso.addDevice(ANALOG_OUTPUT, new AnalogOutputDevice(25));
```

### LedStripDevice
Limited to 8 on a single object

Drives a WS2812B led strip. The type of drivable LED can be changed in LedStripDevice.h, all types supported by FastLED library can be used. StatusLedDevice inherits from LedStripDevice with nbLeds set to 1 by default.
Doesn't get along with AnalogOutputDevice.

Constructor :
```
LedStripDevice(uint8_t pin, int nbLeds);
```

- `pin` is the physical pin for the data signal. Available pins are [0, 1, 2, 3, 4, 5, 12, 13, 14, 15, 16, 17, 18, 19, 21, 22, 23, 25, 26, 27, 32, 33]
- `nbLeds` is the length of the strip (e.g. the number of leds to drive)

Declaration and adding it to a ConnectedScenicObject : 
```cpp
cso.init(STATUS_LED_PIN, LED_STRIP_LENGTH); // needed if using 3 or more LedStripDevice

ConnectedScenicObjectError err;
err += cso.addDevice(LED_STRIP, new LedStripDevice(LED_STRIP_PIN, LED_STRIP_LENGTH));
```

*NOTE 1: based on our experience, it appears that if you are using 3 or more strips, all the LedStripDevice must be declared with the same lenght. This includes the StatusLedDevice as shown in the code above*

*NOTE 2: FastLED.setBrightness(FASTLED_MAX_BRIGHTNESS) will affect all the LedStripDevice, including the StatusLedDevice*

### AccelGyroDevice
Limited to 1 on a single object

The only chip supported is MPU6050 but any sensor communicating through I²C might be usable by creating your own
device class. See the [i2cdevlib for Arduino](https://github.com/jrowberg/i2cdevlib/tree/master/Arduino) for a list
of potentially supported chips.

Constructor :
```
AccelGyroDevice(fs::FS &fs, 
                      const char* calibFilePath, 
                      int pinSDA = -1, 
                      int pinSCL = -1, 
                      uint32_t readPeriodMs = 20, 
                      int filterSize = 3);
```

- `fs` is the filesystem in which the calibration file is stored, generaly SPIFFS
- `calibFilePath` is the name of the file containing the calibration data in text format (see below)
- `pinSDA` and `pinSCL` are pins used for I²C connection
- `readPeriodMs` is the data refresh tempo in milliseconds
- `filterSize` is the size (in number of samples) of the running average filter

Declaration and adding it to a ConnectedScenicObject : 
```cpp
ConnectedScenicObjectError err;
err += cso.addDevice(ACCEL_GYRO, new AccelGyroDevice(SPIFFS, "/mpu.calib", 19, 23));
```

#### Calibration file

This device will need to open a calibration file from SPIFFS. This file contains this type of data :
```
# ax	ay		az	gx		gy	gz
-1934	114	1220	12	3	-7
```
Lines starting with '#' are ignored. The device will try to load 6 int values from a single line. 
These values correspond to accelerometer and gyroscope offsets. They can be obtained with 
the [IMU_Zero](https://github.com/jrowberg/i2cdevlib/blob/master/Arduino/MPU6050/examples/IMU_Zero/IMU_Zero.ino) sketch.

To upload the calibration file to SPIFFS, you will need 
to install [the ESP32 filesystem uploader](https://github.com/me-no-dev/arduino-esp32fs-plugin) 
and to put your calibration file in a "data" folder next to your sketch. Then, go to Arduino IDE, 
click on *Tools* and *ESP32 Sketch Data Upload*.


## Usage

Please see examples for details.

### Two buttons example

```cpp
#include <WiFi.h>
#include <ConnectedScenicObject.h>

#define STATUS_LED_PIN 4

ConnectedScenicObject cso;
const uint16_t hostPort = 9001; // port on wich we expect the master to be listening OSC
const uint16_t recvPort = 9000; // port to listen OSC on this module

void setup()
{
	Serial.begin(115200);
	Serial.println();
    cso.init(STATUS_LED_PIN);
	cso.setStatusLed(COLOR_BOOT);
    
	// connect to Wifi
    WiFi.begin(ssid, pwd);
	WiFi.config(ip, gateway, subnet);

	//if you get here you have connected to the WiFi
	cso.setStatusLed(COLOR_WIFI_CONNECTED);
	delay(500);
	IPAddress myIp = WiFi.localIP();
	String host = String(myIp[0]) + "." + String(myIp[1]) + "." + String(myIp[2]) + ".255";
	
	// begin to listen OSC
	cso.startOSC(recvPort);
	// set host (currently broadcast, will be updated to master's ip when receiving /who message from master)
	// and host port
	cso.setHost(host, hostPort);
	// add DIGITAL_INPUT (button) device on GPIO18 and GPIO19, with internal Pullup enabled
	// and filter the read value over 5 readings to avoid bounces
	// you should always check if addDevice returns an error
	ConnectedScenicObjectError err;
	err += cso.addDevice(DIGITAL_INPUT, new DigitalInputDevice(18, INPUT_PULLUP, 5));
	err += cso.addDevice(DIGITAL_INPUT, new DigitalInputDevice(19, INPUT_PULLUP, 5));
	// if error occured when creating devices, set the status led orange for 5 seconds
	if(err.code) {
		Serial.println(err.message);
		cso.setStatusLed(COLOR_WARNING);
		delay(5000);
	}
	else {
		cso.setStatusLed(COLOR_SETUP_OK);
	}
}

void loop()
{
    cso.update();
}
```

### Potentiometer example
```cpp
#include <WiFi.h>
#include <ConnectedScenicObject.h>

ConnectedScenicObject cso;
const uint16_t hostPort = 9001; // port on wich we expect the master to be listening OSC
const uint16_t recvPort = 9000; // port to listen OSC on this module

void setup()
{
	Serial.begin(115200);
	Serial.println();
	// we don't use status led on this object, so init doesn't take any parameter
    cso.init();
    
	// connect to Wifi
    WiFi.begin(ssid, pwd);
	WiFi.config(ip, gateway, subnet);

	//if you get here you have connected to the WiFi
	IPAddress myIp = WiFi.localIP();
	String host = String(myIp[0]) + "." + String(myIp[1]) + "." + String(myIp[2]) + ".255";
	
	cso.startOSC(recvPort);
	cso.setHost(host, hostPort);
	// add ANALOG_INPUT (potentiometer) device on GPIO32
	// and filter the read value over 9 readings through a median running filter
	ConnectedScenicObjectError err;
	err += cso.addDevice(ANALOG_INPUT, new AnalogInputDevice(32, 9));
	if(err.code) {
		Serial.println(err.message);
		cso.setStatusLed(COLOR_WARNING);
		delay(5000);
	}
	else {
		cso.setStatusLed(COLOR_SETUP_OK);
	}
}

void loop()
{
    cso.update();
}
```

###  LedStrip example
```cpp
#include <WiFi.h>
#include <FastLED.h> // will be included by ConnectedScenicObject.h but it's more clear
#include <ConnectedScenicObject.h>

#define FASTLED_MAX_BRIGHTNESS 96

ConnectedScenicObject cso;
const uint16_t hostPort = 9001; // port on wich we expect the master to be listening OSC
const uint16_t recvPort = 9000; // port to listen OSC on this module

void setup()
{
	Serial.begin(115200);
	Serial.println();
    cso.init();
	// all ledstrips (and status led if used) will be affected by this command
	FastLED.setBrightness(FASTLED_MAX_BRIGHTNESS);
    
	// connect to Wifi
    WiFi.begin(ssid, pwd);
	WiFi.config(ip, gateway, subnet);

	//if you get here you have connected to the WiFi
	IPAddress myIp = WiFi.localIP();
	String host = String(myIp[0]) + "." + String(myIp[1]) + "." + String(myIp[2]) + ".255";
	
	cso.startOSC(recvPort);
	cso.setHost(host, hostPort);
	// Add a WS2812B leds strip with 24 leds on GPIO4
	ConnectedScenicObjectError err;
	err += cso.addDevice(LED_STRIP, new LedStripDevice(4, 24));
	if(err.code) {
		Serial.println(err.message);
		cso.setStatusLed(COLOR_WARNING);
		delay(5000);
	}
	else {
		cso.setStatusLed(COLOR_SETUP_OK);
	}
}

void loop()
{
    cso.update();
}
```

###  Accelerometer / Gyroscope (MPU6050) example
It is assumed that a file called *mpu.calib* containing the calibration data for the accelerometer is in the SPIFFS on the ESP32 as explained in [this section](#calibration-file).

```cpp
#include <WiFi.h>
#include <FS.h>
#include <SPIFFS.h>
#include <ConnectedScenicObject.h>

#define FASTLED_MAX_BRIGHTNESS 48

ConnectedScenicObject cso;
const uint16_t hostPort = 9001; // port on wich we expect the master to be listening OSC
const uint16_t recvPort = 9000; // port to listen OSC on this module

void setup()
{
	Serial.begin(115200);
	Serial.println();
	// init object with status led on GPIO16
    cso.init(16);
	// Limit Status led brightness
	FastLED.setBrightness(FASTLED_MAX_BRIGHTNESS);
	
	// open SPIFFS to load MPU6050 calibration file
	if(!SPIFFS.begin(true)){
		Serial.println("An Error has occurred while mounting SPIFFS");
		cso.setStatusLed(COLOR_WARNING);
		delay(2000);
	}
    
	// connect to Wifi
    WiFi.begin(ssid, pwd);
	WiFi.config(ip, gateway, subnet);

	//if you get here you have connected to the WiFi
	IPAddress myIp = WiFi.localIP();
	String host = String(myIp[0]) + "." + String(myIp[1]) + "." + String(myIp[2]) + ".255";
	
	cso.startOSC(recvPort);
	cso.setHost(host, hostPort);
	// Add a MPU6050 Accelerometer connected to GPIO19 (SDA) and GPIO23 (SCL)
	// Calibration for this device is stored in mpu.calib file at the root of SPIFFS
	// it has been generated with the sketch in ressources/MPU6050_calibration
	ConnectedScenicObjectError err;
	err += cso.addDevice(ACCEL_GYRO, new AccelGyroDevice(SPIFFS, "/mpu.calib", 19, 23));
	if(err.code) {
		Serial.println(err.message);
		cso.setStatusLed(COLOR_WARNING);
		delay(5000);
	}
	else {
		cso.setStatusLed(COLOR_SETUP_OK);
	}
}

void loop()
{
    cso.update();
}
```

## Creating your own devices
You can create your own devices by inheritance from an already implemented Device class if the behaviour of your device is just an extension something already implemented or by inheritance from the *GenericDevice* class.

Create two files next to your \*.ino file. For example, *MyExtendedDevice.h* and *MyExtendedDevice.cpp*.

In *MyExtendedDevice.h*:
- include the header from the class you want to inherit from
- declare the constructor as public method
- declare the functions to override as public virtual methods with the same signature as in the super class

In *MyExtendedDevice.cpp*:
- implement the constructor (with a call to the super class constructor in the initializer list if inheriting from already implemented class - not GenericDevice)
- implement the functions to override

In the \*.ino file:
- include the header of your class: 

`#include "MyExtendedDevice.h"`
- add devices as you would do with the other devices:

`err += cso.addDevice(BASE_TYPE, new MyExtendedDevice(PIN, [OTHER_PARAMETERS]));`

*NOTE :* **BASE_TYPE** *is the type of device from the super class (e.g. DIGITAL_INPUT, ANALOG_INPUT, TOUCH_INPUT, ROTARY_ENCODER, DIGITAL_OUTPUT, PWM_OUTPUT, ANALOG_OUTPUT, LED_STRIP, ACCEL_GYRO or STATUS_LED). If you create your device by inheriting from GenericDevice class, check the section below.*

### Inherit from GenericDevice
In that case, you will need to modify the ConnectedScenicObject library itself.

Create two files in the library folder, next to *ConnectedScenicObject.h*. For example, *MyExtendedDevice.h* and *MyExtendedDevice.cpp*.

Implement the code has explained above. You **need to implement** at least : 
- the constructor
- `virtual void init();`
- `virtual OscMessage update();`
- `virtual void oscCallback(OscMessage& m);`
- `virtual std::vector<int> usedPins();`

In *ConnectedScenicObject.h*:
- include the header of your class
- add an identifier for your device in the `DeviceType` enum, right before `NB_DEVICE_TYPES`

In *ConnectedScenicObject.cpp*:
- add a type name string for your device at the end of the array `ConnectedScenicObject::deviceTypeNames[NB_DEVICE_TYPES]`
- add a maximum instances number for your device at the end of the array `ConnectedScenicObject::deviceTypeMaxInstances[NB_DEVICE_TYPES]`
- if your device is dependant on special physical pins, add definition of these pins in *AvailableDevicePins.h* and create a rule in `ConnectedScenicObject::addDevice` method.

#### Example : HologramStrip
This class inherits from LedStripDevice and implements / overrides more OSC-controlled fonctionality. It is intended to control led strips on rotating structure in order to create a hologram effect.

*HologramStrip.h*
```cpp
#ifndef HOLOGRAM_STRIP_H
#define HOLOGRAM_STRIP_H

#include "LedStripDevice.h"


class HologramStrip: public LedStripDevice {
  private:
    int _realNbLeds;
    float _fps;
    uint32_t _lastFrameMicros;
    
    CRGBPalette16 _palette;
    TBlendType _blending;
    int _paletteIndex;

    CRGB _animationColor;
    int _animationIndex;
    int _animationPhase;
    
  public:
    HologramStrip(uint8_t pin, int nbLeds, float fps = 100);
    virtual OscMessage update();
    virtual void oscCallback(OscMessage& m);
};

#endif
```

*HologramStrip.cpp*
```cpp
#include "HologramStrip.h"



HologramStrip::HologramStrip(uint8_t pin, int nbLeds, float fps):
    LedStripDevice(pin, nbLeds), _realNbLeds(nbLeds), _fps(fps), _blending(NOBLEND), _paletteIndex(-1), 
    _animationColor(CRGB::Red), _animationIndex(-1), _animationPhase(-1)
{
  fill_solid( _palette, 16, CRGB::Black);
}



OscMessage HologramStrip::update() {
  uint32_t m = micros();
  if(m - _lastFrameMicros > 1000000.0f / _fps) {
    _lastFrameMicros = m;
    if(_paletteIndex >= 0) {
      uint8_t colorIndex = _paletteIndex;
      for( int i = 0; i < _realNbLeds; i++) {
          _leds[i] = ColorFromPalette( _palette, colorIndex, 255, _blending);
          colorIndex += 3;
      }
      _paletteIndex++;
      if(_paletteIndex > 255) {
        _paletteIndex = 0;
      }
    }
    
    else if( _animationPhase >= 0) {
      // increase fps with limit at 4 x _nbLeds (0.25 second to update all the ledstrip)
      _fps += 0.5;
      if(_fps > 4 *_realNbLeds) _fps = 4 * _realNbLeds;
      // play animation
      if(_animationPhase == 0) { // light leds one by one
        if(_animationIndex >= 0) _leds[_animationIndex] = CRGB::Black;
        _animationIndex++;
        if(_animationIndex >= _realNbLeds) {
          _animationIndex--;
          _animationPhase++;
        }
        _leds[_animationIndex] = _animationColor;
      }
      else if(_animationPhase == 1) {
        _animationIndex--;
        if(_animationIndex <= 0) {
          _animationIndex = 0;
          _animationPhase = 2;
        }
        _leds[_animationIndex] = _animationColor; 
      }
      else if(_animationPhase == 2) {
        _animationIndex++;
        if(_animationIndex >= _realNbLeds) {
          _animationIndex = _realNbLeds - 1;
          _animationPhase = 1;
        }
        _leds[_animationIndex] = _animationColor; 
      }
    }
  }
  return LedStripDevice::update();
}



void HologramStrip::oscCallback(OscMessage& m) {
  if(ArduinoOSC::match("/device/ledstrip/clear", m.address())) {
    if(m.typeTags() == "" || m.typeTags() == "i" && (m.arg<int>(0) == -1 || m.arg<int>(0) == _id)) {
      fill_solid(_leds, _nbLeds, CRGB::Black);
      fill_solid( _palette, 16, CRGB::Black);
      _paletteIndex = -1;
      _animationPhase = -1;
    }
  }
  if(ArduinoOSC::match("/device/ledstrip/set_palette", m.address()) && m.typeTags().startsWith("is") && m.arg<int>(0) == _id) {
    _paletteIndex = 0;
    String paletteName = m.arg<String>(1);
    paletteName.toLowerCase();
    if(paletteName == "rainbow") {
      _palette = RainbowColors_p;
    }
    else if(paletteName == "rainbowstripe") {
      _palette = RainbowStripeColors_p;
    }
    else if(paletteName == "ocean") {
      _palette = OceanColors_p;
    }
    else if(paletteName == "lava") {
      _palette = LavaColors_p;
    }
    else if(paletteName == "forest") {
      _palette = ForestColors_p;
    }
    else if(paletteName == "party") {
      _palette = PartyColors_p;
    }
    else if(m.typeTags() == "isiiiiiiiiiiiiiiii"){
      for(int i = 0; i < 16; i++) {
        _palette[i] = CRGB(m.arg<int>(i+2));
      }
    }
  }
  if(ArduinoOSC::match("/device/ledstrip/set_blend", m.address()) && m.typeTags() == "ii" && m.arg<int>(0) == _id) {
    int blending = m.arg<int>(1);
    switch(blending) {
      case 0:
        _blending = NOBLEND;
        break;
      case 1:
        _blending = LINEARBLEND;
        break;
      default:
        break;
    }
  }
  if(ArduinoOSC::match("/device/ledstrip/set_fps", m.address()) && m.typeTags() == "if" && m.arg<int>(0) == _id) {
    float fps = m.arg<float>(1);
    _fps = constrain(fps, 0.1, 400.0);
  }
  if(ArduinoOSC::match("/device/ledstrip/animate", m.address()) && m.typeTags().startsWith("i") && m.arg<int>(0) == _id) {
    _animationIndex = -1;
    _animationPhase = 0;
    _fps = 2.0;
    if(m.typeTags() == "ii") {
      _realNbLeds = constrain(m.arg<int>(1), 0, _nbLeds);
    }
  }
  if(ArduinoOSC::match("/device/ledstrip/set_animation_color", m.address()) && m.typeTags() == "ii" && m.arg<int>(0) == _id){
    _animationColor = CRGB(m.arg<int>(1));
  }
  LedStripDevice::oscCallback(m);
}
```

*Implementation in the ino file*
```cpp
#include "HologramStrip.h"

#define STRIP_PIN 15
#define LED_STRIP_LENGTH  30

// ...

setup() {
  //...
  ConnectedScenicObjectError err;
  err += cso.addDevice(LED_STRIP, new HologramStrip(STRIP_PIN, LED_STRIP_LENGTH));
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
```

## License
Copyright (c) 2019 [UMONS](https://web.umons.ac.be/en/) - [numediart](https://web.umons.ac.be/numediart/fr/accueil/) - [CLICK'](http://www.clicklivinglab.org/)
 
*ConnectedScenicObject* is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public
License as published by the Free Software Foundation; either
version 2.1 of the License, or (at your option) any later version.

This library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public
License along with this library; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA

## Legal Notices
This work was produced as part of the FEDER Digistorm project, co-financed by the European Union and the Wallonia Region.

![Logo FEDER-FSE](https://www.enmieux.be/sites/all/themes/enmieux_theme/img/logo-feder-fse.png)
