//+------------------------------------------------------------------+
//|                                                          lot.mqh |
//|                                                      Edward Bako |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Edward Bako"
#property link      "https://www.mql5.com"

input double DecreaseFactor = 5.0;
//+------------------------------------------------------------------+
//| Calculate lot size                                               |
//+------------------------------------------------------------------+
double Lot()
  {
      TReply r;
      redis.Command("HGET %s lot", SignalKey(), r);

      if(r.type == REDIS_REPLY_ERROR)
         { 
            Print("Lot Redis Error: ", r.str); 
            return(0);
         }
         
      if(r.type == REDIS_REPLY_STRING && StringLen(r.str) > 0)
         { return(StringToDouble(r.str)); }
      
      return(0);
//   double one_lot = SymbolInfoDouble(Symbol(), SYMBOL_MARGIN_INITIAL);
//   double min_lot = SymbolInfoDouble(Symbol(), SYMBOL_VOLUME_MIN);
//   double Equity = AccountInfoDouble(ACCOUNT_EQUITY);
//   double CurrentMargin = AccountInfoDouble(ACCOUNT_MARGIN);
//   double Free = AccountInfoDouble(ACCOUNT_MARGIN_FREE);
//
//   double MoneyAvailable = Equity/margin_call*100 - CurrentMargin;
//   if(MoneyAvailable < 0) MoneyAvailable = 0;
//   double MoneyToTrade = MathMin(Equity*symbol_max_load/100, MoneyAvailable);
//   double lot_size = MathFloor(MoneyToTrade/one_lot/min_lot)*min_lot;
//   
//   int ordersN = 0;     // history orders total
//   int losses = 0;      // number of losses orders without a break
//   
//   if(DecreaseFactor > 0)
//      {
//      HistorySelect(0, TimeCurrent());
//      ordersN = HistoryDealsTotal();
//      
//      for(int i = ordersN - 1; i >= 0; i--)
//         {
//         ulong ticket = HistoryDealGetTicket(i);
//         if(ticket == 0)
//           {
//            Print("Error in history!");
//            break;
//           }
//         if(HistoryDealGetString(ticket, DEAL_SYMBOL) != Symbol())
//            continue;
//         //---
//         double profit = HistoryDealGetDouble(ticket, DEAL_PROFIT);
//         if(profit > 0) break;
//         if(profit < 0) losses++;
//         }
//      if(losses > 0)
//         lot_size = NormalizeDouble(lot_size - lot_size * losses / DecreaseFactor, 2);
//      }
//   
//   if(lot_size < min_lot) lot_size = min_lot;
//   return(lot_size);
  }
//+------------------------------------------------------------------+

double StopLoss()
   {
      TReply r;
      redis.Command("HGET %s sl", SignalKey(), r);

      if(r.type == REDIS_REPLY_ERROR)
         { 
            Print("StopLoss Redis Error: ", r.str); 
            return(0);
         }
         
      if(r.type == REDIS_REPLY_STRING && StringLen(r.str) > 0)
         { return(StringToDouble(r.str)); }
      
      return(0);
   }

int Magic()
   {
      TReply r;
      redis.Command("HGET %s magic", SignalKey(), r);

      if(r.type == REDIS_REPLY_ERROR)
         { 
            Print("Magic Redis Error: ", r.str); 
            return(0);
         }
         
      if(r.type == REDIS_REPLY_STRING && StringLen(r.str) > 0)
         { return((int)StringToInteger(r.str)); }
      
      return(0);
   }
//+------------------------------------------------------------------+