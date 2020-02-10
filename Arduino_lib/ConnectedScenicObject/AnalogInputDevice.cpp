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


#include "AnalogInputDevice.h"


int AnalogInputDevice::nbInstances = 0;

AnalogInputDevice::AnalogInputDevice(uint8_t pin, float threshold, uint16_t filterSize):
  _pin(pin), _valFilter(RunningMedian(filterSize > 0? filterSize : 1))
{
	_threshold = constrain(threshold, 0.0001, 0.5);
}



void AnalogInputDevice::init() {
  _id = nbInstances;
  nbInstances++;
    
  pinMode(_pin, INPUT);
  _lastValue = analogRead(_pin) / 4095.0;
}



OscMessage AnalogInputDevice::update() {
  OscMessage m;
  _valFilter.add(analogRead(_pin) / 4095.0);
  float newValue = _valFilter.getMedian();
  if(fabs(_lastValue - newValue) >= _threshold) {
    m = OscMessage("/analog_input");
    m.push(_id);
    m.push(newValue);
    _lastValue = newValue;
  }
  return m;
}



void AnalogInputDevice::oscCallback(OscMessage& m) {
  
}



std::vector<int> AnalogInputDevice::usedPins() {
  std::vector<int> pins;
  pins.push_back(_pin);
  return pins;
}

