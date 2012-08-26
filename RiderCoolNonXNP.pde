/* =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
RiderCool by Kristopher Kortright, June 2012 - Aug 2012 (o_o)
This software is licensed via CERN Open Source Hardware License
=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=*/
#define VERSION            "Ver 1.0"

#include <Wire.h>
#include <SPI.h>  // not used here, but needed to prevent a RTClib compile error
#include "RTClib.h"
RTC_Millis RTC;

#include <Adafruit_GFX.h>
#include <Adafruit_ST7735.h>
#include <SPI.h>
#include <Adafruit_BMP085.h>
Adafruit_BMP085 bmp;

int DigitalPSTdrivePIN1 = 36;
int DigitalPSTdrivePIN2 = 37; 
int DigitalPSTdrivePIN3 = 38;
int DigitalPSTdrivePIN4 = 39; 
int DigitalRELAYdrivePIN = 46;
int DigitalPINnetworkStateLEDred = 25;
int DigitalPINnetworkStateLEDblue = 27;
int DigitalPINnetworkStateLEDgreen = 29;
int DigitalPINcontrollerPower = 47;
int DigitalPINRGBLEDstatus = 49;
int DigitalPINxbeePacketInLED = 45;       
int DigitalPINxbeePacketOutLED = 44;
int DigitalPINxbeepacketLossLED = 43;
int AnalogPINrotaryA0 = 54;
int AnalogPINrotaryA1 = 55;
int AnalogPINrotaryA2 = 56;
int AnalogPINrotaryA3 = 57;
int AnalogPINtmp36tempA7 = 61;
int AnalogPINphotoCellA8 = 62;
int AnalogPINphotoCellA9 = 63;
int AnalogThermistorSensorPIN1 = 67;
int AnalogThermistorSensorPIN2 = 65;
int AnalogThermistorSensorPIN3 = 66;
int AnalogPINliquidLevelSensorA13 = 64;
int AnalogPINliquidLevelSensorA15 = 69;
int FlowSensorPIN = 58;
int AnalogPINbutton1 = 59;
int AnalogPINbutton2 = 60;
int TFT18shieldSCLKpin = 52;
int TFT18shieldMOSIpin = 51;
int DigitalTFT18shieldCsPIN = 53;
int DigitalTFT18shieldDcPIN = 9;
int DigitalTFT18shieldRstPIN = 8;
int DigitalTFT18shieldLightPIN  = 50;

#define MAX_BUFFER_LENGTH 192
int MAX_BUFFER_LENGTHS = 192;

int POWERSWITCH_ENABLE = 1;
int ButtonOneState = 1;
int ButtonTwoState = 1;
long e, f, g;
int a, b, c, d, h, j, k, r, s, t, x, y, z;
char buffer1[MAX_BUFFER_LENGTH], buffer2[MAX_BUFFER_LENGTH], buffer3[MAX_BUFFER_LENGTH], inChar;
int TempSensorCount = 3;
int MinutesNow, MinutesWas, HoursNow, SegmentCounter;
int MasterTEMPstatus = -1;
int AIRtempHIcount, CPUtempHIcount, COOLANTtempHIcount;
int TemperatureAIR, TemperatureCPU, TemperatureCOOLANT;
int TempHIwarnLevelAIR, TempHIalarmLevelAIR;
int TempHIwarnLevelCPU, TempHIalarmLevelCPU;
int TempHIwarnLevelCOOLANT, TempHIalarmLevelCOOLANT;
int AIRtempHIcountMAX, CPUtempHIcountMAX, COOLANTtempHIcountMAX;
float SensorAverageReading;
float steinhart;
float temperatureF;
int ThermistorTemp;
int SensorSamples[5];
int SensorSettleDelay;
long MasterSensor;
int FlexBaseline;
int LightLevel, FlexResistance, Tmp36temp;
int MAXIMUM_POOL_LEVEL = 200;
int MINIMUM_POOL_LEVEL = 240;
int FluidLevelAlarming = 0;
int poolButtonOneDelay = 0;
int poolButtonTwoDelay = 20;
int poolButtonOneCount, poolButtonTwoCount, WaterHoseValve;
int MiloneSensorReading, FloatSensorReading, FluidSensorReading, UnderFillAlarms;
int BMP085TempReading, BMP085PressureReading, BMP085AltitueReading;
int lastflowpinstate, FlowSensorReading, lastFlowSensorReadingtimer, pulses, flowpinstate;
int SensorModuleActive, SensorSamplePass, LightLevel2, PoolWaterLevelNum, PoolWaterLevelDem;
int BMPtemperatureRemain, BMPaltitudeRemain, varInBuf1, Remain1;
int BMPtemperature, BMPaltitude, SensorDisplayScreen, BMPsensorVectorNow;
int BMPpressureLastReading, BMPsensorCount, BMPsensorUpReadings, BMPsensorDownReadings, BMPpressureLastHour;
float fRemain1, fStart;
uint32_t BMPpressure, checkTime;

