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


#include "ConnectedScenicObject.h"



ConnectedScenicObjectError::ConnectedScenicObjectError(int c, String m) {
  code = c;
  message = m;
}



String ConnectedScenicObject::deviceTypeNames[NB_DEVICE_TYPES] = {
  "digital_input",
  "analog_input",
  "touch_input",
  "rotary_encoder",
  "digital_output",
  "pwm_output",
  "analog_output",
  "ledstrip",
  "accel_gyro",
  "status_led"
};

int ConnectedScenicObject::deviceTypeMaxInstances[NB_DEVICE_TYPES] = {
  16, //digital inputs
  6,  //analog inputs, only ADC1 as WiFi is used
  10, //touch inputs
  4,  //rotary_encoder
  16, //digital outputs
  8,  //pwm outputs
  2,  //analog outputs
  8,  //led strips
  1,  //accelerometer/gyroscope
  1   //status led
};


String ConnectedScenicObject::_host = "127.000.000.001";
int ConnectedScenicObject::_hostPort = 9001;

std::multimap<DeviceType, GenericDevice*> ConnectedScenicObject::_devices = std::multimap<DeviceType, GenericDevice*>();
std::map<uint8_t, String> ConnectedScenicObject::_pinUsed = std::map<uint8_t, String>();

StatusLedDevice* ConnectedScenicObject::_statusLed = new StatusLedDevice(-1);
OscWiFi ConnectedScenicObject::_osc;
bool ConnectedScenicObject::_sendIam = false;
bool ConnectedScenicObject::_knockSent = false;
bool ConnectedScenicObject::_connected = false;


ConnectedScenicObject::ConnectedScenicObject() {
	
}



void ConnectedScenicObject::init(int statusLedPin, int nbLedsToDeclare) {
  // reserve some pins
  _pinUsed[1] = "Serial_port_TX";
  _pinUsed[3] = "Serial_port_RX";
  for(uint8_t p = 6; p <= 11; p++) {
    _pinUsed[p] = "SPI_Flash_memory";
  }
  
  if(statusLedPin >= 0) {
    delete _statusLed;
    _statusLed = new StatusLedDevice(statusLedPin, nbLedsToDeclare);
    addDevice(STATUS_LED, _statusLed);
  }
}



void ConnectedScenicObject::startOSC(uint16_t listeningPort) {
    _osc.begin(listeningPort);
    _osc.subscribe("///*", this->processOSC);
}



void ConnectedScenicObject::setStatusLed(const CRGB& color) {
  if(_statusLed) {
    _statusLed->setColor(color);
    FastLED.show();
  }
}



void ConnectedScenicObject::setHost(const String& host, const int& hostPort) {
  _host = host;
  _hostPort = hostPort;
}



void ConnectedScenicObject::sendMessage(OscMessage& m) {
	m.ip(_host);
	m.port(_hostPort);
	_osc.send(m);
}


String ConnectedScenicObject::checkPinAvailable(uint8_t pin) {
  return _pinUsed[pin];
}



