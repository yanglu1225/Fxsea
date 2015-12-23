//+------------------------------------------------------------------+
//|                                                 BaseFunction.mqh |
//|                                                      dengqianfei |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "dengqianfei"
#property link      "https://www.mql5.com"
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



class D_BaseFunction
{
   public:

   public:
      D_BaseFunction();
      ~D_BaseFunction();
      
   public:
      bool AvailableLots(string symbol,int cmd,double lots,double risk,double maxlosspoint);
      
};




D_BaseFunction::D_BaseFunction(void)
{
   
}

D_BaseFunction::~D_BaseFunction(void)
{

}



//+------------------------------------------------------------------+
//| AvailableLots  --- true -- can open ,  false -- can not open more|
//| symbol --  symbol                                                |
//| cmd  -- OP_BUY or OP_SELL , can not support hedge                |
//| lots  -- lots that you want to open                              |
//| risk  -- used margin / equity < risk;                            |
//| maxlosspoint -- max loss point that you can risk                 |
//+------------------------------------------------------------------+
bool D_BaseFunction::AvailableLots(string symbol,int cmd,double lots,double risk,double maxlosspoint)
{
  bool bRet = false;
  
  if(risk < 0 || risk > 1.0)
  {
       Alert("input parameter risk must in (0,1.0]");
       return false;
  }
  if(lots <= 0)
  {
       Alert("input parameter lots must > 0");
       return false;
  }
  if(lots > 0)
  {
      double minilot =  MarketInfo(symbol,MODE_MINLOT);
      if(lots < minilot)
      {
          Alert("input parameter lots must > minilot");
          return false;
      }
  }
  
  //1. get the equity
  double equity = AccountEquity();
  //2. available equity according to the risk
  double avilable = equity * (1.0 - risk);
  //3. available free equiy after the open the lots
  double freeMarRemain = AccountFreeMarginCheck(symbol,cmd,lots);
  
  if(freeMarRemain < avilable)
  {
    return false;
  }
  
  //4. maxlosspoint check
  double totalLots = 0;
  for(int pos = 0; pos < OrdersTotal();pos++)
  {
      if(OrderSelect(pos,SELECT_BY_POS)==false) 
      {
         continue;
      }
      totalLots += OrderLots();
  }
  totalLots += lots;
  double points = MarketInfo(symbol,MODE_POINT)* 10;
  double lotsize = MarketInfo(symbol,MODE_LOTSIZE);
  double loss = totalLots * maxlosspoint * points * lotsize ;
  
  double margin = equity - freeMarRemain;
  if(equity == freeMarRemain)
  {
      margin = 1;
  }
  
  double stopLevel = (freeMarRemain - loss) / margin;
  int level=AccountStopoutLevel(); 
  
  if(AccountStopoutMode()==0) 
  {
      if( stopLevel > (level/100.0))
      {
         bRet = true;
      }
      else
      {
         bRet = false;
      }
  }
  else
  {
       if((freeMarRemain - loss) > stopLevel)
       {
         bRet = true;
       }
       else
       {
         bRet = false;
       }
  } 

  return bRet;

}