Adafruit_ST7735 tft = Adafruit_ST7735(DigitalTFT18shieldCsPIN, DigitalTFT18shieldDcPIN, DigitalTFT18shieldRstPIN);


// Sensor Constants - These were taken from example code by LadyAda (http://www.ladyada.net/learn/sensors/thermistor.html)
//  TMP36 Constants: (Touch these ONLY if you know what your doing, and even then I would be careful).
//  Tie the 3.3V bus to ARef so that the sensors are more accurate.
#define aref_voltage 3.3         
// Thermistor:
//   resistance at 25 degrees C
#define THERMISTORNOMINAL 10000      
//   temp. for nominal resistance (almost always 25 C)
#define TEMPERATURENOMINAL 25   
//   how many samples to take and SensorAverageReading, more takes longer
//   but is more 'smooth'
#define NUMSAMPLES 5
//   The beta coefficient of the thermistor (usually 3000-4000)
#define BCOEFFICIENT 3950
//   the value of the 'other' resistor
#define SERIESRESISTOR 10000    



void XNPlogger(const char *buffer4, int linefeed)
{
  if((linefeed == 0) || (linefeed == 1)) {   // If we want time-stamps on our log messages
    DateTime now = RTC.now();
    checkTime = now.unixtime();
    Serial.print("[");
    Serial.print(checkTime);
    Serial.print("] ");
  }
  if((linefeed == 1) || (linefeed == 3)) {
    Serial.print(buffer4);
  } else if((linefeed == 0) || (linefeed == 2)) {
    Serial.println(buffer4);
  }
}


