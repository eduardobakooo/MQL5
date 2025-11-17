//+------------------------------------------------------------------+
//|                                                    percent_b.mq5 |
//|                                                      Edward Bako |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Edward Bako"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 1
#property indicator_plots   1
//--- plot MAIN
#property indicator_label1  "MAIN"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- levels
#property indicator_level1 0
#property indicator_level2 50
#property indicator_level3 100
#property indicator_levelcolor clrSlateGray
#property indicator_levelstyle STYLE_DOT
#property indicator_levelwidth 1
//--- input parameters
input int      BandsPeriod=20;
input double   BandsDeviation=2.0;
//--- indicator buffers
double         MAINBuffer[];

int inside = 0;
int bands_handle = INVALID_HANDLE;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,MAINBuffer,INDICATOR_DATA);
   
//--- create Bollinger Bands indicator handle
   bands_handle = iBands(_Symbol, _Period, BandsPeriod, 0, BandsDeviation, PRICE_TYPICAL);
   if(bands_handle == INVALID_HANDLE)
     {
      Print("Failed to create iBands indicator handle");
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
   if(bands_handle != INVALID_HANDLE)
      IndicatorRelease(bands_handle);
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
   if(rates_total < BandsPeriod)
      return(0);
      
   int start;
   if(prev_calculated == 0)
      start = BandsPeriod - 1;
   else
      start = prev_calculated - 1;
   
//--- prepare buffers for bands
   double upper[], lower[];
   ArraySetAsSeries(upper, true);
   ArraySetAsSeries(lower, true);
   
//--- copy Bollinger Bands data
   int to_copy = rates_total - start + 1;
   if(CopyBuffer(bands_handle, 1, 0, to_copy, upper) <= 0)
     {
      Print("Failed to copy upper band buffer");
      return(0);
     }
   if(CopyBuffer(bands_handle, 2, 0, to_copy, lower) <= 0)
     {
      Print("Failed to copy lower band buffer");
      return(0);
     }
   
//--- main calculation loop
   for(int i = start; i < rates_total; i++)
     {
      int index = rates_total - 1 - i;
      double price = (high[i] + low[i] + close[i]) / 3.0;
      
      if(price < upper[index] && price > lower[index])
         inside++;
      
      double band_width = upper[index] - lower[index];
      if(band_width > 0)
         MAINBuffer[i] = (price - lower[index]) / band_width * 100.0;
      else
         MAINBuffer[i] = 0.0;
     }
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
