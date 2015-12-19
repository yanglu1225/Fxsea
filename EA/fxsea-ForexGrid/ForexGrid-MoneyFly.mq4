//+------------------------------------------------------------------+
//|                                           ForexGrid-MoneyFly.mq4 |
//|                                                     hu jianglong |
//|                                                      qq:47217817 |
//+------------------------------------------------------------------+
#property copyright "hu jianglong"
#property link      "qq:47217817"
#property version   "2.01"
#property strict

#include "MFTrade.mqh"
#include "MFLog.mqh"
#include "MFSave.mqh"
#include "MFRiskManager.mqh"
#include "MFSendMail.mqh"

input double   g_risk = 1.0;               // risk (0.0,1.0]  risk(r) = margin(m) / equity(e)
input double   g_dRiskPointRng = 1400 ;    // max loss point range, not total total. recommand: >= (high-low)/(size*Point*10)
input string   g_strSymbol = "GBPJPYpro";     // symbol
input double   g_dGridLow = 180.0;       // grid low price
input double   g_dGridHigh = 194.0;      // grid high price
input double   g_dGridSize = 50;           // grid size unit
input double   g_dSellLots = 0.01;          // long lots
input double   g_dBuyLots = 0.02;           // short lots
//input double   g_dStopLossPoint = 0.0;   
input double   g_dTakeProfit = 60.0;       // take profit
input int      g_iMagic = 114022;          // magic num
input double   g_dTakeProfitStop = 70;     // profit stop

MFTrade g_trade;
MFRiskManager g_rsk;
HedgeMode g_hm;
GRIDDATA g_gd;
MFSave g_saveFile;
MFLog  g_logFile("log.txt",FT_LOG);
MFLog  g_profitFile("profit.txt",FT_PROFIT);
MFSendMail g_sendMail;
bool   g_GridInitOK = false;
double g_dOrderMaxProfitPoint = 0.0;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
 // 
 
   g_trade.SetSymbol(g_strSymbol);
   g_trade.SetMagicNum(g_iMagic);
   
   
   g_gd.dLowP = g_dGridLow;     
   g_gd.dHighP = g_dGridHigh;    
   g_gd.dUnitSize = g_dGridSize; 
   g_gd.dBuyLots = g_dBuyLots;  
   g_gd.dSellLots = g_dSellLots; 
   g_gd.dTP = g_dTakeProfit;       
   g_gd.dSL = 0.0;       
   g_gd.dTP2 = g_dTakeProfitStop;      
   g_gd.iMagicNum = g_iMagic; 
   
   if(g_gd.dBuyLots > g_gd.dSellLots) g_hm = HM_SHORT;
   if(g_gd.dBuyLots < g_gd.dSellLots) g_hm = HM_LONG;
   if(g_gd.dBuyLots == g_gd.dSellLots) g_hm = HM_EQUAL;
   
   
   RISK rsk;
   rsk.dMaxPointRng = g_dRiskPointRng;
   rsk.dRisk = g_risk;
   rsk.iMagicNum = g_iMagic;
   rsk.strSymbol = g_strSymbol;
   
   g_rsk.SetGridData(g_gd,g_hm);
   g_rsk.SetRisk(rsk);
   
   //g_rsk.DynamicRiskControl(0.3);
   
   g_GridInitOK =  g_rsk.GridRiskCheckInit();
   if(g_GridInitOK)
   {
     g_GridInitOK = true;
     MFMakeAndUpdateGrid();
   }

   
   g_dOrderMaxProfitPoint = g_saveFile.GetSaveValue();
 
   if(!MFCheckInputParameter())
   return (INIT_PARAMETERS_INCORRECT);
  
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   if(g_GridInitOK)
   {
     MFRefresh(); 
   }
  }
//+------------------------------------------------------------------+


