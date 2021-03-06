//+------------------------------------------------------------------+
//|                                                      MFTrade.mqh |
//|                                                     hu jianglong |
//|                                                      qq:47217817 |
//+------------------------------------------------------------------+
#property copyright "hu jianglong"
#property link      "qq:47217817"
#property version   "1.00"
#property strict
#include "MFDefine.mqh"
#include <stdlib.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class MFTrade
{

private:
   double m_dMaxLots;
   string m_strSymbol;
   //int m_iSlipage;
   int m_iMagicNum;
   int m_iRetryNum; 
   
public:
   
private:
   void LogError();
   bool IsFreeMarginOK(double dLots);
   string GetTicketInfo(int iTicket,TicketMarketMode tiketType);
   bool OrderTypeMatch(int iMTType,OType orderType);
   bool TradeTypeMatch(int iMTType,TType tradeType);
   bool StopLev(double pr1,double pr2);
   
public:
    MFTrade();
    ~MFTrade();
                    
public:
   bool IsMarketClosed();
   bool IsOrderExist(double dOrderPrice,double dLots,double dDelta,int iOrderType);
   string OrderTypeToStr(int iOrderType);
   //bool CloseOrderWithType(OType orderType,TType tradeType);
   bool ClosePendingOrder(OType orderType);
   bool CloseOpenOrder(OType orderType);
   bool CloseOrderByTicket(int iTicket);
   int CloseOpenOrderByPrice(double dPrice,int orderType);
   int SendOrd(int iOrderType,double dLots,double dOpenPrice,double dTP,double dSL);
   int SendOrdInstant(int iOrderType,double dLots,double dTP,double dSL);
   //bool ModifyOrder();
   
   bool  ModifyOrder(int iTicket, double dPrice, double stoploss, double takeprofit);
   
   void MoveStopLoss(int myStopLoss);
   void SetSymbol(string strSymbol);
   void SetMagicNum(int iMagicNum);
   bool LockAccount(int& iTicket);
   bool UnLockAccount(int iTicket);
};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
MFTrade::MFTrade()
  {
    m_dMaxLots = 0.0;
    m_iRetryNum = 10;
    m_strSymbol = _Symbol;
    m_iMagicNum = 114022;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
MFTrade::~MFTrade()
  {
  }
  
  
void MFTrade::SetSymbol(string strSymbol)
{
  m_strSymbol = strSymbol;
}

 void MFTrade::SetMagicNum(int iMagicNum)
 {
   m_iMagicNum = iMagicNum;
 }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| monday 6:00 - saturday 4:00 open                                 |
//+------------------------------------------------------------------+
bool MFTrade::IsMarketClosed(void)
{

  bool bRet = false;
  int iDayOfWeek = TimeDayOfWeek(TimeLocal());
  int iHour = TimeHour(TimeLocal());
  int iMinute = TimeMinute(TimeLocal());
  if((iDayOfWeek == 6) &&(iHour>3)) // saturday 
  {
    bRet = true;
  }
  
  if(iDayOfWeek == 0)// sunday
  {
    bRet = true;
  }
  // || ((iHour=4)&&(iMinute<30)))
  if((iDayOfWeek == 1) &&(iHour<6)) // monday 
  {
    bRet = true;
  }
  
  
  return bRet;
}

/*
  
OP_BUY	0	
OP_SELL	1	
OP_BUYLIMIT	2	
OP_SELLLIMIT	3	
OP_BUYSTOP	4	
OP_SELLSTOP	5	
*/
//+------------------------------------------------------------------+
//| dOrderPrice -- order price                                       |
//| dDelta      -- error range  point                                     |
//| dLots       -- lots                                              |
//| iOrderType  -- order type  0 -- buy  1 -- sell                   |
//+------------------------------------------------------------------+
 bool  MFTrade::IsOrderExist(double dOrderPrice,double dDelta,double dLots,int iOrderType)
  {
    bool bRes = false;
    int iTotalNums = OrdersTotal();
    double dPoint = MarketInfo(m_strSymbol,MODE_POINT);
    double dDeta = dDelta * dPoint * 10;

    if(iTotalNums>0)
    {
      for(int i=OrdersTotal();i>=0;i--)
      {

        if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) continue;
        if(OrderSymbol()!= m_strSymbol || OrderMagicNumber()!= m_iMagicNum) continue;
         
         double dPrice = OrderOpenPrice();
         int iType = OrderType();
         double dAbs = MathAbs(dPrice - dOrderPrice);
         if((dAbs <= dDeta) && (dLots == OrderLots()) && (MathMod(iOrderType,2.0) == MathMod(iType,2.0))) 
         { 
            bRes  = true; 
            break;
         }

      }
    }
    return bRes;
  }


