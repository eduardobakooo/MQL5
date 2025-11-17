//+------------------------------------------------------------------+
//|                                                       orders.mqh |
//|                                                      Edward Bako |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Edward Bako"
#property link      "https://www.mql5.com"

#define  ORDER_G_TICKET       0
#define  ORDER_G_TYPE         1
#define  ORDER_G_LOTS         2
#define  ORDER_G_OPENPRICE    3
#define  ORDER_G_STOPLOSS     4
#define  ORDER_G_TAKEPROFIT   5
#define  ORDER_G_MAGIC        6
#define  ORDER_G_COMMENT      7
//+------------------------------------------------------------------+
//| Load Orders From Terminal                                        |
//+------------------------------------------------------------------+
int LoadOrders()
  {
   int count = 0;

   ArrayInitialize(orders, 0);

//--- Load open positions
   for(int i = 0; i < PositionsTotal(); i++)
     {
      if(PositionGetSymbol(i) == _Symbol)
        {
         orders[count][ORDER_G_TICKET] = PositionGetInteger(POSITION_TICKET);
         orders[count][ORDER_G_TYPE] = PositionGetInteger(POSITION_TYPE);
         orders[count][ORDER_G_LOTS] = PositionGetDouble(POSITION_VOLUME);
         orders[count][ORDER_G_OPENPRICE] = PositionGetDouble(POSITION_PRICE_OPEN);
         orders[count][ORDER_G_STOPLOSS] = PositionGetDouble(POSITION_SL);
         orders[count][ORDER_G_TAKEPROFIT] = PositionGetDouble(POSITION_TP);
         orders[count][ORDER_G_MAGIC] = PositionGetInteger(POSITION_MAGIC);
         count++;
        }
     }

//--- Load pending orders
   for(int i = 0; i < OrdersTotal(); i++)
     {
      ulong ticket = OrderGetTicket(i);
      if(ticket > 0 && OrderGetString(ORDER_SYMBOL) == _Symbol)
        {
         orders[count][ORDER_G_TICKET] = ticket;
         orders[count][ORDER_G_TYPE] = OrderGetInteger(ORDER_TYPE);
         orders[count][ORDER_G_LOTS] = OrderGetDouble(ORDER_VOLUME_CURRENT);
         orders[count][ORDER_G_OPENPRICE] = OrderGetDouble(ORDER_PRICE_OPEN);
         orders[count][ORDER_G_STOPLOSS] = OrderGetDouble(ORDER_SL);
         orders[count][ORDER_G_TAKEPROFIT] = OrderGetDouble(ORDER_TP);
         orders[count][ORDER_G_MAGIC] = OrderGetInteger(ORDER_MAGIC);
         count++;
        }
     }

   return count;
  }
//+------------------------------------------------------------------+
