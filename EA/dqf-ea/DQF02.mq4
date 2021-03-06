//+------------------------------------------------------------------+
//|                                                        DQF01.mq4 |
//|                                                      dengqianfei |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "dengqianfei"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict


#include "D_M_03.mqh"



input double   g_dLots                    = 0.01;                    // 开仓手数
input int      g_iSlippage                = 3;                       // 滑点


//-------------------------------------------------------------------------------------
// Moving1
input int      g_iMovingPeriod_1          = 13;
input int      g_iMovingPeriod_2          = 56;
input int      g_iMovingShift             = 0;
input int      g_iWR_Period               = 20;
input double   g_fStopProfitFactor        = 0.1;
input double   g_fATRFactor               = 2.0;
input double   g_dPoint                   = 75;
input int      g_iWR_HighMax              = -10;
//-------------------------------------------------------------------------------------


D_M_03 D_Moving_31;
D_M_03 D_Moving_32;




double g_fLotsCH = 0.01;         // 根据资金净值，计算合理的开仓手数



int g_iMagic_31          = 20151031;
int g_iMagic_32          = 20151032;


int g_iMagic_31_01       = 20151101;
int g_iMagic_31_02       = 20151102;
int g_iMagic_31_03       = 20151103;

int g_iMagic_32_01       = 20151104;
int g_iMagic_32_02       = 20151105;
int g_iMagic_32_03       = 20151106;




// 根据资金净值，计算开仓手数
// 每500美元，增加 0.01 手
void GetLots()
{
   double fLots = 0.01;
   double fFactor = 0.5;
   int iA = 20000;
   int iB = 10000;
   
   double fAE = AccountEquity() / 2;
   
   g_fLotsCH = fLots;
   if(fAE < iA)
   {
      return;
   }
   
   int iBase = fAE / iA;
   
   if(fAE < iB)
   {
      g_fLotsCH = fLots * iBase;
   }
   else
   {
      g_fLotsCH = fLots * iBase * fFactor;
   }
   
   g_fLotsCH = NormalizeDouble(g_fLotsCH, 2);
   
   //Print("Lots: ", g_fLotsCH);
}


bool CheckMagic(int iMagic)
{
   if(iMagic != g_iMagic_31 && iMagic != g_iMagic_32 && iMagic != g_iMagic_31_01 && iMagic != g_iMagic_31_02 && iMagic != g_iMagic_31_03 && iMagic != g_iMagic_32_01 && iMagic != g_iMagic_32_02 && iMagic != g_iMagic_32_03)
   {
      return false;
   }
   
   return true;
}


void CheckOrders()
{
   GetLots();
   
   int iOrderCount = OrdersTotal();
   
   if(iOrderCount == 0)
   {
      D_Moving_31.g_ticket                   = -1;
      D_Moving_31.g_dLots                    = g_fLotsCH;
      D_Moving_31.g_OpenType                 = OT_NULL;
      D_Moving_31.g_OpenValid                = OV_NULL;
      D_Moving_31.g_bSetStopPrice            = false;
      
      D_Moving_32.g_ticket                   = -1;
      D_Moving_32.g_dLots                    = g_fLotsCH;
      D_Moving_32.g_OpenType                 = OT_NULL;
      D_Moving_32.g_OpenValid                = OV_NULL;
      D_Moving_32.g_bSetStopPrice            = false;
  

      return;
   }


   for(int i=0; i<iOrderCount; i++)
   {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) == false)
      {
         continue;
      }
      
      if(OrderSymbol() == Symbol())
      {
         int iMagic = OrderMagicNumber();
         int iTicket = OrderTicket();
         int iType = OrderType();
         double fLots = OrderLots();
         
         OpenType opentype = OT_NULL;
         if(iType == OP_BUY)
         {
            opentype = OT_BUY;
         }
         else if(iType == OP_SELL)
         {
            opentype = OT_SELL;
         }
         
         
         if(iMagic == g_iMagic_31)
         {
            D_Moving_31.g_ticket       = iTicket;
            D_Moving_31.g_dLots        = fLots;
            D_Moving_31.g_OpenType     = opentype;
            D_Moving_31.g_OpenValid    = OV_Valid;
         }
         else if(iMagic == g_iMagic_32)
         {
            D_Moving_32.g_ticket       = iTicket;
            D_Moving_32.g_dLots        = fLots;
            D_Moving_32.g_OpenType     = opentype;
            D_Moving_32.g_OpenValid    = OV_Valid;
         }
         
      }
   }
   
}