/*
//+------------------------------------------------------------------+
//| close the order with type                                        |
//+------------------------------------------------------------------+
 bool  MFTrade::CloseOrderWithType(OType orderType,TType tradeType)
 {
    bool bRet = true; 
    // high performace
    //int iTotalNums = OrdersTotal();
    for(int pos=0;pos < OrdersTotal();pos++)
    {
     if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
     if(OrderSymbol()!= m_strSymbol || OrderMagicNumber()!= m_iMagicNum) continue;
     int iType = OrderType();
     
     if(OrderTypeMatch(iType,orderType) && TradeTypeMatch(iType,tradeType))
     {
        for(int i = 0; i<m_iRetryNum; i++)
        {  
           RefreshRates();
           if((iType > 1)) // pending order
           { 
             bRet=OrderDelete(OrderTicket());
             if(bRet) { break;}
             else { LogError();}
           }
           else  // buy or sell order
           {
             if((tradeType == TT_OPEN || (tradeType == TT_ALL)))
             {
                double dPrice = 0.0;
                if(iType == OP_BUY) 
                  { dPrice = MarketInfo(m_strSymbol,MODE_BID);}
                else 
                  { dPrice = MarketInfo(m_strSymbol,MODE_ASK);}
                bRet = OrderClose(OrderTicket(),OrderLots(),dPrice,0,clrRed);
                if(bRet) 
                 { break;}
                else 
                 { LogError();}
             }
           }
        }
           
      }
         
    }
   
  // low performace
  //if( ClosePendingOrder(orderType) && CloseOpenOrder(orderType)) bRet = true;
   
    return bRet;
 }
 */
 
//+------------------------------------------------------------------+
//| close pengding order with order type                             |
//+------------------------------------------------------------------+
bool MFTrade::ClosePendingOrder(OType orderType)
{
    bool bRet = false;
    //int iTotalNums = OrdersTotal();
    for(int pos=0;pos<OrdersTotal();pos++)
    {
     if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
     if(OrderSymbol()!= m_strSymbol || OrderMagicNumber()!= m_iMagicNum) continue;
     int iType = OrderType();
     if(iType > 1)// pending order
     { 
       if(OrderTypeMatch(iType,orderType))
       {
         for(int i = 0; i<m_iRetryNum; i++)
         {   
             RefreshRates();
             bRet=OrderDelete(OrderTicket());
             if(bRet) { break;}
             else { LogError();}
         }
       }
           
      }
         
    }
   
   return bRet;
 
}
 
//+------------------------------------------------------------------+
//| close open order with order type                                 |
//+------------------------------------------------------------------+
bool MFTrade::CloseOpenOrder(OType orderType)
{
   bool bRet = false;
  // int iTotalNums = OrdersTotal();
   for(int pos=0;pos<OrdersTotal();pos++)
   {
     if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
     if(OrderSymbol()!= m_strSymbol || OrderMagicNumber()!= m_iMagicNum) continue;
     int iType = OrderType();
 
     if(iType <= 1)// open order
     {
         if(OrderTypeMatch(iType,orderType))
         {
           for(int i = 0; i<m_iRetryNum; i++)
           {
                double dPrice = 0.0;
                RefreshRates();
                if(iType == OP_BUY) 
                  { dPrice = MarketInfo(m_strSymbol,MODE_BID);}
                else 
                  { dPrice = MarketInfo(m_strSymbol,MODE_ASK);}
                bRet = OrderClose(OrderTicket(),OrderLots(),dPrice,0);
                if(bRet) 
                 { break;}
                else 
                 { LogError();}
           }     
         }
      }   
   }
   
   return bRet;

}
 
