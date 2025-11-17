//+------------------------------------------------------------------+
//|                                                        trade.mqh |
//|                                                      Edward Bako |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Edward Bako"
#property link      "https://www.mql5.com"

#include <Trade\Trade.mqh>

CTrade trade;
//+------------------------------------------------------------------+
//| Trades Controller                                                |
//+------------------------------------------------------------------+
void Trade(int TradeOp)
  {
   switch(TradeOp)
     {
      case SIGNAL_OPEN_BUY:
         
         Close_All(ORDER_TYPE_SELL);
         lots = Lot();
         Print("SIGNAL OPEN BUY received. Lots: ", lots, ". OpenedOrders: ", orders_total);
         if(lots > 0 && orders_total < max_orders)
            { OpenOrder(ORDER_TYPE_BUY, lots); }
         return;
      case SIGNAL_CLOSE_BUY:
         //Print("SIGNAL CLOSE BUY received.");
         Close_All(ORDER_TYPE_BUY);
         return;
      case SIGNAL_OPEN_SELL:
         
         Close_All(ORDER_TYPE_BUY);
         lots = Lot();
         Print("SIGNAL OPEN SELL received. Lots: ", lots, ". OpenedOrders: ", orders_total);
         if(lots > 0 && orders_total < max_orders)
            { OpenOrder(ORDER_TYPE_SELL, lots); }
         return;
      case SIGNAL_CLOSE_SELL:
         //Print("SIGNAL CLOSE SELL received.");
         Close_All(ORDER_TYPE_SELL);
         return;
      case SIGNAL_NONE:
         //Trail_Stop(ORDER_TYPE_BUY);
         //Trail_Stop(ORDER_TYPE_SELL);
         return;
     }
  }
//+------------------------------------------------------------------+
//| Close all positions by type                                      |
//+------------------------------------------------------------------+
void Close_All(ENUM_ORDER_TYPE Tip)
  {
   //Print("Close All ", OrderTypeToStr(Tip), "S");

   for(int i = 0; i < orders_total; i++)
     {
      ulong ticket;
      double lot;

      if((int)orders[i][ORDER_G_TYPE] == Tip)
        {
         lot = orders[i][ORDER_G_LOTS];
         ticket = (ulong)orders[i][ORDER_G_TICKET];

         Print("Trying to close position #", ticket, "...");
         
         int attempts = 0;
         while(attempts < 5)
           {
            bool Answer = trade.PositionClose(ticket, 3);

            if(Answer == true)
               break;
            else
              {
               if(Errors(trade.ResultRetcode()) == false)
                  break;
               attempts++;
              }
           }
        }
     }
   return;
  }
//+------------------------------------------------------------------+
//| Calculate right price by order type                              |
//+------------------------------------------------------------------+
double RightPrice(ENUM_ORDER_TYPE Tip)
  {
   switch(Tip)
     {
      case ORDER_TYPE_BUY: return(SymbolInfoDouble(_Symbol, SYMBOL_ASK));
      case ORDER_TYPE_SELL: return(SymbolInfoDouble(_Symbol, SYMBOL_BID));
     }
   return(SymbolInfoDouble(_Symbol, SYMBOL_BID));
  }
  
double CloseRightPrice(ENUM_ORDER_TYPE Tip)
   {
   switch(Tip)
      {
      case ORDER_TYPE_BUY: return(SymbolInfoDouble(_Symbol, SYMBOL_BID));
      case ORDER_TYPE_SELL: return(SymbolInfoDouble(_Symbol, SYMBOL_ASK));
      }
   return(SymbolInfoDouble(_Symbol, SYMBOL_BID));   
   }  
//+------------------------------------------------------------------+
//| Calculate right color by order type                              |
//+------------------------------------------------------------------+
color RightColor(ENUM_ORDER_TYPE Tip)
  {
   switch(Tip)
     {
      case ORDER_TYPE_BUY: return(clrGreen);
      case ORDER_TYPE_SELL: return(clrIndianRed);
     }
   return(clrIndigo);
  }