void XNPcollectSensorData()
{
  if(SensorModuleActive == 1) {
    SensorSamplePass++;
    if(SensorSamplePass == 1) {
      SensorSamples[0] = analogRead(AnalogThermistorSensorPIN1);
    } else if(SensorSamplePass == 21) {
      SensorSamples[1] = analogRead(AnalogThermistorSensorPIN1);
    } else if(SensorSamplePass == 41) {
      SensorSamples[2] = analogRead(AnalogThermistorSensorPIN1);
    } else if(SensorSamplePass == 61) {
      SensorSamples[3] = analogRead(AnalogThermistorSensorPIN1);
    } else if(SensorSamplePass == 81) {
      SensorSamples[4] = analogRead(AnalogThermistorSensorPIN1);
      SensorAverageReading = 0;
      for(b = 0; b < 5; b++) {
         SensorAverageReading += SensorSamples[b];
      }
      SensorAverageReading /= 5;
      SensorAverageReading = 1023 / SensorAverageReading - 1;
      SensorAverageReading = SERIESRESISTOR / SensorAverageReading;
      steinhart = 0;
      steinhart = SensorAverageReading / THERMISTORNOMINAL;
      steinhart = log(steinhart);
      steinhart /= BCOEFFICIENT;
      steinhart += 1.0 / (TEMPERATURENOMINAL + 273.15);
      steinhart = 1.0 / steinhart;
      steinhart -= 273.15;   
      temperatureF = (steinhart * 9.0 / 5.0) + 32.0;
      TemperatureAIR = int(temperatureF);
      sprintf(buffer2, " ");
      XNPlogger(buffer2, 2);
      sprintf(buffer2, "-] Sensor Readings:");
      XNPlogger(buffer2, 2);
      sprintf(buffer2, "-] Thermistor #1 Temperature Reading: %d F, AlarmCount: %d", TemperatureAIR, AIRtempHIcount); 
      XNPlogger(buffer2, 2);  
    } else if(SensorSamplePass == 101) {
      SensorSamples[0] = analogRead(AnalogThermistorSensorPIN2);
    } else if(SensorSamplePass == 121) {
      SensorSamples[1] = analogRead(AnalogThermistorSensorPIN2);
    } else if(SensorSamplePass == 141) {
      SensorSamples[2] = analogRead(AnalogThermistorSensorPIN2);
    } else if(SensorSamplePass == 161) {
      SensorSamples[3] = analogRead(AnalogThermistorSensorPIN2);
    } else if(SensorSamplePass == 181) {
      SensorSamples[4] = analogRead(AnalogThermistorSensorPIN2);
      SensorAverageReading = 0;
      for(b = 0; b < 5; b++) {
         SensorAverageReading += SensorSamples[b];
      }
      SensorAverageReading /= 5;
      SensorAverageReading = 1023 / SensorAverageReading - 1;
      SensorAverageReading = SERIESRESISTOR / SensorAverageReading;
      steinhart = 0;
      steinhart = SensorAverageReading / THERMISTORNOMINAL;
      steinhart = log(steinhart);
      steinhart /= BCOEFFICIENT;
      steinhart += 1.0 / (TEMPERATURENOMINAL + 273.15);
      steinhart = 1.0 / steinhart;
      steinhart -= 273.15;   
      temperatureF = (steinhart * 9.0 / 5.0) + 32.0;
      TemperatureCPU = int(temperatureF);
      sprintf(buffer2, "-] Thermistor #2 Temperature Reading: %d F, AlarmCount: %d", TemperatureCPU, CPUtempHIcount); 
      XNPlogger(buffer2, 2);  
    } else if(SensorSamplePass == 201) {
      SensorSamples[0] = analogRead(AnalogThermistorSensorPIN3);
    } else if(SensorSamplePass == 221) {
      SensorSamples[1] = analogRead(AnalogThermistorSensorPIN3);
    } else if(SensorSamplePass == 241) {
      SensorSamples[2] = analogRead(AnalogThermistorSensorPIN3);
    } else if(SensorSamplePass == 261) {
      SensorSamples[3] = analogRead(AnalogThermistorSensorPIN3);
    } else if(SensorSamplePass == 281) {
      SensorSamples[4] = analogRead(AnalogThermistorSensorPIN3);
      SensorAverageReading = 0;
      for(b = 0; b < 5; b++) {
         SensorAverageReading += SensorSamples[b];
      }
      SensorAverageReading /= 5;
      SensorAverageReading = 1023 / SensorAverageReading - 1;
      SensorAverageReading = SERIESRESISTOR / SensorAverageReading;
      steinhart = 0;
      steinhart = SensorAverageReading / THERMISTORNOMINAL;
      steinhart = log(steinhart);
      steinhart /= BCOEFFICIENT;
      steinhart += 1.0 / (TEMPERATURENOMINAL + 273.15);
      steinhart = 1.0 / steinhart;
      steinhart -= 273.15;   
      temperatureF = (steinhart * 9.0 / 5.0) + 32.0;
      TemperatureCOOLANT = int(temperatureF);
      sprintf(buffer2, "-] Thermistor #3 Temperature Reading: %d F, AlarmCount: %d", TemperatureCOOLANT, COOLANTtempHIcount); 
      XNPlogger(buffer2, 2);
    } else if(SensorSamplePass == 301) {
      LightLevel = analogRead(AnalogPINphotoCellA8);
      LightLevel = map(LightLevel, 0, 900, 0, 10); 
      LightLevel = constrain(LightLevel, 0, 10);
      sprintf(buffer1, "-] Photo Cell Sensor #1 reading: %d)", LightLevel);
      XNPlogger(buffer1, 2);
    } else if(SensorSamplePass == 321) {
      LightLevel2 = analogRead(AnalogPINphotoCellA9);
      LightLevel2 = map(LightLevel2, 0, 900, 0, 10); 
      LightLevel2 = constrain(LightLevel2, 0, 10);
      sprintf(buffer1, "-] Photo Cell Sensor #2 reading: %d)", LightLevel2);
      XNPlogger(buffer1, 2);
    } else if(SensorSamplePass == 341) {
      SensorSamples[0] = analogRead(AnalogPINliquidLevelSensorA13);
    } else if(SensorSamplePass == 361) {
      SensorSamples[1] = analogRead(AnalogPINliquidLevelSensorA13);
    } else if(SensorSamplePass == 381) {
      SensorSamples[2] = analogRead(AnalogPINliquidLevelSensorA13);
    } else if(SensorSamplePass == 401) {
      SensorSamples[3] = analogRead(AnalogPINliquidLevelSensorA13);
    } else if(SensorSamplePass == 421) {
      SensorSamples[4] = analogRead(AnalogPINliquidLevelSensorA13);
      SensorAverageReading = 0;
      for(b = 0; b < 5; b++) {
         SensorAverageReading += SensorSamples[b];
      }
      SensorAverageReading /= 5;
      FloatSensorReading = SensorAverageReading;
      sprintf(buffer2, "-] Liquid Float Sensor: %d", FloatSensorReading); 
      XNPlogger(buffer2, 2);
    } else if(SensorSamplePass == 441) {
      SensorSamples[0] = analogRead(AnalogPINliquidLevelSensorA15);
    } else if(SensorSamplePass == 461) {
      SensorSamples[1] = analogRead(AnalogPINliquidLevelSensorA15);
    } else if(SensorSamplePass == 481) {
      SensorSamples[2] = analogRead(AnalogPINliquidLevelSensorA15);
    } else if(SensorSamplePass == 501) {
      SensorSamples[3] = analogRead(AnalogPINliquidLevelSensorA15);
    } else if(SensorSamplePass == 521) {
      SensorSamples[4] = analogRead(AnalogPINliquidLevelSensorA15);
      SensorAverageReading = 0;
      for(b = 0; b < 5; b++) {
         SensorAverageReading += SensorSamples[b];
      }
      SensorAverageReading /= 5;
      MiloneSensorReading = SensorAverageReading;
      sprintf(buffer2, "-] Liquid Milone Sensor: %d", MiloneSensorReading); 
      XNPlogger(buffer2, 2);
    } else if((SensorSamplePass > 540) && (SensorSamplePass < 562)) {
      digitalWrite(FlowSensorPIN, HIGH);
      flowpinstate = digitalRead(FlowSensorPIN);
      if(flowpinstate == lastflowpinstate) {
        lastFlowSensorReadingtimer++;
      } else {
        if(flowpinstate == HIGH) {
          //low to high transition!
          pulses++;
        }
        lastflowpinstate = flowpinstate;
        FlowSensorReading = 1000.0;
        FlowSensorReading /= lastFlowSensorReadingtimer;  // in hertz
        lastFlowSensorReadingtimer = 0;
        sprintf(buffer2, "-] Flow Sensor: %d", FlowSensorReading); 
        XNPlogger(buffer2, 2);
      }
    } else if(SensorSamplePass == 600) {
      fStart = bmp.readTemperature();
      if(fStart < 1) {
        varInBuf1 = 0;
        Remain1 = 0;
      } else {
        varInBuf1 = int(fStart);
        fRemain1 = fStart - varInBuf1;
        fRemain1 = fRemain1 * 100;
        Remain1 = int(fRemain1);
      }
      BMPtemperature = int(varInBuf1);
      BMPtemperatureRemain = Remain1;
      fStart = bmp.readAltitude(101500);
      if(fStart < 1) {
        varInBuf1 = 0;
        Remain1 = 0;
      } else {
        varInBuf1 = int(fStart);
        fRemain1 = fStart - varInBuf1;
        fRemain1 = fRemain1 * 100;
        Remain1 = int(fRemain1);
      }
      BMPaltitude = int(varInBuf1);
      BMPaltitudeRemain = Remain1;
      BMPpressureLastReading = BMPpressure;
      BMPpressure = bmp.readPressure();
      if(BMPpressure > BMPpressureLastReading) {
        BMPsensorDownReadings++;
        BMPsensorVectorNow = 2;
      } else {
        BMPsensorUpReadings++;
        BMPsensorVectorNow = 1;
      }
      DateTime now = RTC.now();
      MinutesNow = now.minute();
      if(MinutesNow == 0) {
        if(BMPsensorCount == 0) {
          BMPsensorCount = 1;
          if(BMPsensorUpReadings > BMPsensorDownReadings) {
            BMPpressureLastHour = 2;
          } else {
            BMPpressureLastHour = 1;
          }
          BMPsensorUpReadings = 0;
          BMPsensorDownReadings = 0;
        }
      } else if(MinutesNow == 1) {
        BMPsensorCount = 0;
      }
      sprintf(buffer2, "-] Current BMP Temp: %d.%d, Pressure: %lu (%lu), Altitude: %d.%d", 
        BMPtemperature, BMPtemperatureRemain, BMPpressure, BMPpressureLastReading, BMPaltitude, BMPaltitudeRemain); 
      XNPlogger(buffer2, 2);
      sprintf(buffer2, "-] Pressure Up Readings: %d, Pressure Down Readings: %d, Vector Now: %d, Vector Last Hour: %d", 
        BMPsensorUpReadings, BMPsensorDownReadings, BMPpressureLastHour, BMPsensorVectorNow);
      XNPlogger(buffer2, 2);
      SensorSamplePass == 0;
      SensorModuleActive = 2;
    }
  }
}