// 检查自定义开单
// 适配优先原则： 
void CheckCustomOrder()
{
   int iOrderCount = OrdersTotal();
    
   for(int i=0; i<iOrderCount; i++)
   {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) == false)
      {
         continue;
      }
      
      if(OrderSymbol() == Symbol())
      {
         int iMagic = OrderMagicNumber();
         int iTicket = OrderTicket();
         int iType = OrderType();
         double fLots = OrderLots();
         
         if(iMagic == g_iMagic_31 || iMagic == g_iMagic_32 || iMagic == g_iMagic_31_01 || iMagic == g_iMagic_31_02 || iMagic == g_iMagic_31_03 || iMagic == g_iMagic_32_01 || iMagic == g_iMagic_32_02 || iMagic == g_iMagic_32_03)
         {
            continue;
         }
         
         //------------------------------------------------------------------//
         // 适配
         
         OpenType opentype = OT_NULL;
         if(iType == OP_BUY)
         {
            opentype = OT_BUY;
         }
         else if(iType == OP_SELL)
         {
            opentype = OT_SELL;
         }
         
      }
   }
   
   
   //------------------------------------------------------------//
   // 重新根据资金净值，计算开仓手数
   GetLots();
   
   if(D_Moving_31.g_ticket == -1)
   {
      D_Moving_31.g_dLots  = g_fLotsCH;
   }
   if(D_Moving_32.g_ticket == -1)
   {
      D_Moving_32.g_dLots  = g_fLotsCH;
   }
   
   if(D_Moving_31.g_D_W_02.g_ticket == -1)
   {
      D_Moving_31.g_D_W_02.g_dLots  = g_fLotsCH;
   }
   if(D_Moving_32.g_D_W_02.g_ticket == -1)
   {
      D_Moving_32.g_D_W_02.g_dLots  = g_fLotsCH;
   }
   
   if(D_Moving_31.g_D_W_05.g_ticket_buy == -1 && D_Moving_31.g_D_W_05.g_ticket_sell == -1)
   {
      D_Moving_31.g_D_W_05.g_dLots  = g_fLotsCH;
   }
   if(D_Moving_32.g_D_W_05.g_ticket_buy == -1 && D_Moving_32.g_D_W_05.g_ticket_sell == -1)
   {
      D_Moving_32.g_D_W_05.g_dLots  = g_fLotsCH;
   }
   
   if(D_Moving_31.g_D_W_06.g_ticket == -1)
   {
      D_Moving_31.g_D_W_06.g_dLots  = g_fLotsCH;
   }
   if(D_Moving_32.g_D_W_06.g_ticket == -1)
   {
      D_Moving_32.g_D_W_06.g_dLots  = g_fLotsCH;
   }

}