void MFMakeAndUpdateGrid()
{
   // 1. Set the pair and get the price
   double dPoint =MarketInfo(g_strSymbol,MODE_POINT);
   int iSlip=MarketInfo(g_strSymbol,MODE_SPREAD);
   double dSlipPrice = MarketInfo(g_strSymbol,MODE_SPREAD) * dPoint;  
   double dStartPrice, dEndPrice;
   dStartPrice = MathMin(g_gd.dHighP,g_gd.dLowP);
   dEndPrice = MathMax(g_gd.dHighP,g_gd.dLowP);
   double dDetaPrice = g_dGridSize * dPoint * 10;

   // 2. sell and buy
   double dPrice = dStartPrice; 
   double dBuyLots = g_gd.dBuyLots;
   double dSellLots = g_gd.dSellLots;
   double dLots = MathMin(dBuyLots,dSellLots);
   
   //int ii = 1;
   while(dPrice < dEndPrice)
   {  
     // Print("nums:",ii," price:",dPrice);
      
      if(!g_rsk.GridLotsAviable(dLots)) 
      {
        Alert("there are not enough money to open order! please deposit ");
        break;
      }
  
       switch(g_hm)
       {
         case HM_EQUAL:
         {
           if(!g_trade.IsOrderExist(dPrice,10,dBuyLots,0))
           {
             int iTicket = g_trade.SendOrd(0,dBuyLots,dPrice,0.0,0.0);
             if(iTicket>0)
             g_logFile.SaveTicketInfo2File(iTicket,TMM_TRADES,"#open order");
           }

           double dP = dPrice - dSlipPrice;
           if(!g_trade.IsOrderExist(dP,10,dSellLots,1))
           {
             int iTicket = g_trade.SendOrd(1,dSellLots,dP,0.0,0.0);
             if(iTicket>0)
             g_logFile.SaveTicketInfo2File(iTicket,TMM_TRADES,"#open order");
           }
           break;
         }
         
         case HM_LONG:
         {
           bool bSel = false;
           if(!g_trade.IsOrderExist(dPrice,10,dSellLots,1))
           {
             if(dSellLots > 0.0)
             {
                int iTicket = g_trade.SendOrd(1,dSellLots,dPrice,0.0,0.0);
                if(iTicket>0)
                {  
                  bSel = true;
                  g_logFile.SaveTicketInfo2File(iTicket,TMM_TRADES,"#open order");
                }
             }
           }
           if(bSel)
           {
              double dP = dPrice + dSlipPrice;
              if(!g_trade.IsOrderExist(dPrice,10,dBuyLots,0))
              { 
                if(dBuyLots > 0.0)
                {
                   int iTicket = g_trade.SendOrd(0,dBuyLots,dP,0.0,0.0);   
                   if(iTicket>0)
                     g_logFile.SaveTicketInfo2File(iTicket,TMM_TRADES,"#open order");
                }  
              }
           }  
           break;
         }
       
         case HM_SHORT:
         {
           bool bBuy = false;
           if(!g_trade.IsOrderExist(dPrice,10,dBuyLots,0))
           {
             if(dBuyLots > 0.0)
             {           
                int iTicket =  g_trade.SendOrd(0,dBuyLots,dPrice,0.0,0.0);
                if(iTicket>0)
                {  
                  bBuy = true;
                  g_logFile.SaveTicketInfo2File(iTicket,TMM_TRADES,"#open order");
                }
             }
             
           }
          
           if(bBuy)
           {
             double dP = dPrice - dSlipPrice;
             if(!g_trade.IsOrderExist(dP,10,dSellLots,1))
             {
               if(dSellLots > 0.0)
               {
                int iTicket =g_trade.SendOrd(1,dSellLots,dP,0.0,0.0); 
                if(iTicket>0)
                g_logFile.SaveTicketInfo2File(iTicket,TMM_TRADES,"#open order");     
               }    
             }  
           }  
           break;
         }
       }
   
      dPrice = NormalizeDouble(dPrice + dDetaPrice,_Digits);
    
   }

}


void MFRefresh()
{
 
  //g_rsk.DynamicRiskControl(g_dDrawdwnLockRatio);
  //if(g_rsk.IsAccountLocked()) return;
  
  switch(g_hm)
   {
     case HM_EQUAL:
      {
           MFCheckOrderEqualMode();
           break;
      }
         
     case HM_LONG:
      {
          MFCheckOrderLongMode();
          break;
      }
       
     case HM_SHORT:
      {   
           MFCheckOrderShortMode();
           break;
      }
       
   }
}

// sell trend  long trend
void MFCheckOrderLongMode()
{
    MFCheckProfitStop(0);
    MFCheckProfitTake(1);
}


// buy trend  short trend
void MFCheckOrderShortMode()
{
    MFCheckProfitStop(1);
    MFCheckProfitTake(0);
}


// standard hedage
void MFCheckOrderEqualMode()
{
    MFCheckProfitTake(2);
}

//+------------------------------------------------------------------+
//| close all oreder  iType: 0 -- buy  1 -- sell          |
//+------------------------------------------------------------------+
void MFCloseAllOpenOrder(int iType)
{
    if(iType > 1 || iType < 0) return;
    for(int pos=OrdersTotal();pos>=0;pos--)
    {
        if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
        if(OrderSymbol()!= g_strSymbol || OrderMagicNumber()!= g_iMagic) continue;
        int iOrderType = OrderType();
       
        if(iOrderType == iType)
        {
          int iTicket = OrderTicket();
          bool bClose = g_trade.CloseOrderByTicket(iTicket);
          
          if(bClose)
          g_profitFile.SaveTicketInfo2File(iTicket,TMM_HISTORY,"profit loss order");
        }     
    }

}


