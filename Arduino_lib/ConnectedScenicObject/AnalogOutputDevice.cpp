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


#include "AnalogOutputDevice.h"

uint8_t AnalogOutputDevice::nbInstances = 0;


AnalogOutputDevice::AnalogOutputDevice(uint8_t pin, uint8_t initVal) :
      _pin(pin), _value(initVal), _targetValue(initVal), _ramp(false), _waveformType(-1)
{
   
}



void AnalogOutputDevice::init() {
  _id = nbInstances;
  nbInstances++;
  
  dacWrite(_pin, _value);
}



OscMessage AnalogOutputDevice::update() {
  OscMessage m;
  if(_waveformType >= 0 && _waveformType < maxWaveform) {
    uint16_t index = round(((micros() - _waveformT0micros) * maxSamplesNum * _waveformFreq / 1000000.0f));
    if(index >= maxSamplesNum) {
      index -= maxSamplesNum;
      _waveformT0micros = micros();
    }
    _value = waveformsTable[_waveformType][index];
    dacWrite(_pin, _value);
  }
  else if(_value != _targetValue) {
    if(!_ramp) {
      _value = _targetValue;
      dacWrite(_pin, _value);
      m = OscMessage("/analog_output_set");
      m.push(_id);
      m.push(_value/255.0f);
    }
    else {
      int newVal = round(_rampValInit + (_targetValue - _rampValInit) / (float)_rampDuration * (millis() - _rampT0millis));
      if(newVal != _value) {
        _value = newVal;
        dacWrite(_pin, _value);
        if(_value == _targetValue) {
          m = OscMessage("/analog_output_set");
          m.push(_id);
          m.push(_value/255.0f);
        }
      }
    }
  }
  return m;
}



void AnalogOutputDevice::oscCallback(OscMessage& m) {
  if(ArduinoOSC::match("/device/analog_output/set", m.address()) && m.typeTags() == String("if") && m.arg<int>(0) == _id) {
    _targetValue = round(constrain(m.arg<float>(1), 0.0f, 1.0f) * 255);
    _ramp = false;
    _waveformType = -1;
  }
  if(ArduinoOSC::match("/device/analog_output/ramp", m.address()) && m.typeTags() == String("iff") && m.arg<int>(0) == _id) {
    _rampValInit = _value;
    _targetValue = round(constrain(m.arg<float>(1), 0.0f, 1.0f) * 255);
    _rampDuration = round(constrain(m.arg<float>(2), 0.1f, 60.0f) * 1000);
    _rampT0millis = millis();
    _ramp = true;
    _waveformType = -1;
  }
  if(ArduinoOSC::match("/device/analog_output/waveform", m.address()) && m.typeTags() == String("isf") && m.arg<int>(0) == _id) {
    String type = m.arg<String>(1);
    if(type == "sine") _waveformType = 0;
    if(type == "triangle") _waveformType = 1;
    if(type == "sawtooth") _waveformType = 2;
    if(type == "square") _waveformType = 3;
    if(_waveformType >= 0) {
      _waveformFreq = constrain(m.arg<float>(2), minFreq, maxFreq);
      _waveformT0micros = micros();
    }
  }
}



std::vector<int> AnalogOutputDevice::usedPins() {
  std::vector<int> pins;
  pins.push_back(_pin);
  return pins;
}