//+------------------------------------------------------------------+
//| Open single order                                                |
//+------------------------------------------------------------------+
void OpenOrder(ENUM_ORDER_TYPE Tip, double lot_size)
  {
   double SL, TP;
   SL = 0;
   TP = 0;
   
   // Get stop level
   int stops_level = (int)SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL);
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   
   // Set magic number
   trade.SetExpertMagicNumber(Magic());
   
   int attempts = 0;
   while(attempts < 5)
     {
      //int sar_handle = iSAR(_Symbol, _Period, SARStep, SARMax);
      //double SAR[1];
      //CopyBuffer(sar_handle, 0, 0, 1, SAR);
      
      double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
      double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      
      Print("ASK: ", ask, " BID: ", bid);
      
      //int bands_handle = iBands(_Symbol, _Period, BandsPeriod, 0, BandsDeviation, PRICE_TYPICAL);
      //double BB_UP[1], BB_LOW[1];
      //CopyBuffer(bands_handle, 1, 0, 1, BB_UP);
      //CopyBuffer(bands_handle, 2, 0, 1, BB_LOW);
      
      //switch(Tip)
      //  {
      //   case ORDER_TYPE_BUY:
      //     {
      //      double SLevel = bid - (stops_level + 5) * point;
      //      Print("BUY== SAR: ", SAR, ", BY LEVEL: ", SLevel);
      //      SL = SLevel; //BB_UP[0] - (BB_UP[0] - BB_LOW[0])/4;
      //      TP = 0;
      //      break;
      //     }
      //   case ORDER_TYPE_SELL:
      //     {
      //      double SLevel = ask + (stops_level + 5) * point;
      //      Print("SELL== SAR: ", SAR, ". BY LEVEL: ", SLevel);
      //      SL = SLevel; //BB_LOW[0] + (BB_UP[0] - BB_LOW[0])/4;
      //      TP = 0;
      //      break;
      //     }
      //  }
      
      Print("Trying to open ", OrderTypeToStr(Tip), " on ", lot_size, " lots. Price: ",
            RightPrice(Tip), ", SL: ", SL, ", TP: ", TP);  

      bool result = false;
      if(Tip == ORDER_TYPE_BUY)
         result = trade.Buy(lot_size, _Symbol, 0, StopLoss(), TP);
      else if(Tip == ORDER_TYPE_SELL)
         result = trade.Sell(lot_size, _Symbol, 0, StopLoss(), TP);
      
      if(result == true)
         break;
      else
        {
         if(Errors(trade.ResultRetcode()) == false)
            break;
         attempts++;
        }
     }
   return;
  }
//+------------------------------------------------------------------+
//| Modify stoploss level of positions by type                       |
//+------------------------------------------------------------------+
void Trail_Stop(ENUM_ORDER_TYPE Tip)
  {
   double SL;
   bool modify = false;
   
   int stops_level = (int)SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL);
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   
   for(int i = 0; i < orders_total; i++)
     {
      if((int)orders[i][ORDER_G_TYPE] == Tip)
        {
         int attempts = 0;
         while(attempts < 5)
           {
            //int sar_handle = iSAR(_Symbol, _Period, SARStep, SARMax);
            //double SAR[1];
            //CopyBuffer(sar_handle, 0, 0, 1, SAR);
            
            //int bands_handle = iBands(_Symbol, _Period, BandsPeriod, 0, BandsDeviation, PRICE_TYPICAL);
            //double BB_UP[1], BB_LOW[1];
            //CopyBuffer(bands_handle, 1, 0, 1, BB_UP);
            //CopyBuffer(bands_handle, 2, 0, 1, BB_LOW);

            switch(Tip)
              {
               case ORDER_TYPE_BUY:
                 {
                  double SLevel = bid - (stops_level + 5) * point;
                  SL = SLevel; //MathMin(SAR[0], SLevel);
                  if(SL > orders[i][ORDER_G_STOPLOSS])
                     modify = true;
                  break;   
                 }
               case ORDER_TYPE_SELL:
                 {
                  double SLevel = ask + (stops_level + 5) * point;
                  SL = SLevel; //MathMax(SAR[0], SLevel);
                  if(SL < orders[i][ORDER_G_STOPLOSS])
                     modify = true;
                  break;   
                 }
              }
            if(modify == true)
              {
               modify = false;
               ulong ticket = (ulong)orders[i][ORDER_G_TICKET];
               Print("Trying to modify position #", ticket,
                     ", Old SL: ", orders[i][ORDER_G_STOPLOSS], ", New SL: ", SL);
               
               bool Answer = trade.PositionModify(ticket, SL, orders[i][ORDER_G_TAKEPROFIT]);
               
               if(Answer == true)
                  break;
               else
                 {
                  if(Errors(trade.ResultRetcode()) == false)
                     break;
                  attempts++;
                 }
              }
            else
               break;
           }
        }
     }
   return;
  }
//+------------------------------------------------------------------+
//| Convert order type to string                                     |
//+------------------------------------------------------------------+
string OrderTypeToStr(ENUM_ORDER_TYPE Tip)
  {
   string str;
   if(Tip == ORDER_TYPE_BUY)
      str = "BUY ORDER";
   if(Tip == ORDER_TYPE_SELL)
      str = "SELL ORDER";
   return(str);
  }   
//+------------------------------------------------------------------+