//+------------------------------------------------------------------+
//| check the profit stop order  iType: 0 -- buy  1 -- sell   2 -- buy and sell       |
//+------------------------------------------------------------------+
void MFCheckProfitStop(int iType)
{
    if(iType > 1 || iType < 0) return;
    double dPoint =MarketInfo(g_strSymbol,MODE_POINT);
    double dMaxProfitPoint = 0.0;
    //int iTotalNums = OrdersTotal();
   
    for(int pos=OrdersTotal();pos>=0;pos--)
    {
        if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
        if(OrderSymbol()!= g_strSymbol || OrderMagicNumber()!= g_iMagic) continue;
        int iOrderType = OrderType();
        if(iOrderType == iType)
        { 
          double dProfit = OrderProfit();
          double dLots = OrderLots();
          double dProfitPoint = dProfit/dLots * 0.1;
          if(dMaxProfitPoint < dProfitPoint) dMaxProfitPoint = dProfitPoint;
        }   
    }
    
    if(dMaxProfitPoint > 0 && dMaxProfitPoint < g_dOrderMaxProfitPoint)
    {
      double dDeltaProfitPoint = g_dOrderMaxProfitPoint - dMaxProfitPoint;
      // sell all the buy order
      if(dDeltaProfitPoint > g_dTakeProfitStop)
      {
        //MFCloseAllBuyOrder();     
        //Print("close buy order-----------");
        MFCloseAllOpenOrder(iType);
        //MFMakeAndUpdateGrid();
        dMaxProfitPoint = 0.0;
        g_dOrderMaxProfitPoint = 0.0;
        g_saveFile.SetSaveValue(g_dOrderMaxProfitPoint);
        g_sendMail.SendMailToMeMsg(g_profitFile.GetFileContents());
        g_sendMail.SendMailToFxseaServer(g_profitFile.GetFileContents());
      }
      
    }
    
    if(g_dOrderMaxProfitPoint  < dMaxProfitPoint) 
    {
      g_dOrderMaxProfitPoint = dMaxProfitPoint;
      g_saveFile.SetSaveValue(g_dOrderMaxProfitPoint);
    }

}


//+------------------------------------------------------------------+
//| check the profit take order  iType: 0 -- buy  1 -- sell          |
//+------------------------------------------------------------------+
void MFCheckProfitTake(int iType)
{
    if(iType > 2 || iType < 0) return;
    
    //int iTotalNums = OrdersTotal();
    for(int pos=OrdersTotal();pos>=0;pos--)
    {
       if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
       if(OrderSymbol()!= g_strSymbol || OrderMagicNumber()!= g_iMagic) continue;
       int iOrderType = OrderType();
       if((iOrderType == iType) && (iOrderType <=1))
       {
          double dProfit = OrderProfit();
          double dLots = OrderLots();
          double dProfitPoint = dProfit/dLots * 0.1;
          if(dProfitPoint >= g_dTakeProfit)
          {
            int iTicket = OrderTicket();
            bool bClose = g_trade.CloseOrderByTicket(iTicket);
            if(bClose)
            { 
              int iTicket2 = -1;
              if(iType == 0)
                 iTicket2 = g_trade.CloseOpenOrderByPrice(OrderOpenPrice(),1);    
               if(iType == 1)
                 iTicket2 = g_trade.CloseOpenOrderByPrice(OrderOpenPrice(),0); 
              if(iTicket2 >0)
              g_profitFile.SaveTicketInfo2File(iTicket2,TMM_HISTORY,"profit take order");            
              g_profitFile.SaveTicketInfo2File(iTicket,TMM_HISTORY,"profit take order");
              MFMakeAndUpdateGrid();
              g_sendMail.SendMailToMeMsg(g_profitFile.GetFileContents());
              g_sendMail.SendMailToFxseaServer(g_profitFile.GetFileContents());
            }
          } 
       }
       
       
       if((iType == 2) && (iOrderType <=1))
       {
          double dProfit = OrderProfit();
          double dLots = OrderLots();
          double dProfitPoint = dProfit/dLots * 0.1;
          if(dProfitPoint >= g_dTakeProfit)
          {
            int iTicket = OrderTicket();
            bool bClose = g_trade.CloseOrderByTicket(iTicket);
            if(bClose)
            {             
              g_profitFile.SaveTicketInfo2File(iTicket,TMM_HISTORY,"profit take order");
              MFMakeAndUpdateGrid();
              g_sendMail.SendMailToMeMsg(g_profitFile.GetFileContents());
              g_sendMail.SendMailToFxseaServer(g_profitFile.GetFileContents());
            }
          } 
       
       }
       
           
    }
}


bool MFCheckInputParameter()
{
   bool bRet = true;
   double dMinLots = MarketInfo(g_strSymbol,MODE_MINLOT);
   double dLots = MathMin(g_dBuyLots,g_dSellLots);
   
   if(dLots < dMinLots && dLots !=0.0)
   {
      Alert("invalid trade volume,please change the sell or buy lots, the min lots is " ,dMinLots);
      bRet = false;  
   }
   
   return bRet;
}



