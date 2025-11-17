//+------------------------------------------------------------------+
//|                                                       volume.mq5 |
//|                                                      Edward Bako |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Edward Bako"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   2
//--- plot MAIN
#property indicator_label1  "MAIN"
#property indicator_type1   DRAW_HISTOGRAM
#property indicator_color1  clrDodgerBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot MA
#property indicator_label2  "MA"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrOrangeRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- level
#property indicator_level1 100
#property indicator_levelcolor clrSeaGreen
#property indicator_levelstyle STYLE_SOLID
#property indicator_levelwidth 1
//--- input parameters
input int      MAPeriod=50;
//--- indicator buffers
double         MAINBuffer[], MA[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0, MAINBuffer, INDICATOR_DATA);
   SetIndexBuffer(1, MA, INDICATOR_DATA);
   
//---
   return(INIT_SUCCEEDED);
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
   if(rates_total < MAPeriod)
      return(0);
   
   int start;
   if(prev_calculated == 0)
      start = MAPeriod - 1;
   else
      start = prev_calculated - 1;
   
//--- main calculation loop
   for(int i = start; i < rates_total; i++)
     {
      if(i < MAPeriod - 1)
        {
         MAINBuffer[i] = 0;
         MA[i] = 0;
         continue;
        }
      
//--- calculate moving average of volume
      double sum = 0;
      for(int j = 0; j < MAPeriod; j++)
         sum += tick_volume[i - j];
      
      double ma = sum / MAPeriod;
      MA[i] = ma;
      
//--- calculate volume as percentage of MA
      if(ma > 0)
         MAINBuffer[i] = (double)tick_volume[i] / ma * 100.0;
      else
         MAINBuffer[i] = 0.0;
     }
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
