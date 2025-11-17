//+------------------------------------------------------------------+
//|                                                           II.mq5 |
//|                                                      Edward Bako |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Edward Bako"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   2
//--- plot Main
#property indicator_label1  "Main"
#property indicator_type1   DRAW_HISTOGRAM
#property indicator_color1  clrOrangeRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- plot sma
#property indicator_label2  "sma"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRoyalBlue
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1

input int Period_II = 14;
input int II_SMA = 20;
//--- indicator buffers
double         MainBuffer[];
double         smaBuffer[];
double         IIBuffer[];

double         sum = 0;
double         sumv = 0;
datetime       TimePrev;
bool           inited = false;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0, MainBuffer, INDICATOR_DATA);
   SetIndexBuffer(1, smaBuffer, INDICATOR_DATA);
   SetIndexBuffer(2, IIBuffer, INDICATOR_CALCULATIONS);
   
   ArraySetAsSeries(MainBuffer, true);
   ArraySetAsSeries(smaBuffer, true);
   ArraySetAsSeries(IIBuffer, true);
   
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
   if(rates_total < II_SMA)
      return(0);
      
//--- set arrays as series
   ArraySetAsSeries(time, true);
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   ArraySetAsSeries(close, true);
   ArraySetAsSeries(tick_volume, true);
   ArraySetAsSeries(volume, true);
      
   int start;
   if(prev_calculated == 0)
     {
      start = rates_total - Period_II - 1;
      sum = 0;
      sumv = 0;
      inited = false;
     }
   else
      start = rates_total - prev_calculated;
   
//--- calculate II values first
   for(int i = start; i >= 0; i--)
     {
      IIBuffer[i] = CalculateII(i, high, low, close, volume);
     }
   
//--- main calculation loop
   int i = start;
   while(i >= 0)
     {
      if(i < rates_total - 1)
        {
         sum += IIBuffer[i];
         sumv += tick_volume[i];
        }
      
      if(i < rates_total - Period_II)   
        {
         sum -= IIBuffer[i + Period_II];
         sumv -= tick_volume[i + Period_II];
         if(sumv > 0)
            MainBuffer[i] = sum / sumv;
         else
            MainBuffer[i] = 0;
        }
      else
         MainBuffer[i] = 0;   
         
      i--;
     }
      
//--- handle current bar
   if(TimePrev != time[0])
     {
      TimePrev = time[0];
      if(inited == false)
         inited = true;
      else
        {
         sum += IIBuffer[1];
         sumv += tick_volume[1];
        }
      if(rates_total > Period_II)
        {
         sum -= IIBuffer[Period_II];
         sumv -= tick_volume[Period_II];
        }
     }

   IIBuffer[0] = CalculateII(0, high, low, close, volume);
   if(sumv + tick_volume[0] > 0)
      MainBuffer[0] = (sum + IIBuffer[0]) / (sumv + tick_volume[0]);
   else
      MainBuffer[0] = 0;
   
//--- calculate SMA (if needed)
   if(II_SMA > 0)
     {
      for(int i = 0; i < rates_total - II_SMA + 1; i++)
        {
         double sma_sum = 0;
         for(int j = i; j < i + II_SMA; j++)
            sma_sum += MainBuffer[j];
         smaBuffer[i] = sma_sum / II_SMA;
        }
     }
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Calculate Intraday Intensity                                     |
//+------------------------------------------------------------------+
double CalculateII(int index, const double &high[], const double &low[], 
                   const double &close[], const long &volume[])
  {
   double range = high[index] - low[index];
   if(range > 0)
      return ((2 * close[index] - high[index] - low[index]) / range * volume[index]) * 10000.0;
   return 0.0;   
  }               
//+------------------------------------------------------------------+
