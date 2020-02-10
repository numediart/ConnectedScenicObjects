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


#ifndef ACCEL_GYRO_H
#define ACCEL_GYRO_H

#include "GenericDevice.h"
// load calib from file
#include <FS.h>
#include <SPIFFS.h>
// get accelerometer / gyro data
#include "I2Cdev.h"
#include "MPU6050.h"
#include "Wire.h"
// filter values
#include "RunningAverage.h" // https://github.com/RobTillaart/Arduino/tree/master/libraries/RunningAverage



class AccelGyroDevice: public GenericDevice {
  protected:
    MPU6050 _mpu;
    int _SDA;
    int _SCL;
    uint32_t _sendDataEveryMs;
    uint32_t _sendDataTimer;
    int16_t _agOffsets[6];
    bool _mpuConnected;
    bool _configLoaded;
    bool _readData;

    RunningAverage _sensorValFilters[6];
    
  public:
    AccelGyroDevice(fs::FS &fs, 
                      const char* calibFilePath, 
                      int pinSDA = -1, 
                      int pinSCL = -1, 
                      uint32_t readPeriodMs = 20, 
                      int filterSize = 3);
    void  mpuInit();
    virtual void init();
    virtual OscMessage update();
    virtual void oscCallback(OscMessage& m);
    virtual std::vector<int> usedPins();
};

#endif
