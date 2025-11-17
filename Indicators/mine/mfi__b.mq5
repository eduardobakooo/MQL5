//+------------------------------------------------------------------+
//|                                                       mfi_%b.mq5 |
//|                                                      Edward Bako |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Edward Bako"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   1
//--- plot Main
#property indicator_label1  "Main"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrFireBrick
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- Levels
#property indicator_level1 0
#property indicator_level2 50
#property indicator_level3 100
#property indicator_levelcolor clrSlateGray
#property indicator_levelstyle STYLE_DOT
#property indicator_levelwidth 1
//--- input parameters
input int      MFIPeriod=14;
input int      BandsPeriod=50;
input double   BandsDeviation=2.0;
//--- indicator buffers
double         MainBuffer[], MFI[];

int inside = 0;
int outside = 0;
int middleout = 0;
int stepback = 1000;
int mfi_handle = INVALID_HANDLE;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0, MainBuffer, INDICATOR_DATA);
   SetIndexBuffer(1, MFI, INDICATOR_CALCULATIONS);
   
//--- create MFI indicator handle
   mfi_handle = iMFI(_Symbol, _Period, MFIPeriod, VOLUME_TICK);
   if(mfi_handle == INVALID_HANDLE)
     {
      Print("Failed to create iMFI indicator handle");
      return(INIT_FAILED);
     }
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   if(mfi_handle != INVALID_HANDLE)
      IndicatorRelease(mfi_handle);
  }
//+------------------------------------------------------------------+
//| Calculate Bollinger Bands on array                               |
//+------------------------------------------------------------------+
void CalculateBandsOnArray(const double &array[], int total, int period, double deviation,
                          int index, double &upper, double &middle, double &lower)
  {
   if(index + period > total)
     {
      upper = 0;
      middle = 0;
      lower = 0;
      return;
     }
   
//--- calculate SMA (middle band)
   double sum = 0;
   for(int i = index; i < index + period; i++)
      sum += array[i];
   middle = sum / period;
   
//--- calculate standard deviation
   double sum_deviation = 0;
   for(int i = index; i < index + period; i++)
     {
      double diff = array[i] - middle;
      sum_deviation += diff * diff;
     }
   double std_dev = MathSqrt(sum_deviation / period);
   
//--- calculate upper and lower bands
   upper = middle + deviation * std_dev;
   lower = middle - deviation * std_dev;
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   if(rates_total < BandsPeriod + MFIPeriod)
      return(0);
      
   int start;
   if(prev_calculated == 0)
      start = BandsPeriod + MFIPeriod - 1;
   else
      start = prev_calculated - 1;
   
//--- copy MFI data
   int to_copy = rates_total - start + BandsPeriod;
   if(CopyBuffer(mfi_handle, 0, 0, to_copy, MFI) <= 0)
     {
      Print("Failed to copy MFI buffer");
      return(0);
     }
   
//--- main calculation loop
   for(int i = start; i < rates_total; i++)
     {
      double upper, lower, middle;
      
//--- calculate Bollinger Bands on MFI array
      CalculateBandsOnArray(MFI, rates_total, BandsPeriod, BandsDeviation, i, upper, middle, lower);
      
//--- statistics
      if(i < rates_total - stepback)
        {
         if(middle > 75 || middle < 25)
            middleout++;
        }
         
      if(MFI[i] < upper && MFI[i] > lower)
         inside++;
      else
         outside++;      
      
//--- calculate %b value
      double band_width = upper - lower;
      if(band_width > 0)
         MainBuffer[i] = (MFI[i] - lower) / band_width * 100.0;
      else
         MainBuffer[i] = 0.0;
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
