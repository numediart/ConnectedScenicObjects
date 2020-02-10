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


#include "LedStripDevice.h"


int LedStripDevice::nbInstances = 0;

LedStripDevice::LedStripDevice(uint8_t pin, int nbLeds) :
    _pin(pin), _nbLeds(nbLeds), _sizeRequest(false)
{
  _leds = new CRGB[_nbLeds]; 
  fill_solid(_leds, _nbLeds, CRGB::Black);
}



LedStripDevice::~LedStripDevice() {
	delete _leds;
}



void LedStripDevice::incrementInstances() {
  nbInstances++;
}



void LedStripDevice::init() {
  _id = nbInstances;
  incrementInstances();
  switch(_pin) {
	case 0:
	  FastLED.addLeds<LED_TYPE, 0, LED_COLOR_ORDER>(_leds, _nbLeds);
	  break;
	case 1:
	  FastLED.addLeds<LED_TYPE, 1, LED_COLOR_ORDER>(_leds, _nbLeds);
	  break;
	case 2:
	  FastLED.addLeds<LED_TYPE, 2, LED_COLOR_ORDER>(_leds, _nbLeds);
	  break;
	case 3:
	  FastLED.addLeds<LED_TYPE, 3, LED_COLOR_ORDER>(_leds, _nbLeds);
	  break;
	case 4:
	  FastLED.addLeds<LED_TYPE, 4, LED_COLOR_ORDER>(_leds, _nbLeds);
	  break;
	case 5:
	  FastLED.addLeds<LED_TYPE, 5, LED_COLOR_ORDER>(_leds, _nbLeds);
	  break;
	// pin 6 to 11 are reserved for SPI Flash memory
	case 12:
	  FastLED.addLeds<LED_TYPE, 12, LED_COLOR_ORDER>(_leds, _nbLeds);
	  break;
	case 13:
	  FastLED.addLeds<LED_TYPE, 13, LED_COLOR_ORDER>(_leds, _nbLeds);
	  break;
	case 14:
	  FastLED.addLeds<LED_TYPE, 14, LED_COLOR_ORDER>(_leds, _nbLeds);
	  break;
	case 15:
	  FastLED.addLeds<LED_TYPE, 15, LED_COLOR_ORDER>(_leds, _nbLeds);
	  break;
	case 16:
	  FastLED.addLeds<LED_TYPE, 16, LED_COLOR_ORDER>(_leds, _nbLeds);
	  break;
	case 17:
	  FastLED.addLeds<LED_TYPE, 17, LED_COLOR_ORDER>(_leds, _nbLeds);
	  break;
	case 18:
	  FastLED.addLeds<LED_TYPE, 18, LED_COLOR_ORDER>(_leds, _nbLeds);
	  break;
	case 19:
	  FastLED.addLeds<LED_TYPE, 19, LED_COLOR_ORDER>(_leds, _nbLeds);
	  break;
	// pin 20 is not compatible with FastLED
	case 21:
	  FastLED.addLeds<LED_TYPE, 21, LED_COLOR_ORDER>(_leds, _nbLeds);
	  break;
	case 22:
	  FastLED.addLeds<LED_TYPE, 22, LED_COLOR_ORDER>(_leds, _nbLeds);
	  break;
	case 23:
	  FastLED.addLeds<LED_TYPE, 23, LED_COLOR_ORDER>(_leds, _nbLeds);
	  break;
	// pin 24 is not compatible with FastLED
	case 25:
	  FastLED.addLeds<LED_TYPE, 25, LED_COLOR_ORDER>(_leds, _nbLeds);
	  break;
	case 26:
	  FastLED.addLeds<LED_TYPE, 26, LED_COLOR_ORDER>(_leds, _nbLeds);
	  break;
	case 27:
	  FastLED.addLeds<LED_TYPE, 27, LED_COLOR_ORDER>(_leds, _nbLeds);
	  break;
	// pin 28 to 31 are not compatible with FastLED
	// Need special handling for pins > 31
	case 32:
	  FastLED.addLeds<LED_TYPE, 32, LED_COLOR_ORDER>(_leds, _nbLeds);
	  break;
	case 33:
	  FastLED.addLeds<LED_TYPE, 33, LED_COLOR_ORDER>(_leds, _nbLeds);
	  break;
	default:
	  break;
  }
}



OscMessage LedStripDevice::update() {
  OscMessage m;
  if(_sizeRequest) {
    _sizeRequest = false;
	m = OscMessage("/ledstrip/size");
    m.push(_id);
    m.push(_nbLeds);
  }
  return m;
}



void LedStripDevice::oscCallback(OscMessage& m) {
  if(ArduinoOSC::match("/device/ledstrip/set_color", m.address()) && m.typeTags().startsWith("iii") && m.arg<int>(0) == _id) {
    int firstId = m.arg<int>(1);
    for(int i = 2; i < m.size(); i++) {
      int id = firstId + i - 2;
      if(m.getTypeTag(i) == 'i' && id < _nbLeds) {
        CRGB color = CRGB(m.arg<int>(i));
        _leds[id] = color;
      }
    }
  }
  if(ArduinoOSC::match("/device/ledstrip/clear", m.address())) {
    if(m.typeTags() == "" || m.typeTags() == "i" && (m.arg<int>(0) == -1 || m.arg<int>(0) == _id)) {
      fill_solid(_leds, _nbLeds, CRGB::Black);
    }
  }
  if(ArduinoOSC::match("/device/ledstrip/get_size", m.address()) && m.typeTags()== "i" && m.arg<int>(0) == _id) {
    _sizeRequest = true;
  }
}



std::vector<int> LedStripDevice::usedPins() {
  std::vector<int> pins;
  pins.push_back(_pin);
  return pins;
}
