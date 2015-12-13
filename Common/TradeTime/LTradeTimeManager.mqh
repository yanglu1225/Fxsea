//+------------------------------------------------------------------+
//|                                             TradeTimeManager.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class TradeTimeManager
  {
public:
      bool TradeOnFriday;
      int Friday_Hour;
      int Open_Hour;
      int Close_Hour;
public:
      TradeTimeManager();
     ~TradeTimeManager();
     
     bool isTimeValid();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
TradeTimeManager::TradeTimeManager()
  {
      TradeOnFriday = true;
      Friday_Hour = 0;
      Open_Hour = 0;
      Close_Hour = 0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
TradeTimeManager::~TradeTimeManager()
  {
  }
//+------------------------------------------------------------------+


bool TradeTimeManager::isTimeValid()
{
   bool Trade = true;
   if (!TradeOnFriday && DayOfWeek() == 5) Trade = FALSE;
   if (TradeOnFriday && DayOfWeek() == 5 && TimeHour(TimeCurrent()) > Friday_Hour) Trade = FALSE;   
   if (Open_Hour==24)Open_Hour=0;
   if (Close_Hour==24)Close_Hour=0;     
   if (Open_Hour < Close_Hour && TimeHour(TimeCurrent()) < Open_Hour || TimeHour(TimeCurrent()) >= Close_Hour) Trade = FALSE;
   if (Open_Hour > Close_Hour && (TimeHour(TimeCurrent()) < Open_Hour && TimeHour(TimeCurrent()) >= Close_Hour)) Trade = FALSE; 
 //  if (Month()==12 && Day()>22)  Trade = FALSE; 
 //  if (Month()==1 && Day()<5)  Trade = FALSE;  

   return Trade;
}