//+------------------------------------------------------------------+
//| compare the MT4/MT5 order type with self defined order type      |
//+------------------------------------------------------------------+ 
bool MFTrade::OrderTypeMatch(int iMTType,OType orderType)
{
   int iMod = (int)MathMod(iMTType,2);
   return(((iMod == orderType) || (orderType >iMod)));
}

//+------------------------------------------------------------------+
//| compare the MT4/MT5 order type with self defined trade type      |
//+------------------------------------------------------------------+ 
bool MFTrade::TradeTypeMatch(int iMTType,TType tradeType)
{
   bool bRet = false;
   if( (iMTType > 1) && ((tradeType == TT_PENDING) || (tradeType == TT_ALL)))
     bRet = true;
    if( (iMTType < 1) && ((tradeType == TT_OPEN) || (tradeType == TT_ALL)))
      bRet = true;
   return bRet;
}
 
//+------------------------------------------------------------------+
//| get last error to log file                                       |
//+------------------------------------------------------------------+ 
void  MFTrade::LogError()
{
  int error = GetLastError();
  string strError = ErrorDescription(error);
  Print(strError); 
}
//+------------------------------------------------------------------+
//| iOrderType -- type  0 -- buy   1 -- sell   limited or stop order | 
//| dLots   -- must > 0.01; (1k)                                     |
//| dOpenPrice -- open price                                         |
//| dTP  -- takeprofit point, at least > 10 point                    |
//| dSL  -- stoplost, at least > 10 point                            |
//+------------------------------------------------------------------+
int MFTrade::SendOrd(int iOrderType,double dLots,double dOpenPrice,double dTP,double dSL)
{
   int iTicket = 0;
 //  if(!IsFreeMarginOK(dLots))
 //     return(iTicket);
   double dPoint = MarketInfo(m_strSymbol,MODE_POINT);
   int digtits = MarketInfo(m_strSymbol,MODE_DIGITS);
   for(int i=1;i<m_iRetryNum;i++)
     {
      RefreshRates();
      double dBid = MarketInfo(m_strSymbol,MODE_BID);
      double dAsk = MarketInfo(m_strSymbol,MODE_ASK);
      int iType = 0;
      double dSl=0.0,dTp=0.0;
      double dPrice = NormalizeDouble(dOpenPrice,digtits);
      string strCom = "MFly-EA";
      switch(iOrderType)
       {
         case 0:
         {
              if(dPrice > dAsk) iType = OP_BUYSTOP;
              else iType = OP_BUYLIMIT;
              if(dSL>0)
              {
                  dSl = dPrice-dSL*dPoint*10;
                  dSL = NormalizeDouble(dSl,digtits);
              }
              if(dTP>0)
              {
                  dTp = dPrice+dTP*dPoint*10;
                  dTp = NormalizeDouble(dTp,digtits);
              }
              iTicket=OrderSend(m_strSymbol,iType,dLots,dPrice,0,dSl,dTp,strCom,m_iMagicNum,0,clrYellow);
              
              break;
         }
         case 1:
         {  
              if(dPrice > dBid) iType = OP_SELLLIMIT;
              else iType = OP_SELLSTOP;
              if(dSL>0)
              {
                  dSl = dPrice + dSL*dPoint*10;
                  dSL = NormalizeDouble(dSl,digtits);
              }
              if(dTP>0)
              {
                  dTp = dPrice - dTP*dPoint*10;
                  dTp = NormalizeDouble(dTp,digtits);
              }
              
              iTicket=OrderSend(m_strSymbol,iType,dLots,dPrice,0,dSl,dTp,strCom,m_iMagicNum,0,clrGreen);
              break;
          }
        }
        
      if(iTicket>0) break;
      else LogError();
   }
  return iTicket;

}

