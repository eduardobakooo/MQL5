//+------------------------------------------------------------------+
//|                                                       Stream.mq5 |
//|                                                      Edward Bako |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Edward Bako"
#property link      "https://www.mql5.com"
#property version   "2.00"
#property indicator_chart_window
//--- includes
#define MSVCRT_DLL
#include <redis.mqh>
//--- input parameters
input string   address="127.0.0.1";
input int      port=6379;
input string   password="";
input int      db=0;
input int      accountId=179;

CRedis redis;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   Print("Starting Quotes Export on: " + address + ":" + (string)port);
   
   if(!redis.ConnectWithTimeout(address, port, 3000))
     {
      Print("Redis connection error: ", redis.GetLastError());
      return(INIT_FAILED);
     }
   
   Print("Connected to Redis successfully");
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
//---
   if(redis.GetLastError() != 0)
     {
      // Try to reconnect
      if(!redis.ConnectWithTimeout(address, port, 3000))
        {
         return(rates_total);
        }
     }

   MqlTick last_tick;
   if(SymbolInfoTick(_Symbol, last_tick))
     {
      TReply reply;
      redis.Command("SET %s %s", AskKey(), DoubleToString(last_tick.ask), reply);
      redis.Command("SET %s %s", BidKey(), DoubleToString(last_tick.bid), reply);
     }
   
   StreamQuote(Quote(time, open, high, low, close, tick_volume));
   StreamAccount();
   StreamOrders();
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
string DataKey()
   {
      return("series:" + _Symbol + ":" + (string)_Period + ":data");
   }
   
string AskKey()
   {
      return(_Symbol + ":ask");
   }   
   
string BidKey()
   {
      return(_Symbol + ":bid");
   }
   
string AccountKey()
   {  
      return("account:" + (string)accountId + ":data");
   }
   
string OrdersKey()
   {
      return("account:" + (string)accountId + ":orders_data");
   }
   
void StreamAccount()
   {
      TReply r;
      string key = AccountKey();
      
      redis.Command("HSET %s name %s", key, AccountInfoString(ACCOUNT_NAME), r);
      redis.Command("HSET %s company %s", key, AccountInfoString(ACCOUNT_COMPANY), r);
      redis.Command("HSET %s currency %s", key, AccountInfoString(ACCOUNT_CURRENCY), r);
      redis.Command("HSET %s leverage %s", key, (string)AccountInfoInteger(ACCOUNT_LEVERAGE), r);
      redis.Command("HSET %s stopout_level %s", key, DoubleToString(AccountInfoDouble(ACCOUNT_MARGIN_SO_SO)), r);
      redis.Command("HSET %s stopout_mode %s", key, (string)AccountInfoInteger(ACCOUNT_MARGIN_SO_MODE), r);
      redis.Command("HSET %s balance %s", key, DoubleToString(AccountInfoDouble(ACCOUNT_BALANCE)), r);
      redis.Command("HSET %s credit %s", key, DoubleToString(AccountInfoDouble(ACCOUNT_CREDIT)), r);
      redis.Command("HSET %s equity %s", key, DoubleToString(AccountInfoDouble(ACCOUNT_EQUITY)), r);
      redis.Command("HSET %s margin %s", key, DoubleToString(AccountInfoDouble(ACCOUNT_MARGIN)), r);
      redis.Command("HSET %s free_margin %s", key, DoubleToString(AccountInfoDouble(ACCOUNT_MARGIN_FREE)), r);
      
      if(r.type == REDIS_REPLY_ERROR)
         { Print("StreamAccount Error: ", r.str); }
   }

void StreamOrders()
   {
      int total_orders = OrdersTotal() + PositionsTotal();
      if(total_orders > 0)
         {
            TReply r;
            
            // Stream pending orders
            for(int i = 0; i < OrdersTotal(); i++)
               {
                  ulong ticket = OrderGetTicket(i);
                  if(ticket > 0)
                     {
                        redis.Command("HSET %s %s %s", OrdersKey(), (string)ticket, OrderInfo(ticket, true), r);
                        if(r.type == REDIS_REPLY_ERROR)
                           { Print("StreamOrders Error: ", r.str); }
                     }
               }
            
            // Stream positions
            for(int i = 0; i < PositionsTotal(); i++)
               {
                  if(PositionGetSymbol(i) != "")
                     {
                        ulong ticket = PositionGetInteger(POSITION_TICKET);
                        redis.Command("HSET %s %s %s", OrdersKey(), (string)ticket, PositionInfo(ticket), r);
                        if(r.type == REDIS_REPLY_ERROR)
                           { Print("StreamOrders Error: ", r.str); }
                     }
               }
         }   
   }
   
