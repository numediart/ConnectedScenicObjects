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


#include "RotaryEncoderDevice.h"

int RotaryEncoderDevice::nbInstances = 0;


RotaryEncoderDevice::RotaryEncoderDevice(uint8_t pinA, uint8_t pinB, uint8_t pinButton, int mode) : 
      _pinA(pinA), _pinB(pinB), _pinButton(pinButton), _mode(mode)
{
}



void RotaryEncoderDevice::init() {
  _id = nbInstances;
  nbInstances++;
  
  pinMode(_pinA, _mode);
  pinMode(_pinB, _mode);
  pinMode(_pinButton, _mode);
  
  uint8_t initValue = _mode == INPUT_PULLUP? HIGH : LOW;
  _stateA = initValue;
  _stateB = initValue;
  _stateButton = initValue;
  _previousStateA = initValue;
  _previousStateB = initValue;
  _previousStateButton = initValue;

  _value = 0;
  _previousValue = 0;
}



OscMessage RotaryEncoderDevice::update() {
  _previousStateA = _stateA;
  _previousStateB = _stateB;
  _previousStateButton = _stateButton;

  _stateA = digitalRead(_pinA);
  _stateB = digitalRead(_pinB);
  _stateButton = digitalRead(_pinButton);

  _previousValue = _value;
  if((_stateA && !_previousStateA && !_stateB)) { // clockwise if pullup
      if(_mode == INPUT_PULLUP)
          _value++;
      else
          _value--;
  }
  else if((_stateA && !_previousStateA && _stateB)) { // anticlockwise if pullup
      if(_mode == INPUT_PULLUP)
          _value--;
      else
          _value++;
  }
  
  OscMessage m;
  if(_value != _previousValue) {
    m = OscMessage("/rotary_encoder/value");
    m.push(_id);
    m.push(_value);
  }
  else if(_stateButton != _previousStateButton) {
    m = OscMessage("/rotary_encoder/button");
    m.push(_id);
    m.push(_mode == INPUT_PULLUP? !_stateButton : _stateButton);
  }
  return m;
}



void RotaryEncoderDevice::oscCallback(OscMessage& m) {
  if(ArduinoOSC::match("/device/rotary_encoder/reset", m.address()) && m.typeTags().startsWith("i") && m.arg<int>(0) == _id) {
    if(m.typeTags() == String ("ii"))
      _value = m.arg<int>(1);
    else
      _value = 0;
  }
}



std::vector<int> RotaryEncoderDevice::usedPins() {
  std::vector<int> pins;
  pins.push_back(_pinA);
  pins.push_back(_pinB);
  pins.push_back(_pinButton);
  return pins;
}