//+------------------------------------------------------------------+
//| iOrderType -- type  0 -- buy   1 -- sell  instant order          | 
//| dLots   -- must > 0.01; (1k)                                     |
//| dTP  -- takeprofit point, at least > 10 point                    |
//| dSL  -- stoplost, at least > 10 point                            |
//+------------------------------------------------------------------+
int MFTrade::SendOrdInstant(int iOrderType,double dLots,double dTP,double dSL)
{
   int iTicket = -1;
   double dPoint = MarketInfo(m_strSymbol,MODE_POINT);
   double dBid = MarketInfo(m_strSymbol,MODE_BID);
   double dAsk = MarketInfo(m_strSymbol,MODE_ASK);
 //  if(!IsFreeMarginOK(dLots))
 //     return(iTicket);
   int iSpread =  MarketInfo(m_strSymbol,MODE_SPREAD);
   double dBuyLossStop = dAsk - dSL*dPoint*10;
   double dBuyTakeProfit = dAsk + dTP*dPoint*10;
   double dSellLossStop = dBid +  dSL*dPoint*10;
   double dSellTakeProfit = dBid -  dTP*dPoint*10;
   
   if(dTP <=0.0)
   {
    dBuyTakeProfit = 0.0; 
    dSellTakeProfit = 0.0;
   }
   
   if(dSL <=0.0)
   {
    dBuyLossStop = 0.0; 
    dSellLossStop = 0.0;
   }   
   
   
   for(int i=1;i<m_iRetryNum;i++)
     {
      RefreshRates();
      dBid = MarketInfo(m_strSymbol,MODE_BID);
      dAsk = MarketInfo(m_strSymbol,MODE_ASK);
      int iType = 0;
      double dSl=0.0,dTp=0.0;
      string strCom = "MFly-EA";
      switch(iOrderType)
       {
         case 0:
         {
              iTicket=OrderSend(m_strSymbol,OP_BUY,dLots,dAsk,iSpread,dBuyLossStop,dBuyTakeProfit,strCom,m_iMagicNum,0,clrYellow);
              break;
         }
         case 1:
         {              
              iTicket=OrderSend(m_strSymbol,OP_SELL,dLots,dBid,0,dSellLossStop,dSellTakeProfit,strCom,m_iMagicNum,0,clrGreen);
              break;
          }
        }
        
      if(iTicket>0) break;
      else LogError();
   }
  return iTicket;



}

//+------------------------------------------------------------------+
//| check the free margin                                            |
//+------------------------------------------------------------------+ 
bool MFTrade::IsFreeMarginOK(double dLots)
{

  bool bRet = false;
  
  // Equity is small than
 
  //0. test whether the free margin can buy dLots, if not there is no free margin
  if(AccountFreeMarginCheck(Symbol(),OP_BUY,dLots)<=0 || GetLastError()==134) 
  {
     return bRet ;
  }
  else
  { bRet = true;}
  
  /*
  //1. get free margin
 
  double dOpenLots = 0.0;
  double dOpenProfits = 0.0;
  double dNotOpenLots = 0.0;
  
  //2. the num of lots 
  int total=OrdersTotal();
  for(int pos=0;pos<total;pos++)
  {
     if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
     if(OrderSymbol()!= m_strSymbol || OrderMagicNumber()!= m_iMagicNum) continue;
     int iOrderType = OrderType();
     // OP_BUY or OP_SELL is open trade
     if(iOrderType == OP_BUY || iOrderType == OP_SELL)
     {
        dOpenLots += OrderLots();
        dOpenProfits += OrderProfit();
     }
     else //OP_BUYLIMIT OP_SELLLIMIT  OP_BUYSTOP OP_SELLSTOP are not open trade
     {
        dNotOpenLots += OrderLots();
     }
   
   }
  
   double dCurTotalLots = dOpenLots + dNotOpenLots;
   if(dCurTotalLots == 0)
   {
     return true;
   }
 
   //3. profit point 
   double dLotSize = MarketInfo(m_strSymbol,MODE_LOTSIZE);
   double dProfitPoint = 0.0;

   if(dOpenLots!=0) dProfitPoint= dOpenProfits/dOpenLots* 0.1;
   
    //4. cal the avaiable lots
    double dFreeMargin = AccountFreeMargin();
    double dAvailableLots = 0.0;
    dAvailableLots =  (dFreeMargin - dCurTotalLots*(m_iMarginPoint-dProfitPoint))/1000;

   if(dAvailableLots > 0.01) bRet = true;
  */
   return true;

}