void Process()
{
   CheckCustomOrder();

   D_Moving_31.MFMainProcess();
   D_Moving_32.MFMainProcess();
   
}


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(60);
   
   Print("<<<<<<<<<<<<<<<<<<<< OnInit >>>>>>>>>>>>>>>>>>>>>>>>>"); 
   
   //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>//
   D_Moving_31.g_name                  = Symbol();
   D_Moving_31.g_dLots                 = g_dLots;
   D_Moving_31.g_iSlippage             = g_iSlippage;
   D_Moving_31.g_iMagic                = g_iMagic_31;
   D_Moving_31.g_iMovingPeriod_1       = 26;
   D_Moving_31.g_iMovingPeriod_2       = 52;
   D_Moving_31.g_iMovingShift          = g_iMovingShift;
   D_Moving_31.g_fStopProfitFactor     = g_fATRFactor;
   D_Moving_31.timeframe_b             = PERIOD_W1;
   D_Moving_31.timeframe_s             = PERIOD_D1;
   D_Moving_31.timeframe_m             = PERIOD_H4;
   D_Moving_31.g_iWR_HighMax           = -50;
   D_Moving_31.g_iWR_LowMax            = -50;
   D_Moving_31.g_D_W_02.g_name         = Symbol();
   D_Moving_31.g_D_W_02.g_iMagic       = g_iMagic_31_01;
   D_Moving_31.g_D_W_02.g_dLots        = g_dLots;
   D_Moving_31.g_D_W_02.g_iSlippage    = g_iSlippage;
   D_Moving_31.g_D_W_02.timeframe      = PERIOD_H4;
   D_Moving_31.g_D_W_02.g_iWR_Period   = 15;
   D_Moving_31.g_D_W_02.g_iWR_HighMax  = -20;
   D_Moving_31.g_D_W_02.g_iWR_LowMax   = -80;
   D_Moving_31.g_D_W_02.g_iWR_HighSign = -20;
   D_Moving_31.g_D_W_02.g_iWR_LowSign  = -80;
   D_Moving_31.g_D_W_03.g_name         = Symbol();
   D_Moving_31.g_D_W_03.timeframe      = PERIOD_H4;
   D_Moving_31.g_D_W_03.g_iWR_Period   = 15;
   D_Moving_31.g_D_W_03.g_TestCount    = 2;
   D_Moving_31.g_D_W_03.g_sFileName    = "SAV_DM31_DW03.txt";
   D_Moving_31.g_D_W_03.Load();
   D_Moving_31.g_D_W_05.g_name         = Symbol();
   D_Moving_31.g_D_W_05.g_iMagic       = g_iMagic_31_02;
   D_Moving_31.g_D_W_05.g_dLots        = g_dLots;
   D_Moving_31.g_D_W_05.g_iSlippage    = g_iSlippage;
   D_Moving_31.g_D_W_05.g_dPoint       = 115;
   D_Moving_31.g_D_W_05.g_ProfitLevel  = 4;
   D_Moving_31.g_D_W_05.g_FirstLevel   = 1;
   D_Moving_31.g_D_W_05.g_sFileName    = "SAV_DM31_DW05.txt";
   D_Moving_31.g_D_W_05.Load();
   D_Moving_31.g_D_W_05.ClearCorrect();
   D_Moving_31.g_D_W_06.g_name         = Symbol();
   D_Moving_31.g_D_W_06.g_iMagic       = g_iMagic_31_03;
   D_Moving_31.g_D_W_06.g_dLots        = g_dLots;
   D_Moving_31.g_D_W_06.g_iSlippage    = g_iSlippage;
   D_Moving_31.g_D_W_06.timeframe      = PERIOD_D1;
   D_Moving_31.g_D_W_06.g_iWR_Period   = 25;
   D_Moving_31.g_D_W_06.g_iWR_HighMax  = -12;
   D_Moving_31.g_D_W_06.g_iWR_LowMax   = -88;
   D_Moving_31.g_D_W_06.g_OpenBuyTime  = iTime(D_Moving_31.g_D_W_06.g_name,D_Moving_31.g_D_W_06.timeframe,1);
   D_Moving_31.g_D_W_06.g_OpenSellTime = iTime(D_Moving_31.g_D_W_06.g_name,D_Moving_31.g_D_W_06.timeframe,1);
   D_Moving_31.g_D_W_06.g_sFileName    = "SAV_DM31_DW06.txt";
   D_Moving_31.g_D_W_06.Load();
   
   D_Moving_32.g_name                  = Symbol();
   D_Moving_32.g_dLots                 = g_dLots;
   D_Moving_32.g_iSlippage             = g_iSlippage;
   D_Moving_32.g_iMagic                = g_iMagic_32;
   D_Moving_32.g_iMovingPeriod_1       = 19;
   D_Moving_32.g_iMovingPeriod_2       = 80;
   D_Moving_32.g_iMovingShift          = g_iMovingShift;
   D_Moving_32.g_fStopProfitFactor     = g_fATRFactor;
   D_Moving_32.timeframe_b             = PERIOD_D1;
   D_Moving_32.timeframe_s             = PERIOD_H4;
   D_Moving_32.timeframe_m             = PERIOD_H1;
   D_Moving_32.g_iWR_HighMax           = -40;
   D_Moving_32.g_iWR_LowMax            = -60;
   D_Moving_32.g_D_W_02.g_name         = Symbol();
   D_Moving_32.g_D_W_02.g_iMagic       = g_iMagic_32_01;
   D_Moving_32.g_D_W_02.g_dLots        = g_dLots;
   D_Moving_32.g_D_W_02.g_iSlippage    = g_iSlippage;
   D_Moving_32.g_D_W_02.timeframe      = PERIOD_H1;
   D_Moving_32.g_D_W_02.g_iWR_Period   = 17;
   D_Moving_32.g_D_W_02.g_iWR_HighMax  = -20;
   D_Moving_32.g_D_W_02.g_iWR_LowMax   = -80;
   D_Moving_32.g_D_W_02.g_iWR_HighSign = -20;
   D_Moving_32.g_D_W_02.g_iWR_LowSign  = -80;
   D_Moving_32.g_D_W_03.g_name         = Symbol();
   D_Moving_32.g_D_W_03.timeframe      = PERIOD_H1;
   D_Moving_32.g_D_W_03.g_iWR_Period   = 17;
   D_Moving_32.g_D_W_03.g_TestCount    = 4;
   D_Moving_32.g_D_W_03.g_sFileName    = "SAV_DM32_DW03.txt";
   D_Moving_32.g_D_W_03.Load();
   D_Moving_32.g_D_W_05.g_name         = Symbol();
   D_Moving_32.g_D_W_05.g_iMagic       = g_iMagic_32_02;
   D_Moving_32.g_D_W_05.g_dLots        = g_dLots;
   D_Moving_32.g_D_W_05.g_iSlippage    = g_iSlippage;
   D_Moving_32.g_D_W_05.g_dPoint       = 110;
   D_Moving_32.g_D_W_05.g_ProfitLevel  = 4;
   D_Moving_32.g_D_W_05.g_FirstLevel   = 1;
   D_Moving_32.g_D_W_05.g_sFileName    = "SAV_DM32_DW05.txt";
   D_Moving_32.g_D_W_05.Load();
   D_Moving_32.g_D_W_05.ClearCorrect();
   D_Moving_32.g_D_W_06.g_name         = Symbol();
   D_Moving_32.g_D_W_06.g_iMagic       = g_iMagic_32_03;
   D_Moving_32.g_D_W_06.g_dLots        = g_dLots;
   D_Moving_32.g_D_W_06.g_iSlippage    = g_iSlippage;
   D_Moving_32.g_D_W_06.timeframe      = PERIOD_H4;
   D_Moving_32.g_D_W_06.g_iWR_Period   = 32;
   D_Moving_32.g_D_W_06.g_iWR_HighMax  = -7;
   D_Moving_32.g_D_W_06.g_iWR_LowMax   = -93;
   D_Moving_32.g_D_W_06.g_OpenBuyTime  = iTime(D_Moving_32.g_D_W_06.g_name,D_Moving_32.g_D_W_06.timeframe,1);
   D_Moving_32.g_D_W_06.g_OpenSellTime = iTime(D_Moving_32.g_D_W_06.g_name,D_Moving_32.g_D_W_06.timeframe,1);
   D_Moving_32.g_D_W_06.g_sFileName    = "SAV_DM32_DW06.txt";
   D_Moving_32.g_D_W_06.Load();
   //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>//


 
   CheckOrders();
   
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   Print("<<<<<<<<<<<<<<<<<<<< OnDeinit >>>>>>>>>>>>>>>>>>>>>>>>>"); 
   
//--- destroy timer
   EventKillTimer();
      
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
  
   Process();
   
//---
   
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Tester function                                                  |
//+------------------------------------------------------------------+
double OnTester()
  {
//---
   double ret=0.0;
//---

//---
   return(ret);
  }
//+------------------------------------------------------------------+
