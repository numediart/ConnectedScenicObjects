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


#include "PwmOutputDevice.h"

uint8_t PwmOutputDevice::nbInstances = 0;

PwmOutputDevice::PwmOutputDevice(uint8_t pin, double freq, uint32_t initVal) :
      _pin(pin), _freq(freq), _value(initVal), _targetValue(initVal), _ramp(false)
{
}



void PwmOutputDevice::init() {
  _id = nbInstances;  
  nbInstances++;
  
  ledcSetup(_id, _freq, PWM_RES);
  ledcAttachPin(_pin, _id);
  ledcWrite(_id, _value);
}



OscMessage PwmOutputDevice::update() {
  OscMessage m;
  if(_value != _targetValue) {
    if(!_ramp) {
      _value = _targetValue;
      ledcWrite(_id, _value);
      m = OscMessage("/pwm_output_set");
      m.push(_id);
      m.push(_value/PWM_MAX);
    }
    else {
      int newVal = round((float)_rampValInit + ((float)_targetValue - (float)_rampValInit) / (float)_rampDuration * (millis() - _rampT0));
      if(newVal != _value) {
        _value = newVal;
        ledcWrite(_id, _value);
        if(_value == _targetValue) {
          m = OscMessage("/pwm_output_set");
          m.push(_id);
          m.push(_value/PWM_MAX);
        }
      }
    }
  }
  return m;
}



void PwmOutputDevice::oscCallback(OscMessage& m) {
  if(ArduinoOSC::match("/device/pwm_output/set", m.address()) && m.typeTags() == String("if") && m.arg<int>(0) == _id) {
    _targetValue = round(constrain(m.arg<float>(1), 0.0f, 1.0f) * PWM_MAX);
    _ramp = false;
  }
  if(ArduinoOSC::match("/device/pwm_output/ramp", m.address()) && m.typeTags() == String("iff") && m.arg<int>(0) == _id) {
    _rampValInit = _value;
    _targetValue = round(constrain(m.arg<float>(1), 0.0f, 1.0f) * PWM_MAX);
    _rampDuration = round(constrain(m.arg<float>(2), 0.1f, 60.0f) * 1000);
    _rampT0 = millis();
    _ramp = true;
  }
}



std::vector<int> PwmOutputDevice::usedPins() {
  std::vector<int> pins;
  pins.push_back(_pin);
  return pins;
}