//+------------------------------------------------------------------+
//| move stop loss, you need set stoploss and takeprofit when open the order |
//+------------------------------------------------------------------+ 

void MFTrade::MoveStopLoss(int myStopLoss)
{
  //int total=OrdersTotal();
  double dPoint = MarketInfo(m_strSymbol,MODE_POINT);
  double dBid = MarketInfo(m_strSymbol,MODE_BID);
  double dAsk = MarketInfo(m_strSymbol,MODE_ASK);
  for(int pos=OrdersTotal();pos>=0;pos--)
  {
     if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
     if(OrderSymbol()!= m_strSymbol || OrderMagicNumber()!= m_iMagicNum) continue;
     dBid = MarketInfo(m_strSymbol,MODE_BID);
     dAsk = MarketInfo(m_strSymbol,MODE_ASK);
     int iOrderType = OrderType();
     double dStopLostPri = OrderStopLoss();
     bool bModify = false;
     // OP_BUY or OP_SELL is open trade
     RefreshRates();
     if((iOrderType == OP_BUY) && (OrderProfit() > 0) && ((dBid - OrderStopLoss()) > (2*myStopLoss*dPoint*10)))
     {
       dStopLostPri = dBid - myStopLoss*dPoint * 10;
       bModify = true;
     }
     if(iOrderType == OP_BUY && (OrderProfit() > 0) && ((OrderStopLoss() - dAsk) > (2*myStopLoss*dPoint*10)))
     {
        dStopLostPri = dAsk + myStopLoss*dPoint * 10;
        bModify = true;
     }
     
     if(bModify)
     {
        for(int i = 0; i<m_iRetryNum; i++)
        { 
          RefreshRates();
          bool bMo = OrderModify(OrderTicket(),OrderOpenPrice(),dBid - myStopLoss*dPoint * 10,OrderTakeProfit(),0);
          if (bMo) break;
        }
     }
   }
  
}



 bool MFTrade::CloseOrderByTicket(int iTicket)
 {
   bool bRet = false;
   if(OrderSelect(iTicket,SELECT_BY_TICKET)==false) return bRet;
    for(int i = 0; i<m_iRetryNum; i++)
    {
      RefreshRates();
      double dBid = MarketInfo(m_strSymbol,MODE_BID);
      double dAsk = MarketInfo(m_strSymbol,MODE_ASK); 
      if(OrderType() == OP_BUY)
        bRet = OrderClose(iTicket,OrderLots(),dBid,0,clrRed);
      if(OrderType() == OP_SELL)
        bRet = OrderClose(iTicket,OrderLots(),dAsk,0,clrRed);  
      if(bRet) break;
      else
         LogError();
    }
   
   return bRet;
 }

//+------------------------------------------------------------------+
//| orderType 0 -- buy  1 -- sell                                     |
//+------------------------------------------------------------------+ 
int MFTrade::CloseOpenOrderByPrice(double dPrice,int orderType)
{
   int iTicket = -1;
   //int iTotalNums = OrdersTotal();
   for(int pos=OrdersTotal();pos>=0;pos--)
   {
     if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
     if(OrderSymbol()!= m_strSymbol || OrderMagicNumber()!= m_iMagicNum) continue;
     int iType = OrderType();
     if(iType <= 1)// open order
     {
         if(orderType == iType)
         {
           for(int i = 0; i<m_iRetryNum; i++)
           {  
              RefreshRates();
              double dOrderPrice = OrderOpenPrice(); 
              if(MathAbs(dPrice - dOrderPrice)/(Point*10) < 10)
              {  
                int iTicketID = OrderTicket();
                double dPri = dPrice;
                if(iType == OP_BUY) 
                { dPri = MarketInfo(m_strSymbol,MODE_BID);}
                else 
                { dPri = MarketInfo(m_strSymbol,MODE_ASK);}
                bool bRet = OrderClose(iTicketID,OrderLots(),dPri,0);
                if(bRet) 
                { 
                  iTicket = iTicketID;
                  break;
                }
                else 
                { LogError();} 
                
              }
           }     
         }
      }   
   }
   
   
   return iTicket;
}


