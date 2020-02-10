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


#include "DigitalInputDevice.h"


int DigitalInputDevice::nbInstances = 0;


DigitalInputDevice::DigitalInputDevice(uint8_t pin, int mode, uint16_t filterSize, uint32_t longPressTime) : 
      _pin(pin), _mode(mode), _filterSize(filterSize > 0? filterSize : 1), _longPressMillis(longPressTime), _state(0), _previousState(0)
{
}



void DigitalInputDevice::init() {
  _id = nbInstances;
  nbInstances++;

  pinMode(_pin, _mode);
  
  _filter = new int[_filterSize];
  _filterIndex = 0;
  int initValue = _mode == INPUT_PULLUP? HIGH : LOW;
  for(int i = 0; i < _filterSize; i++) {
    _filter[i] = initValue;
  }
}



OscMessage DigitalInputDevice::update() {
  // update value
  _filter[_filterIndex] = digitalRead(_pin);
  _filterIndex++;
  if(_filterIndex >= _filterSize) _filterIndex = 0;
  // check for state change
  float val = 0;
  for(int i = 0; i < _filterSize; i++) {
    val += _filter[_filterIndex];
  }
  if(_mode == INPUT_PULLUP) {
    // more LOW values than HIGH in filter, so button is pressed
    _state = val < _filterSize / 2? 1 : 0;
  }
  else {
    _state = val > _filterSize / 2? 1 : 0;
  }
  OscMessage m;
  if(_state != _previousState) {
    m = OscMessage("/digital_input");
    m.push(_id);
    m.push(_state);
	if(_state == 1) {
		_pressT0 = millis();
		_longPressCount = 1;
	}
  }
  else if(_state == 1 && millis() - _pressT0 > _longPressMillis) {
	_pressT0 = millis();
	_longPressCount++;
	if(_longPressCount > 1) {
		m = OscMessage("/digital_input");
		m.push(_id);
		m.push(_longPressCount);
	}
  }
  _previousState = _state;
  return m;
}



void DigitalInputDevice::oscCallback(OscMessage& m) {

}



std::vector<int> DigitalInputDevice::usedPins() {
  std::vector<int> pins;
  pins.push_back(_pin);
  return pins;
}

