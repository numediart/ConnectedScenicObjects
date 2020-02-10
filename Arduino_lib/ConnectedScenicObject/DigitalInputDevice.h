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


#ifndef DIGITAL_INPUT_DEVICE_H
#define DIGITAL_INPUT_DEVICE_H

#include "GenericDevice.h"
#include "Arduino.h"


class DigitalInputDevice: public GenericDevice{
  protected:
    static int nbInstances;
    uint8_t _id;
    uint8_t _pin;
    int _mode;
    int* _filter;
    uint16_t _filterSize;
    uint16_t _filterIndex;
    int _state; // 1 -> buttonPressed, 0 -> button released
    int _previousState;
	
	uint32_t _pressT0;
	uint32_t _longPressMillis;
	uint8_t _longPressCount;
    
  public:
    DigitalInputDevice(uint8_t pin, int mode = INPUT_PULLUP, uint16_t filterSize = 15, uint32_t longPressTime = 1000);
    virtual void init();
    virtual OscMessage update();
    virtual void oscCallback(OscMessage& m);
    virtual std::vector<int> usedPins();
};

#endif // DIGITAL_INPUT_DEVICE_H
