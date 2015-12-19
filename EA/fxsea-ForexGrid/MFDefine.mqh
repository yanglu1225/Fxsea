//+------------------------------------------------------------------+
//|                                                     MFDefine.mqh |
//|                                                     hu jianglong |
//|                                                      qq:47217817 |
//+------------------------------------------------------------------+
#property copyright "hu jianglong"
#property link      "qq:47217817"
#property strict
//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
// #define MacrosHello   "Hello, world!"
// #define MacrosYear    2010
//+------------------------------------------------------------------+
//| DLL imports                                                      |
//+------------------------------------------------------------------+
// #import "user32.dll"
//   int      SendMessageA(int hWnd,int Msg,int wParam,int lParam);
// #import "my_expert.dll"
//   int      ExpertRecalculate(int wParam,int lParam);
// #import
//+------------------------------------------------------------------+
//| EX5 imports                                                      |
//+------------------------------------------------------------------+
// #import "stdlib.ex5"
//   string ErrorDescription(int error_code);
// #import
//+------------------------------------------------------------------+

enum OType      // order type
{
 OT_BUY = 0,    // OP_BUY(0),OP_BUYLIMIT(2),OP_BUYSTOP(4)
 OT_SELL = 1,   // OP_SELL(1),OP_SELLLIMIT(3),OP_SELLSTOP(5)
 OT_ALL = 2,    // all above type
};

enum PType      // position type (open order)
{
 PT_PROFIT = 0, // profit position
 OT_LOSS = 1,   // loss position
};

enum TType    // trade type -- penging or open order
{
 TT_OPEN = 0,    // open order
 TT_PENDING = 1, // pending order
 TT_ALL = 2,     // pending and open order
};


enum FType     // log file type
{
 FT_LOG = 0,    // log file  FILE_CSV|FILE_READ|FILE_WRITE
 FT_PROFIT = 1, // profit file  FILE_BIN|FILE_READ|FILE_WRITE
};

enum SType
{
  ST_BUY = 0,  // buy signal
  ST_SELL = 1, // sell signal
  ST_NO = 2,   // no signal
}; 


enum TicketMarketMode     // log file type
{
 TMM_TRADES = 0,   // open or pending market 
 TMM_HISTORY = 1,  // close or del market
};

enum HedgeMode
{
 HM_LONG = 0,   // buy lots > sell lots, up trend 
 HM_SHORT = 1,  // buy lots < sell lots, down trend
 HM_EQUAL = 2,  // normal grid, buy lots == sell lots
};

struct GRIDDATA
{
  double dLowP;     // low price
  double dHighP;    // high price
  double dUnitSize; // delta
  double dBuyLots;  // buy lots
  double dSellLots; // sell lots
  double dTP;       // takeprofit
  double dSL;       // stoploss, set 0.0;
  double dTP2;      // when hedge mode is not equal, use this to take profit at opposite trend
                    // it means when the opposite trend is change to the profit trend,
                    // when (max drawdown > tp2) close all opposite order; 
  int    iMagicNum; // magic num
};

struct RISK
{
  string strSymbol;      // Symbol
  int    iMagicNum;      // magic num 
  double dRisk;          // (0.0,1.0]  risk(r) = margin(m) / equity(e) , when risk == 1.0 or 0.0, it means auto risk management
  double dMaxPointRng;   // max loss point range, not the total poing
  RISK()
  {
   strSymbol = _Symbol;   // Symbol
   iMagicNum = 114022;   // magic num 
   dRisk = 1.0;       // (0.0,1.0]  risk(r) = margin(m) / equity(e) , when risk == 1.0 or 0.0, it means auto risk management
   dMaxPointRng = 0;   // 100:1 
  }
  ~RISK(){};
  /*
  RISK operator= (const RISK& rsk)
  {
   strSymbol = rsk.strSymbol;   
   iMagicNum = rsk.iMagicNum;  
   dRisk = rsk.dRisk;      
   dLeverage = rsk.dLeverage;  
   return rsk; 
  }*/
};