// Specific function for displaying the RiderCool Pool Temp Data
void XNPdisplayPoolControlSensorData(void) 
{
  if(SensorModuleActive == 3) {
    SensorDisplayScreen++;
    if(SensorDisplayScreen == 4) {
      SensorDisplayScreen = 1;
    }
    if(SensorDisplayScreen == 1) {
      tft.fillRect(1, 21, tft.width()-1, tft.height()-62, ST7735_BLUE);
      tft.setCursor(5, 26);
      tft.setTextColor(ST7735_WHITE);
      tft.setTextSize(2);
      tft.print("H20:  ");
      tft.setTextColor(ST7735_CYAN);
      sprintf(buffer1, "%d", TemperatureCOOLANT);
      tft.print(buffer1);
      tft.setTextColor(ST7735_WHITE);
      tft.print(" F");
      tft.setCursor(5, 46);
      tft.setTextColor(ST7735_WHITE);
      tft.print("Air:  ");
      tft.setTextColor(ST7735_CYAN);
      sprintf(buffer1, "%d", TemperatureAIR);
      tft.print(buffer1);
      tft.setTextColor(ST7735_WHITE);
      tft.print(" F");
      tft.setCursor(5, 66);
      tft.setTextColor(ST7735_WHITE);
      tft.print("CPU:  ");
      tft.setTextColor(ST7735_CYAN);
      sprintf(buffer1, "%d", TemperatureCPU);
      tft.print(buffer1);
      tft.setTextColor(ST7735_WHITE);
      tft.print(" F");
    } else if(SensorDisplayScreen == 2) {
      tft.fillRect(1, 21, tft.width()-1, tft.height()-62, ST7735_BLUE);
      tft.setCursor(5, 26);
      tft.setTextColor(ST7735_WHITE);
      tft.setTextSize(2);
      tft.print("Bar: ");
      tft.setTextColor(ST7735_CYAN);
      sprintf(buffer1, "%lu", BMPpressure);
      tft.print(buffer1);
      if(BMPpressureLastHour == 2) {
        tft.drawFastVLine(151, 27, 12, ST7735_GREEN);
        tft.drawPixel(150, 28, ST7735_GREEN);
        tft.drawPixel(149, 29, ST7735_GREEN);
        tft.drawPixel(148, 30, ST7735_GREEN);
        tft.drawPixel(152, 28, ST7735_GREEN);
        tft.drawPixel(153, 29, ST7735_GREEN);
        tft.drawPixel(154, 30, ST7735_GREEN);
      } else {
        tft.drawFastVLine(151, 27, 12, ST7735_MAGENTA);
        tft.drawPixel(150, 38, ST7735_MAGENTA);
        tft.drawPixel(149, 37, ST7735_MAGENTA);
        tft.drawPixel(148, 36, ST7735_MAGENTA);
        tft.drawPixel(152, 38, ST7735_MAGENTA);
        tft.drawPixel(153, 37, ST7735_MAGENTA);
        tft.drawPixel(154, 36, ST7735_MAGENTA);
      }
      if(BMPsensorVectorNow == 2) {
        tft.drawFastVLine(141, 27, 12, ST7735_GREEN);
        tft.drawPixel(140, 28, ST7735_GREEN);
        tft.drawPixel(139, 29, ST7735_GREEN);
        tft.drawPixel(138, 30, ST7735_GREEN);
        tft.drawPixel(142, 28, ST7735_GREEN);
        tft.drawPixel(143, 29, ST7735_GREEN);
        tft.drawPixel(144, 30, ST7735_GREEN);
      } else {
        tft.drawFastVLine(141, 27, 12, ST7735_MAGENTA);
        tft.drawPixel(140, 38, ST7735_MAGENTA);
        tft.drawPixel(139, 37, ST7735_MAGENTA);
        tft.drawPixel(138, 36, ST7735_MAGENTA);
        tft.drawPixel(142, 38, ST7735_MAGENTA);
        tft.drawPixel(143, 37, ST7735_MAGENTA);
        tft.drawPixel(144, 36, ST7735_MAGENTA);
      }
      tft.setCursor(5, 46);
      tft.setTextColor(ST7735_WHITE);
      tft.print("Tmp: ");
      tft.setTextColor(ST7735_CYAN);
      sprintf(buffer1, "%d.%d", BMPtemperature, BMPtemperatureRemain);
      tft.print(buffer1);
      tft.setTextColor(ST7735_WHITE);
      tft.print("C");
      tft.setCursor(5, 66);
      tft.setTextColor(ST7735_WHITE);
      tft.print("Alt: ");
      tft.setTextColor(ST7735_CYAN);
      sprintf(buffer1, "%d.%d", BMPaltitude, BMPaltitudeRemain);
      tft.print(buffer1);
    } else if(SensorDisplayScreen == 3) {
      tft.fillRect(1, 21, tft.width()-1, tft.height()-62, ST7735_BLUE);
      tft.setCursor(5, 26);
      tft.setTextColor(ST7735_WHITE);
      tft.setTextSize(2);
      tft.print("Lvl: ");
      tft.setTextColor(ST7735_CYAN);
      sprintf(buffer1, "~%d.%d\"", PoolWaterLevelNum, PoolWaterLevelDem);
      tft.print(buffer1);
      tft.setCursor(5, 46);
      tft.setTextColor(ST7735_WHITE);
      tft.print("Flt: ");
      if(FloatSensorReading > 0) {
        tft.setTextColor(ST7735_YELLOW);
        sprintf(buffer1, "ALARM");
      } else {
        tft.setTextColor(ST7735_GREEN);
        sprintf(buffer1, "OK");
      }
      tft.print(buffer1);
      tft.setCursor(5, 66);
      tft.setTextColor(ST7735_WHITE);
      tft.print("Flo: ");
      tft.setTextColor(ST7735_CYAN);
      if(WaterHoseValve == 0) {
        if(FlowSensorReading > 0) {
          tft.setTextColor(ST7735_RED);
          sprintf(buffer1, "OFF/%d", FlowSensorReading);
        } else {
          tft.setTextColor(ST7735_GREEN);
          sprintf(buffer1, "OFF/0");
        }
      } else {
        if(FlowSensorReading > 0) {
          tft.setTextColor(ST7735_YELLOW);
          sprintf(buffer1, "ON/%d", FlowSensorReading);
        } else {
          tft.setTextColor(ST7735_RED);
          sprintf(buffer1, "ON/0");
        }
      }
      tft.print(buffer1);
    }

    // Now show the clock
    DateTime now = RTC.now();
    MinutesNow = now.minute();
    if(MinutesWas != MinutesNow) {
      tft.fillRect(0, 84, tft.width()-2, tft.height()-1, ST7735_BLACK);
      tft.setCursor(5, 92);
      tft.setTextColor(ST7735_WHITE);
      tft.setTextSize(2);
      tft.print("Time: ");
      tft.setTextColor(ST7735_CYAN);
      tft.print("");
      MinutesWas = MinutesNow;
      HoursNow = now.hour();
      if(HoursNow > 12) {
        HoursNow = HoursNow - 12;
      }
      if(HoursNow > 99) {
        HoursNow = HoursNow - 90;
        tft.print(HoursNow);
      }
      tft.print(HoursNow);
      tft.print(":");
      tft.setTextColor(ST7735_CYAN);
      if(MinutesNow > 49) {
        tft.print("5");
        MinutesNow = MinutesNow - 50;
      } else if(MinutesNow > 39) {
        tft.print("4");
        MinutesNow = MinutesNow - 40;
      } else if(MinutesNow > 29) {
        tft.print("3");
        MinutesNow = MinutesNow - 30;
      } else if(MinutesNow > 19) {
        tft.print("2");
        MinutesNow = MinutesNow - 20;
      } else if(MinutesNow > 9) {
        tft.print("1");
        MinutesNow = MinutesNow - 10;
      } else {
        tft.print("0");
      }
      tft.print(MinutesNow);
    }
    tft.drawRect(0, 20, tft.width()-1, tft.height()-62, ST7735_BLUE);
    //tft.drawRect(0, 20, tft.width()-1, tft.height()-41, ST7735_BLUE);
  }
  SensorModuleActive = 4;
}


