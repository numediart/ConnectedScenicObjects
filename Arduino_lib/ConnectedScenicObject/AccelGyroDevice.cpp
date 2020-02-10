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


#include "AccelGyroDevice.h"


AccelGyroDevice::AccelGyroDevice(fs::FS &fs, 
                                  const char* calibFilePath, 
                                  int pinSDA, 
                                  int pinSCL, 
                                  uint32_t readPeriodMs, 
                                  int filterSize):
_SDA(pinSDA), 
_SCL(pinSCL), 
_sendDataEveryMs(readPeriodMs), 
_mpuConnected(false), 
_readData(false), 
_configLoaded(false),
_sensorValFilters{ RunningAverage(filterSize > 0? filterSize : 1), 
                  RunningAverage(filterSize > 0? filterSize : 1), 
                  RunningAverage(filterSize > 0? filterSize : 1), 
                  RunningAverage(filterSize > 0? filterSize : 1), 
                  RunningAverage(filterSize > 0? filterSize : 1), 
                  RunningAverage(filterSize > 0? filterSize : 1) }
{
  File configFile = fs.open(calibFilePath);
  if(configFile) {
    String line = configFile.readStringUntil('\n');
    while(line.startsWith("#")) {
      line = configFile.readStringUntil('\n');
    }
    for(int i = 0; i < 6; i++) {
      int firstTab = line.indexOf('\t');
      _agOffsets[i] = line.substring(0, firstTab).toInt();
      line = line.substring(firstTab + 1);
    }
    _configLoaded = true;
    configFile.close();
  }
}



void AccelGyroDevice::mpuInit() {
  if(_SDA < 0 || _SCL < 0) {
    Wire.begin();
  }
  else {
    Wire.begin(_SDA, _SCL);
  }
  _mpu.initialize();
  _mpuConnected = _mpu.testConnection();
  if(_mpuConnected && _configLoaded) {
    _mpu.setXAccelOffset(_agOffsets[0]);
    _mpu.setYAccelOffset(_agOffsets[1]);
    _mpu.setZAccelOffset(_agOffsets[2]);
    _mpu.setXGyroOffset(_agOffsets[3]);
    _mpu.setYGyroOffset(_agOffsets[4]);
    _mpu.setZGyroOffset(_agOffsets[5]);
  }
}



void AccelGyroDevice::init() {
  
}


OscMessage AccelGyroDevice::update() {
  OscMessage m;
  if(millis() - _sendDataTimer >= _sendDataEveryMs && _readData) {
    _sendDataTimer = millis();
    m = OscMessage("/accel_gyro");
    if(!_configLoaded) {
      m.push("config_file_not_loaded");
    }
    if(!_mpuConnected) {
      m.push("mpu_not_connected");
      mpuInit();
    }
    else {
      int16_t sensorVals[6];
      _mpu.getMotion6(&sensorVals[0], &sensorVals[1], &sensorVals[2], 
                      &sensorVals[3], &sensorVals[4], &sensorVals[5]);
      float deviationSum = 0.0;
      for(int i = 0; i < 6; i++) {
        _sensorValFilters[i].addValue(sensorVals[i] / 32768.0);
        deviationSum += _sensorValFilters[i].getStandardDeviation();
      }
      if(deviationSum == 0.0) {
        m.push("mpu_stuck");
        mpuInit();
      }
      else {
        for(int i = 0; i < 6; i++) {
          m.push(_sensorValFilters[i].getAverage());
        }
      }
    }
  }
  return m;
}



void AccelGyroDevice::oscCallback(OscMessage& m) {
  if(ArduinoOSC::match("/device/accel_gyro/start", m.address())) {
    _readData = true;
  }
  if(ArduinoOSC::match("/device/accel_gyro/stop", m.address())) {
    _readData = false;
  }
}



std::vector<int> AccelGyroDevice::usedPins() {
  std::vector<int> pins;
  pins.push_back(_SDA);
  pins.push_back(_SCL);
  return pins;
}

