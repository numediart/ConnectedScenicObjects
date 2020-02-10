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


#include "StatusLedDevice.h"

StatusLedDevice::StatusLedDevice(uint8_t pin, int nbLedsToDeclare): 
  LedStripDevice(pin, nbLedsToDeclare), _blinking(false), _blinkCount(0), _blinkTotal(-1)
{
}



void StatusLedDevice::setColor(const CRGB& color){
  _leds[0] = color;
}



void StatusLedDevice::incrementInstances() {
  // do nothing
}



void StatusLedDevice::init() {
  LedStripDevice::init();
}



OscMessage StatusLedDevice::update() {
  if(_blinking && millis() - _blinkT0 > 500) {
    _blinkT0 = millis();
    if(_blinkTotal <= 0 || _blinkCount < _blinkTotal) {
      if(_leds[0] == CRGB(CRGB::Black)) {
        _leds[0] = _blinkColor;
        _blinkCount++;
      }
      else {
        _leds[0] = CRGB::Black;
      }
    }
    else { // blinkCount reaches blinkTotal
      _leds[0] = _backupColor;
      _blinking = false;
    }
  }
  return OscMessage();
}



void StatusLedDevice::oscCallback(OscMessage& m) {
  if(ArduinoOSC::match("/status_led/set_color", m.address()) && m.typeTags() == "i") {
    _leds[0] = CRGB(m.arg<int>(0));
    _blinking = false;
  }
  if(ArduinoOSC::match("/status_led/blink", m.address())) {
    _backupColor = _leds[0];
    if(m.typeTags() == "i") {
      _blinkTotal = m.arg<int>(0);
      _blinkColor = _backupColor;
    }
    else if(m.typeTags() == "ii") {
      _blinkTotal = m.arg<int>(0);
      _blinkColor = CRGB(m.arg<int>(1));
    }
    else {
      _blinkTotal = 5;
      _blinkColor = CRGB::Red;
    }
    _blinking = true;
    _blinkCount = 0;
    _blinkT0 = millis();
  }
  if(ArduinoOSC::match("/status_led/blink/stop", m.address())) {
    _blinking = false;
    _leds[0] = _backupColor;
  }
}



std::vector<int> StatusLedDevice::usedPins() {
  std::vector<int> pins;
  pins.push_back(_pin);
  return pins;
}