/* Milone 9" Fluid Level Sensor Tare/Birth cirtificate levels:
  3.5IN = > 270
    4IN = 270 = Minimum accurate range
  4.5IN = 250
    5IN = 240 = "Normal end of Low Range" - trigger for filling pool.
  5.5IN = 230 = Middle of normal range, 240-200
    6IN = 210 = "Normal end of High Range"  
  6.1IN = 200 = Trigger point for stopping fill on pool.
  6.5IN = 190
    7IN = 170
  7.1IN = 172 = Float Sensor Tilt Point
  7.5IN = 155
    8IN = 145 = Maximum accurate range.
    9IN = < 145
*/

// Specific function for processing the RiderCool Pool Sensor Data
void XNPprocessPoolControlSensorData(void) 
{
  if(SensorModuleActive == 2) {
    if(MiloneSensorReading > 270) {
      PoolWaterLevelNum = 4;
      PoolWaterLevelDem = 0;
    } else if(MiloneSensorReading > 250) {
      PoolWaterLevelNum = 4;
      PoolWaterLevelDem = 5;
    } else if(MiloneSensorReading > 240) {
      PoolWaterLevelNum = 5;
      PoolWaterLevelDem = 0;
    } else if(MiloneSensorReading > 230) {
      PoolWaterLevelNum = 5;
      PoolWaterLevelDem = 5;
    } else if(MiloneSensorReading > 210) {
      PoolWaterLevelNum = 6;
      PoolWaterLevelDem = 0;
    } else if(MiloneSensorReading > 190) {
      PoolWaterLevelNum = 6;
      PoolWaterLevelDem = 5;
    } else if(MiloneSensorReading > 170) {
      PoolWaterLevelNum = 7;
      PoolWaterLevelDem = 0;
    } else if(MiloneSensorReading > 155) {
      PoolWaterLevelNum = 7;
      PoolWaterLevelDem = 5;
    } else {
      PoolWaterLevelNum = 8;
      PoolWaterLevelDem = 0;
    }
    if(FluidLevelAlarming == 1) {
      if((MiloneSensorReading > MAXIMUM_POOL_LEVEL) || (FloatSensorReading > 0)) {
          digitalWrite(DigitalPSTdrivePIN1, LOW);
          digitalWrite(DigitalPSTdrivePIN2, LOW);
        if(WaterHoseValve == 1) {
          WaterHoseValve = 0;
        }
      } else if((MiloneSensorReading < MINIMUM_POOL_LEVEL) && (FloatSensorReading < 1)) {
        if(UnderFillAlarms < 50) {
          UnderFillAlarms++;
        } else if(UnderFillAlarms < 999) {
          UnderFillAlarms = 999;
          sprintf(buffer1, "Pool UnderFill Alarm! (Reading: %d, Level: %d.%d) Turning on water to fill it up!", MiloneSensorReading, PoolWaterLevelNum, PoolWaterLevelDem);
          XNPlogger(buffer1, 2);
          digitalWrite(DigitalPSTdrivePIN1, HIGH);
          digitalWrite(DigitalPSTdrivePIN2, HIGH);
          WaterHoseValve = 1;
        }
      } else {
        if(WaterHoseValve == 1) {
          WaterHoseValve = 0;
          UnderFillAlarms = 0;
          digitalWrite(DigitalRELAYdrivePIN, LOW);
          sprintf(buffer1, "Pool now showing in normal fill range, turning-off water valve!");
          XNPlogger(buffer1, 2);
        }
      }
    }
  }
  SensorModuleActive = 3;
}





