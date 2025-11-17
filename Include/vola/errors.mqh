//+------------------------------------------------------------------+
//|                                                       errors.mqh |
//|                                                      Edward Bako |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Edward Bako"
#property link      "https://www.mql5.com"
//+------------------------------------------------------------------+
//| Handle errors. true - continue. false - fatal.                   |
//+------------------------------------------------------------------+
bool Errors(int Error)
  {
   switch(Error)
     {
      case 0: // ERR_SUCCESS
         Print("OK");
         return(false);
         //--- Retriable Errors
      case 10004: // TRADE_RETCODE_REQUOTE
         Print("Requote.");
         Sleep(100);
         return(true);
      case 10006: // TRADE_RETCODE_REJECT
         Print("Request rejected.");
         return(false);
      case 10007: // TRADE_RETCODE_CANCEL
         Print("Request canceled by trader.");
         return(false);
      case 10008: // TRADE_RETCODE_PLACED
         Print("Order placed.");
         return(false);
      case 10009: // TRADE_RETCODE_DONE
         Print("Request completed.");
         return(false);
      case 10010: // TRADE_RETCODE_DONE_PARTIAL
         Print("Request completed partially.");
         return(false);
      case 10011: // TRADE_RETCODE_ERROR
         Print("Request processing error.");
         return(false);
      case 10012: // TRADE_RETCODE_TIMEOUT
         Print("Request timeout.");
         return(true);
      case 10013: // TRADE_RETCODE_INVALID
         Print("Invalid request.");
         return(false);
      case 10014: // TRADE_RETCODE_INVALID_VOLUME
         Print("Invalid volume in the request.");
         return(false);
      case 10015: // TRADE_RETCODE_INVALID_PRICE
         Print("Invalid price in the request.");
         return(true);
      case 10016: // TRADE_RETCODE_INVALID_STOPS
         Print("Invalid stops in the request.");
         return(false);
      case 10017: // TRADE_RETCODE_TRADE_DISABLED
         Print("Trade is disabled.");
         return(false);
      case 10018: // TRADE_RETCODE_MARKET_CLOSED
         Print("Market is closed.");
         return(false);
      case 10019: // TRADE_RETCODE_NO_MONEY
         Print("Not enough money to complete the request.");
         return(false);
      case 10020: // TRADE_RETCODE_PRICE_CHANGED
         Print("Prices changed.");
         Sleep(100);
         return(true);
      case 10021: // TRADE_RETCODE_PRICE_OFF
         Print("No quotes to process the request.");
         Sleep(100);
         return(true);
      case 10022: // TRADE_RETCODE_INVALID_EXPIRATION
         Print("Invalid order expiration date in the request.");
         return(false);
      case 10023: // TRADE_RETCODE_ORDER_CHANGED
         Print("Order state changed.");
         return(true);
      case 10024: // TRADE_RETCODE_TOO_MANY_REQUESTS
         Print("Too many requests.");
         Sleep(500);
         return(true);
      case 10025: // TRADE_RETCODE_NO_CHANGES
         Print("No changes in request.");
         return(false);
      case 10026: // TRADE_RETCODE_SERVER_DISABLES_AT
         Print("Autotrading disabled by server.");
         return(false);
      case 10027: // TRADE_RETCODE_CLIENT_DISABLES_AT
         Print("Autotrading disabled by client terminal.");
         return(false);
      case 10028: // TRADE_RETCODE_LOCKED
         Print("Request locked for processing.");
         Sleep(100);
         return(true);
      case 10029: // TRADE_RETCODE_FROZEN
         Print("Order or position frozen.");
         return(false);
      case 10030: // TRADE_RETCODE_INVALID_FILL
         Print("Invalid order filling type.");
         return(false);
      case 10031: // TRADE_RETCODE_CONNECTION
         Print("No connection with the trade server.");
         Sleep(500);
         return(true);
      case 10032: // TRADE_RETCODE_ONLY_REAL
         Print("Operation is allowed only for live accounts.");
         return(false);
      case 10033: // TRADE_RETCODE_LIMIT_ORDERS
         Print("Number of pending orders has reached the limit.");
         return(false);
      case 10034: // TRADE_RETCODE_LIMIT_VOLUME
         Print("Volume of orders and positions for the symbol has reached the limit.");
         return(false);
      case 10035: // TRADE_RETCODE_INVALID_ORDER
         Print("Incorrect or prohibited order type.");
         return(false);
      case 10036: // TRADE_RETCODE_POSITION_CLOSED
         Print("Position with the specified identifier already closed.");
         return(false);
      case 10038: // TRADE_RETCODE_INVALID_CLOSE_VOLUME
         Print("Close volume exceeds the current position volume.");
         return(false);
      case 10039: // TRADE_RETCODE_CLOSE_ORDER_EXIST
         Print("Close order already exists for specified position.");
         return(false);
      case 10040: // TRADE_RETCODE_LIMIT_POSITIONS
         Print("Number of positions has reached the limit.");
         return(false);
      case 10041: // TRADE_RETCODE_REJECT_CANCEL
         Print("Request to cancel order rejected.");
         return(false);
      case 10042: // TRADE_RETCODE_LONG_ONLY
         Print("Only long positions are allowed.");
         return(false);
      case 10043: // TRADE_RETCODE_SHORT_ONLY
         Print("Only short positions are allowed.");
         return(false);
      case 10044: // TRADE_RETCODE_CLOSE_ONLY
         Print("Only position closing is allowed.");
         return(false);
      case 10045: // TRADE_RETCODE_FIFO_CLOSE
         Print("Position closing is allowed only by FIFO rule.");
         return(false);
         //--- Critical Errors
      case 2: // ERR_COMMON_ERROR
         Print("General Error.");
         return(false);
      case 5: // ERR_OLD_VERSION
         Print("Old terminal version.");
         return(false);
      case 64: // ERR_ACCOUNT_DISABLED
         Print("Account disabled.");
         return(false);
      case 65: // ERR_INVALID_ACCOUNT
         Print("Invalid account.");
         return(false);
      case 133: // ERR_TRADE_DISABLED
         Print("Trade is disabled.");
         return(false);
      default:
         Print("ERROR #", Error);
         return(false);
     }
  }
//+------------------------------------------------------------------+
