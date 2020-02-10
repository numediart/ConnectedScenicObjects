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


#ifndef AVAILABLE_DEVICE_PINS_H
#define AVAILABLE_DEVICE_PINS_H

// IMPORTANT!
// - Pins 1 and 3 are reserved for Serial port
// - Pins 6 to 11 are connected to the SPI Flash integrated on
//   ESP-WROOM32 and are not recommended for other uses
// - Pins 34 to 39 are inputs only
// - Pins 34 to 39 have no internal pullup resistor
// - Pins 37 and 38 (ADC1) are not accessible on ESP-WROOM32
// - Some pins are shared between several functions (e.g. pins 32 and 33)
//   For example, you can't create AnalogInputDevice(ANALOG_INPUT_0_PIN)
//   and TouchInputDevice(TOUCH_INPUT_9_PIN) as they will both use pin 32

#define ANALOG_INPUT_0_PIN 32
#define ANALOG_INPUT_1_PIN 33
#define ANALOG_INPUT_2_PIN 34
#define ANALOG_INPUT_3_PIN 35
#define ANALOG_INPUT_4_PIN 36
#define ANALOG_INPUT_5_PIN 39


#define TOUCH_INPUT_0_PIN 4
#define TOUCH_INPUT_1_PIN 0
#define TOUCH_INPUT_2_PIN 2
#define TOUCH_INPUT_3_PIN 15
#define TOUCH_INPUT_4_PIN 13
#define TOUCH_INPUT_5_PIN 12
#define TOUCH_INPUT_6_PIN 14
#define TOUCH_INPUT_7_PIN 27
#define TOUCH_INPUT_8_PIN 33
#define TOUCH_INPUT_9_PIN 32


#define ANALOG_OUTPUT_0_PIN 25
#define ANALOG_OUTPUT_1_PIN 26


#define LEDSTRIP_0_PIN 0
#define LEDSTRIP_1_PIN 1
#define LEDSTRIP_2_PIN 2
#define LEDSTRIP_3_PIN 3
#define LEDSTRIP_4_PIN 4
#define LEDSTRIP_5_PIN 5
#define LEDSTRIP_6_PIN 12
#define LEDSTRIP_7_PIN 13
#define LEDSTRIP_8_PIN 14
#define LEDSTRIP_9_PIN 15
#define LEDSTRIP_10_PIN 16
#define LEDSTRIP_11_PIN 17
#define LEDSTRIP_12_PIN 18
#define LEDSTRIP_13_PIN 19
#define LEDSTRIP_14_PIN 21
#define LEDSTRIP_15_PIN 22
#define LEDSTRIP_16_PIN 23
#define LEDSTRIP_17_PIN 25
#define LEDSTRIP_18_PIN 26
#define LEDSTRIP_19_PIN 27
#define LEDSTRIP_20_PIN 32
#define LEDSTRIP_21_PIN 33

#endif
