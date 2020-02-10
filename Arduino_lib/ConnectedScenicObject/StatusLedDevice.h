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


#ifndef STATUS_LED_DEVICE_H
#define STATUS_LED_DEVICE_H

#include "LedStripDevice.h"

class StatusLedDevice: public LedStripDevice {
  protected:
    CRGB _backupColor;
    CRGB _blinkColor;
    bool _blinking;
    int _blinkCount;
    int _blinkTotal;
    uint32_t _blinkT0;
    
  public:
    StatusLedDevice(uint8_t pin, int nbLedsToDeclare = 1);
    void setColor(const CRGB& color);
    virtual void incrementInstances();
    virtual void init();
    virtual OscMessage update();
    virtual void oscCallback(OscMessage& m);
    virtual std::vector<int> usedPins();
  
};

#endif // STATUS_LED_DEVICE_H
