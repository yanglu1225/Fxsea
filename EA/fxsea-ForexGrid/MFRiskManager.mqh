//+------------------------------------------------------------------+
//|                                                MFRiskManager.mqh |
//|                                                     hu jianglong |
//|                                                      qq:47217817 |
//+------------------------------------------------------------------+
#property copyright "hu jianglong"
#property link      "qq:47217817"
#property version   "1.00"
#property strict
#include "MFDefine.mqh"
#include "MFTrade.mqh"
#include "MFSave.mqh"

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class MFRiskManager
{
private:
     RISK m_risk;
     GRIDDATA m_grid;
     HedgeMode m_HMode;
     int m_iGridNums;
     MFTrade m_trade;
     bool m_bAcctLocked;
     int  m_iLockTicket;
     MFSave m_fileSaveTicket;
    // string m_strGlobalLockTicket;
     
public:
     MFRiskManager();
     ~MFRiskManager();
private:
     double MathF(double a,double b,double c);
     bool OrderTypeMatch(int iMTType,OType orderType);
     int GridNumsCalByRiskAndMargin();   
     int GridNumsCalByPriceAndDelta();      
     double GridLotsOfCurUnilateral();
     //double MaxRiskLots();  
     double MaxRiskPoint();   
     
    double LotsOfCurrent();
    double GridBalanceCalByPriceAndDelta();
     double GridBalanceCalByMaxLossPointRng();
    void SaveGlobalVar();
    void ReadGlobalVar();
   
public:
     void SetRisk(RISK& risk);
     void SetGridData(GRIDDATA& gd,HedgeMode hd);
     bool GridRiskCheckInit();
     bool GridLotsAviable(double dLots);
     void DynamicRiskControl(double dMaxDrawdown);
     bool IsAccountLocked();
    
};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
MFRiskManager::MFRiskManager()
  {
    m_iGridNums = 0;
    m_bAcctLocked = false;
    m_iLockTicket = -1;   
   // m_strGlobalLockTicket = "LockedTicket";
    m_fileSaveTicket.SetFileName("LockedTicket.txt");
    ReadGlobalVar();
     
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
MFRiskManager::~MFRiskManager()
  {
  }
  
void MFRiskManager::SetRisk(RISK& rsk)
  {
  
   m_risk.strSymbol = rsk.strSymbol;   
   m_risk.iMagicNum = rsk.iMagicNum;  
   m_risk.dRisk = rsk.dRisk;      
   m_risk.dMaxPointRng = rsk.dMaxPointRng;  
   
   
  // m_risk = rsk;
  }
  
void MFRiskManager::SetGridData(GRIDDATA& gd,HedgeMode hd)
{
  m_grid = gd;
  m_HMode = hd;
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| get the lots if use grid 
//| calc gird high according with risk and free balance                   |
//+------------------------------------------------------------------+ 
int MFRiskManager::GridNumsCalByRiskAndMargin()
{

  //  margin(m) / equity(e) = risk(r)
  double r=m_risk.dRisk;//e,m,
  if(r == 0.0) r = AccountStopoutLevel();
  // margin(m) = lots(ls) * marginrequired(mr) //MARGINREQUIRED
  double ls,mr=1000;
  mr = MarketInfo(m_risk.strSymbol,MODE_MARGINREQUIRED);
  // equity(e) = balance(b) - profitlost(pl)
  double b = 1000; //,pl
  b = AccountBalance();
  //b = MathMin(AccountFreeMargin(),AccountBalance());
  
  // profitlost(pl) = (n*(n+1) / 2.0) * ordersize(os) * 10 *gridsize(gz)
  double os = 0.02,gz=50.0; //n,
  os = MathMax(m_grid.dSellLots,m_grid.dBuyLots);
  double osmr = MathMax(m_grid.dSellLots,m_grid.dBuyLots)-MathMin(m_grid.dSellLots,m_grid.dBuyLots); 
  if(os <= 0.0) return 0;
  gz = m_grid.dUnitSize;
  
  //n= ls/os
  double t1 = 5 * os * gz;
  
  
  double aa = t1;
  double bb = t1 + osmr*mr/r;
  double cc = 0.0 - b;
  
  
  ls = MathF(aa,bb,cc);
  
  
  return int(ls);
  
  
}


int MFRiskManager::GridNumsCalByPriceAndDelta()
{
   double dPoint = MarketInfo(m_risk.strSymbol,MODE_POINT);
   int iRet = 1;
   double dH,dL,dSz;
   dH = MathMax(m_grid.dHighP,m_grid.dLowP);
   dL = MathMin(m_grid.dHighP,m_grid.dLowP);
   dSz = m_grid.dUnitSize;
   if(dSz <= 0.0) return iRet;
   double delta = (dH - dL) / (dPoint*10);
   
   iRet = int(delta/dSz);
   
   return iRet;
}


double MFRiskManager::GridBalanceCalByPriceAndDelta()
{
   double dRet = 0;
   double dH,dL,dSz;
   dH = MathMax(m_grid.dHighP,m_grid.dLowP);
   dL = MathMin(m_grid.dHighP,m_grid.dLowP);
   dSz = m_grid.dUnitSize;
   if(dSz <= 0.0) return dRet;
   double delta = (dH - dL) / (Point*10);
   
   int iGridNums = int(delta/dSz);
   double dLots = MathMax(m_grid.dSellLots,m_grid.dBuyLots) - MathMin(m_grid.dBuyLots,m_grid.dSellLots);
   double dMLots = MathMax(m_grid.dSellLots,m_grid.dBuyLots);
   double mr = MarketInfo(m_risk.strSymbol,MODE_MARGINREQUIRED);
   double dMargin = iGridNums * dLots * mr;
   double dMr = dMargin/m_risk.dRisk;
   double dLoss = dMLots*m_grid.dUnitSize*10*(iGridNums + 1)*iGridNums/2.0;
   
   dRet = dMr + dLoss;
   
   return dRet;
}

bool MFRiskManager::GridRiskCheckInit()
{
   bool bRet = false;
   if(m_iGridNums <=0.0)
    m_iGridNums= GridNumsCalByRiskAndMargin();
   int iNum = m_iGridNums;
   int iNum1 = GridNumsCalByPriceAndDelta();
   
   if(iNum >= iNum1) bRet = true;
   else
   {
     double dMr = GridBalanceCalByPriceAndDelta();
     dMr = NormalizeDouble(dMr,1);
      Alert("blance is not enough you need :",dMr," $");
      Alert("or please change the high price and low price range, or grid size");
      Alert("grid size: ",iNum);
      
   }
   
   double dB = GridBalanceCalByMaxLossPointRng();
   double dBanlace = AccountBalance();
   if(dB > dBanlace)
   {
      Alert("blance is not enough you need :",dB," $");
      Alert("or please change the max loss point range");
     bRet = false;
   }
   
   return bRet;
  
}

double MFRiskManager::GridBalanceCalByMaxLossPointRng()
{
   double dBalance = 0.0;
   double dMaxLoss = 0.0;
   double dMaxMr = 0.0;
   int dN = int(m_risk.dMaxPointRng / m_grid.dUnitSize);
   double dLotSize = MathMax(m_grid.dBuyLots,m_grid.dSellLots);
   dMaxLoss = (dN * (dN+1) / 2.0) * m_grid.dUnitSize * dLotSize * 10; 
   
   double dLots = MathMax(m_grid.dBuyLots,m_grid.dSellLots) - MathMin(m_grid.dBuyLots,m_grid.dSellLots);
   double dMr = MarketInfo(m_risk.strSymbol,MODE_MARGINREQUIRED);
   dMaxMr = dN * dLots * dMr / m_risk.dRisk;
   
   dBalance = dMaxLoss + dMaxMr;
   
   return dBalance;


}




//+------------------------------------------------------------------+
//| get the lots of pengding, open order                             |
//| MathMax(dBLots,dSLots)                       |
//+------------------------------------------------------------------+ 
double MFRiskManager::GridLotsOfCurUnilateral()
{
  double dLots = 0.0;
  double dSLots = 0.0;
  double dBLots = 0.0;
  //int total=OrdersTotal();
  for(int pos=OrdersTotal();pos>0;pos--)
  {
     if(OrderSelect(pos,SELECT_BY_POS,MODE_TRADES)==false) continue;
     if(OrderSymbol()!= m_risk.strSymbol || OrderMagicNumber()!= m_risk.iMagicNum) continue;
     int iOrderType = OrderType();
     if(OrderTypeMatch(iOrderType,OT_BUY)) // buy order (BUY,BUYLIMITED,BUYSTOP)
     { dBLots += OrderLots();}
     else // sell order // sell order (SELL,SELLLIMITED,SELLSTOP)
     { dSLots += OrderLots();}
   
  }
  
  /* 
   if(m_HMode == HM_EQUAL) 
   { dLots = (dSLots + dBLots)/2.0;}
   else
   { dLots = MathMax(dBLots,dSLots);}
  */
   dLots = MathMax(dBLots,dSLots);
   return dLots;
   
}

bool MFRiskManager::GridLotsAviable(double dLots)
{
   bool bRet = false;
   if(m_iGridNums <=0.0)
    m_iGridNums= GridNumsCalByRiskAndMargin();
    
   int iNums = m_iGridNums;
   double dLs = MathMax(m_grid.dSellLots,m_grid.dBuyLots);
   double dLotsTotal = iNums * dLs;
   double dLotsCur = GridLotsOfCurUnilateral();
   //Print("funtion:",__FUNCTION__,", dLotsCur:",dLotsCur,"  ,total:",dLotsTotal);
   if(dLotsTotal > (dLotsCur + dLots)) bRet = true;
   return bRet;
}



double  MFRiskManager::MaxRiskPoint()
{
  double dLots = 0.0;
 // double dLots = GridRiskManager();
  return dLots;
}

double MFRiskManager::MathF(double a,double b,double c)
{
 double x,delta,y;
 if(a==0.0 && b==0.0 &&c != 0.0) return 0.0;
 else if(a==0&&b!=0)
 {
  x=-c/b;
  return x;
 }
 else 
 {
  delta=b*b-4*a*c;
  if(delta==0.0)
  {
   x=(-b+sqrt(delta))/(2*a);
   x = MathMax(x,0);
   return x;
  }
  else if(delta<0)
  {
   x=(-b+sqrt(delta))/(2*a);
   y=(-b-sqrt(delta))/(2*a);
   x=MathMax(x,y);
   return x;
  }
  else
  {
   x=(-b+sqrt(delta))/(2*a);
   y=(-b-sqrt(delta))/(2*a);
   x=MathMax(x,y);
   return x;
  }
 }
 return 0.0;
}



//+------------------------------------------------------------------+
//| get the lots of pengding + open order                             |
//+------------------------------------------------------------------+ 
double MFRiskManager::LotsOfCurrent()
{
  double dLots = 0.0;
  double dSLots = 0.0;
  double dBLots = 0.0;
  int total=OrdersTotal();
  for(int pos=0;pos<total;pos++)
  {
     if(OrderSelect(pos,SELECT_BY_POS,MODE_TRADES)==false) continue;
     if(OrderSymbol()!= m_risk.strSymbol || OrderMagicNumber()!= m_risk.iMagicNum) continue;
     int iOrderType = OrderType();
     if(OrderTypeMatch(iOrderType,OT_BUY)) // buy order (BUY,BUYLIMITED,BUYSTOP)
     { dBLots += OrderLots();}
     else // sell order // sell order (SELL,SELLLIMITED,SELLSTOP)
     { dSLots += OrderLots();}
  }
  
  dLots = dSLots + dBLots;
  return dLots;
   
}

//+------------------------------------------------------------------+
//| compare the MT4/MT5 order type with self defined order type      |
//+------------------------------------------------------------------+ 
bool MFRiskManager::OrderTypeMatch(int iMTType,OType orderType)
{
   int iMod = (int)MathMod(iMTType,2.0);
   return(((iMod == orderType) || (orderType >iMod)));
}



void MFRiskManager::DynamicRiskControl(double dMaxDrawdown)
{

   double dAsk = MarketInfo(m_risk.strSymbol,MODE_ASK);
   double dBid = MarketInfo(m_risk.strSymbol,MODE_BID);
   double dPoint = MarketInfo(m_risk.strSymbol,MODE_POINT);
   double dLockPriceH = 0.0;
   double dLockPriceL = 0.0;
   bool bLock = false;
   if(m_HMode == HM_LONG) 
   {
      if(dAsk > m_grid.dHighP)
      bLock = true;
   } 
   if(m_HMode == HM_SHORT) 
   {
      if(dBid < m_grid.dLowP)
      bLock = true;
   }
   if(m_HMode == HM_EQUAL)
   {
      if(dBid < m_grid.dLowP || dAsk > m_grid.dHighP)
      bLock = true;
   }

   if(bLock && !m_bAcctLocked ) // lock
   {
      m_bAcctLocked = m_trade.LockAccount(m_iLockTicket);
      if(m_bAcctLocked)
      {
         SaveGlobalVar();
         Print("DynamicRiskControl ---------------------------------- locked ok, ticket id:",m_iLockTicket);
      }
   }
   
   if(m_bAcctLocked && m_iLockTicket>0) // unlock 
   {
      if(OrderSelect(m_iLockTicket,SELECT_BY_TICKET)==false) 
      {
          m_bAcctLocked = false;
          m_iLockTicket = -1;
          SaveGlobalVar();
          return ;
      }
      
      double dOPrice = OrderOpenPrice();
      int iOrderType = OrderType();
      double dDlta = 0.0;
      bool bUnlock = false;
      if(iOrderType == OP_BUY)
      { 
        dDlta = (dOPrice - dBid)/(dPoint*10);
        if(dDlta >= m_grid.dUnitSize)
        bUnlock = true;
      }
      if(iOrderType == OP_SELL)
      { 
        dDlta = (dAsk - dOPrice)/(dPoint*10);
        if(dDlta >= m_grid.dUnitSize)
        bUnlock = true;
      }  
      
      if(bUnlock)
      {
        Print("DynamicRiskControl ---------------------------------- unlocked start dDlta:",dDlta," ticket id)",m_iLockTicket);
        if(m_trade.UnLockAccount(m_iLockTicket))
        {
          Alert("DynamicRiskControl ---------------------------------- unlocked, ticket id)",m_iLockTicket);
          Print("DynamicRiskControl ---------------------------------- unlocked ok, ticket id)",m_iLockTicket);
          m_bAcctLocked = false;
          m_iLockTicket = -1;
          SaveGlobalVar();
        }
        
      }
    }
   

}


void MFRiskManager::ReadGlobalVar()
{
  m_iLockTicket = int( m_fileSaveTicket.GetSaveValue());
  if(m_iLockTicket > 0)
  m_bAcctLocked = true; 
  //Print("DynamicRiskControl ---------------------------------- read ticket: ",m_iLockTicket);
}

void MFRiskManager::SaveGlobalVar()
{
  m_fileSaveTicket.SetSaveValue(m_iLockTicket); 

}

bool MFRiskManager::IsAccountLocked()
{
  return m_bAcctLocked;
}