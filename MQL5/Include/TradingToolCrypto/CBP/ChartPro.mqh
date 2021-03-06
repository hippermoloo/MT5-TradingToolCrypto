//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2020, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#include <TradingToolCrypto\CBP\ExchangeList.mqh>
#include <TradingToolCrypto\TT\convert_time.mqh>
#include <TradingToolCrypto\TT\timestamp.mqh>


MqlBookInfo book_array[];//MqlBookInfo priceArray[];
MqlTick ticks[];

MqlRates rates[];
MqlRates rates_lastbar[];
MqlRates ratesNew[];



input group "--------------DEV DEBUG--------------"
input bool Delete_Historical_DB = false;
input bool Dev_Debug_History = false;
input bool Dev_Debug_Orderbook = false;
input bool Dev_Debug_Ticks = false;
input group "--------------DEV DEBUG--------------"

int Global_binance_MaxBars = 999;
int Global_bybit_MaxBars = 200;
int Global_bitmex_MaxBars = 200;
int Global_switcheo_MaxBars = 1000;
int Global_deribit_MaxBars = 200;
int Global_kucoin_MaxBars = 500;
int Global_kucoin_Futures_MaxBars = 200;
int Global_satang_MaxBars = 500;
int Global_ftx_MaxBars = 1000;
int Global_coinbase_MaxBars = 300;
int Global_digitex_MaxBars = 1500;
int Global_huobifutures_MaxBars = 1000;
int Global_kraken_MaxBars = 720;
int Global_zbg_MaxBars = 500;
int Global_btse_MaxBars = 200;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int check_maxbars(int exchange)
  {

   if((exchange == 1) || (exchange == 5) || (exchange == 6))
     {
      return (Global_binance_MaxBars);
     }

   if(exchange == 2)
     {
      return (Global_bybit_MaxBars);
     }
   if(exchange == 3)
     {
      return (Global_bitmex_MaxBars);
     }
   if(exchange == 4)
     {
      return (Global_kucoin_MaxBars);
     }

   if(exchange == 7)
     {
      return (Global_deribit_MaxBars);
     }

   if(exchange == 8)
     {
      return (Global_switcheo_MaxBars);
     }

   if(exchange == 9)
     {
      return (Global_coinbase_MaxBars);
     }

   if(exchange == 12)
     {
      return (Global_ftx_MaxBars);
     }

   if(exchange == 13)
     {
      return (Global_satang_MaxBars);
     }

   if(exchange == 14)
     {
      return (Global_digitex_MaxBars);
     }

   if(exchange == 15)
     {
      return (Global_huobifutures_MaxBars);
     }

   if(exchange == 17)
     {
      return (Global_zbg_MaxBars);
     }

   if(exchange == 18)
     {
      return (Global_kraken_MaxBars);
     }
   if(exchange == 19)
     {
      return (Global_kucoin_Futures_MaxBars);
     }
   if(exchange == 20)
     {
      return (Global_btse_MaxBars);
     }

   return (1);
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
long CreateCustomSymbol(string customSymbolName, int sym_digit, int timeframe, string template_name)
  {
   long OpenChartId = 0;
// If returns false, the symbol does not exist in the Market Watch
//Selects a symbol in the Market Watch window(true) or removes a symbol from the window(false).
   if(!SymbolSelect(customSymbolName, true))
     {

      // Symbol Name,  Sub Group, and what Symbol_Properties to copy ( symbol properties? )
      if(!CustomSymbolCreate(customSymbolName, "CryptoBridge", NULL))
        {
         Print("CustomSymbolCreate failed: " + IntegerToString(GetLastError()));
         ResetLastError();
         return(0);
        }

      //SYMBOL_TICKS_BOOKDEPTH
      if(!CustomSymbolSetInteger(customSymbolName, SYMBOL_TICKS_BOOKDEPTH, 20))
        {
         Print("CustomSymbolSetInteger | SYMBOL_TICKS_BOOKDEPTH | Failed" + IntegerToString(GetLastError()));
         ResetLastError();
        }

      if(!CustomSymbolSetInteger(customSymbolName, SYMBOL_DIGITS, sym_digit))
        {
         Print("CustomSymbolSetInteger | SYMBOL_DIGITS | Failed" + IntegerToString(GetLastError()));
         ResetLastError();
        }

      if(!CustomSymbolSetInteger(customSymbolName, SYMBOL_CHART_MODE, SYMBOL_CHART_MODE_BID))
        {
         Print("CustomSymbolSetInteger | SYMBOL_CHART_MODE | Failed" + IntegerToString(GetLastError()));
         ResetLastError();
        }

      /*
        //SYMBOL_VISIBLE
         if(!CustomSymbolSetInteger(customSymbolName,SYMBOL_VISIBLE,true))
        {
         Print("CustomSymbolSetInteger | SYMBOL_VISIBLE | Failed" + IntegerToString( GetLastError() ) );
         ResetLastError();
         return;
        }
      */

      //SYMBOL_SPREAD_FLOAT
      if(!CustomSymbolSetInteger(customSymbolName, SYMBOL_SPREAD_FLOAT, true))
        {
         Print("CustomSymbolSetInteger | SYMBOL_SPREAD_FLOAT | Failed" + IntegerToString(GetLastError()));
         ResetLastError();
        }

      //SYMBOL_TRADE_STOPS_LEVEL
      if(!CustomSymbolSetInteger(customSymbolName, SYMBOL_TRADE_STOPS_LEVEL, 0))
        {
         Print("CustomSymbolSetInteger | SYMBOL_TRADE_STOPS_LEVEL | Failed" + IntegerToString(GetLastError()));
         ResetLastError();
        }
      //SYMBOL_TRADE_FREEZE_LEVEL
      if(!CustomSymbolSetInteger(customSymbolName, SYMBOL_TRADE_FREEZE_LEVEL, 0))
        {
         Print("CustomSymbolSetInteger | SYMBOL_TRADE_FREEZE_LEVEL | Failed" + IntegerToString(GetLastError()));
         ResetLastError();
        }
      //get_double_trade
      //SYMBOL_POINT
      if(!CustomSymbolSetDouble(customSymbolName, SYMBOL_POINT, Extra_Digits_To_Min_Lot(sym_digit)))
        {
         Print("CustomSymbolSetDouble | SYMBOL_POINT | Failed" + IntegerToString(GetLastError()));
         ResetLastError();
        }
      //SYMBOL_TRADE_TICK_SIZE
      if(!CustomSymbolSetDouble(customSymbolName, SYMBOL_TRADE_TICK_SIZE, Extra_Digits_To_Min_Lot(sym_digit)))
        {
         Print("CustomSymbolSetDouble | SYMBOL_TRADE_TICK_SIZE | Failed" + IntegerToString(GetLastError()));
         ResetLastError();
        }

      //SYMBOL_VOLUME_MIN
      if(!CustomSymbolSetDouble(customSymbolName, SYMBOL_VOLUME_MIN,0.00000001))
        {
         Print("CustomSymbolSetDouble | SYMBOL_VOLUME_MIN | Failed" + IntegerToString(GetLastError()));
         ResetLastError();
        }

      //SYMBOL_VOLUME_MAX
      if(!CustomSymbolSetDouble(customSymbolName, SYMBOL_VOLUME_MAX, 100))
        {
         Print("CustomSymbolSetInteger | SYMBOL_VOLUME_MAX | Failed" + IntegerToString(GetLastError()));
         ResetLastError();
        }
      //SYMBOL_VOLUME_LIMIT
      if(!CustomSymbolSetDouble(customSymbolName, SYMBOL_VOLUME_LIMIT, 1000))
        {
         Print("CustomSymbolSetDouble | SYMBOL_VOLUME_LIMIT | Failed" + IntegerToString(GetLastError()));
         ResetLastError();
        }

      // APRIL 23, 2020 Add more SYMBOL_CALC_MODE_EXCH_STOCKS
      //SYMBOL_TRADE_CALC_MODE
      if(!CustomSymbolSetInteger(customSymbolName, SYMBOL_TRADE_CALC_MODE, SYMBOL_CALC_MODE_EXCH_STOCKS))
        {
         Print("CustomSymbolSetInteger | SYMBOL_TRADE_CALC_MODE | Failed" + IntegerToString(GetLastError()));
         ResetLastError();
        }

      //SYMBOL_TRADE_CONTRACT_SIZE
      if(!CustomSymbolSetDouble(customSymbolName, SYMBOL_TRADE_CONTRACT_SIZE, 1))
        {
         Print("CustomSymbolSetDouble | SYMBOL_TRADE_CONTRACT_SIZE | Failed" + IntegerToString(GetLastError()));
         ResetLastError();
        }
      //SYMBOL_TRADE_TICK_VALUE
      if(!CustomSymbolSetDouble(customSymbolName, SYMBOL_TRADE_TICK_VALUE, 1))
        {
         Print("CustomSymbolSetDouble | SYMBOL_TRADE_TICK_VALUE | Failed" + IntegerToString(GetLastError()));
         ResetLastError();
        }

      if(!SymbolSelect(customSymbolName, true))
        {
         Print("Creating the CustomChart Failed for some reason: " + IntegerToString(GetLastError()));
         Alert("Creating the CustomChart Failed for some reason: " + IntegerToString(GetLastError()));
         ResetLastError();
        }
      else
        {

         OpenChartId =     ChartOpen(customSymbolName, tf(timeframe));
         ChartApplyTemplate(OpenChartId,template_name);
        }
     }
   else
     {

      OpenChartId =     ChartOpen(customSymbolName, tf(timeframe));
      ChartApplyTemplate(OpenChartId,template_name);
     }
   return(OpenChartId);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void  orderbookadd(string sym)
  {
   /*
    Required to activate the DOM
   */
   if(MarketBookAdd(sym))
     {
      Print("DOM SUCCESSFULLY OPENED ON: " + sym);
     }
   else
     {
      Print("DOM FAILED ON: " + sym);
     }
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string ChartPro_Klines_URL(int broker, string sym, int chart_tf, string start, string end)
  {
   bool debugging = false;
   if(debugging)
     {

      Print("Func_KlinesURL |  start | " + start + " | end | " + end);
      Print("Func_KlinesURL |  start | " + (datetime)StringToInteger(start) + " | end | " + (datetime)StringToInteger(end));

     }

   if(broker == 1)
     {
      return ("https://api.binance.com/api/v3/klines?symbol=" + sym +
              "&interval=" + timeframe_binance(chart_tf) +
              "&startTime=" + (long)StringToInteger(start) * 1000 +
              "&endTime=" + (long)StringToInteger(end) * 1000 +
              "&limit=" + IntegerToString(Global_binance_MaxBars));
     }

   if(broker == 2)
     {
      return ("https://api.bybit.com/v2/public/kline/list" +
              "?from=" + (int)start +
              "&interval=" + timeframe_bybit(chart_tf) +
              "&limit=" + Global_bybit_MaxBars +
              "&symbol=" + sym);
     }

   if(broker == 3)
     {
      return ("https://www.bitmex.com/api/v1/trade/bucketed/" +

              "?binSize=" + timeframe_binance(chart_tf) +
              "&partial=true" +
              "&startTime=" + Time_Convert_Datetime_To_ISO8601((int)start) +
              "&endTime=" + Time_Convert_Datetime_To_ISO8601((int)end) +
              "&symbol=" + sym +
              "&count=" + 200 +
              "&reverse=true");
     }

   if(broker == 4)
     {

      return ("https://api.kucoin.com/api/v1/market/candles?type=" + timeframe_kucoin(chart_tf) +
              "&symbol=" + sym +
              "&startAt=" + StringToInteger(start) +
              "&endAt=" + StringToInteger(end));
     }

   if(broker == 5)
     {

      return ("https://fapi.binance.com/fapi/v1/klines?symbol=" + sym +
              "&interval=" + timeframe_binance(chart_tf) +
              "&startTime=" + (long)StringToInteger(start) * 1000 +
              "&endTime=" + (long)StringToInteger(end) * 1000 +
              "&limit=" + IntegerToString(Global_binance_MaxBars));
     }

   if(broker == 6)
     {
      return ("https://api.binance.us/api/v3/klines?symbol=" + sym +
              "&interval=" + timeframe_binance(chart_tf) +
              "&startTime=" + (long)StringToInteger(start) * 1000 +
              "&endTime=" + (long)StringToInteger(end) * 1000 +
              "&limit=" + IntegerToString(Global_binance_MaxBars));
     }

   if(broker == 7)
     {
      return ("https://www.deribit.com/api/v2/public/get_tradingview_chart_data?instrument_name=" + sym +
              "&start_timestamp=" + (long)StringToInteger(start) * 1000 +
              "&end_timestamp=" + (long)StringToInteger(end) * 1000 +
              "&resolution=" + timeframe_bybit(chart_tf));
     }

   if(broker == 8)
     {

      return ("https://api.switcheo.network/v2/tickers/candlesticks?pair=" + sym +
              "&start_time=" + (int)start +
              "&end_time=" + (int)end +
              "&interval=" + timeframe_switcheo(chart_tf));
     }

   if(broker == 9)
     {
      return ("https://api.pro.coinbase.com/products/" + sym +
              "/candles" + "?start=" + Time_Convert_Datetime_To_ISO8601((int)start) +
              "&end=" + Time_Convert_Datetime_To_ISO8601((int)end) +
              "&granularity=" + timeframe_ftx(chart_tf));
     }

   if(broker == 12)
     {
      return ("https://ftx.com/api/markets/" + sym +
              "/candles?resolution=" + timeframe_ftx(chart_tf) +
              "&limit=" + Global_ftx_MaxBars +
              "&start_time=" + (int)StringToInteger(start) +
              "&end_time=" + (int)StringToInteger(end));
     }

   if(broker == 13)
     {
      //satang pro
      return ("https://api.tdax.com/api/v3/klines?symbol=" + sym +
              "&interval=" + timeframe_binance(chart_tf) +
              "&startTime=" + (long)StringToInteger(start) * 1000 +
              "&endTime=" + (long)StringToInteger(end) * 1000);
     }

   if(broker == 14)
     {
      return ("https://rest.mapi.digitexfutures.com/api/v1/public/klines" +
              "?symbol=" + sym +
              "&interval=" + timeframe_kucoin(chart_tf) +
              "&from=" + (long)StringToInteger(start) +
              "&to=" + (long)StringToInteger(end)    +
              "&count=" + Global_digitex_MaxBars);
     }

   if(broker == 15)
     {

      return ("https://api.hbdm.com/market/history/kline" +
              "?symbol=" + sym +
              "&period=" + timeframe_kucoin(chart_tf) +
              "&size=" + Global_huobifutures_MaxBars +
              "&from=" + (long)StringToInteger(start) +
              "&to=" + (long)StringToInteger(end));
     }

   if(broker == 16)
     {
      //phemex - has no rest api for klines
      return ("");
     }

   if(broker == 17)
     {
      return ("https://kline.zbg.com/api/data/v1/klines" +
              "?marketName=" + sym +
              "&type=" + timeframe_zbg(chart_tf) +
              "&dataSize=" + Global_zbg_MaxBars +
              "&from=" + (long)StringToInteger(start) +
              "&to=" + (long)StringToInteger(end));
     }

   if(broker == 18)
     {
      //as xbtusd&since=1559347200000000000 wo
      // return ("https://api.kraken.com/0/public/Trades?pair=" + sym + "&since=" + (long)StringToInteger(start)*1000000000);
      return ("https://api.kraken.com/0/public/OHLC" +
              "?pair=" + sym +
              "&interval=" + timeframe_bybit(chart_tf));  //+ "&since=" + (long)StringToInteger(start)
     }

   if(broker == 19)
     {
      return ("https://api-futures.kucoin.com/api/v1/kline/query"+
              "?symbol="+ sym +
              "&granularity=" + timeframe_bybit(chart_tf) +
              "&from=" + StringToInteger(start)*1000);// + "&to=" + StringToInteger(end)*1000
     }

   if(broker == 20)
     {
      return ("https://api.btse.com/futures/api/v2.1/ohlcv"+
              "?symbol="+ sym +
              "&resolution=" + timeframe_bybit(chart_tf) +
              "&start=" + StringToInteger(start) +
              "&end=" + StringToInteger(end));
     }

   return ("");
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string timeframe_binance(int tf)
  {

   if(tf == 1)
     {
      return ("1m");
     }
   if(tf == 3)
     {
      return ("1m");
     }
   if(tf == 5)
     {
      return ("5m");
     }

   if(tf == 15)
     {
      return ("15m");
     }
   if(tf == 30)
     {
      return ("30m");
     }
   if(tf == 60)
     {
      return ("1h");
     }
   if(tf == 120)
     {
      return ("2h");
     }
   if(tf == 240)
     {
      return ("4h");
     }
   if(tf == 360)
     {
      return ("6h");
     }
   if(tf == 480)
     {
      return ("8h");
     }
   if(tf == 720)
     {
      return ("12h");
     }
   if(tf == 1440)
     {
      return ("1d");
     }
   return ("1m");
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string timeframe_zbg(int tf)
  {

   if(tf == 1)
     {
      return ("1M");
     }
   if(tf == 3)
     {
      return ("1M");
     }
   if(tf == 5)
     {
      return ("5M");
     }

   if(tf == 15)
     {
      return ("15M");
     }
   if(tf == 30)
     {
      return ("30M");
     }
   if(tf == 60)
     {
      return ("1H");
     }
   if(tf == 120)
     {
      return ("1H");
     }
   if(tf == 240)
     {
      return ("1H");
     }
   if(tf == 360)
     {
      return ("1H");
     }
   if(tf == 480)
     {
      return ("1H");
     }
   if(tf == 720)
     {
      return ("1H");
     }
   if(tf == 1440)
     {
      return ("1D");
     }
   return ("1M");
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string timeframe_kucoin(int tf)
  {

   if(tf == 1)
     {
      return ("1min");
     }
   if(tf == 3)
     {
      return ("3min");
     }
   if(tf == 5)
     {
      return ("5min");
     }

   if(tf == 15)
     {
      return ("15min");
     }
   if(tf == 30)
     {
      return ("30min");
     }
   if(tf == 60)
     {
      return ("1hour");
     }
   if(tf == 120)
     {
      return ("2hour");
     }
   if(tf == 240)
     {
      return ("4hour");
     }
   if(tf == 360)
     {
      return ("6hour");
     }
   if(tf == 480)
     {
      return ("8hour");
     }
   if(tf == 720)
     {
      return ("12hour");
     }
   if(tf == 1440)
     {
      return ("1day");
     }
   return ("1min");
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string timeframe_bybit(int tf)
  {

   if(tf == 1)
     {
      return ("1");
     }
   if(tf == 3)
     {
      return ("3");
     }
   if(tf == 5)
     {
      return ("5");
     }
   if(tf == 15)
     {
      return ("15");
     }
   if(tf == 30)
     {
      return ("30");
     }
   if(tf == 60)
     {
      return ("60");
     }
   if(tf == 120)
     {
      return ("120");
     }
   if(tf == 240)
     {
      return ("240");
     }
   if(tf == 360)
     {
      return ("360");
     }
   if(tf == 720)
     {
      return ("720");
     }
   if(tf == 1440)
     {
      return ("D");
     }
   return ("1");
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string timeframe_ftx(int tf)
  {

   if(tf == 1)
     {
      return ("60");
     }
   if(tf == 3)
     {
      return ("180");
     }
   if(tf == 5)
     {
      return ("300");
     }
   if(tf == 15)
     {
      return ("900");
     }
   if(tf == 30)
     {
      return ("1800");
     }
   if(tf == 60)
     {
      return ("3600");
     }
   if(tf == 120)
     {
      return ("7200");
     }
   if(tf == 240)
     {
      return ("14400");
     }
   if(tf == 360)
     {
      return ("21600");
     }
   if(tf == 720)
     {
      return ("43200");
     }
   if(tf == 1440)
     {
      return ("86400");
     }
   return ("60");
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string timeframe_switcheo(int tf)
  {

   if(tf == 1)
     {
      return ("1");
     }
   if(tf == 3)
     {
      return ("3");
     }
   if(tf == 5)
     {
      return ("5");
     }
   if(tf == 15)
     {
      return ("15");
     }
   if(tf == 30)
     {
      return ("30");
     }
   if(tf == 60)
     {
      return ("60");
     }
   if(tf == 120)
     {
      return ("120");
     }
   if(tf == 240)
     {
      return ("240");
     }
   if(tf == 360)
     {
      return ("360");
     }
   if(tf == 720)
     {
      return ("720");
     }
   if(tf == 1440)
     {
      return ("D");
     }
   return ("1");
  }




//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ChartPro_historical_data(int exchange_id, string sym,string sym_chart, int chart_tf, datetime start, datetime end, int loop_speed, int symbol_spread, long chartID, bool debug)
  {
   char
   try
      [];
   char response[];
   string new_url = "";
   string server_header = "";
   string server_string = "";


   if(debug)
     {
      Print(" exchange_id " +exchange_id + "" +
            " sym "  +sym + "" +
            " sym_chart " +sym_chart+ "" +
            " chart_tf " +chart_tf + "" +
            " start " +start + "" +
            " end " +end + ""
           );
     }

   datetime current = start;
   /*
     Return the max # bars that the exchange api will return within the json object
    */
   const int max_bars_request = check_maxbars(exchange_id);
   Print(" max_bars_request " +max_bars_request+ "");

   /*
    Return only the data set start and end datetimes that are within MaxBars[]
    */
   datetime ending = Time_Return_EndTime(current, chart_tf, max_bars_request, end);
   Print(" ending " +ending+ "");
   /*
    How many api calls, do we need to make to grab all the data between the start and end time
    */
   const int howmanyrequest = webrequest_howmany(chart_tf, max_bars_request, start, end);
   Print(" howmanyrequest " +howmanyrequest+ "");
   /*

    */
   int i = 0;
   int loaded = 0;
   int Eraser = 0;
   for(int req = 0; req < howmanyrequest; req++)
     {
      /*
        Create a unique url to fetch the data from api endpoint
        */
      new_url = ChartPro_Klines_URL(exchange_id, sym, chart_tf, (int)current, (int)ending);
      /*

      Nov 5 - 2020

      */
      if(Delete_Historical_DB){
      Eraser =     CustomRatesDelete(
                      sym_chart,       // symbol name
                      (int)current,         // start date
                      (int)ending           // end date
                   );
      }


      if(new_url == "")
        {
         Print("ChartPro_Klines_URL | FAILED ");
         return(true);
        }

      if(debug)
        {
         Print("1 current " +current  + " ending " + ending);
         current = Time_Return_EndTime(current, chart_tf, max_bars_request, end);
         ending = Time_Return_EndTime(current, chart_tf, max_bars_request, end);
        }


      if(debug)
        {
         Print("2 current " +current  + " ending " + ending);
        }

      if(debug)
        {
         Print("URL: " + new_url + "\n" +
               "Requests " + req + " / " + howmanyrequest);
        }

      int res = WebRequest("GET", new_url, "", 30000, try, response, server_header);

      if(res == -1)
        {
         if(debug)
            Print("Historical Data ERROR" + IntegerToString(GetLastError()));
         ResetLastError();
         return (false);
        }
      else
        {

         if(debug)
           {
            Print("WebRequest code: " + IntegerToString(res));
            server_string = CharArrayToString(response, 0, WHOLE_ARRAY);
            Print("API RESPONSE " + server_string);
           }
         /*

            Json parsing of the data

            */
         jasonClass.Clear();
         jasonClass.Deserialize(response);
         /*

            Load the parsed data in the rates array

            */
         //string sym,string sym_chart
         loaded = parse_historical_data(exchange_id, max_bars_request, symbol_spread,sym, sym_chart);

         if(debug)
           {
            Print("loaded " + loaded + " exchange_id " + exchange_id + " max_bars_request " + max_bars_request + " sym " + sym);
           }

         // BREAK THE URL WebRequest LOOP
         /*
         if(loaded != max_bars_request)
           {
            if(debug)
               Print("BREAK THE LOOP");
            break;
           }
          */

         Sleep(loop_speed);
        }
     } // How many requests

// ChartRedraw(chartID);
   return (true);
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int webrequest_howmany(int timeframe, int limit, datetime start, datetime end)
  {
   bool debugging = false;
   if(timeframe == 0 || limit == 0)
      return (0);

   int diff = end - start;
   double minutes = diff / 60;
   double try_minutes = minutes / timeframe; // 200/1 = 200 bars
   double fits = try_minutes / limit;

   if(debugging)
     {
      Print("How_Many_Request() " +
            " TF: " + timeframe +
            " LIMIT: " + limit +
            " START: " + start +
            " END: " + end +
            " SEC: " + diff +
            " MIN: " + minutes +
            " /TF: " + (try_minutes - limit) + "/" + limit +
            " FITS: " + fits + " times "

           );
     }


   if(fits > 1.0 && 2.0 >= fits)
     {
      return (2);
     }
   if(fits <= 1.0)
     {
      return (1);
     }

   return (NormalizeDouble(fits, 0) + 1);
  }


/*
   BINANCE = 1,
  BYBIT = 2,
  BITMEX = 3,
  KUCOIN = 4,
  BINANCE_FUTURES = 5,
  BINANCE_US = 6,
  DERIBIT = 7,
// OKEX = 8,
  COINBASE = 9,
//  BITFINEX = 10,
// BITSTAMP =11,
  FTX = 12,
  SATANG_PRO = 13,
  DIGITEX = 14,
  HUOBI_FUTURES = 15,
  PHEMEX = 16,
  ZBG = 17,
  KRAKEN = 18,
  KUCOIN_FUTURES = 19
*/

/*
Parse the json data based on the exchange format ( exchange id)

*/
string timestamp_open = "";
datetime bar_time = 0;
string open = "";
double bar_open = 0;
string high = "";
double bar_high = 0;
string low = "";
double bar_low = 0;
string close = "";
double bar_close = 0;
string volume_tick = "";
long bar_volume_tick = 0;
string quote_volume_base = "";

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int parse_historical_data(int exchange_id, int max_bars, int spread, string sym, string sym_chart)
  {
   bool debugging = true;
   int i = 0;
   int rates_counter = max_bars - 1;
   ArrayResize(rates, max_bars);

   /*
   binance  = binance futures == binance us
   */
   if(exchange_id == 1 ||exchange_id == 5 || exchange_id == 6)
     {
      for(i = 0; i < max_bars; i++)
        {
         open = jasonClass[i][1].ToStr();
         bar_open = StringToDouble(open);
         if(bar_open == 0){
            break;
         }
         timestamp_open = jasonClass[i][0].ToStr(); // Current Bar from exchange
         bar_time = Time_Convert_MilliSeconds_To_Datetime(timestamp_open);
         high = jasonClass[i][2].ToStr();
         bar_high = StringToDouble(high);
         low = jasonClass[i][3].ToStr();
         bar_low = StringToDouble(low);
         close = jasonClass[i][4].ToStr();
         bar_close = StringToDouble(close);
         volume_tick = jasonClass[i][8].ToStr();
         bar_volume_tick = StringToInteger(volume_tick);
         quote_volume_base = jasonClass[i][9].ToStr();
         rates[rates_counter - i].open = bar_open;
         rates[rates_counter - i].time = bar_time;
         rates[rates_counter - i].high = bar_high;
         rates[rates_counter - i].low = bar_low;
         rates[rates_counter - i].close = bar_close;
         rates[rates_counter - i].tick_volume = bar_volume_tick;
         rates[rates_counter - i].real_volume = StringToDouble(quote_volume_base);
         rates[rates_counter - i].spread = spread;
        }
     }
   /*
      bybit
   */
   if(exchange_id == 2)
     {
      for(i = 0; i < max_bars; i++)
        {
         open = jasonClass["result"][i]["open"].ToStr();
         bar_open = StringToDouble(open);
          if(bar_open == 0){
            break;
         }
         bar_time = jasonClass["result"][i]["open_time"].ToInt(); // Current Bar from exchange
         high = jasonClass["result"][i]["high"].ToStr();
         bar_high = StringToDouble(high);
         low = jasonClass["result"][i]["low"].ToStr();
         bar_low = StringToDouble(low);
         close = jasonClass["result"][i]["close"].ToStr();
         bar_close = StringToDouble(close);
         volume_tick = jasonClass["result"][i]["volume"].ToStr();
         bar_volume_tick = StringToInteger(volume_tick);
         rates[rates_counter - i].open = bar_open;
         rates[rates_counter - i].time = bar_time;
         rates[rates_counter - i].high = bar_high;
         rates[rates_counter - i].low = bar_low;
         rates[rates_counter - i].close = bar_close;
         rates[rates_counter - i].tick_volume = bar_volume_tick;
         rates[rates_counter - i].real_volume = bar_volume_tick;
         rates[rates_counter - i].spread = spread;
        }
     }
   /*
        bitmex
     */
   if(exchange_id == 3)
     {

      for(i = 0; i < max_bars; i++)
        {
         bar_time = Time_Convert_ISO8601_To_Datetime(jasonClass[i]["timestamp"].ToStr());
         open = jasonClass[i]["open"].ToStr();
         bar_open = StringToDouble(open);
          if(bar_open == 0){
            break;
         }
         high = jasonClass[i]["high"].ToStr();
         bar_high = StringToDouble(high);
         low = jasonClass[i]["low"].ToStr();
         bar_low = StringToDouble(low);
         close = jasonClass[i]["close"].ToStr();
         bar_close = StringToDouble(close);
         volume_tick = jasonClass[i]["volume"].ToStr();
         bar_volume_tick = StringToInteger(volume_tick);
         rates[rates_counter - i].time = bar_time;
         rates[rates_counter - i].open = bar_open;
         rates[rates_counter - i].high = bar_high;
         rates[rates_counter - i].low = bar_low;
         rates[rates_counter - i].close = bar_close;
         rates[rates_counter - i].tick_volume = bar_volume_tick;
         rates[rates_counter - i].real_volume = bar_volume_tick;
         rates[rates_counter - i].spread = spread;
        }

     }

   /*
          kucoin and kucoin futures ( checking to see if the data is the same)
       */
   if(exchange_id == 4)
     {
      for(i = 0; i < max_bars; i++)
        {

         timestamp_open = jasonClass["data"][i][0].ToStr();
         bar_time = StringToInteger(timestamp_open);
         open = jasonClass["data"][i][1].ToStr();
         bar_open = StringToDouble(open);
          if(bar_open == 0){
            break;
         }
         high = jasonClass["data"][i][3].ToStr();
         bar_high = StringToDouble(high);
         low = jasonClass["data"][i][4].ToStr();
         bar_low = StringToDouble(low);
         close = jasonClass["data"][i][2].ToStr();
         bar_close = StringToDouble(close);
         volume_tick = jasonClass["data"][i][5].ToStr();
         bar_volume_tick = StringToInteger(volume_tick);
         quote_volume_base = jasonClass["data"][i][6].ToStr();
         rates[rates_counter - i].open = bar_open;
         rates[rates_counter - i].time = bar_time;
         rates[rates_counter - i].high = bar_high;
         rates[rates_counter - i].low = bar_low;
         rates[rates_counter - i].close = bar_close;
         rates[rates_counter - i].tick_volume = bar_volume_tick;
         rates[rates_counter - i].real_volume = StringToDouble(quote_volume_base);
         rates[rates_counter - i].spread = spread;
        }
     }




   /*
           deribit
         */

   if(exchange_id == 7)
     {
      for(i = 0; i < max_bars; i++)
        {
         open = jasonClass["result"]["open"][i].ToStr();
         bar_open = StringToDouble(open);
          if(bar_open == 0){
            break;
         }
         timestamp_open = jasonClass["result"]["ticks"][i].ToStr();
         bar_time = StringToInteger(timestamp_open) / 1000;
         high = jasonClass["result"]["high"][i].ToStr();
         bar_high = StringToDouble(high);
         low = jasonClass["result"]["low"][i].ToStr();
         bar_low = StringToDouble(low);
         close = jasonClass["result"]["close"][i].ToStr();
         bar_close = StringToDouble(close);
         volume_tick = jasonClass["result"]["volume"][i].ToStr();
         bar_volume_tick = StringToInteger(volume_tick);
         rates[rates_counter - i].open = bar_open;
         rates[rates_counter - i].time = bar_time;
         rates[rates_counter - i].high = bar_high;
         rates[rates_counter - i].low = bar_low;
         rates[rates_counter - i].close = bar_close;
         rates[rates_counter - i].tick_volume = bar_volume_tick;
         rates[rates_counter - i].real_volume = bar_volume_tick;
         rates[rates_counter - i].spread = spread;
        }
     }
   /*
         coinbase
    */
   if(exchange_id == 9)
     {
      for(i = 0; i < max_bars; i++)
        {
         open = jasonClass[i][3].ToStr();
         bar_open = StringToDouble(open);
          if(bar_open == 0){
            break;
         }
         timestamp_open = jasonClass[i][0].ToStr(); // Current Bar from exchange
         bar_time = StringToInteger(timestamp_open);
         high = jasonClass[i][2].ToStr();
         bar_high = StringToDouble(high);
         low = jasonClass[i][1].ToStr();
         bar_low = StringToDouble(low);
         close = jasonClass[i][4].ToStr();
         bar_close = StringToDouble(close);
         volume_tick = jasonClass[i][5].ToStr();
         bar_volume_tick = StringToInteger(volume_tick);
         rates[rates_counter - i].open = bar_open;
         rates[rates_counter - i].time = bar_time;
         rates[rates_counter - i].high = bar_high;
         rates[rates_counter - i].low = bar_low;
         rates[rates_counter - i].close = bar_close;
         rates[rates_counter - i].tick_volume = bar_volume_tick;
         rates[rates_counter - i].real_volume = StringToDouble(volume_tick);
         rates[rates_counter - i].spread = spread;
        }
     }
   /*
          ftx
      */
   if(exchange_id == 12)
     {
      for(i = 0; i < max_bars; i++)
        {
         open = jasonClass["result"][i]["open"].ToStr();
         bar_open = StringToDouble(open);
          if(bar_open == 0){
            break;
         }
         timestamp_open = jasonClass["result"][i]["time"].ToStr();
         bar_time = Time_Convert_MilliSeconds_To_Datetime(timestamp_open);
         high = jasonClass["result"][i]["high"].ToStr();
         bar_high = StringToDouble(high);
         low = jasonClass["result"][i]["low"].ToStr();
         bar_low = StringToDouble(low);
         close = jasonClass["result"][i]["close"].ToStr();
         bar_close = StringToDouble(close);
         volume_tick = jasonClass["result"][i]["volume"].ToStr();
         bar_volume_tick = StringToInteger(volume_tick);
         quote_volume_base = jasonClass["result"][i]["volume"].ToStr();
         rates[rates_counter - i].open = bar_open;
         rates[rates_counter - i].time = bar_time;
         rates[rates_counter - i].high = bar_high;
         rates[rates_counter - i].low = bar_low;
         rates[rates_counter - i].close = bar_close;
         rates[rates_counter - i].tick_volume = bar_volume_tick;
         rates[rates_counter - i].real_volume = StringToDouble(quote_volume_base);
         rates[rates_counter - i].spread = spread;
        }

     }
   /*
    Satang Pro
   */
   if(exchange_id == 13)
     {
      for(i = 0; i < max_bars; i++)
        {
         open = jasonClass[i][1].ToStr();
         bar_open = StringToDouble(open);
          if(bar_open == 0){
            break;
         }
         timestamp_open = jasonClass[i][0].ToStr(); // Current Bar from exchange
         bar_time = Time_Convert_MilliSeconds_To_Datetime(timestamp_open);
         high = jasonClass[i][2].ToStr();
         bar_high = StringToDouble(high);
         low = jasonClass[i][3].ToStr();
         bar_low = StringToDouble(low);
         close = jasonClass[i][4].ToStr();
         bar_close = StringToDouble(close);
         volume_tick = jasonClass[i][5].ToStr();
         bar_volume_tick = StringToInteger(volume_tick);
         quote_volume_base = jasonClass[i][5].ToStr();
         rates[rates_counter - i].open = bar_open;
         rates[rates_counter - i].time = bar_time;
         rates[rates_counter - i].high = bar_high;
         rates[rates_counter - i].low = bar_low;
         rates[rates_counter - i].close = bar_close;
         rates[rates_counter - i].tick_volume = bar_volume_tick;
         rates[rates_counter - i].real_volume = StringToDouble(quote_volume_base);
         rates[rates_counter - i].spread = spread;
        }
     }

   /*
   Digitex
   */
   int inserted_candles =0;
   if(exchange_id == 14)
     {
      for(i = 0; i < max_bars; i++)
        {

         open = jasonClass["data"]["klines"][i]["o"].ToStr();
         bar_open = StringToDouble(open);
          if(bar_open == 0){
            break;
         }
         timestamp_open = jasonClass["data"]["klines"][i]["id"].ToStr();
         bar_time = StringToInteger(timestamp_open);
         high = jasonClass["data"]["klines"][i]["h"].ToStr();
         bar_high = StringToDouble(high);
         low = jasonClass["data"]["klines"][i]["l"].ToStr();
         bar_low = StringToDouble(low);
         close = jasonClass["data"]["klines"][i]["c"].ToStr();
         bar_close = StringToDouble(close);
         volume_tick = jasonClass["data"]["klines"][i]["v"].ToStr();
         bar_volume_tick = StringToInteger(volume_tick);
         quote_volume_base = volume_tick;
         inserted_candles++;
         rates[rates_counter - inserted_candles].open = bar_open;
         rates[rates_counter - inserted_candles].time = bar_time;
         rates[rates_counter - inserted_candles].high = bar_high;
         rates[rates_counter - inserted_candles].low = bar_low;
         rates[rates_counter - inserted_candles].close = bar_close;
         rates[rates_counter - inserted_candles].tick_volume = bar_volume_tick;
         rates[rates_counter - inserted_candles].real_volume = StringToDouble(quote_volume_base);
         rates[rates_counter - inserted_candles].spread =spread;
        }

      if(inserted_candles!= i)
        {
         i = inserted_candles;
         Print("inserted_candles " +inserted_candles + " i " + i + " maxbars " + max_bars);
        }

     }

   /*
   HUOBI_FUTURES
   */
   if(exchange_id == 15)
     {
      for(i = 0; i < max_bars; i++)
        {
         open = jasonClass["data"][i]["open"].ToStr();
         bar_open = StringToDouble(open);
          if(bar_open == 0){
            break;
         }
         timestamp_open =  jasonClass["data"][i]["id"].ToStr();
         bar_time = StringToInteger(timestamp_open);
         high = jasonClass["data"][i]["high"].ToStr();
         bar_high = StringToDouble(high);
         low = jasonClass["data"][i]["low"].ToStr();
         bar_low = StringToDouble(low);
         close = jasonClass["data"][i]["close"].ToStr();
         bar_close = StringToDouble(close);
         volume_tick =  jasonClass["data"][i]["count"].ToStr();
         bar_volume_tick = StringToInteger(volume_tick);
         quote_volume_base = jasonClass["data"][i]["amount"].ToStr();
         rates[rates_counter - i].open = bar_open;
         rates[rates_counter - i].time = bar_time;
         rates[rates_counter - i].high = bar_high;
         rates[rates_counter - i].low = bar_low;
         rates[rates_counter - i].close = bar_close;
         rates[rates_counter - i].tick_volume = bar_volume_tick;
         rates[rates_counter - i].real_volume = StringToDouble(quote_volume_base);
         rates[rates_counter - i].spread = spread;
        }
     }



   /*
   PHEMEX has no rest api klines end point
   */
   if(exchange_id == 16)
     {

     }
   /*
    request returns the latest bar first,
    - most exchanges send the oldest bar first in the array
   */
   if(exchange_id == 17)
     {
      for(i = 0; i < max_bars; i++)
        {
         open = jasonClass["datas"][i][4].ToStr();
         bar_open = StringToDouble(open);
          if(bar_open == 0){
            break;
         }
         timestamp_open = jasonClass["datas"][i][3].ToStr();
         bar_time = StringToInteger(timestamp_open);
         high = jasonClass["datas"][i][5].ToStr();
         bar_high = StringToDouble(high);
         low = jasonClass["datas"][i][6].ToStr();
         bar_low = StringToDouble(low);
         close = jasonClass["datas"][i][7].ToStr();
         bar_close = StringToDouble(close);
         volume_tick = jasonClass["datas"][i][8].ToStr();
         bar_volume_tick = StringToInteger(volume_tick);
         quote_volume_base = volume_tick;
         rates[i].open = bar_open;
         rates[i].time = bar_time;
         rates[i].high = bar_high;
         rates[i].low = bar_low;
         rates[i].close = bar_close;
         rates[i].tick_volume = bar_volume_tick;
         rates[i].real_volume = StringToDouble(quote_volume_base);
         rates[i].spread =spread;
        }
     }


   /*
   KRAKEN
   */
   if(exchange_id == 18)
     {
      for(i = 0; i < max_bars; i++)
        {
         open = jasonClass["result"][sym][i][1].ToStr();
         bar_open = StringToDouble(open);
          if(bar_open == 0){
            break;
         }
         timestamp_open = jasonClass["result"][sym][i][0].ToStr();
         bar_time = StringToInteger(timestamp_open);;
         high = jasonClass["result"][sym][i][2].ToStr();
         bar_high = StringToDouble(high);
         low = jasonClass["result"][sym][i][3].ToStr();
         bar_low = StringToDouble(low);
         close = jasonClass["result"][sym][i][4].ToStr();
         bar_close = StringToDouble(close);
         volume_tick = jasonClass["result"][sym][i][7].ToStr();
         bar_volume_tick = StringToInteger(volume_tick);
         quote_volume_base = jasonClass["result"][sym][i][6].ToStr();
         rates[rates_counter - i].open = bar_open;
         rates[rates_counter - i].time = bar_time;
         rates[rates_counter - i].high = bar_high;
         rates[rates_counter - i].low = bar_low;
         rates[rates_counter - i].close = bar_close;
         rates[rates_counter - i].tick_volume = bar_volume_tick;
         rates[rates_counter - i].real_volume = StringToDouble(quote_volume_base);
         rates[rates_counter - i].spread = spread;
        }
     }

   /*
     KUCOIN_FUTURES
     */
   if(exchange_id == 19)
     {
      for(i = 0; i < max_bars; i++)
        {
         timestamp_open = jasonClass["data"][i][0].ToStr();
         bar_time = StringToInteger(timestamp_open)/1000;
         open = jasonClass["data"][i][1].ToStr();
         bar_open = StringToDouble(open);
          if(bar_open == 0){
            break;
         }
         high = jasonClass["data"][i][3].ToStr();
         bar_high = StringToDouble(high);
         low = jasonClass["data"][i][4].ToStr();
         bar_low = StringToDouble(low);
         close = jasonClass["data"][i][2].ToStr();
         bar_close = StringToDouble(close);
         volume_tick = jasonClass["data"][i][5].ToStr();
         bar_volume_tick = StringToInteger(volume_tick);
         quote_volume_base = jasonClass["data"][i][6].ToStr();
         rates[rates_counter - i].open = bar_open;
         rates[rates_counter - i].time = bar_time;
         rates[rates_counter - i].high = bar_high;
         rates[rates_counter - i].low = bar_low;
         rates[rates_counter - i].close = bar_close;
         rates[rates_counter - i].tick_volume = bar_volume_tick;
         rates[rates_counter - i].real_volume = StringToDouble(quote_volume_base);
         rates[rates_counter - i].spread = spread;
        }
     }



   /*

   BTSE
   - Print(i + " BTSE " + timestamp_open + " date " + (datetime)bar_time            + " | open " + open);

   */
   if(exchange_id == 20)
     {
      for(i = 0; i < max_bars; i++)
        {

         timestamp_open = jasonClass[i][0].ToStr();
         bar_time = StringToInteger(timestamp_open);
         open = jasonClass[i][1].ToStr();
         bar_open = StringToDouble(open);
          if(bar_open == 0){
            break;
         }
         high = jasonClass[i][2].ToStr();
         bar_high = StringToDouble(high);
         low = jasonClass[i][3].ToStr();
         bar_low = StringToDouble(low);
         close = jasonClass[i][4].ToStr();
         bar_close = StringToDouble(close);
         volume_tick = jasonClass[i][5].ToStr();
         bar_volume_tick = StringToInteger(volume_tick);
         quote_volume_base = volume_tick;
         rates[rates_counter - i].open = bar_open;
         rates[rates_counter - i].time = bar_time;
         rates[rates_counter - i].high = bar_high;
         rates[rates_counter - i].low = bar_low;
         rates[rates_counter - i].close = bar_close;
         rates[rates_counter - i].tick_volume = bar_volume_tick;
         rates[rates_counter - i].real_volume = StringToDouble(quote_volume_base);
         rates[rates_counter - i].spread = spread;
        }
     }

   int ret = -1;
   int ok = 0;

   if(i != max_bars)
     {

      int unfilled = max_bars - i;
      int filled = i;
      ArrayFree(rates_lastbar);
      ArrayResize(rates_lastbar, filled, max_bars);
      int copied = ArrayCopy(rates_lastbar, rates, 0, unfilled, filled);
      ret = CustomRatesUpdate(sym_chart, rates_lastbar, WHOLE_ARRAY);
     }
   else
     {
      // Resizing the array is not required.
      ret = CustomRatesUpdate(sym_chart, rates, WHOLE_ARRAY);
     }

   if(ret != -1 && ret != 0)
     {
      if(debugging)
         Print("Historical Chart: " + sym + " updated succesfully with bars_count: " + IntegerToString(ret));
     }
 /*    
   else
     {

      int size = ArraySize(rates);
      datetime startF = rates[0].time;
      datetime endF = rates[size - 1].time;
      ret = CustomRatesReplace(sym_chart, startF, endF, rates, WHOLE_ARRAY);

      if(debugging)
         Print("CustomRatesReplace | " + startF + " < " + endF);

      if(ret <= 0)
        {

         if(debugging)
            Print("FAILED CustomRatesReplace | " + startF + " < " + endF);
         ResetLastError();

        }
     }
  */
   return(i);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime ChartPro_Server_Timestamp(int exchange_id)
  {

   string server_timestamp = "";
   long convertToInt = 0;



   if(exchange_id == 0)
     {
      return(".bdx");
     }
   if(exchange_id == 1)
     {
      //   /api/v3/time
      server_timestamp =  check_server_timestamp(exchange_id, "https://api.binance.com/api/v3/time");
      Print("ChartPro_Server_Timestamp(): Binance Server TimeStamp " + server_timestamp);
      convertToInt = StringToInteger(server_timestamp)/1000;// convert ms to seconds
      Print("ChartPro_Server_Timestamp(): convertToInt " + convertToInt+ " datetime " + (datetime) convertToInt);
      return(convertToInt);
     }
///v2/public/time
   if(exchange_id == 2)
     {
      server_timestamp =  check_server_timestamp(exchange_id, "https://api.bybit.com/v2/public/time");
      Print("ChartPro_Server_Timestamp(): Bybit Server TimeStamp " + server_timestamp);
      convertToInt = StringToInteger(server_timestamp);
      Print("ChartPro_Server_Timestamp(): convertToInt " + convertToInt+ " datetime " + (datetime) convertToInt);
      return(convertToInt);
     }
   if(exchange_id == 3)
     {

      server_timestamp =  check_server_timestamp(exchange_id, "https://www.bitmex.com/api/v1/instrument?reverse=true&count=1");
      convertToInt = Time_Convert_ISO8601_To_Datetime(server_timestamp);
      Print("ChartPro_Server_Timestamp(): convertToInt " + convertToInt + " | server_timestamp " + server_timestamp+ " datetime " + (datetime) convertToInt);
      return(convertToInt);
     }
   if(exchange_id == 4)
     {
      server_timestamp = check_server_timestamp(exchange_id, "https://api.kucoin.com/api/v1/market/orderbook/level1?symbol=BTC-USDT");
      Print("ChartPro_Server_Timestamp(): Kucoin Server TimeStamp " + server_timestamp);
      convertToInt = StringToInteger(server_timestamp)/1000;
      Print("ChartPro_Server_Timestamp(): convertToInt " + convertToInt+ " datetime " + (datetime) convertToInt);
      return(convertToInt);
     }


   if(exchange_id == 5)
     {
      //   /api/v3/time
      server_timestamp =  check_server_timestamp(exchange_id, "https://fapi.binance.com/fapi/v1/time");
      Print("ChartPro_Server_Timestamp(): Binance Server TimeStamp " + server_timestamp);
      convertToInt = StringToInteger(server_timestamp)/1000;// convert ms to seconds
      Print("ChartPro_Server_Timestamp(): convertToInt " + convertToInt+ " datetime " + (datetime) convertToInt);
      return(convertToInt);
     }
   if(exchange_id == 6)
     {
      //   /api/v3/time
      server_timestamp =  check_server_timestamp(exchange_id, "https://api.binance.us/api/v3/time");
      Print("ChartPro_Server_Timestamp(): Binance Server TimeStamp " + server_timestamp);
      convertToInt = StringToInteger(server_timestamp)/1000;// convert ms to seconds
      Print("ChartPro_Server_Timestamp(): convertToInt " + convertToInt+ " datetime " + (datetime) convertToInt);
      return(convertToInt);
     }
   if(exchange_id == 7)
     {
      server_timestamp =  check_server_timestamp(exchange_id, "https://www.deribit.com/api/v2/public/get_time?");
      Print("ChartPro_Server_Timestamp(): DERIBIT Server TimeStamp " + server_timestamp);
      convertToInt = StringToInteger(server_timestamp)/1000;// convert ms to seconds
      Print("ChartPro_Server_Timestamp(): convertToInt " + convertToInt+ " datetime " + (datetime) convertToInt);
      return(convertToInt);
     }
   if(exchange_id == 8)
     {
      server_timestamp =  check_server_timestamp(exchange_id, "https://api.switcheo.network/v2/exchange/timestamp");
      Print(" Switcheo Server TimeStamp " + server_timestamp);
      convertToInt = StringToInteger(server_timestamp);
      convertToInt = convertToInt/1000; // turn into seconds instead of milliseconds
      Print("ChartPro_Server_Timestamp(): convertToInt " + convertToInt+ " datetime " + (datetime) convertToInt);
      return(convertToInt);
     }


   if(exchange_id == 9)
     {

      server_timestamp =  check_server_timestamp(exchange_id, "https://api.pro.coinbase.com/time");
      Print(" CoinBase Server TimeStamp (string) " + server_timestamp);
      convertToInt = StringToInteger(server_timestamp);
      Print("ChartPro_Server_Timestamp(): convertToInt " + convertToInt+ " datetime " + (datetime) convertToInt);
      return(convertToInt);
     }


   if(exchange_id == 12)
     {
      ///markets/{market_name}/trades?limit={limit}&start_time={start_time}&end_time={end_time}
      server_timestamp =  check_server_timestamp(exchange_id, "https://ftx.com/api/markets/BTC-PERP/trades?limit=1");
      Print(" FTX Server TimeStamp (string) " + server_timestamp);
      convertToInt = StringToInteger(server_timestamp);
      Print("ChartPro_Server_Timestamp(): convertToInt " + convertToInt+ " datetime " + (datetime) convertToInt);
      return(convertToInt);
     }

   if(exchange_id == 13)
     {
      server_timestamp =  check_server_timestamp(exchange_id, "https://api.tdax.com/api/v3/exchangeInfo");
      Print(" Satang Server TimeStamp " + server_timestamp);
      convertToInt = StringToInteger(server_timestamp);
      convertToInt = convertToInt/1000; // turn into seconds instead of milliseconds
      Print("ChartPro_Server_Timestamp(): convertToInt " + convertToInt+ " datetime " + (datetime) convertToInt);
      return(convertToInt);
     }

   if(exchange_id == 14)
     {
      ///markets/{market_name}/trades?limit={limit}&start_time={start_time}&end_time={end_time}
      server_timestamp =  check_server_timestamp(exchange_id, "https://rest.mapi.digitexfutures.com/api/v1/public/time");
      Print(" DIGITEX Server TimeStamp (string) " + server_timestamp);
      convertToInt = StringToInteger(server_timestamp)/1000;
      Print("ChartPro_Server_Timestamp(): convertToInt " + convertToInt+ " datetime " + (datetime) convertToInt);
      return(convertToInt);
     }

   if(exchange_id == 15)
     {

      server_timestamp =  check_server_timestamp(exchange_id, "https://api.hbdm.com/api/v1/timestamp");
      Print(" HUOBI FUTURES Server TimeStamp (string) " + server_timestamp);
      convertToInt = StringToInteger(server_timestamp)/1000;
      Print("ChartPro_Server_Timestamp(): convertToInt " + convertToInt+ " datetime " + (datetime) convertToInt);
      return(convertToInt);
     }


   if(exchange_id == 16)
     {
      server_timestamp =  check_server_timestamp(exchange_id, "https://api.phemex.com/md/ticker/24hr?symbol=BTCUSD");
      Print(" PHEMEX FUTURES Server TimeStamp (string) " + server_timestamp);
      long tryA= StringToInteger(server_timestamp);
      convertToInt = tryA/1000000000;
      Print(" PHEMEX FUTURES Server TimeStamp (long) " + tryA + " | datetime " + (datetime)convertToInt + " | int " + convertToInt + " " + (int) TimeLocal());
      return(convertToInt);
     }

   if(exchange_id == 17)
     {
      server_timestamp =  check_server_timestamp(exchange_id, "https://kline.zbg.com/api/data/v1/entrusts?marketName=BTC_USDT&dataSize=1");
      Print(" ZBG Server TimeStamp (string) " + server_timestamp);
      long tryA= StringToInteger(server_timestamp);
      convertToInt = tryA;
      Print(" ZBG Server TimeStamp (long) " + tryA + " | datetime " + (datetime)convertToInt + " | int " + convertToInt + " " + (int) TimeLocal());
      return(convertToInt);
     }




// //https://api.kraken.com/0/public/Time
   if(exchange_id == 18)
     {
      server_timestamp =  check_server_timestamp(exchange_id, "https://api.kraken.com/0/public/Time");
      Print(" KRAKEN Server TimeStamp (string) " + server_timestamp);
      convertToInt = StringToInteger(server_timestamp);
      Print("ChartPro_Server_Timestamp(): convertToInt " + convertToInt+ " datetime " + (datetime) convertToInt);
      return(convertToInt);
     }

   if(exchange_id == 19)
     {
      server_timestamp =  check_server_timestamp(exchange_id, "https://api-futures.kucoin.com/api/v1/timestamp");
      Print("ChartPro_Server_Timestamp(): Kucoin Server TimeStamp " + server_timestamp);
      convertToInt = StringToInteger(server_timestamp)/1000;
      Print("ChartPro_Server_Timestamp(): convertToInt " + convertToInt + " | " + " datetime " + (datetime) convertToInt);
      return(convertToInt);
     }

   if(exchange_id == 20)
     {
      server_timestamp =  check_server_timestamp(exchange_id, "https://api.btse.com/futures/api/v2.1/orderbook/L2?symbol=BTCPFC");
      Print("ChartPro_Server_Timestamp(): BTSE Server TimeStamp " + server_timestamp);
      convertToInt = StringToInteger(server_timestamp)/1000;
      Print("ChartPro_Server_Timestamp(): convertToInt " + convertToInt + " | " + " datetime " + (datetime) convertToInt);
      return(convertToInt);
     }

   return(0);
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string check_server_timestamp(int exchange_id, string url)
  {

   char try
      [], response[];
   string server_header="";

   if(Dev_Debug_History)
      Print("check_server_timestamp() url | " +  url);

   int res = WebRequest("GET", url, "", 10000, try, response, server_header);

   if(res == -1)
     {
      Print("Get_Webrequest ERROR" + IntegerToString(GetLastError()));
      ResetLastError();
      return("");
     }
   else
     {

      if(Dev_Debug_History)
        {
         Print("Get_Webrequest Request code: " + IntegerToString(res));
        }

      string server_string = CharArrayToString(response, 0, WHOLE_ARRAY);
      if(Dev_Debug_History)
         Print("ServerResponse " + server_string);

      jasonClass.Clear();
      jasonClass.Deserialize(response);

      if(exchange_id == 1    || exchange_id ==5   || exchange_id == 6)
        {
         string tryA = jasonClass["serverTime"].ToStr();
         Print("Binance: " + tryA);
         return(tryA);

        }

      if(exchange_id == 2)
        {
         string tryA = jasonClass["time_now"].ToStr();
         Print("Bybit: " + tryA);
         return(tryA);
        }

      if(exchange_id == 3)
        {
         string tryA = jasonClass[0]["timestamp"].ToStr();
         Print("Bitmex TimeServer: " + tryA);
         return(tryA);
        }




      if(exchange_id == 4)
        {
         string tryA = jasonClass["data"]["time"].ToStr();
         Print("Kucoin: " + tryA);
         return(tryA);
        }



      if(exchange_id == 7)
        {
         return(jasonClass["result"].ToStr());
        }

      if(exchange_id == 8)
        {
         return(jasonClass["timestamp"].ToStr());
        }

      if(exchange_id == 9)
        {
         return(jasonClass["epoch"].ToStr());
        }

      if(exchange_id == 12)
        {
         /*
         use the trades data to get the timestamp
         - "https://ftx.com/api/markets/BTC-PERP/trades?limit=1"
         */
         string response3 = jasonClass["result"][0]["time"].ToStr();
         //Print("FTX Time Response: " + response3 );
         //2020-05-28T08:29:20Z
         StringSetLength(response3,19);
         //Print("FTX Time Response: " + response3 );
         int  get_now = Time_Convert_ISO8601_To_Datetime(response3+"Z");
         //Print("FTX Time Convert: " + get_now);
         return(get_now);
        }

      if(exchange_id == 13)
        {
         return(jasonClass["serverTime"].ToStr());
        }

      if(exchange_id == 14)
        {
         /*
         jasonClass["data"]["timestamp"].ToStr()
         or
         jasonClass["data"][1].ToStr()
         */
         return(jasonClass["data"]["timestamp"].ToStr());// milliseconds long
        }

      if(exchange_id == 15)
        {
         return(jasonClass["ts"].ToStr());
        }

      if(exchange_id == 16)
        {
         return(jasonClass["result"]["timestamp"].ToStr());
        }

      if(exchange_id == 17)
        {
         return(jasonClass["datas"]["timestamp"].ToStr());
        }

      if(exchange_id == 18)

         return(jasonClass["result"]["unixtime"].ToStr());
     }

   if(exchange_id == 19)
     {

      return(jasonClass["data"].ToStr());
     }
   if(exchange_id == 20)
     {

      return(jasonClass["timestamp"].ToStr());
     }

   return("");
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int ChartPro_GMT_Shift(datetime server)
  {

// what is the GMT shift from local time and the server time?

   int seconds_L = (int) TimeLocal();
   int seconds_S = (int) server;
   static int hours_shift = 0;

   if(seconds_L > seconds_S)
     {

      hours_shift = ((seconds_L- seconds_S) /60)/60;

     }
   else
     {

      hours_shift = ((seconds_S- seconds_L) /60)/60;

     }


   Print(" HOURS SHIFT " +  hours_shift);

   return(hours_shift);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ChartPro_historical_delete_nextday(string sym, int date)
  {
   /*
      Delete (flush) the historical data rates past the server time
      - this can happen sometimes. but very rare
     */
   int next_day = 1440 *60;
   next_day = (int)date+next_day;
   datetime future = next_day;
   int deleted_bars = CustomRatesDelete(sym,date,future);

   if(deleted_bars>0)
     {
      Print("Flush Candles From Historical Data: " +deleted_bars) ;
      return(true);
     }
   return(false);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string ChartPro_RemoveSymbolSuffix(string chart_symbol)
  {

   if(chart_symbol == "")
     {
      Print("ERROR IN the ChartPro_RemoveSymbolSuffix " + chart_symbol);
      return("");

     }

   /*
      BTCUSDT.binance
      BTCUSD.b2b
   */
   const string sep=".";            // A separator as a character
   ushort u_sep;                    // The code of the separator character
   string result[];                 // An array to get strings
   u_sep=StringGetCharacter(sep,0);
   int k=StringSplit(chart_symbol,u_sep,result);
   if(k>0)
     {
      string value = result[0];
      return(value);
     }

   return("");

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string ChartPro_ReturnSymbolSuffix(string chart_symbol)
  {
   /*
      BTCUSDT.binance
      BTCUSD.b2b
   */
   const string sep=".";            // A separator as a character
   ushort u_sep;                    // The code of the separator character
   string result[];                 // An array to get strings
   u_sep=StringGetCharacter(sep,0);
   int k=StringSplit(chart_symbol,u_sep,result);
   if(k>0){
      string value = sep + result[1];
      return(value);
   }
   return("");
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Chart_Pro_SymbolSuffixToExch(string suffix)
  {

   if(suffix == ".bnx")
     {
      return(0);
     }
   if(suffix == ".bnc")
     {
      return(1);
     }
   if(suffix == ".byb")
     {
      return(2);
     }
   if(suffix == ".mex")
     {
      return(3);
     }
   if(suffix == ".kuc")
     {
      return(4);
     }
   if(suffix == ".bnf")
     {
      return(5);
     }
   if(suffix == ".bnu")
     {
      return(6);
     }
   if(suffix == ".der")
     {
      return(7);
     }
   if(suffix == ".okx")
     {
      return(8);
     }
   if(suffix == ".cbs")
     {
      return(9);
     }

   if(suffix == ".btf")
     {
      return(10);
     }

   if(suffix == ".bsp")
     {
      return(11);
     }
   if(suffix == ".ftx")
     {
      return(12);
     }
   if(suffix == ".sat")
     {
      return(13);
     }
   if(suffix == ".dig")
     {
      return(14);
     }
   if(suffix == ".huo")
     {
      return(15);
     }
   if(suffix == ".phe")
     {
      return(16);
     }
   if(suffix == ".zbg")
     {
      return(17);
     }
   if(suffix == ".kra")
     {
      return(18);
     }
   if(suffix == ".kuf")
     {
      return(19);
     }

   if(suffix == ".bts")
     {
      return(20);
     }
   return(-1);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Depth = 10; // MarketDepth Pull size ( 5 bids, / 5 Asks) Don't change or code breaks

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string orderbookurl(int broker, string exchange_sym)
  {

   if(broker == 1)
     {
      return("https://api.binance.com/api/v3/depth?symbol="+ exchange_sym + "&limit=" + IntegerToString(Depth));
     }
   if(broker == 2)
     {
      return("https://api.bybit.com/v2/public/orderBook/L2?symbol="+ exchange_sym);
     }
   if(broker == 3)
     {
      return("https://www.bitmex.com/api/v1/orderBook/L2?symbol=" +exchange_sym +"&depth=10");
     }
   if(broker == 4)//spot
     {
      //https://api.kucoin.com/api/v1/market/orderbook/level2_20?symbol=BTC-USDT
      return("https://api.kucoin.com/api/v1/market/orderbook/level2_20?symbol=" +exchange_sym);
     }
   if(broker == 5)
     {
      return("https://fapi.binance.com/fapi/v1/depth?symbol="+ exchange_sym + "&limit=" + IntegerToString(Depth));
     }
   if(broker == 6)
     {
      return("https://api.binance.us/api/v3/depth?symbol="+ exchange_sym + "&limit=" + IntegerToString(Depth));
     }
   if(broker == 7)
     {
      return("https://www.deribit.com/api/v2/public/get_order_book?depth=" + IntegerToString(Depth)     +"&instrument_name="+ exchange_sym);
     }


   if(broker == 9)
     {
      //returns 50 bars
      return("https://api.pro.coinbase.com/products/"+ exchange_sym + "/book?level=2");
     }



   if(broker == 12)
     {
      return("https://ftx.com/api/markets/"+ exchange_sym + "/orderbook?depth=" + IntegerToString(Depth));
     }
   if(broker == 13)
     {
      return("https://api.tdax.com/api/v3/depth?symbol="+ exchange_sym + "&limit=" + IntegerToString(Depth));
     }
   if(broker == 14)
     {
      return("https://rest.mapi.digitexfutures.com/api/v1/public/orderbook?symbol="+ exchange_sym + "&depth=" + IntegerToString(Depth));
     }
   if(broker == 15)
     {
      return("https://api.hbdm.com/market/depth?symbol="+ exchange_sym + "&type=step" + IntegerToString(1));
     }
   if(broker == 16)
     {
      return("https://api.phemex.com/md/orderbook?symbol="+ exchange_sym);
     }

//https://kline.zbg.com/api/data/v1/entrusts
   if(broker == 17)
     {
      return("https://kline.zbg.com/api/data/v1/entrusts?marketName="+ exchange_sym + "&dataSize=" + IntegerToString(Depth));
     }


   if(broker == 18)
     {
      return("https://api.kraken.com/0/public/Depth?pair="+ exchange_sym);
     }
   if(broker == 19)//futures
     {
      return("https://api-futures.kucoin.com/api/v1/level2/depth20?symbol=" +exchange_sym);
     }
   if(broker == 20)
     {
      return("https://api.btse.com/futures/api/v2.1/orderbook/L2?symbol="+ exchange_sym);
     }

   return("");

  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ChartPro_orderbook(int exchange_id, string sym,string sym_chart, int sym_digit,int sym_lot, bool debug)
  {

   char try
      [], response[];
   string server_header = "";
   string server_string = "";

   string new_url = orderbookurl(exchange_id,sym);

   if(debug)
     {
      Print("Orderbook Data URL: " + new_url);
     }

   int res = WebRequest("GET", new_url, "", 5000, try, response, server_header);

   if(res == -1)
     {
      Print("WebRequest() ERROR" + IntegerToString(GetLastError()));
      ResetLastError();
      return (false);
     }
   else
     {

      if(res==5200)
        {

         Print("WebRequest() ERROR " + IntegerToString(GetLastError()));
         ResetLastError();
         return (false);
        }
      /*
      check for rate limit next
      429 = rate limit reached
      */

      if(res == 429)
        {
         Print("|| Slow IP Request before ban =/ ||");
        }

      if(res == 418)
        {
         Print("|| IP Address has been banned =/ ||");
         ExpertRemove();
         return (false);
        }

      if(debug)
        {
         Print("Orderbook Data Request code: " + IntegerToString(res));
         server_string = CharArrayToString(response, 0, WHOLE_ARRAY);
         Print("Orderbook Data response: " + server_string);
        }

      jasonClass.Clear();
      jasonClass.Deserialize(response);


      parse_book(exchange_id, sym_chart, sym_digit, sym_lot, debug);

      return (true);
     }

   return (false);
  }


/*

 - Bug fixed with binance volume of the orderbook ( something that has been there from the start. )

*/
string object_1 = "";
string object_2 = "";
string object_3 = "";
string object_4 = "";

double price_ask_1 = 0;
double price_bid_1 = 0;
double price_ask_1_q = 0;
double price_bid_1_q = 0;

datetime last_bar_update =0;
int last_bar_counter = 0;

/*
 - all values must be positive
 -
 double           price;           // Price
 long             volume;          // Volume
 double           volume_real;     // Real Volume

*/
int parse_book(int exchange_id, string sym_chart, int sym_quote, int sym_lot,  bool debug)
  {

   /*
   Nov 21 - free the arrays
   */
   ArrayFree(book_array);
   bool getBook=MarketBookGet(sym_chart,book_array);


   const string sym = ChartPro_RemoveSymbolSuffix(sym_chart);
   const int rates_counter = Depth - 1;      // 9
   const int rates_counter_buy = Depth;      // 10
   ArrayResize(book_array, Depth * 2);       // Bids and ask , both sides = twice the array size
   /*
    orderbook
   */
   int ret_code_book = -1;

   /*
    binance  = binance futures == binance us
    */
   if(exchange_id == 1 ||exchange_id == 5 || exchange_id == 6)
     {
      for(int i = 0; i < Depth; i++)
        {
         object_2 = jasonClass["asks"][i][0].ToStr();
         price_ask_1 = StringToDouble(object_2);
         object_3 = jasonClass["asks"][i][1].ToStr();
         price_ask_1_q = StringToDouble(object_3);

         if(price_ask_1 ==0)
           {
            if(debug)
               Print(" Empty Asks ");
            break;
           }

         book_array[rates_counter - i].price = NormalizeDouble(price_ask_1, sym_quote);
         book_array[rates_counter - i].volume_real = NormalizeDouble(price_ask_1_q, sym_lot); // VOLUME is (long) , VOLUME_REAL is (doublbe)
         book_array[rates_counter - i].type = BOOK_TYPE_SELL;
         book_array[rates_counter - i].volume = 1;
        }

      for(int i = 0; i < Depth; i++)
        {
         object_1 = jasonClass["bids"][i][0].ToStr();
         price_bid_1 = StringToDouble(object_1);
         object_4 = jasonClass["bids"][i][1].ToStr();
         price_bid_1_q = StringToDouble(object_4);

         if(price_bid_1 ==0)
           {
            if(debug)
               Print(" Empty Bids ");
            break;
           }

         book_array[rates_counter_buy + i].price = NormalizeDouble(price_bid_1, sym_quote);
         book_array[rates_counter_buy + i].volume_real = NormalizeDouble(price_bid_1_q, sym_lot); // VOLUME is (long) , VOLUME_REAL is (doublbe)
         book_array[rates_counter_buy + i].type = BOOK_TYPE_BUY;
         book_array[rates_counter_buy + i].volume= 1;
        }

     }// END OF BINANCE

// bybit
   if(exchange_id == 2)
     {

      int sell_c = 0;
      for(int i = 25; i < 35; i++)
        {
         object_2 = jasonClass["result"][i]["price"].ToStr();
         price_ask_1 = StringToDouble(object_2);
         object_3 = jasonClass["result"][i]["size"].ToStr();
         price_ask_1_q = StringToDouble(object_3);
         if(price_ask_1 ==0)
           {
            if(debug)
               Print(" Empty Asks at i " + i + " and depth " + Depth + " this should be 10 max");
            break;
           }
         book_array[sell_c].price = NormalizeDouble(price_ask_1, sym_quote);
         book_array[sell_c].volume_real = NormalizeDouble(price_ask_1_q, sym_lot); // VOLUME is (long) , VOLUME_REAL is (doublbe)
         book_array[sell_c].type = BOOK_TYPE_SELL;
         book_array[sell_c].volume = 1;
         sell_c++;
        }

      int buy_c = 10;
      for(int i = 0; i < 10; i++)
        {
         object_1 = jasonClass["result"][i]["price"].ToStr();
         price_bid_1 = StringToDouble(object_1);
         object_4 = jasonClass["result"][i]["size"].ToStr();
         price_bid_1_q = StringToDouble(object_4);

         if(price_bid_1 ==0)
           {
            if(debug)
               Print(" Empty Bids ");
            break;
           }

         book_array[buy_c].price = NormalizeDouble(price_bid_1, sym_quote);
         book_array[buy_c].volume_real = NormalizeDouble(price_bid_1_q, sym_lot); // VOLUME is (long) , VOLUME_REAL is (doublbe)
         book_array[buy_c].type = BOOK_TYPE_BUY;
         book_array[buy_c].volume = 1;
         buy_c++;
        }
     }

   /*

   bitmex has 1 array with asks and bids. asks[0-10] and bids[10-20]
   - The ask[] is the same as most brokers.
   - the bid[] counts through the bitmex array while starting at 10


   */
   if(exchange_id == 3)
     {

      for(int i = 0; i < Depth; i++)
        {
         object_2 = jasonClass[i]["price"].ToStr();
         price_ask_1 = StringToDouble(object_2);
         object_3 = jasonClass[i]["size"].ToStr();
         price_ask_1_q = StringToDouble(object_3);

         if(price_ask_1 ==0)
           {
            if(debug)
               Print(" Empty Asks at i " + i + " and depth " + Depth + " this should be 10 max ");
            break;
           }

         book_array[rates_counter - i].price = NormalizeDouble(price_ask_1, sym_quote);
         book_array[rates_counter - i].volume_real = NormalizeDouble(price_ask_1_q, sym_lot); // VOLUME is (long) , VOLUME_REAL is (doublbe)
         book_array[rates_counter - i].type = BOOK_TYPE_SELL;
         book_array[rates_counter - i].volume = 1;
        }


      for(int i = 0; i < Depth; i++)
        {
         object_1 = jasonClass[Depth+i]["price"].ToStr();
         price_bid_1 = StringToDouble(object_1);
         object_4 = jasonClass[Depth+i]["size"].ToStr();
         price_bid_1_q = StringToDouble(object_4);
         if(price_bid_1 ==0)
           {
            if(debug)
               Print(" Empty Bids  at i " + i + " and depth " + Depth + " this should be 10 max ");
            break;
           }
         book_array[rates_counter_buy + i].price = NormalizeDouble(price_bid_1, sym_quote);
         book_array[rates_counter_buy + i].volume_real = NormalizeDouble(price_bid_1_q, sym_lot); // VOLUME is (long) , VOLUME_REAL is (doublbe)
         book_array[rates_counter_buy + i].type = BOOK_TYPE_BUY;
         book_array[rates_counter_buy + i].volume = 1;
        }
     }

// kucoin and kucoin futures
   if(exchange_id == 4 || exchange_id == 19)
     {

      for(int i = 0; i < Depth; i++)
        {
         object_2 = jasonClass["data"]["asks"][i][0].ToStr();
         price_ask_1 = StringToDouble(object_2);
         object_3 = jasonClass["data"]["asks"][i][1].ToStr();
         price_ask_1_q = StringToDouble(object_3);
         if(price_ask_1 ==0)
           {
            if(debug)
               Print(" Empty Asks at i " + i + " and depth " + Depth + " this should be 10 max ");
            break;
           }
         book_array[rates_counter - i].price = NormalizeDouble(price_ask_1, sym_quote);
         book_array[rates_counter - i].volume_real = NormalizeDouble(price_ask_1_q, sym_lot); // VOLUME is (long) , VOLUME_REAL is (doublbe)
         book_array[rates_counter - i].type = BOOK_TYPE_SELL;
         book_array[rates_counter - i].volume = 1;
        }

      for(int i = 0; i < Depth; i++)
        {
         object_1 = jasonClass["data"]["bids"][i][0].ToStr();
         price_bid_1 = StringToDouble(object_1);
         object_4 = jasonClass["data"]["bids"][i][1].ToStr();
         price_bid_1_q = StringToDouble(object_4);
         if(price_bid_1 ==0)
           {
            if(debug)
               Print(" Empty Bids  at i " + i + " and depth " + Depth + " this should be 10 max ");
            break;
           }
         book_array[rates_counter_buy + i].price = NormalizeDouble(price_bid_1, sym_quote);
         book_array[rates_counter_buy + i].volume_real = NormalizeDouble(price_bid_1_q, sym_lot); // VOLUME is (long) , VOLUME_REAL is (doublbe)
         book_array[rates_counter_buy + i].type = BOOK_TYPE_BUY;
         book_array[rates_counter_buy + i].volume = 1;
        }

     }

   if(exchange_id == 7)
     {
      for(int i = 0; i < Depth; i++)
        {

         object_2 = jasonClass["result"]["asks"][i][0].ToStr();
         price_ask_1 = StringToDouble(object_2);
         object_3 = jasonClass["result"]["asks"][i][1].ToStr();
         price_ask_1_q = StringToDouble(object_3);
         if(price_ask_1 ==0)
           {
            if(debug)
               Print(" Empty Asks at i " + i + " and depth " + Depth + " this should be 10 max ");
            break;
           }
         book_array[rates_counter - i].price = NormalizeDouble(price_ask_1, sym_quote);
         book_array[rates_counter - i].volume_real = NormalizeDouble(price_ask_1_q, sym_lot); // VOLUME is (long) , VOLUME_REAL is (doublbe)
         book_array[rates_counter - i].type = BOOK_TYPE_SELL;
         book_array[rates_counter - i].volume = 1;
        }

      for(int i = 0; i < Depth; i++)
        {
         object_1 = jasonClass["result"]["bids"][i][0].ToStr();
         price_bid_1 = StringToDouble(object_1);
         object_4 = jasonClass["result"]["bids"][i][1].ToStr();
         price_bid_1_q = StringToDouble(object_4);
         if(price_bid_1 ==0)
           {
            if(debug)
               Print(" Empty Bids  at i " + i + " and depth " + Depth + " this should be 10 max ");
            break;
           }
         book_array[rates_counter_buy + i].price = NormalizeDouble(price_bid_1, sym_quote);
         book_array[rates_counter_buy + i].volume_real = NormalizeDouble(price_bid_1_q, sym_lot); // VOLUME is (long) , VOLUME_REAL is (doublbe)
         book_array[rates_counter_buy + i].type = BOOK_TYPE_BUY;
         book_array[rates_counter_buy + i].volume = 1;
        }

     }
   if(exchange_id == 8)
     {
      //okex
     }
   if(exchange_id == 9)
     {
      for(int i = 0; i < Depth; i++)
        {
         object_2 = jasonClass["asks"][i][0].ToStr();
         price_ask_1 = StringToDouble(object_2);
         object_3 = jasonClass["asks"][i][1].ToStr();
         price_ask_1_q = StringToDouble(object_3);
         if(price_ask_1 ==0)
           {
            if(debug)
               Print(" Empty Asks at i " + i + " and depth " + Depth + " this should be 10 max ");
            break;
           }
         book_array[rates_counter - i].price = NormalizeDouble(price_ask_1, sym_quote);
         book_array[rates_counter - i].volume_real = NormalizeDouble(price_ask_1_q, sym_lot); // VOLUME is (long) , VOLUME_REAL is (doublbe)
         book_array[rates_counter - i].type = BOOK_TYPE_SELL;
         book_array[rates_counter - i].volume = 1;
        }

      for(int i = 0; i < Depth; i++)
        {
         object_1 = jasonClass["bids"][i][0].ToStr();
         price_bid_1 = StringToDouble(object_1);
         object_4 = jasonClass["bids"][i][1].ToStr();
         price_bid_1_q = StringToDouble(object_4);
         if(price_bid_1 ==0)
           {
            if(debug)
               Print(" Empty Bids  at i " + i + " and depth " + Depth + " this should be 10 max ");
            break;
           }
         book_array[rates_counter_buy + i].price = NormalizeDouble(price_bid_1, sym_quote);
         book_array[rates_counter_buy + i].volume_real = NormalizeDouble(price_bid_1_q, sym_lot); // VOLUME is (long) , VOLUME_REAL is (doublbe)
         book_array[rates_counter_buy + i].type = BOOK_TYPE_BUY;
         book_array[rates_counter_buy + i].volume = 1;
        }

     }
   if(exchange_id == 10)
     {

     }
   if(exchange_id == 11)
     {

     }
   if(exchange_id == 12)
     {
      for(int i = 0; i < Depth; i++)
        {
         object_2 = jasonClass["result"]["asks"][i][0].ToStr();
         price_ask_1 = StringToDouble(object_2);
         object_3 = jasonClass["result"]["asks"][i][1].ToStr();
         price_ask_1_q = StringToDouble(object_3);
         if(price_ask_1 ==0)
           {
            if(debug)
               Print(" Empty Bids  at i " + i + " and depth " + Depth + " this should be 10 max ");
            break;
           }
         book_array[rates_counter - i].price = NormalizeDouble(price_ask_1, sym_quote);
         book_array[rates_counter - i].volume_real = NormalizeDouble(price_ask_1_q, sym_lot); // VOLUME is (long) , VOLUME_REAL is (doublbe)
         book_array[rates_counter - i].type = BOOK_TYPE_SELL;
         book_array[rates_counter - i].volume = 1;
        }
      /*
         BID BOOK
      */
      for(int i = 0; i < Depth; i++)
        {
         object_1 = jasonClass["result"]["bids"][i][0].ToStr();
         price_bid_1 = StringToDouble(object_1);
         object_4 = jasonClass["result"]["bids"][i][1].ToStr();
         price_bid_1_q = StringToDouble(object_4);
         if(price_bid_1 ==0)
           {
            if(debug)
               Print(" Empty Bids  at i " + i + " and depth " + Depth + " this should be 10 max ");
            break;
           }
         book_array[rates_counter_buy + i].price = NormalizeDouble(price_bid_1, sym_quote);
         book_array[rates_counter_buy + i].volume_real = NormalizeDouble(price_bid_1_q, sym_lot); // VOLUME is (long) , VOLUME_REAL is (doublbe)
         book_array[rates_counter_buy + i].type = BOOK_TYPE_BUY;
         book_array[rates_counter_buy + i].volume = 1;
        }
     }
   if(exchange_id == 13)
     {
      for(int i = 0; i < Depth; i++)
        {
         object_2 = jasonClass["asks"][i][0].ToStr();
         price_ask_1 = StringToDouble(object_2);
         object_3 = jasonClass["asks"][i][1].ToStr();
         price_ask_1_q = StringToDouble(object_3);
         if(price_ask_1 ==0)
           {
            if(debug)
               Print(" Empty Bids  at i " + i + " and depth " + Depth + " this should be 10 max ");
            break;
           }
         book_array[rates_counter - i].price = NormalizeDouble(price_ask_1, sym_quote);
         book_array[rates_counter - i].volume_real = NormalizeDouble(price_ask_1_q, sym_lot); // VOLUME is (long) , VOLUME_REAL is (doublbe)
         book_array[rates_counter - i].type = BOOK_TYPE_SELL;
         book_array[rates_counter - i].volume = 1;
        }

      for(int i = 0; i < Depth; i++)
        {
         object_1 = jasonClass["bids"][i][0].ToStr();
         price_bid_1 = StringToDouble(object_1);
         object_4 = jasonClass["bids"][i][1].ToStr();
         price_bid_1_q = StringToDouble(object_4);
         if(price_bid_1 ==0)
           {
            if(debug)
               Print(" Empty Bids  at i " + i + " and depth " + Depth + " this should be 10 max ");
            break;
           }
         book_array[rates_counter_buy + i].price = NormalizeDouble(price_bid_1, sym_quote);
         book_array[rates_counter_buy + i].volume_real = NormalizeDouble(price_bid_1_q, sym_lot); // VOLUME is (long) , VOLUME_REAL is (doublbe)
         book_array[rates_counter_buy + i].type = BOOK_TYPE_BUY;
         book_array[rates_counter_buy + i].volume = 1;
        }
     }


   if(exchange_id == 14)
     {
      for(int i = 0; i < Depth; i++)
        {
         object_2 = jasonClass["data"]["asks"][i][0].ToStr();
         price_ask_1 = StringToDouble(object_2);
         object_3 = jasonClass["data"]["asks"][i][1].ToStr();
         price_ask_1_q = StringToDouble(object_3);
         if(price_ask_1 ==0)
           {
            if(debug)
               Print(" Empty Bids  at i " + i + " and depth " + Depth + " this should be 10 max ");
            break;
           }
         book_array[rates_counter - i].price = NormalizeDouble(price_ask_1, sym_quote);
         book_array[rates_counter - i].volume_real = NormalizeDouble(price_ask_1_q, sym_lot); // VOLUME is (long) , VOLUME_REAL is (doublbe)
         book_array[rates_counter - i].type = BOOK_TYPE_SELL;
         book_array[rates_counter - i].volume = 1;
        }

      for(int i = 0; i < Depth; i++)
        {
         object_1 = jasonClass["data"]["bids"][i][0].ToStr();
         price_bid_1 = StringToDouble(object_1);
         object_4 = jasonClass["data"]["bids"][i][1].ToStr();
         price_bid_1_q = StringToDouble(object_4);
         if(price_bid_1 ==0)
           {
            if(debug)
               Print(" Empty Bids  at i " + i + " and depth " + Depth + " this should be 10 max ");
            break;
           }
         book_array[rates_counter_buy + i].price = NormalizeDouble(price_bid_1, sym_quote);
         book_array[rates_counter_buy + i].volume_real = NormalizeDouble(price_bid_1_q, sym_lot); // VOLUME is (long) , VOLUME_REAL is (doublbe)
         book_array[rates_counter_buy + i].type = BOOK_TYPE_BUY;
         book_array[rates_counter_buy + i].volume = 1;
        }
     }
   if(exchange_id == 15)
     {
      for(int i = 0; i < Depth; i++)
        {
         object_2 = jasonClass["tick"]["asks"][i][0].ToStr();
         price_ask_1 = StringToDouble(object_2);
         object_3 = jasonClass["tick"]["asks"][i][1].ToStr();
         price_ask_1_q = StringToDouble(object_3);
         if(price_ask_1 ==0)
           {
            if(debug)
               Print(" Empty Bids  at i " + i + " and depth " + Depth + " this should be 10 max ");
            break;
           }
         book_array[rates_counter - i].price = NormalizeDouble(price_ask_1, sym_quote);
         book_array[rates_counter - i].volume_real = NormalizeDouble(price_ask_1_q, sym_lot); // VOLUME is (long) , VOLUME_REAL is (doublbe)
         book_array[rates_counter - i].type = BOOK_TYPE_SELL;
         book_array[rates_counter - i].volume = 1;
        }

      for(int i = 0; i < Depth; i++)
        {
         object_1 = jasonClass["tick"]["bids"][i][0].ToStr();
         price_bid_1 = StringToDouble(object_1);
         object_4 = jasonClass["tick"]["bids"][i][1].ToStr();
         price_bid_1_q = StringToDouble(object_4);
         if(price_bid_1 ==0)
           {
            if(debug)
               Print(" Empty Bids  at i " + i + " and depth " + Depth + " this should be 10 max ");
            break;
           }
         book_array[rates_counter_buy + i].price = NormalizeDouble(price_bid_1, sym_quote);
         book_array[rates_counter_buy + i].volume_real = NormalizeDouble(price_bid_1_q, sym_lot); // VOLUME is (long) , VOLUME_REAL is (doublbe)
         book_array[rates_counter_buy + i].type = BOOK_TYPE_BUY;
         book_array[rates_counter_buy + i].volume = 1;
        }
     }
   if(exchange_id == 16)
     {
      for(int i = 0; i < Depth; i++)
        {
         object_2 = jasonClass["result"]["book"]["asks"][i][0].ToStr();
         price_ask_1 = StringToDouble(object_2)/10000;
         object_3 = jasonClass["result"]["book"]["asks"][i][1].ToStr();
         price_ask_1_q = StringToDouble(object_3);
         if(price_ask_1 ==0)
           {
            if(debug)
               Print(" Empty Bids  at i " + i + " and depth " + Depth + " this should be 10 max ");
            break;
           }
         book_array[rates_counter - i].price = NormalizeDouble(price_ask_1, sym_quote);
         book_array[rates_counter - i].volume_real = NormalizeDouble(price_ask_1_q, sym_lot); // VOLUME is (long) , VOLUME_REAL is (doublbe)
         book_array[rates_counter - i].type = BOOK_TYPE_SELL;
         book_array[rates_counter - i].volume = 1;
        }

      for(int i = 0; i < Depth; i++)
        {
         object_1 = jasonClass["result"]["book"]["bids"][i][0].ToStr();
         price_bid_1 = StringToDouble(object_1)/10000;
         object_4 = jasonClass["result"]["book"]["bids"][i][1].ToStr();
         price_bid_1_q = StringToDouble(object_4);
         if(price_bid_1 ==0)
           {
            if(debug)
               Print(" Empty Bids  at i " + i + " and depth " + Depth + " this should be 10 max ");
            break;
           }
         book_array[rates_counter_buy + i].price = NormalizeDouble(price_bid_1, sym_quote);
         book_array[rates_counter_buy + i].volume_real = NormalizeDouble(price_bid_1_q, sym_lot); // VOLUME is (long) , VOLUME_REAL is (doublbe)
         book_array[rates_counter_buy + i].type = BOOK_TYPE_BUY;
         book_array[rates_counter_buy + i].volume = 1;
        }
     }
   if(exchange_id == 17)
     {
      // ZBG

      //ZEC_USDT
      for(int i = 0; i < Depth; i++)
        {
         object_2 = jasonClass["datas"]["asks"][i][0].ToStr();
         price_ask_1 = StringToDouble(object_2);
         object_3 = jasonClass["datas"]["asks"][i][1].ToStr();
         price_ask_1_q = StringToDouble(object_3);
         if(price_ask_1 ==0)
           {
            if(debug)
               Print(" Empty Asks ");
            break;
           }
         book_array[rates_counter - i].price = NormalizeDouble(price_ask_1, sym_quote);
         book_array[rates_counter - i].volume_real = NormalizeDouble(price_ask_1_q, sym_lot); // VOLUME is (long) , VOLUME_REAL is (doublbe)
         book_array[rates_counter - i].type = BOOK_TYPE_SELL;
         book_array[rates_counter - i].volume = 1;
        }
      for(int i = 0; i < Depth; i++)
        {
         object_1 = jasonClass["datas"]["bids"][i][0].ToStr();
         price_bid_1 = StringToDouble(object_1);
         object_4 = jasonClass["datas"]["bids"][i][1].ToStr();
         price_bid_1_q = StringToDouble(object_4);
         if(price_bid_1 ==0)
           {
            if(debug)
               Print(" Empty Bids ");
            break;
           }
         book_array[rates_counter_buy + i].price = NormalizeDouble(price_bid_1, sym_quote);
         book_array[rates_counter_buy + i].volume_real = NormalizeDouble(price_bid_1_q, sym_lot); // VOLUME is (long) , VOLUME_REAL is (doublbe)
         book_array[rates_counter_buy + i].type = BOOK_TYPE_BUY;
         book_array[rates_counter_buy + i].volume= 1;
        }
     }
   if(exchange_id == 18)
     {
      for(int i = 0; i < Depth; i++)
        {
         object_2  = jasonClass["result"][sym]["asks"][i][0].ToStr();
         price_ask_1 = StringToDouble(object_2);
         object_3 = jasonClass["result"][sym]["asks"][i][1].ToStr();
         price_ask_1_q = StringToDouble(object_3);
         if(price_ask_1 ==0)
           {
            if(debug)
               Print(" Empty Bids  at i " + i + " and depth " + Depth + " this should be 10 max ");
            break;
           }
         book_array[rates_counter - i].price = NormalizeDouble(price_ask_1, sym_quote);
         book_array[rates_counter - i].volume_real = NormalizeDouble(price_ask_1_q, sym_lot); // VOLUME is (long) , VOLUME_REAL is (doublbe)
         book_array[rates_counter - i].type = BOOK_TYPE_SELL;
         book_array[rates_counter - i].volume = 1;
        }

      for(int i = 0; i < Depth; i++)
        {
         object_1 = jasonClass["result"][sym]["bids"][i][0].ToStr();
         price_bid_1 = StringToDouble(object_1);
         object_4 = jasonClass["result"][sym]["bids"][i][1].ToStr();
         price_bid_1_q = StringToDouble(object_4);
         if(price_bid_1 ==0)
           {
            if(debug)
               Print(" Empty Bids  at i " + i + " and depth " + Depth + " this should be 10 max ");
            break;
           }
         book_array[rates_counter_buy + i].price = NormalizeDouble(price_bid_1, sym_quote);
         book_array[rates_counter_buy + i].volume_real = NormalizeDouble(price_bid_1_q, sym_lot); // VOLUME is (long) , VOLUME_REAL is (doublbe)
         book_array[rates_counter_buy + i].type = BOOK_TYPE_BUY;
         book_array[rates_counter_buy + i].volume = 1;
        }
     }
   if(exchange_id == 19)
     {
      // kucoin futures? use == 4
     }
   if(exchange_id == 20)
     {
      for(int i = 0; i < Depth; i++)
        {
         object_2 = jasonClass["sellQuote"][i]["price"].ToStr();
         price_ask_1 = StringToDouble(object_2);
         object_3 = jasonClass["sellQuote"][i]["size"].ToStr();
         price_ask_1_q = StringToDouble(object_3);
         if(price_ask_1 ==0)
           {
            if(debug)
               Print(" Empty Bids  at i " + i + " and depth " + Depth + " this should be 10 max ");
            break;
           }
         book_array[rates_counter - i].price = NormalizeDouble(price_ask_1, sym_quote);
         book_array[rates_counter - i].volume_real = NormalizeDouble(price_ask_1_q, sym_lot); // VOLUME is (long) , VOLUME_REAL is (doublbe)
         book_array[rates_counter - i].type = BOOK_TYPE_SELL;
         book_array[rates_counter - i].volume = 1;
        }

      for(int i = 0; i < Depth; i++)
        {
         object_1 = jasonClass["buyQuote"][i]["price"].ToStr();
         price_bid_1 = StringToDouble(object_1);
         object_4 = jasonClass["buyQuote"][i]["size"].ToStr();
         price_bid_1_q = StringToDouble(object_4);
         if(price_bid_1 ==0)
           {
            if(debug)
               Print(" Empty Bids  at i " + i + " and depth " + Depth + " this should be 10 max ");
            break;
           }
         book_array[rates_counter_buy + i].price = NormalizeDouble(price_bid_1, sym_quote);
         book_array[rates_counter_buy + i].volume_real = NormalizeDouble(price_bid_1_q, sym_lot); // VOLUME is (long) , VOLUME_REAL is (doublbe)
         book_array[rates_counter_buy + i].type = BOOK_TYPE_BUY;
         book_array[rates_counter_buy + i].volume = 1;
        }
     }

   /*

   Standard for all exchanges

   */
   ret_code_book = CustomBookAdd(sym_chart, book_array);

   if(ret_code_book != -1)
     {

      if(debug)
        {


         if(ret_code_book >0)
           {
            Print("BOOK UPDATED: " + ret_code_book);
            //  Print(" Book Size: " + IntegerToString(ArraySize(book_array)) + " Ask [9] " + DoubleToString(book_array[9].price, sym_quote) + " Q [9] " + DoubleToString(book_array[9].volume_real, sym_lot));
            //  Print(" Book Size: " + IntegerToString(ArraySize(book_array)) + " Bid [10] " + DoubleToString(book_array[10].price, sym_quote) + " Q [10] " + DoubleToString(book_array[10].volume_real, sym_lot));

           }

        }
     }
   else
     {

      if(debug)
        {
         Print("BOOK UPDATE FAILED: " + IntegerToString(GetLastError()));
         ResetLastError();
        }
     }


   return(ret_code_book);
  }
//+------------------------------------------------------------------+



/*
 This function needs to be improved for performance issues since its used every second

  - grabs the best bid and ask from the Orderbook array and uses these values for the ticks[] and rates[]
  - CustomAddTicks() CustomAddRates()
  - Loads the info into the tick data base before the Bar[] is updated.
  - uses two different datetime timestamps for the bar[] which is 1minute intervals while ticks[] is every second , or whatever the rate limit is.
*/
int ChartPro_RatesAdd(int exchange_id, string sym, bool debug, datetime time, datetime tick_time,  int digit_quote, int digit_volume)
  {

   ArrayFree(ratesNew);

   int copied=CopyRates(sym,PERIOD_M1,0,1,ratesNew);

   static int counter = 0;
   counter++;
   int step_1 = ArrayResize(ratesNew,1);
   int step_2 = ArrayResize(book_array,20);


   /*
   Everything Below Must be copied for each exchange to work correctly.
   BINANCE = 1,
   BYBIT = 2,
   BITMEX = 3,
   KUCOIN = 4,
   BINANCE_FUTURES = 5,
   BINANCE_US = 6,
   DERIBIT = 7,
   // OKEX = 8,
   COINBASE = 9,
   //  BITFINEX = 10,
   // BITSTAMP =11,
   FTX = 12,
   SATANG_PRO = 13,
   DIGITEX = 14,
   HUOBI_FUTURES = 15,
   PHEMEX = 16,
   ZBG = 17,
   KRAKEN = 18,
   KUCOIN_FUTURES = 19,
   BTSE = 20
   */
   double best_ask = 0;
   double best_bid = 0;
   double vol = 0;

   if(exchange_id == 1 || exchange_id == 4 || exchange_id == 5 || exchange_id == 6 || exchange_id == 7 || exchange_id == 9 || exchange_id == 12 || exchange_id == 14 || exchange_id == 15 || exchange_id == 16  ||  exchange_id == 18)
     {
      best_ask = book_array[9].price;
      best_bid = book_array[10].price;
      vol = (book_array[9].volume_real + book_array[10].volume_real) /2 ;
     }

   if(exchange_id == 2 || exchange_id == 3 || exchange_id == 13 || exchange_id == 20 ||  exchange_id == 17)
     {
      best_ask = book_array[0].price;
      best_bid = book_array[10].price;
      vol = (book_array[0].volume_real + book_array[10].volume_real) /2 ;
     }

//  Print("L2  ask " + best_ask +"  | bid  "+ best_bid  + " ID " + exchange_id);

   tickadd(sym, best_bid, best_ask, vol, Dev_Debug_Ticks,tick_time, digit_quote, digit_volume);

// New Bar each time the TimeStamp (time) is updated within the Get_BarTimeStamp()
   if(ratesNew[0].time != time)
     {
      if(debug)
         Print("Func_Rates() Bar Time does not == Current Time == New Bar == First Bar ==> counter: " + counter);
      counter = 0;

      ratesNew[0].time = time;
      ratesNew[0].open = best_bid;
      ratesNew[0].high = best_bid;
      ratesNew[0].low = best_bid;
      ratesNew[0].close = best_bid;

      ratesNew[0].spread = 1;
      ratesNew[0].tick_volume = 1;
      ratesNew[0].real_volume = (book_array[10].volume_real + book_array[10].volume_real) / 2 ;

      // Update the current bar
     }
   else
     {
      //high
      if(best_bid> ratesNew[0].high)
        {
         ratesNew[0].high = best_bid;
        }

      //low
      if(best_bid < ratesNew[0].low)
        {
         ratesNew[0].low = best_bid;
        }

      ratesNew[0].close = best_bid;
      //ratesNew[0].time = time;

      ratesNew[0].spread = 1;
      ratesNew[0].tick_volume = counter;
      ratesNew[0].real_volume += (book_array[10].volume_real + book_array[10].volume_real) / 2 ;

     }

   int ret_code_rates = CustomRatesUpdate(sym, ratesNew);

   if(ret_code_rates != -1)
     {
      if(debug)
        {
         Print("BAR UPDATED: " + IntegerToString(ret_code_rates));
        }
     }
   else
     {
      if(debug)
        {
         Print("BAR FAILED: " + IntegerToString(GetLastError()));
        }
      ResetLastError();
     }


   return(ret_code_rates);
  }




//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int tickadd(string sym, double bid, double ask, double volume, bool debug,long time_ms, int digit_quote, int digit_volume)
  {

   ArrayFree(ticks);
   int received=CopyTicks(sym,ticks,COPY_TICKS_ALL,time_ms,1);



   time_ms = time_ms*1000;

   if(bid == 0 || ask == 0)
     {
      if(debug)
         Print("Func_Ticks: Empty Bid Ask Bucket");
      return(0);
     }

   const double update_ask = NormalizeDouble(ask, digit_quote);
   const double update_bid = NormalizeDouble(bid, digit_quote);
   const double update_volume_real = NormalizeDouble(volume, digit_volume);
   int size_of =  ArrayResize(ticks, 1);
   int tickflag = 0;
   int ret_code_tick = -1;

//  if(debug)
//     Print("Func_Ticks: symbol " + sym + " |  Bid " + DoubleToString(bid,digit_quote) + " Ask: " + ask + " Volume " + volume + " tick time " + time_ms);


   if(ticks[0].ask != update_ask)
     {
      // Print("Tick ask updated");
      ticks[0].ask = update_ask;
     }

   if(ticks[0].bid != update_bid)
     {
      // Print("Tick bid updated");
      ticks[0].bid = update_bid;
     }

   if(ticks[0].last != update_bid)
     {
      // Print("Tick last updated");
      ticks[0].last = update_bid;
     }

   if(ticks[0].time_msc != time_ms)
     {
      // Print("Tick time updated");
      ticks[0].time_msc = time_ms;
     }

   if(ticks[0].volume_real != update_volume_real)
     {
      // Print("Tick volume updated");
      ticks[0].volume_real = update_volume_real;
     }


   ticks[0].volume =1;
   ticks[0].flags = TICK_FLAG_BID|TICK_FLAG_ASK|TICK_FLAG_LAST|TICK_FLAG_SELL;// TICK_FLAG_BID|TICK_FLAG_ASK|TICK_FLAG_LAST|TICK_FLAG_SELL;

   if(debug)
      Print("Func_Ticks: symbol " + sym +
            "  | ask " + ticks[0].ask +
            "  | bid " + ticks[0].bid +
            "  | last " + ticks[0].last  +
            "  | Flag " + ticks[0].flags +
            "  | Volume " + ticks[0].volume +
            "  | R. Volume " + ticks[0].volume_real +
            "  | Milliseconds: " + ticks[0].time_msc

           );


// We must ensure the symbol exists within the market watch in order to add a new tick


   if(SymbolSelect(sym, true))
     {

      ret_code_tick = CustomTicksAdd(sym, ticks,WHOLE_ARRAY);

      if(ret_code_tick >= 1)
        {
         if(debug)
           {
            Print("TICK ADDED: " + ret_code_tick);
           }
        }
      else
        {

         int error = GetLastError();
         ResetLastError();
         if(debug)
           {
            Print("TICK FAILED: " + IntegerToString(error));
           }
        }
     }
   else
     {

      if(debug)
        {
         Print("SYMBOL DOESNT EXIST IN MARKETWATCH, USE CustomTicksReplace() ");
        }

      int Millisecond_Speed = 10000;
      ret_code_tick = CustomTicksReplace(sym,time_ms-Millisecond_Speed,time_ms,ticks,WHOLE_ARRAY);

     }

   return(0);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool closechart_removemarketwatch_delete(const string sym, const long chart_id)
  {

//close the chart
   const bool closed = ChartClose(chart_id);
   if(!closed)
     {
      Print(" failed to close the symbol 's chart " + GetLastError() + " Chart ID " + chart_id);
      ResetLastError();
      return(false);
     }

// remove from the market watch
   const bool try
         = SymbolSelect(sym,false);
   if(!try)
     {
      Print(" failed to remove the symbol from the market watch | "  + sym+" | " + GetLastError());
      ResetLastError();
      return(false);
     }

// const bool exist = SymbolExist(sym,true);
//  Print(" exist ?? " + IntegerToString(exist));

   const bool del = CustomSymbolDelete(sym);
   if(!del)
     {
      Print(" failed to delete  the custom symbol sym: " + sym+" | " + GetLastError());
      ResetLastError();
      return(false);
     }
   return(true);
  }
  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Extra_Digits_To_Min_Lot(int sym_digits)
  {

   if(sym_digits == 0)
     {
      return (1.0);
     }
   if(sym_digits == 1)
     {
      return (0.1);
     }
   if(sym_digits == 2)
     {
      return (0.01);
     }
   if(sym_digits == 3)
     {
      return (0.001);
     }
   if(sym_digits == 4)
     {
      return (0.0001);
     }
   if(sym_digits == 5)
     {
      return (0.00001);
     }
   if(sym_digits == 6)
     {
      return (0.000001);
     }
   if(sym_digits == 7)
     {
      return (0.0000001);
     }
   if(sym_digits == 8)
     {
      return (0.00000001);
     }

   return (1);
  }
  


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ENUM_TIMEFRAMES tf(int value)
  {

   if(value == 1)
     {
      return(PERIOD_M1);
     }
   if(value == 5)
     {
      return(PERIOD_M5);
     }
   if(value == 15)
     {
      return(PERIOD_M15);
     }
   if(value == 30)
     {
      return(PERIOD_M30);
     }
   if(value == 60)
     {
      return(PERIOD_H1);
     }
   if(value == 120)
     {
      return(PERIOD_H2);
     }
   if(value == 240)
     {
      return(PERIOD_H4);
     }
   if(value == 1440)
     {
      return(PERIOD_D1);
     }

   return(PERIOD_M1);

  }
  
  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string create_suffix(int id)
  {
   if(id == 0)
     {
      return(".bnx");
     }
   if(id == 1)
     {
      return(".bnc");
     }
   if(id == 2)
     {
      return(".byb");
     }
   if(id == 3)
     {
      return(".mex");
     }
   if(id == 4)
     {
      return(".kuc");
     }
   if(id == 5)
     {
      return(".bnf");
     }
   if(id == 6)
     {
      return(".bnu");
     }
   if(id == 7)
     {
      return(".der");
     }
   if(id == 8)
     {
      return(".okx");
     }
   if(id == 9)
     {
      return(".cbs");
     }

   if(id == 10)
     {
      return(".btf");
     }

   if(id == 11)
     {
      return(".bsp");
     }
   if(id == 12)
     {
      return(".ftx");
     }
   if(id == 13)
     {
      return(".sat");
     }
   if(id == 14)
     {
      return(".dig");
     }
   if(id == 15)
     {
      return(".huo");
     }
   if(id == 16)
     {
      return(".phe");
     }
   if(id == 17)
     {
      return(".zbg");
     }
   if(id == 18)
     {
      return(".kra");
     }
   if(id == 19)
     {
      return(".kuf");
     }

   if(id == 20)
     {
      return(".bts");
     }

   return(".cbp");

  }
  
  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string ChartPro_Symbols_URL(int broker)
  {

   if(broker == 1)
     {
      return("https://api.binance.com/api/v3/ticker/price");
     }
   if(broker == 2)
     {
      return("https://api.bybit.com/v2/public/orderBook/L2?symbol=");
     }
   if(broker == 3)
     {
      return("https://www.bitmex.com/api/v1/orderBook/L2?symbol=");
     }
   if(broker == 4)//spot
     {

      return("https://api.kucoin.com/api/v1/market/orderbook/level2_20?symbol=");
     }
   if(broker == 5)
     {
      return("https://fapi.binance.com/fapi/v1/ticker/price");
     }
   if(broker == 6)
     {
      return("https://api.binance.us/api/v3/depth?symbol=");
     }
   if(broker == 7)
     {
      return("https://www.deribit.com/api/v2/public/get_order_book?depth=");
     }


   if(broker == 9)
     {
      //returns 50 bars
      return("https://api.pro.coinbase.com/products/");
     }



   if(broker == 12)
     {
      return("https://ftx.com/api/markets/");
     }
   if(broker == 13)
     {
      return("https://api.tdax.com/api/v3/depth?symbol=");
     }
   if(broker == 14)
     {
      return("https://rest.mapi.digitexfutures.com/api/v1/public/orderbook?symbol=");
     }
   if(broker == 15)
     {
      return("https://api.hbdm.com/market/depth?symbol=");
     }
   if(broker == 16)
     {
      return("https://api.phemex.com/md/orderbook?symbol=");
     }

//https://kline.zbg.com/api/data/v1/entrusts
   if(broker == 17)
     {
      return("https://kline.zbg.com/api/data/v1/entrusts?marketName=");
     }


   if(broker == 18)
     {
      return("https://api.kraken.com/0/public/Depth?pair=");
     }
   if(broker == 19)//futures
     {
      return("https://api-futures.kucoin.com/api/v1/level2/depth20?symbol=");
     }
   if(broker == 20)
     {
      return("https://api.btse.com/futures/api/v2.1/orderbook/L2?symbol=");
     }

   return("");

  }
  
  

/*

   Make the URL for the get markets endpoint

   Get /endpoint

   save data into Global symbols[] array

*/
int Func_Get_Symbols(int exchange_id)
  {

   string get_url = "";
   if(exchange_id>0)
     {
      get_url = ChartPro_Symbols_URL(exchange_id);
     }

   if(get_url != "")
     {
      Func_FetchSymbols(get_url, exchange_id);
     }

   int symbol_count = ArraySize(symbols);

   return(symbol_count);
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Func_FetchSymbols(string url, int exchange)
  {
   bool debug = true;
   char try
      [], response[];
   string server_header = "";
   string server_string = "";

   string new_url = url;

   if(debug)
     {
      Print("Get Ssymbols URL: " + new_url);
     }

   int res = WebRequest("GET", new_url, "", 5000, try, response, server_header);

   if(res == -1)
     {
      Print("WebRequest() ERROR" + IntegerToString(GetLastError()));
      ResetLastError();
      return (false);
     }
   else
     {

      if(res==5200)
        {

         Print("WebRequest() ERROR " + IntegerToString(GetLastError()));
         ResetLastError();
         return (false);
        }
      /*
      check for rate limit next
      429 = rate limit reached
      */

      if(res == 429)
        {
         Print("|| Slow IP Request before ban =/ ||");
        }

      if(res == 418)
        {
         Print("|| IP Address has been banned =/ ||");
         ExpertRemove();
         return (false);
        }

      if(debug)
        {
         Print("Get Ssymbols Request code: " + IntegerToString(res));
         server_string = CharArrayToString(response, 0, WHOLE_ARRAY);
         Print("Get Ssymbols response: " + server_string);
        }

      jasonClass.Clear();
      jasonClass.Deserialize(response);
      Parse_Symbols_Data(exchange);

      return (true);
     }

   return (false);
  }

string symbols[];
int symbols_digit[];
int symbols_volume[];

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Parse_Symbols_Data(int exchange_id)
  {
   ArrayFree(symbols);
   ArrayResize(symbols,5000);
   ArrayFree(symbols_digit);
   ArrayResize(symbols_digit,5000);
   ArrayFree(symbols_volume);
   ArrayResize(symbols_volume,5000);
   int size = 5000;
   string sym = "";
   double price = 0;
   int digit_quote = 0;

   /*
    binance  = binance futures == binance us
    */
   if(exchange_id == 1 ||exchange_id == 5 || exchange_id == 6)
     {

      for(int i = 0; i < size; i++)
        {
         sym = jasonClass[i]["symbol"].ToStr();
         price = jasonClass[i]["price"].ToStr();

         if(sym == "")
           {
            ArrayResize(symbols,i);
            ArrayResize(symbols_digit,i);
            ArrayResize(symbols_volume,i);
            Print("Breaking loop at index " + i);
            break;
           }
         digit_quote = Func_QuoteDigit(price);
         symbols_digit[i] = digit_quote;
         symbols_volume[i] = Func_LotDigit(digit_quote);
         symbols[i] = sym;
         // Print(price + " |  symbol " + sym + " at index " + i + " | Digits: " + symbols_digit[i] + " | Lot Digit: " +  symbols_volume[i] );

        }
     }// END OF BINANCE

  }
  
  

int Func_QuoteDigit(string price)
  {

   double price_number = StringToDouble(price);
   price = DoubleToString(price_number,8);
// find the last value in the string, if its a zero, then remove it


   int length_at_start_1 = StringLen(price);
   int ok = StringFind(price,"0",length_at_start_1-1);

   string result = "";
   if(ok>0)
     {
      price = StringSubstr(price,0,length_at_start_1-1);
      // Print(" Found a Zero at " + ok + " updated price " + price + " ROUND 1");
     }

   int length_at_start_2 = StringLen(price);
   ok = StringFind(price,"0",length_at_start_2-1);
   if(ok>0)
     {
      price= StringSubstr(price,0,length_at_start_2-1);
      //  Print(" Found a Zero at " + ok + " updated price " + price + " ROUND 2");
     }

   int length_at_start_3 = StringLen(price);
   ok = StringFind(price,"0",length_at_start_3-1);
   if(ok>0)
     {
      price= StringSubstr(price,0,length_at_start_3-1);
      //  Print(" Found a Zero at " + ok + " updated price " + price + " ROUND 3");
     }

   int length_at_start_4 = StringLen(price);
   ok = StringFind(price,"0",length_at_start_4-1);
   if(ok>0)
     {
      price= StringSubstr(price,0,length_at_start_4-1);
      //  Print(" Found a Zero at " + ok + " updated price " + price + " ROUND 4");
     }

   int length_at_start_5 = StringLen(price);
   ok = StringFind(price,"0",length_at_start_5-1);
   if(ok>0)
     {
      price= StringSubstr(price,0,length_at_start_5-1);
      //  Print(" Found a Zero at " + ok + " updated price " + price + " ROUND 5");
     }

   int length_at_start_6 = StringLen(price);
   ok = StringFind(price,"0",length_at_start_6-1);
   if(ok>0)
     {
      price= StringSubstr(price,0,length_at_start_6-1);
      //  Print(" Found a Zero at " + ok + " updated price " + price + " ROUND 6");
     }

   int length_at_start_7 = StringLen(price);
   ok = StringFind(price,"0",length_at_start_7-1);
   if(ok>0)
     {
      price= StringSubstr(price,0,length_at_start_7-1);
      //  Print(" Found a Zero at " + ok + " updated price " + price + " ROUND 7");
     }

   int length_at_start_8 = StringLen(price);
   ok = StringFind(price,"0",length_at_start_8-1);
   if(ok>0)
     {
      price= StringSubstr(price,0,length_at_start_8-1);
      //  Print(" Found a Zero at " + ok + " updated price " + price + " ROUND 8");
     }


//value         = where is "."
//94858.39      = 6
//0.0494039484  = 2
   ok = StringFind(price,".",0);

   result = StringSubstr(price,ok,-1);
// Print(" Price " + price + " | Found . at " + ok + " with result " + result );
   /*

   result is = .909483
   substract 1 to delete the "." from the string, then count the remaining digits
   return digits past the '.'

   */
   ok = StringLen(result);
   return(ok-1);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Func_LotDigit(int digit)
  {

   if(digit == 8 || digit == 0)
     {
      return(0);
     }
   if(digit == 7)
     {
      return(0);
     }
   if(digit == 6)
     {
      return(0);
     }
   if(digit == 5)
     {
      return(0);
     }
   if(digit == 4)
     {
      return(1);
     }
   if(digit == 3)
     {
      return(2);
     }
   if(digit == 2)
     {
      return(3);
     }
   if(digit == 1)
     {
      return(4);
     }

   return(8);
  }