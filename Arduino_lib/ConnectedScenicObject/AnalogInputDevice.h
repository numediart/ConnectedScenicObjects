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


#ifndef ANALOG_INPUT_DEVICE_H
#define ANALOG_INPUT_DEVICE_H

#include "GenericDevice.h"
#include "Arduino.h"
#include "RunningMedian.h" // https://github.com/RobTillaart/Arduino/tree/master/libraries/RunningMedian


class AnalogInputDevice: public GenericDevice {
  protected:
    static int nbInstances;
    uint8_t _id;
    uint8_t _pin;

	float _threshold;
    float _lastValue;
    RunningMedian _valFilter;
    
  public:
    // pin must be between 32 and 39 included
    AnalogInputDevice(uint8_t pin, float threshold = 0.005, uint16_t filterSize = 15);
    virtual void init();
    virtual OscMessage update();
    virtual void oscCallback(OscMessage& m);
    virtual std::vector<int> usedPins();
};

#endif