ConnectedScenicObjectError ConnectedScenicObject::addDevice(DeviceType type, GenericDevice* device) {
  ConnectedScenicObjectError err;
  if(type < 0 || type > NB_DEVICE_TYPES) {
    err.code = 32;
    err.message += "Error : unknown device type (" + String(type) + ")";
    delete device;
    return err;
  }
  if(!device) {
    err.code = 16;
    err.message = "Error when creating " + deviceTypeNames[type];
    err.message += ": new device is null";
    return err;
  }
  
  std::vector<int> devicePins = device->usedPins();
  String checkString = "";
  String refString = "";
  int nbPass = 0;
  for (int &pin : devicePins) {
    if(nbPass > 0) {
      checkString += "/";
      refString += "/";
    }
    checkString += checkPinAvailable(pin);
    nbPass++;
  }
  if(checkString == refString) {
    if(_devices.count(type) >= deviceTypeMaxInstances[type]) {
      err.code = 2;
      err.message = "Error when creating " + deviceTypeNames[type];
      err.message += ": there are already " + String(_devices.count(type)) + " devices of this type";
    }
    // specific device checks
    else if(type == ANALOG_INPUT && 
        !(devicePins[0] == ANALOG_INPUT_0_PIN || devicePins[0] == ANALOG_INPUT_1_PIN || devicePins[0] == ANALOG_INPUT_2_PIN ||
          devicePins[0] == ANALOG_INPUT_3_PIN || devicePins[0] == ANALOG_INPUT_4_PIN || devicePins[0] == ANALOG_INPUT_5_PIN)
          ) {
      err.code = 1;
      err.message = "Error when creating " + deviceTypeNames[type];
      err.message += ": pin " + String(devicePins[0]) + " is not compatible with analog input";
    }
    else if(type == TOUCH_INPUT &&
        !(devicePins[0] == TOUCH_INPUT_0_PIN || devicePins[0] == TOUCH_INPUT_1_PIN || devicePins[0] == TOUCH_INPUT_2_PIN ||
            devicePins[0] == TOUCH_INPUT_3_PIN || devicePins[0] == TOUCH_INPUT_4_PIN || devicePins[0] == TOUCH_INPUT_5_PIN ||
            devicePins[0] == TOUCH_INPUT_6_PIN || devicePins[0] == TOUCH_INPUT_7_PIN || devicePins[0] == TOUCH_INPUT_8_PIN || 
            devicePins[0] == TOUCH_INPUT_9_PIN)
            ) {
      err.code = 1;
      err.message = "Error when creating " + deviceTypeNames[type];
      err.message += ": pin " + String(devicePins[0]) + " is not compatible with touch input";
    }
    else if(type == ANALOG_OUTPUT && !(devicePins[0] == ANALOG_OUTPUT_0_PIN || devicePins[0] == ANALOG_OUTPUT_1_PIN)) {
      err.code = 1;
      err.message = "Error when creating " + deviceTypeNames[type];
      err.message += ": pin " + String(devicePins[0]) + " is not an analog output, only pins 25 and 26 can be used";
    }
    else if((type == LED_STRIP || type == STATUS_LED) && 
          !(devicePins[0] == LEDSTRIP_0_PIN || devicePins[0] == LEDSTRIP_1_PIN || devicePins[0] == LEDSTRIP_2_PIN || devicePins[0] == LEDSTRIP_3_PIN ||
            devicePins[0] == LEDSTRIP_4_PIN || devicePins[0] == LEDSTRIP_5_PIN || devicePins[0] == LEDSTRIP_6_PIN || devicePins[0] == LEDSTRIP_7_PIN ||
            devicePins[0] == LEDSTRIP_8_PIN || devicePins[0] == LEDSTRIP_9_PIN || devicePins[0] == LEDSTRIP_10_PIN || devicePins[0] == LEDSTRIP_11_PIN ||
            devicePins[0] == LEDSTRIP_12_PIN || devicePins[0] == LEDSTRIP_13_PIN || devicePins[0] == LEDSTRIP_14_PIN || devicePins[0] == LEDSTRIP_15_PIN ||
            devicePins[0] == LEDSTRIP_16_PIN || devicePins[0] == LEDSTRIP_17_PIN || devicePins[0] == LEDSTRIP_18_PIN || devicePins[0] == LEDSTRIP_19_PIN ||
			devicePins[0] == LEDSTRIP_20_PIN || devicePins[0] == LEDSTRIP_21_PIN )
          ) {
      err.code = 1;
      err.message = "Error when creating " + deviceTypeNames[type];
      err.message += ": pin " + String(devicePins[0]) + " is not usable for led strip"; 
    }
    else if(type >= DIGITAL_OUTPUT) {
      for (int &pin : devicePins) {
        if(pin > 33) {
          err.code = 1;
          err.message = "Error when creating " + deviceTypeNames[type];
          err.message += ": pin " + String(pin) + " is not an output";
          break;
        }
      }
    }
  }
  else {
    err.code = 4;
    err.message = "Error when creating " + deviceTypeNames[type] + ":";
    for (int &pin : devicePins) {
      if(checkPinAvailable(pin) != "") {
        err.message += " pins " + String(pin) + " is already reserved for " + checkPinAvailable(pin) + ";" ;
      }
    }
  }

  if(err.code == 0) { // no error, reserve device's pins and add the device to the multimap
    int i = 0;
    for (int &pin : devicePins) {
      _pinUsed[pin] = deviceTypeNames[type] + "_" + String(_devices.count(type));
      i++;
    }
    device->init();
    _devices.insert(std::make_pair(type, device));
  }
  else { // an error occured delete the device
    delete device;
  }
  return err;
}



