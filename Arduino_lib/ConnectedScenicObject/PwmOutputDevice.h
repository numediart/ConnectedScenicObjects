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


#ifndef PWM_OUTPUT_DEVICE_H
#define PWM_OUTPUT_DEVICE_H

#include "GenericDevice.h"
#include "Arduino.h"

#define PWM_RES 10 // pwm resolution in bits
#define PWM_MAX 1023.0f // 2^PWM_RES - 1

class PwmOutputDevice: public GenericDevice {
  protected:
    static uint8_t nbInstances;
    uint8_t _id;
    uint8_t _pin;
    double _freq;
    uint32_t _value;
    uint32_t _targetValue;
    
    bool _ramp;
    uint32_t _rampValInit;
    uint32_t _rampDuration;
    uint32_t _rampT0;
    
  public:
    PwmOutputDevice(uint8_t pin, double freq, uint32_t initVal = 0);
    virtual void init();
    virtual OscMessage update();
    virtual void oscCallback(OscMessage& m);
    virtual std::vector<int> usedPins();
};


#endif