bool MFTrade::LockAccount(int& iTicket)
{
  bool bRet = false;
  double dSellLots = 0;
  double dBuyLots = 0;
   for(int pos=OrdersTotal();pos>=0;pos--)
   {
     if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
     if(OrderSymbol()!= m_strSymbol || OrderMagicNumber()!= m_iMagicNum) continue;
     int iType = OrderType();
     if(iType == OP_BUY)// open order
     {
       dBuyLots += OrderLots();
     } 
      
     if(iType == OP_SELL)  
     {
       dSellLots += OrderLots();
     }
   }
   
   bool bLock = false;
   double dLockLots = 0.0;
   int iType = OP_BUY;
   if(dSellLots > dBuyLots)
   {
      dLockLots = dSellLots - dBuyLots;
      iType =  OP_BUY;
      bLock = true;
   }
   if(dSellLots < dBuyLots)
   {
      dLockLots = dBuyLots - dSellLots;
      iType =  OP_SELL;
      bLock = true;   
   }
   if(dSellLots == dBuyLots)
   return false;
   
   if(bLock)
   {
       for(int i = 0; i<m_iRetryNum; i++)
       { 
         RefreshRates();
         double dBid = MarketInfo(m_strSymbol,MODE_BID);
         double dAsk = MarketInfo(m_strSymbol,MODE_ASK);
         int iSpread = MarketInfo(m_strSymbol,MODE_SPREAD);
         if(iType == OP_BUY)
           iTicket = OrderSend(m_strSymbol,iType,dLockLots,dAsk,iSpread,0,0,"Lock Accout",m_iMagicNum,0,clrRed);
         else
           iTicket = OrderSend(m_strSymbol,iType,dLockLots,dBid,iSpread,0,0,"Lock Accout",m_iMagicNum,0,clrRed);
         
         if(iTicket > 0)
         {bRet = true; break;}
         else LogError();
       }   
   }

   
  return bRet;

}


bool MFTrade::UnLockAccount(int iTicket)
{

  return CloseOrderByTicket(iTicket);

}


 bool  MFTrade::ModifyOrder(int iTicket, double dPrice, double stoploss, double takeprofit)
 {
   bool bRet = false;
   if(OrderSelect(iTicket,SELECT_BY_TICKET)==false) return bRet;
   if(OrderSymbol()!= m_strSymbol || OrderMagicNumber()!= m_iMagicNum) return bRet;
    //for(int i = 0; i<m_iRetryNum; i++)
    {
    
      //if(OrderType() == OP_BUY)
      //if(!StopLev(dPrice,stoploss))
      bRet = OrderModify(iTicket,dPrice,stoploss,takeprofit,0,clrRed);
      if(bRet);// break;
      else
         LogError();
    }
   
   return bRet;
 }
 
 
 //+------------------------------------------------------------------+
//| StopLev                                                          |
//+------------------------------------------------------------------+
bool MFTrade:: StopLev(double pr1,double pr2)
  {
   bool res=true;
   double dPoint = MarketInfo(m_strSymbol,MODE_POINT);
  
   long par=MarketInfo(m_strSymbol,MODE_STOPLEVEL);  //SymbolInfoInteger(m_strSymbol,SYMBOL_TRADE_STOPS_LEVEL);
   if(long(MathCeil((pr1-pr2)/dPoint))<=par)res=false;

   return(res);
  }