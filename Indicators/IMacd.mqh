//+------------------------------------------------------------------+
//|                                                        IMacd.mqh |
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
class IMacd
{
private:
      int m_timeframe;      
      int m_fast_period;
      int m_slow_period;
      int m_signal_period;
public:
      IMacd();
     ~IMacd();
     
      void Init(int timeframe, int fast_period, int slow_period, int signal_period);
      double Value(int shift,int applied_price = PRICE_CLOSE,int mode = MODE_MAIN);
};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
IMacd::IMacd()
{
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
IMacd::~IMacd()
{
}
//+------------------------------------------------------------------+
void IMacd::Init(int timeframe, int fast_period, int slow_period, int signal_period)
{
   m_timeframe = timeframe;
   m_fast_period = fast_period;
   m_slow_period = slow_period;
   m_signal_period = signal_period;
}



double IMacd::Value(int shift,int applied_price,int mode)
{
   return iMACD(Symbol(),m_timeframe,m_fast_period,m_slow_period,m_signal_period,applied_price,mode,shift);
}  
