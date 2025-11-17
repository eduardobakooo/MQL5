//+------------------------------------------------------------------+
//|                                                         vola.mq5 |
//|                                                      Edward Bako |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Edward Bako"
#property link      "https://www.mql5.com"
#property version   "1.00"
//--- includes
#define MSVCRT_DLL
#include <redis.mqh>
#include <vola\orders.mqh>
#include <vola\signal.mqh>
#include <vola\lot.mqh>
#include <vola\trade.mqh>
#include <vola\errors.mqh>

//--- input parameters
input double     margin_call=200.0;
input double     symbol_max_load=5.0;
input int        max_orders=1;
input string     address="127.0.0.1";
input int        port=6379;
input string     password="";
input int        db=0;

//--- globals
double lots;
double orders[331][9];
int orders_total;
CRedis redis;

int stop_level;
double point;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- Connect to Redis
   if(!redis.ConnectWithTimeout(address, port, 3000))
     {
      Print("Redis connection error: ", redis.GetLastError());
      return(INIT_FAILED);
     }
   
   Print("Connected to Redis successfully");
   
   if(AccountInfoInteger(ACCOUNT_TRADE_MODE) == ACCOUNT_TRADE_MODE_DEMO)
      Print("Working on demonstration account");
   else
      Print("Working on real account");
   
   stop_level = (int)SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL);
   point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   
   Print("Stop Level: ", stop_level);   
   Print("Point: ", point);

   orders_total = LoadOrders();

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   redis.Free();
   return;
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   orders_total = LoadOrders();
   Trade(Signal());
  }
//+------------------------------------------------------------------+
//| Tester function                                                  |
//+------------------------------------------------------------------+
double OnTester()
  {
//---
   double ret = 0.0;
//---

//---
   return(ret);
  }
//+------------------------------------------------------------------+