// /////////////////
// Main Functions //
// /////////////////

void setup()
{
  // Setup pin I/O modes.
  pinMode(AnalogThermistorSensorPIN1, INPUT);
  pinMode(AnalogThermistorSensorPIN2, INPUT);
  pinMode(AnalogThermistorSensorPIN3, INPUT);
  pinMode(AnalogPINtmp36tempA7, INPUT);
  pinMode(AnalogPINphotoCellA8, INPUT);
  pinMode(AnalogPINphotoCellA9, INPUT);
  pinMode(AnalogPINliquidLevelSensorA13, INPUT);
  pinMode(AnalogPINliquidLevelSensorA15, INPUT);
  pinMode(AnalogPINbutton1, INPUT);
  pinMode(AnalogPINbutton2, INPUT);

  pinMode(DigitalTFT18shieldCsPIN, OUTPUT);
  pinMode(DigitalTFT18shieldRstPIN, OUTPUT);
  pinMode(DigitalTFT18shieldLightPIN, OUTPUT);
  pinMode(DigitalTFT18shieldDcPIN, OUTPUT);
  pinMode(DigitalPSTdrivePIN1, OUTPUT);
  pinMode(DigitalPSTdrivePIN2, OUTPUT);
  pinMode(DigitalPSTdrivePIN3, OUTPUT);
  pinMode(DigitalPSTdrivePIN4, OUTPUT);
  pinMode(DigitalRELAYdrivePIN, OUTPUT);
  pinMode(DigitalPINcontrollerPower, OUTPUT);
  pinMode(DigitalPINRGBLEDstatus, OUTPUT);
  pinMode(AnalogPINbutton1, INPUT);
  pinMode(AnalogPINbutton2, INPUT);

  // Set the data rate for the console
  Serial.begin(115200);

  // Start Serial3 for communicating to the LED RGB Controllers
  Serial3.begin(9600);

  // Set the time up.
  RTC.begin(DateTime(__DATE__, __TIME__));
  DateTime now = RTC.now();
  now = RTC.now();

  // Start the BMP Barometric Pressure sensor
  bmp.begin();

  // Set the Analog reference voltage to 3.3v from the Arduinos
  analogReference(EXTERNAL);

  sprintf(buffer1, ">> RiderCool Startup!");
  XNPlogger(buffer1, 0);
  sprintf(buffer1, " ");
  XNPlogger(buffer1, 2);
  sprintf(buffer1, " RiderCool - A Pool Management System (non-XNP version)");
  XNPlogger(buffer1, 2);
  sprintf(buffer1, " by Kristopher Kortright of Sojourn Studios (o_o), August 2012");
  XNPlogger(buffer1, 2);
  sprintf(buffer1, " This sketch is based on dozens of tutorials by Limor Fried and Adafruit Industries");
  XNPlogger(buffer1, 2);
  sprintf(buffer1, " This software is licensed via CERN Open Source Hardware License, under the same");
  XNPlogger(buffer1, 2);
  sprintf(buffer1, " Terms as Adafruit Industries uses for all of it's tutorials.");
  XNPlogger(buffer1, 2);

  // Now turn on power to the LED RGB Shields!
  digitalWrite(DigitalRELAYdrivePIN, HIGH);

  digitalWrite(DigitalTFT18shieldLightPIN, HIGH);
  tft.initR(INITR_GREENTAB);
  tft.fillScreen(ST7735_BLACK);
  tft.setTextWrap(false);
  tft.fillScreen(ST7735_BLACK);
  tft.setRotation(3);
  tft.setCursor(1, 1);
  tft.setTextColor(ST7735_CYAN);
  tft.setTextSize(2);
  tft.print("RiderCool");
  for (int16_t x=9; x < tft.width()+10; x+=10*2) {
    for (int16_t y=30; y < tft.height(); y+=10*2) {
      tft.drawCircle(x, y, 9, ST7735_WHITE);
      tft.fillCircle(x, y, 8, ST7735_BLUE);
    }
  }
  delay(3000);
  tft.fillRect(0, 20, 159, 64, ST7735_BLUE);
  tft.fillRect(0, 85, 159, 60, ST7735_BLACK);
  tft.setCursor(40, 40);
  tft.setTextColor(ST7735_CYAN);
  tft.setTextSize(2);
  tft.print("GET WET!");
}


