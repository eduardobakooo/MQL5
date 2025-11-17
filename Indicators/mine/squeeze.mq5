//+------------------------------------------------------------------+
//|                                                      squeeze.mq5 |
//|                                                      Edward Bako |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Edward Bako"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   5
//--- plot squeeze
#property indicator_label1  "Squeeze"
#property indicator_type1   DRAW_HISTOGRAM
#property indicator_color1  clrDodgerBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- plot min
#property indicator_label2  "Min"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrSlateGray
#property indicator_style2  STYLE_DASH
#property indicator_width2  1
//--- plot max
#property indicator_label3  "Max"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrSlateGray
#property indicator_style3  STYLE_DASH
#property indicator_width3  1
//--- plot ready
#property indicator_label4  "Ready"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrRed
#property indicator_style4  STYLE_DOT
#property indicator_width4  1
//--- plot bandwidth
#property indicator_label5  "Bandwidth"
#property indicator_type5   DRAW_LINE
#property indicator_color5  clrBlack
#property indicator_style5  STYLE_SOLID
#property indicator_width5  2

input int StepBack = 200;
input int BandsPeriod = 20;
input double BandsDeviation = 2.0;
input double MinSqueze = 0.15;

double squeeze[], min[], max[], ready[], bandwidth[];
int bands_handle = INVALID_HANDLE;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0, squeeze, INDICATOR_DATA);
   SetIndexBuffer(1, min, INDICATOR_DATA);
   SetIndexBuffer(2, max, INDICATOR_DATA);
   SetIndexBuffer(3, ready, INDICATOR_DATA);
   SetIndexBuffer(4, bandwidth, INDICATOR_DATA);
   
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
   if(rates_total < StepBack + BandsPeriod)
      return(0);
   
   int start;
   if(prev_calculated == 0)
      start = StepBack + BandsPeriod - 1;
   else
      start = prev_calculated - 1;
   
//--- prepare buffers for bands
   double upper[], lower[], middle[];
   ArraySetAsSeries(upper, true);
   ArraySetAsSeries(lower, true);
   ArraySetAsSeries(middle, true);
   
//--- copy Bollinger Bands data
   int to_copy = rates_total - start + StepBack + 1;
   if(CopyBuffer(bands_handle, 0, 0, to_copy, middle) <= 0)
     {
      Print("Failed to copy middle band buffer");
      return(0);
     }
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
      
//--- calculate bandwidth
      if(middle[index] > 0)
         bandwidth[i] = (upper[index] - lower[index]) / middle[index] * 100.0;
      else
         bandwidth[i] = 0.0;
      
//--- find min/max in StepBack period
      if(i >= StepBack)
        {
         double minimum = bandwidth[i];
         double maximum = 0;
         
         for(int j = i; j >= i - StepBack + 1 && j >= 0; j--)
           {
            if(minimum > bandwidth[j])
               minimum = bandwidth[j];
            if(maximum < bandwidth[j])
               maximum = bandwidth[j];
           }
         
         min[i] = minimum;
         max[i] = maximum;
         ready[i] = min[i] + (max[i] - min[i]) * MinSqueze;
         
//--- calculate squeeze value
         if(bandwidth[i] < ready[i] && (ready[i] - min[i]) > 0)
            squeeze[i] = max[i] * (ready[i] - bandwidth[i]) / (ready[i] - min[i]);
         else
            squeeze[i] = 0.0;
        }
      else
        {
         min[i] = 0;
         max[i] = 0;
         ready[i] = 0;
         squeeze[i] = 0;
        }
     }
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
