//+------------------------------------------------------------------+
//|                                                         IRSI.mqh |
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
class IRSI 
  {
private:
      int m_timeframe;      //rsi 周期
      int m_period;                 
public:   
      IRSI();
     ~IRSI();
      void Init(int timeframe, int period);
      double Value(int shift,int applied_price = PRICE_CLOSE);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
IRSI::IRSI()
{
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
IRSI::~IRSI()
{
}
//+------------------------------------------------------------------+
void IRSI::Init(int timeframe, int period)
{
   m_timeframe = timeframe;
   m_period = period;
}



double IRSI::Value(int shift,int applied_price)
{
   return iRSI(Symbol(),m_timeframe,m_period,applied_price,shift);  
}