void ConnectedScenicObject::update() {
  if(!_knockSent) {
	    _osc.send(_host, _hostPort, "/knockknock");
		_knockSent = true;
  }
  _osc.parse();
  
  if(_sendIam) {
	_sendIam = false;
	_connected = true;
	setStatusLed(COLOR_OSC_CONNECTED);
    OscMessage iam("/iam");
    iam.ip(_host);
    iam.port(_hostPort);
    iam.push(getMacAddress());
    // give available devices types and number
    for(int t = 0; t < NB_DEVICE_TYPES; t++) {
      int currentTypeDeviceCount = _devices.count((DeviceType)t);
      if(currentTypeDeviceCount > 0) {
        iam.push(deviceTypeNames[t]);
        iam.push(currentTypeDeviceCount);
      }
    }
    _osc.send(iam);
  }
  for(int t = 0; t < NB_DEVICE_TYPES; t++) {
    auto currentTypeDevices = _devices.equal_range((DeviceType)t);
    for (auto currentTypeDevice = currentTypeDevices.first; currentTypeDevice != currentTypeDevices.second; ++currentTypeDevice)
    {
        auto const& currentDevice = currentTypeDevice->second;
        OscMessage m = currentDevice->update();
        if(m.address() != String("")) {
          m.ip(_host);
          m.port(_hostPort);
          _osc.send(m);
        }
    }
  }
  FastLED.show();
}



void ConnectedScenicObject::processOSC(OscMessage& m) {
  //Serial.println(F("### ConnectedScenicObject receveid an OSC message ###"));
  printMessage(m);
  // check if message is special
  if(ArduinoOSC::match("/who", m.address())) {
    _host = m.ip();
	_sendIam = true;
  }
  // message intended fo status led
  else if(m.address().startsWith("/status_led")) {
    _statusLed->oscCallback(m);
  }
  // message intended for one of the devices
  else if(m.address().startsWith("/device")) {
  // check the message is for a known device type
    int targetDeviceType = -1;
    for(int t = 0; t < NB_DEVICE_TYPES; t++) {
      if(m.address().indexOf(deviceTypeNames[t]) >= 0) {
        targetDeviceType = t;
        break;
      }
    }  
    // transfer the message to all the devices with the right type
    // the device will ignore the message if it contains an id different from his
    if(targetDeviceType >= 0) {
      auto currentTypeDevices = _devices.equal_range((DeviceType)targetDeviceType);
      for (auto currentTypeDevice = currentTypeDevices.first; currentTypeDevice != currentTypeDevices.second; ++currentTypeDevice)
      {
          auto const& currentDevice = currentTypeDevice->second;
          currentDevice->oscCallback(m);
      }
    }
  }
}



void ConnectedScenicObject::printMessage(OscMessage& m) {
  Serial.printf("received from or send to\t%s:%i\n", m.ip().c_str(), m.port());
  Serial.printf("addrpattern\t%s\n", m.address().c_str());
  Serial.printf("typetag\t\t%s\n", m.typeTags().c_str());
  int s = m.size();
  for (int i = 0; i < s; i++) {
    Serial.printf("[%i] : ", i);
    String argumentValue = "";
    switch (m.getTypeTag(i)) {
    case 'T':
      argumentValue = "True";
      break;
    case 'F':
      argumentValue = "False";
      break;
    case 'i':
    case 'h':
      argumentValue = String(m.arg<int>(i));
      break;
    case 'f':
      argumentValue = String(m.arg<float>(i));
      break;
    case 'd':
      argumentValue = String(m.arg<double>(i));
      break;
    case 's':
      argumentValue = m.arg<String>(i);
      break;
    default:
      break;
    }
    Serial.println(argumentValue);
  }
  Serial.println("--------------------------");
}



String ConnectedScenicObject::getMacAddress() {
  uint8_t baseMac[6];
  // Get MAC address for WiFi station
  esp_read_mac(baseMac, ESP_MAC_WIFI_STA);
  char baseMacChr[18] = {0};
  sprintf(baseMacChr, "%02X:%02X:%02X:%02X:%02X:%02X", baseMac[0], baseMac[1], baseMac[2], baseMac[3], baseMac[4], baseMac[5]);
  return String(baseMacChr);
}
