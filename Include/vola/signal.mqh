//+------------------------------------------------------------------+
//|                                                       signal.mqh |
//|                                                      Edward Bako |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Edward Bako"
#property link      "https://www.mql5.com"
//+------------------------------------------------------------------+
//| Define Signals codes                                             |
//+------------------------------------------------------------------+
#define SIGNAL_OPEN_BUY       10
#define SIGNAL_CLOSE_BUY      11
#define SIGNAL_OPEN_SELL      20
#define SIGNAL_CLOSE_SELL     21
#define SIGNAL_NONE           0
#define SIGNAL_WRONG          -1
//+------------------------------------------------------------------+
//| Input variables for tune                                         |
//+------------------------------------------------------------------+
input int StepBack=200;
input int BandsPeriod=20;
input double BandsDeviation=3.2;
input double EnterLimit=35.0;
input double ExitLimit=50.0;
input double MinSqueeze=0.15;
input int ADXPeriod=14;
input int ADXMAPeriod=20;
input double SARStep= 0.02;
input double SARMax = 0.2;
input int MFIPeriod = 14;
input int IILength = 10;
input int ADXMALimit = 40;
input int LongMAPeriod = 100;
input int LongerMAPeriod = 150;
input double MACDLimit = 3.0;

//+------------------------------------------------------------------+
//| Produce trade signal                                             |
//+------------------------------------------------------------------+
int Signal()
  {
      TReply r;
      redis.Command("HGET %s signal", SignalKey(), r);

      if(r.type == REDIS_REPLY_ERROR)
         { 
            Print("Signal Redis Error: ", r.str); 
            return(SIGNAL_NONE);
         }
         
      if(r.type == REDIS_REPLY_STRING && StringLen(r.str) > 0)
         { return((int)StringToInteger(r.str)); }
      
      return(SIGNAL_NONE);
      
   //if(Rates[0].tick_volume > 1)
   //   return(SIGNAL_NONE);
   
   // double ADX[1], ADXPlus[2], ADXMinus[2], ADXMA[1],
   //       PercentB[2], II[2], SAR[2], squeeze[1], MFI[1],
   //       MA_Long[1], MA_Longer[1], MacdCurrent[1], SignalCurrent[1];

   //int adx_handle = iADX(_Symbol, _Period, ADXPeriod);
   //CopyBuffer(adx_handle, 0, 0, 1, ADX);
   //CopyBuffer(adx_handle, 1, 0, 2, ADXPlus);
   //CopyBuffer(adx_handle, 2, 0, 2, ADXMinus);
   
   //int adxma_handle = iCustom(_Symbol, _Period, "mine\\adxma", ADXPeriod, ADXMAPeriod);
   //CopyBuffer(adxma_handle, 0, 0, 1, ADXMA);
   
   //int percentb_handle = iCustom(_Symbol, _Period, "mine\\percent_b", BandsPeriod, BandsDeviation);
   //CopyBuffer(percentb_handle, 0, 0, 2, PercentB);
   
   //int ii_handle = iCustom(_Symbol, _Period, "mine\\II", IILength, 20);
   //CopyBuffer(ii_handle, 0, 0, 2, II);
   
   //int sar_handle = iSAR(_Symbol, _Period, SARStep, SARMax);
   //CopyBuffer(sar_handle, 0, 0, 2, SAR);
   
   //int squeeze_handle = iCustom(_Symbol, _Period, "mine\\squeeze", StepBack, BandsPeriod, BandsDeviation, MinSqueeze);
   //CopyBuffer(squeeze_handle, 0, 0, 1, squeeze);
   
   //int mfi_handle = iMFI(_Symbol, _Period, MFIPeriod, VOLUME_TICK);
   //CopyBuffer(mfi_handle, 0, 0, 1, MFI);
   
   //int ma_long_handle = iMA(_Symbol, _Period, LongMAPeriod, 0, MODE_SMA, PRICE_TYPICAL);
   //CopyBuffer(ma_long_handle, 0, 0, 1, MA_Long);
   
   //int ma_longer_handle = iMA(_Symbol, _Period, LongerMAPeriod, 0, MODE_SMA, PRICE_TYPICAL);
   //CopyBuffer(ma_longer_handle, 0, 0, 1, MA_Longer);
   
   //int macd_handle = iMACD(_Symbol, _Period, 12, 26, 9, PRICE_TYPICAL);
   //CopyBuffer(macd_handle, 0, 0, 1, MacdCurrent);
   //CopyBuffer(macd_handle, 1, 0, 1, SignalCurrent);
   
   
   //if(PercentB[1] < 100 - EnterLimit && PercentB[0] >= 100 - EnterLimit )
   //   return(SIGNAL_OPEN_BUY);
      
   //if(PercentB[1] > EnterLimit && PercentB[0] <= EnterLimit )
   //   return(SIGNAL_OPEN_SELL);
      
//   if(PercentB[1] >= 100 - ExitLimit && PercentB[0] < 100 - ExitLimit)
//      return(SIGNAL_CLOSE_BUY);
//      
//   if(PercentB[1] <= ExitLimit && PercentB[0] > ExitLimit)
//      return(SIGNAL_CLOSE_SELL);      

//   if(MA_Long[0] > MA_Longer[0] && SAR[0] >= SAR[1])
      //return(SIGNAL_OPEN_BUY)
   //if(MA_Long[0] < MA_Longer[0] && SAR[0] >= SAR[1])
      //return(SIGNAL_CLOSE_BUY)
//      
   //if(MA_Long[0] < MA_Longer[0] && SAR[0] <= SAR[1])
      //return(SIGNAL_OPEN_SELL)
   //if(MA_Long[0] > MA_Longer[0] && SAR[0] <= SAR[1])
      //return(SIGNAL_CLOSE_SELL)      

      
  }
//+------------------------------------------------------------------+
string SignalKey()
   {
         return(NormalizeSymbol(_Symbol) + ":" + IntegerToString(_Period) + ":signal");
   }
//+------------------------------------------------------------------+
//| Normalize symbol name - remove common broker suffixes like 'rfd' |
//+------------------------------------------------------------------+
string NormalizeSymbol(const string sym)
   {
    int len = StringLen(sym);
    if(len>3)
       {
         string tail = StringSubstr(sym,len-3,3);
         if(StringToLower(tail)=="rfd")
             return(StringSubstr(sym,0,len-3));
       }
    return(sym);
   }
//+------------------------------------------------------------------+