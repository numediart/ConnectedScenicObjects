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


#ifndef ROTARY_ENCODER_DEVICE_H
#define ROTARY_ENCODER_DEVICE_H

#include "GenericDevice.h"


class RotaryEncoderDevice: public GenericDevice {
  protected:
    static int nbInstances;
    uint8_t _id;

    int _mode;
    uint8_t _pinA;
    uint8_t _pinB;
    uint8_t _pinButton;

    uint8_t _stateA;
    uint8_t _stateB;
    uint8_t _stateButton;
    uint8_t _previousStateA;
    uint8_t _previousStateB;
    uint8_t _previousStateButton;

    int32_t _value;
    int32_t _previousValue;
    
  public:
    RotaryEncoderDevice(uint8_t pinA, uint8_t pinB, uint8_t pinButton, int mode = INPUT_PULLUP);
    virtual void init();
    virtual OscMessage update();
    virtual void oscCallback(OscMessage& m);
    virtual std::vector<int> usedPins();
};

#endif

