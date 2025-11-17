//+------------------------------------------------------------------+
//|                                                        adxma.mq5 |
//|                                                      Edward Bako |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Edward Bako"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   2
//--- plot ADXMA
#property indicator_label1  "ADXMA"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_DASH
#property indicator_width1  1
//--- plot ADX
#property indicator_label2  "ADX"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrDodgerBlue
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- level
#property indicator_level1 25
#property indicator_levelcolor clrSlateGray
#property indicator_levelstyle STYLE_DOT
#property indicator_levelwidth 1
//--- input parameters
input int      ADXPeriod=14;
input int      MAPeriod=20;

double ADXMA[], ADX[];
int adx_handle = INVALID_HANDLE;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0, ADXMA, INDICATOR_DATA);
   SetIndexBuffer(1, ADX, INDICATOR_DATA);
   
//--- create ADX indicator handle
   adx_handle = iADX(_Symbol, _Period, ADXPeriod);
   if(adx_handle == INVALID_HANDLE)
     {
      Print("Failed to create iADX indicator handle");
      return(INIT_FAILED);
     }
   
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   if(adx_handle != INVALID_HANDLE)
      IndicatorRelease(adx_handle);
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
   if(rates_total < MathMax(ADXPeriod, MAPeriod))
      return(0);
   
   int start;
   if(prev_calculated == 0)
      start = MAPeriod - 1;
   else
      start = prev_calculated - 1;
   
//--- copy ADX data
   int to_copy = rates_total - start + MAPeriod;
   if(CopyBuffer(adx_handle, 0, 0, to_copy, ADX) <= 0)
     {
      Print("Failed to copy ADX buffer");
      return(0);
     }
   
//--- calculate moving average on ADX
   for(int i = start; i < rates_total; i++)
     {
      if(i < MAPeriod - 1)
        {
         ADXMA[i] = 0;
         continue;
        }
      
      double sum = 0;
      for(int j = 0; j < MAPeriod; j++)
         sum += ADX[i - j];
      
      ADXMA[i] = sum / MAPeriod;
     }
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