// Master Loop function
void loop()
{
  MasterSensor++;

  // Process all sensor readings.
  if(MasterSensor > 150000) {
    MasterSensor = 0;
    SensorModuleActive = 1;
  }
  if(SensorModuleActive == 1) {
    XNPcollectSensorData();
  }
  if(SensorModuleActive == 2) {
    XNPprocessPoolControlSensorData();
    XNPdisplayPoolControlSensorData();
  }

  // Handle the two option buttons elegantly (for the user)
  if(poolButtonOneDelay < 1) {
    g = analogRead(AnalogPINbutton1);
    if(g < 100) {
      poolButtonOneCount++;
    } else {
      poolButtonOneCount = 0;
      ButtonOneState = 0;
    }
    poolButtonOneDelay = 40;
  } else {
    poolButtonOneDelay--;
  }
  if(poolButtonTwoDelay < 1) {
    g = analogRead(AnalogPINbutton2);
    if(g > 100) {
      poolButtonTwoCount++;
    } else {
      poolButtonTwoCount = 0;
      ButtonTwoState = 0;
    }
    poolButtonTwoDelay = 40;
  } else {
    poolButtonTwoDelay--;
  }
  if(poolButtonOneCount == 50) {
    ButtonOneState = 1;
    poolButtonOneCount = 0;
  }
  if(poolButtonTwoCount == 50) {
    ButtonTwoState = 1;
    poolButtonTwoCount = 0;
  }
  if((ButtonOneState == 1) && (ButtonTwoState == 1)) {
    sprintf(buffer1, "BUTTONS #1 and #2 HIT!");
    XNPlogger(buffer1, 0);
    ButtonOneState = 2;
    ButtonTwoState = 2;
    poolButtonOneDelay = 2000;
    poolButtonTwoDelay = 2000;
    // Do something
  } else if((ButtonOneState == 1) && (ButtonTwoState == 0)) {
    sprintf(buffer1, "BUTTON #1 HIT!");
    XNPlogger(buffer1, 0);
    g = 0;
    ButtonOneState = 2;
    poolButtonOneDelay = 2000;
    sprintf(buffer1, "stop");
    Serial3.print(buffer1); 
    // Do something
  } else if((ButtonOneState == 0) && (ButtonTwoState == 1)) {
    sprintf(buffer1, "BUTTON #2 HIT!");
    XNPlogger(buffer1, 0);
    h = 1023;
    ButtonTwoState = 2;
    poolButtonTwoDelay = 2000;
    sprintf(buffer1, "cycle");
    Serial3.print(buffer1); 
    // Do something
  }
}