string OrderInfo(ulong ticket, bool is_order)
   {
      string order_data = "";
      
      if(is_order && OrderSelect(ticket))
        {
         // "ticket|type|magic|lots|symbol|open_time(rfc3339)|open_price|stop_loss|take_profit|close_time(rfc3339)|close_price|profit|swap|commission|expiration|comment"
         order_data = (string)OrderGetInteger(ORDER_TICKET) + "|" + 
                     (string)OrderGetInteger(ORDER_TYPE) + "|" + 
                     (string)OrderGetInteger(ORDER_MAGIC) + "|" + 
                     DoubleToString(OrderGetDouble(ORDER_VOLUME_CURRENT)) + "|" + 
                     OrderGetString(ORDER_SYMBOL) + "|" + 
                     TimeToRFC3339((datetime)OrderGetInteger(ORDER_TIME_SETUP)) + "|" + 
                     DoubleToString(OrderGetDouble(ORDER_PRICE_OPEN)) + "|" + 
                     DoubleToString(OrderGetDouble(ORDER_SL)) + "|" + 
                     DoubleToString(OrderGetDouble(ORDER_TP)) + "|" + 
                     "0" + "|" + // close_time - not applicable for pending orders
                     "0" + "|" + // close_price - not applicable for pending orders
                     "0" + "|" + // profit - not applicable for pending orders
                     "0" + "|" + // swap - not applicable for pending orders
                     "0" + "|" + // commission - not applicable for pending orders
                     TimeToRFC3339((datetime)OrderGetInteger(ORDER_TIME_EXPIRATION)) + "|" + 
                     OrderGetString(ORDER_COMMENT);
        }
      
      return(order_data);
   }

string PositionInfo(ulong ticket)
   {
      // "ticket|type|magic|lots|symbol|open_time(rfc3339)|open_price|stop_loss|take_profit|close_time(rfc3339)|close_price|profit|swap|commission|expiration|comment"
      return((string)PositionGetInteger(POSITION_TICKET) + "|" + 
             (string)PositionGetInteger(POSITION_TYPE) + "|" + 
             (string)PositionGetInteger(POSITION_MAGIC) + "|" + 
             DoubleToString(PositionGetDouble(POSITION_VOLUME)) + "|" + 
             PositionGetString(POSITION_SYMBOL) + "|" + 
             TimeToRFC3339((datetime)PositionGetInteger(POSITION_TIME)) + "|" + 
             DoubleToString(PositionGetDouble(POSITION_PRICE_OPEN)) + "|" + 
             DoubleToString(PositionGetDouble(POSITION_SL)) + "|" + 
             DoubleToString(PositionGetDouble(POSITION_TP)) + "|" + 
             "0" + "|" + // close_time - position is still open
             DoubleToString(PositionGetDouble(POSITION_PRICE_CURRENT)) + "|" + 
             DoubleToString(PositionGetDouble(POSITION_PROFIT)) + "|" + 
             DoubleToString(PositionGetDouble(POSITION_SWAP)) + "|" + 
             "0" + "|" + // commission - use deal history for accurate commission
             "0" + "|" + // expiration - not applicable for positions
             PositionGetString(POSITION_COMMENT));
   }
   
string RedisCommand(string command, string Key, string Message, string MessageAdd = "")
   {
      TReply r;
      
      if(StringLen(MessageAdd) > 0)
         {
            redis.Command(command + " %s %s %s", Key, Message, MessageAdd, r);
         }
      else
         {
            redis.Command(command + " %s %s", Key, Message, r);
         }
      
      if(r.type == REDIS_REPLY_ERROR)
         {
            Print("Redis Error: ", r.str);
            return("");
         }
      
      return(r.str);   
   }
   
 void StreamQuote(string quote)
   {
      TReply r;
      redis.Command("LINDEX %s 0", DataKey(), r);
      string last = r.str;
      
      if(TimeString(last) == TimeString(quote))
         { 
            redis.Command("LSET %s 0 %s", DataKey(), quote, r); 
         }
      else
         { 
            redis.Command("LPUSH %s %s", DataKey(), quote, r); 
         }   
   }
   
 string Quote(const datetime &time[], const double &open[], const double &high[], 
              const double &low[], const double &close[], const long &tick_volume[])
   {
   //-- "yyyy-mm-ddThh:mm:ss+00:00|open|high|low|close|volume"
      int index = ArraySize(time) - 1; // Get the most recent bar
      if(index >= 0)
        {
         return(TimeToRFC3339(time[index]) + "|" + 
                DoubleToString(open[index]) + "|" + 
                DoubleToString(high[index]) + "|" + 
                DoubleToString(low[index]) + "|" + 
                DoubleToString(close[index]) + "|" + 
                (string)tick_volume[index]);
        }
      return("");
   }
   
string LeadingZero(int number)
   {
      if(MathAbs(number) < 10)
         {
            return("0" + (string)number);
         }
      else
         {
            return((string)number);
         }
               
   }

string TimeToRFC3339(datetime time)
   {
      MqlDateTime dt;
      TimeToStruct(time, dt);
      
      int offset = 3 * 60 * 60;
      string sign = "";
      if(offset > 0)
         { sign = "+"; }
      string offsetStr = sign + LeadingZero(offset / 3600)+ ":" + LeadingZero(MathMod(offset, 3600) / 60);
      
      return((string)dt.year + "-" + LeadingZero(dt.mon) + "-" + LeadingZero(dt.day) + "T" + 
             LeadingZero(dt.hour) + ":" + LeadingZero(dt.min) + ":" + LeadingZero(dt.sec) + offsetStr);
   }
   
string TimeString(string quote)
   {
      string result[];
      StringSplit(quote, StringGetCharacter("|", 0), result);
      if(ArraySize(result) > 0)
         { return(result[0]); }
      else
         { return("-"); }   
   }

//+------------------------------------------------------------------+
//| Deinitialization function                                        |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   redis.Free();
  }