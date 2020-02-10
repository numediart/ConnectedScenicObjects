# Arduino libraries

## ESP32 support
ConnectedScenicObject is intended for ESP32 boards. Please install ESP32 support for Arduino IDE by following the instructions on the [official page](https://github.com/espressif/arduino-esp32).

## Librairies installation
To use *ConnectedScenicObject*, close Arduino IDE and Copy/Paste its folder to your
> %USER%/Documents/Arduino/libraries folder.

## Third party libraries 
This libraries are needed for *ConnectedScenicObject*. 

Some of them have been forked and slightly modified to work within this project but should still be compatible with existing code. Details about these modifications are given below.
Others can be installed from Arduino IDE Libraries Manager or directly from Github if you want to have the latest version.

### Unmodified
You can either install them from Github links, from this folder or from Arduino IDE Libraries Manager if available

* [FastLED](https://github.com/FastLED/FastLED) by Daniel Garcia, under MIT License
* [RunningAverage](https://github.com/RobTillaart/Arduino/tree/master/libraries/RunningAverage) and [RunningMedian](https://github.com/RobTillaart/Arduino/tree/master/libraries/RunningMedian) by Rob Tillaart, under MIT License
* [MPU6050](https://github.com/jrowberg/i2cdevlib/tree/master/Arduino/MPU6050) by Jeff Rowberg, under MIT License

### Modified
We recommand to download and install versions from numediart github. However, if you prefer to get the original version of the librairies, they are given here alongside with the slight modifications we made.

* [ArduinoOSC](https://github.com/numediart/ArduinoOSC) forked from [Hideaki Tai's repo](https://github.com/hideakitai/ArduinoOSC), under MIT License
* [I2Cdev](https://github.com/numediart/i2cdevlib/tree/master/Arduino/I2Cdev) forked from [Jeff Rowberg's repo](https://github.com/jrowberg/i2cdevlib/tree/master/Arduino/I2Cdev), under MIT License

#### Modifications

##### ArduinoOSC
1. Create a file ArduinoOSC.cpp next to ArduinoOSC.h
2. Copy/Paste this code in ArduinoOSC.cpp

```C++
#include "ArduinoOSC.h"

bool ArduinoOSC::match(const String& pattern, const String& test, bool full)
{
	if (full) return oscpkt::fullPatternMatch(pattern.c_str(), test.c_str());
	else      return oscpkt::partialPatternMatch(pattern.c_str(), test.c_str());
}
```

3. In ArduinoOSC.h, at line 18, remove the implementation of match function, so you get declaration only:

```C++
bool match(const String& pattern, const String& test, bool full = true);
```

4. Create a file Packetizer.cpp next to Packetizer.h in ArduinoOSC/lib folder
5. Copy/Paste this code in Packetizer.cpp

```C++
#include "Packetizer.h"

uint8_t Packetizer::crc8(const uint8_t* data, size_t size)
{
	uint8_t result = 0xFF;
	for (result = 0; size != 0; --size)
	{
		result ^= *data++;
		for (size_t i = 0; i < 8; ++i)
		{
			if (result & 0x80)
			{
				result <<= 1;
				result ^= 0x85; // x8 + x7 + x2 + x0
			}
			else
				result <<= 1;
		}
	}
	return result;
}
```

6. In Packetizer.h, at line 30, remove the implementation of crc8 function, so you get declaration only:

```C++
uint8_t crc8(const uint8_t* data, size_t size);
```

#### I2Cdev
In I2Cdev.h, add this code around line 95, after `#ifdef` section and before class declaration:

```C++
#if defined (ESP_PLATFORM) || defined (ESP8266)
	#define min _min
	#define max _max
#endif
```


## Finally

Once all librairies are installed, restart Arduino IDE, select an ESP32 board in Tools and the right Serial port. You should be able to upload one of the examples in File->Examples->ConnectedScenicObject