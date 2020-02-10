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


#include "DigitalOutputDevice.h"


int DigitalOutputDevice::nbInstances = 0;

DigitalOutputDevice::DigitalOutputDevice(uint8_t pin, int startState) :
    _pin(pin), _state(startState)
{ 
}



void DigitalOutputDevice::init() {
  _id = nbInstances;
  nbInstances++;
  
  pinMode(_pin, OUTPUT);
  digitalWrite(_pin, _state);
}



OscMessage DigitalOutputDevice::update() {
  return OscMessage();
}



void DigitalOutputDevice::oscCallback(OscMessage& m) {
  if(ArduinoOSC::match("/device/digital_output/set", m.address()) && m.typeTags() == String("ii") && m.arg<int>(0) == _id) {
    _state = m.arg<int>(1);
    if(_state < 0) _state = 0;
    if(_state > 1) _state = 1;
    digitalWrite(_pin, _state);
  }
}



std::vector<int> DigitalOutputDevice::usedPins() {
  std::vector<int> pins;
  pins.push_back(_pin);
  return pins;
}
