//+------------------------------------------------------------------+
//|                                                        DQF01.mq4 |
//|                                                      dengqianfei |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "dengqianfei"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict


#include "D_M_01.mqh"
#include "D_M_02.mqh"



input double   g_dLots                    = 0.01;                    // 开仓手数
input int      g_iSlippage                = 3;                       // 滑点


//-------------------------------------------------------------------------------------
// Moving1
input int      g_iMovingPeriod_1          = 13;
input int      g_iMovingPeriod_2          = 56;
input int      g_iMovingShift             = 0;
input int      g_iWR_Period               = 13;
input double   g_fStopProfitFactor        = 0.1;
input double   g_fATRFactor               = 2.0;
//-------------------------------------------------------------------------------------

//-------------------------------------------------------------------------------------
// Moving2
input int      g_iMA_Period1              = 35;
input int      g_iMA_Period2              = 350;
//-------------------------------------------------------------------------------------



D_M_01 D_Moving_11;
D_M_01 D_Moving_12;
//D_M_01 D_Moving_13;

D_M_02 D_Moving_21;
D_M_02 D_Moving_22;




double g_fLotsCH = 0.01;         // 根据资金净值，计算合理的开仓手数


int g_iMagic_11          = 20150011;
int g_iMagic_12          = 20150012;
int g_iMagic_13          = 20150013;

int g_iMagic_21          = 20150021;
int g_iMagic_22          = 20150022;

int g_iMagic_31          = 20150031;
int g_iMagic_32          = 20150032;
int g_iMagic_33          = 20150033;

int g_iMagic_41          = 20150041;
int g_iMagic_42          = 20150042;
int g_iMagic_43          = 20150043;

int g_iMagic_11_01       = 20150101;
int g_iMagic_11_02       = 20150102;
int g_iMagic_11_03       = 20150103;
int g_iMagic_12_01       = 20150104;
int g_iMagic_12_02       = 20150105;
int g_iMagic_12_03       = 20150106;
int g_iMagic_21_01       = 20150111;
int g_iMagic_21_02       = 20150112;




// 根据资金净值，计算开仓手数
// 每500美元，增加 0.01 手
void GetLots()
{
   double fLots = 0.01;
   double fFactor = 0.6;
   int iA = 10000;
   int iB = 10000;
   
   double fAE = AccountEquity();
   
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
   
   //for(int i=0; i<iBase; ++i)
   //{
      //g_fLotsCH = g_fLotsCH * fFactor;
   //}
   
   g_fLotsCH = NormalizeDouble(g_fLotsCH, 2);
   
   //Print("Lots: ", g_fLotsCH);
}


bool CheckMagic(int iMagic)
{
   if(iMagic != g_iMagic_11 && iMagic != g_iMagic_12 && iMagic != g_iMagic_21 && iMagic != g_iMagic_22 && iMagic != g_iMagic_11_01 && iMagic != g_iMagic_11_02 && iMagic != g_iMagic_11_03 && iMagic != g_iMagic_12_01 && iMagic != g_iMagic_12_02 && iMagic != g_iMagic_12_03 && iMagic != g_iMagic_21_01 && iMagic != g_iMagic_21_02)
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
      D_Moving_11.g_ticket          = -1;
      D_Moving_11.g_dLots           = g_fLotsCH;
      D_Moving_11.g_OpenType        = OT_NULL;
      D_Moving_11.g_OpenValid       = OV_NULL;
      D_Moving_11.g_bSetStopPrice   = false;
      
      D_Moving_12.g_ticket          = -1;
      D_Moving_12.g_dLots           = g_fLotsCH;
      D_Moving_12.g_OpenType        = OT_NULL;
      D_Moving_12.g_OpenValid       = OV_NULL;
      D_Moving_12.g_bSetStopPrice   = false;
      
      
      D_Moving_11.g_D_W_01.g_ticket          = -1;
      D_Moving_11.g_D_W_01.g_dLots           = g_fLotsCH;
      D_Moving_11.g_D_W_01.g_OpenType        = OT_NULL;
      D_Moving_11.g_D_W_01.g_OpenValid       = OV_NULL;
      D_Moving_11.g_D_W_01.g_PriceArea       = PA_NULL;
      
      D_Moving_11.g_D_W_04.g_ticket          = -1;
      D_Moving_11.g_D_W_04.g_dLots           = g_fLotsCH;
      D_Moving_11.g_D_W_04.g_OpenType        = OT_NULL;
      D_Moving_11.g_D_W_04.g_OpenValid       = OV_NULL;
      
      D_Moving_11.g_D_W_05.g_ticket_buy      = -1;
      D_Moving_11.g_D_W_05.g_ticket_sell     = -1;
      D_Moving_11.g_D_W_05.g_dLots           = g_fLotsCH;
      D_Moving_11.g_D_W_05.g_OpenValid       = OV_NULL;
      D_Moving_11.g_D_W_05.g_iCorrect        = 0;
      
      D_Moving_12.g_D_W_01.g_ticket          = -1;
      D_Moving_12.g_D_W_01.g_dLots           = g_fLotsCH;
      D_Moving_12.g_D_W_01.g_OpenType        = OT_NULL;
      D_Moving_12.g_D_W_01.g_OpenValid       = OV_NULL;
      D_Moving_12.g_D_W_01.g_PriceArea       = PA_NULL;
      
      D_Moving_12.g_D_W_04.g_ticket          = -1;
      D_Moving_12.g_D_W_04.g_dLots           = g_fLotsCH;
      D_Moving_12.g_D_W_04.g_OpenType        = OT_NULL;
      D_Moving_12.g_D_W_04.g_OpenValid       = OV_NULL;
      
      D_Moving_12.g_D_W_05.g_ticket_buy      = -1;
      D_Moving_12.g_D_W_05.g_ticket_sell     = -1;
      D_Moving_12.g_D_W_05.g_dLots           = g_fLotsCH;
      D_Moving_12.g_D_W_05.g_OpenValid       = OV_NULL;
      D_Moving_12.g_D_W_05.g_iCorrect        = 0;
    
     
      D_Moving_21.g_ticket                   = -1;
      D_Moving_21.g_dLots                    = g_fLotsCH;
      D_Moving_21.g_OpenType                 = OT_NULL;
      D_Moving_21.g_OpenValid                = OV_NULL;
      D_Moving_21.g_bSetStopPrice            = false;
      
      D_Moving_22.g_ticket                   = -1;
      D_Moving_22.g_dLots                    = g_fLotsCH;
      D_Moving_22.g_OpenType                 = OT_NULL;
      D_Moving_22.g_OpenValid                = OV_NULL;
      D_Moving_22.g_bSetStopPrice            = false;
  

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
         
         if(iMagic == g_iMagic_11)
         {
            D_Moving_11.g_ticket       = iTicket;
            D_Moving_11.g_dLots        = fLots;
            D_Moving_11.g_OpenType     = opentype;
            D_Moving_11.g_OpenValid    = OV_Valid;
            D_Moving_11.g_fStopProfit  = OrderOpenPrice();
            D_Moving_11.GetMaxProfit();
         }
         else if(iMagic == g_iMagic_12)
         {
            D_Moving_12.g_ticket       = iTicket;
            D_Moving_12.g_dLots        = fLots;
            D_Moving_12.g_OpenType     = opentype;
            D_Moving_12.g_OpenValid    = OV_Valid;
            D_Moving_12.g_fStopProfit  = OrderOpenPrice();
            D_Moving_12.GetMaxProfit();
         }
         else if(iMagic == g_iMagic_11_01)
         {
            D_Moving_11.g_D_W_01.g_ticket       = iTicket;
            D_Moving_11.g_D_W_01.g_dLots        = fLots;
            D_Moving_11.g_D_W_01.g_OpenType     = opentype;
            D_Moving_11.g_D_W_01.g_OpenValid    = OV_Valid;
         }
         else if(iMagic == g_iMagic_11_02)
         {
            D_Moving_11.g_D_W_04.g_ticket       = iTicket;
            D_Moving_11.g_D_W_04.g_dLots        = fLots;
            D_Moving_11.g_D_W_04.g_OpenType     = opentype;
            D_Moving_11.g_D_W_04.g_OpenValid    = OV_Valid;
         }
         else if(iMagic == g_iMagic_12_01)
         {
            D_Moving_12.g_D_W_01.g_ticket       = iTicket;
            D_Moving_12.g_D_W_01.g_dLots        = fLots;
            D_Moving_12.g_D_W_01.g_OpenType     = opentype;
            D_Moving_12.g_D_W_01.g_OpenValid    = OV_Valid;
         }
         else if(iMagic == g_iMagic_12_02)
         {
            D_Moving_12.g_D_W_04.g_ticket       = iTicket;
            D_Moving_12.g_D_W_04.g_dLots        = fLots;
            D_Moving_12.g_D_W_04.g_OpenType     = opentype;
            D_Moving_12.g_D_W_04.g_OpenValid    = OV_Valid;
         }
         else if(iMagic == g_iMagic_21)
         {
            D_Moving_21.g_ticket       = iTicket;
            D_Moving_21.g_dLots        = fLots;
            D_Moving_21.g_OpenType     = opentype;
            D_Moving_21.g_OpenValid    = OV_Valid;
         }
         else if(iMagic == g_iMagic_22)
         {
            D_Moving_22.g_ticket       = iTicket;
            D_Moving_22.g_dLots        = fLots;
            D_Moving_22.g_OpenType     = opentype;
            D_Moving_22.g_OpenValid    = OV_Valid;
         }
         
         
         if(iMagic == g_iMagic_11_03)
         {
            if(iType == OP_BUY)
            {
               D_Moving_11.g_D_W_05.g_ticket_buy   = iTicket;
               D_Moving_11.g_D_W_05.g_dLots_buy    = fLots;
               D_Moving_11.g_D_W_05.g_OpenValid    = OV_Valid;
               D_Moving_11.g_D_W_05.SetStopProfit(OrderOpenPrice(), opentype);
            }
            if(iType == OP_SELL)
            {
               D_Moving_11.g_D_W_05.g_ticket_sell  = iTicket;
               D_Moving_11.g_D_W_05.g_dLots_sell   = fLots;
               D_Moving_11.g_D_W_05.g_OpenValid    = OV_Valid;
               D_Moving_11.g_D_W_05.SetStopProfit(OrderOpenPrice(), opentype);
            }
         }
         
         if(iMagic == g_iMagic_12_03)
         {
            if(iType == OP_BUY)
            {
               D_Moving_12.g_D_W_05.g_ticket_buy   = iTicket;
               D_Moving_12.g_D_W_05.g_dLots_buy    = fLots;
               D_Moving_12.g_D_W_05.g_OpenValid    = OV_Valid;
               D_Moving_12.g_D_W_05.SetStopProfit(OrderOpenPrice(), opentype);
            }
            if(iType == OP_SELL)
            {
               D_Moving_12.g_D_W_05.g_ticket_sell  = iTicket;
               D_Moving_12.g_D_W_05.g_dLots_sell   = fLots;
               D_Moving_12.g_D_W_05.g_OpenValid    = OV_Valid;
               D_Moving_12.g_D_W_05.SetStopProfit(OrderOpenPrice(), opentype);
            }
         }
      }
   }
   
}


// 检查自定义开单
// 适配优先原则： D_M_12 > D_M_11
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
         
         if(iMagic == g_iMagic_11 || iMagic == g_iMagic_12 || iMagic == g_iMagic_21 || iMagic == g_iMagic_22 || iMagic == g_iMagic_11_01 || iMagic == g_iMagic_11_02 || iMagic == g_iMagic_11_03 || iMagic == g_iMagic_12_01 || iMagic == g_iMagic_12_02 || iMagic == g_iMagic_12_03 || iMagic == g_iMagic_21_01 || iMagic == g_iMagic_21_02)
         {
            continue;
         }
         //if(iTicket == D_Moving_11.g_ticket || iTicket == D_Moving_12.g_ticket || iTicket == D_Moving_21.g_ticket || iTicket == D_Moving_22.g_ticket || iTicket == D_Moving_31.g_ticket || iTicket == D_Moving_32.g_ticket || iTicket == D_Moving_33.g_ticket || iTicket == D_Moving_41.g_ticket || iTicket == D_Moving_42.g_ticket || iTicket == D_Moving_43.g_ticket)
         {
            //continue;
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
         
         if(D_Moving_12.g_OpenType == OT_NULL)
         {
            D_Moving_12.g_ticket       = iTicket;
            D_Moving_12.g_dLots        = fLots;
            D_Moving_12.g_OpenType     = opentype;
            D_Moving_12.g_OpenValid    = OV_Valid;
         }
         else if(D_Moving_11.g_OpenType == OT_NULL)
         {
            D_Moving_11.g_ticket       = iTicket;
            D_Moving_11.g_dLots        = fLots;
            D_Moving_11.g_OpenType     = opentype;
            D_Moving_11.g_OpenValid    = OV_Valid;
         }
         
      }
   }
   
   
   //------------------------------------------------------------//
   // 重新根据资金净值，计算开仓手数
   GetLots();
   
   if(D_Moving_11.g_ticket == -1)
   {
      D_Moving_11.g_dLots  = g_fLotsCH;
   }
   if(D_Moving_12.g_ticket == -1)
   {
      D_Moving_12.g_dLots  = g_fLotsCH;
   }


   if(D_Moving_11.g_D_W_01.g_ticket == -1)
   {
      D_Moving_11.g_D_W_01.g_dLots  = g_fLotsCH;
   }
   if(D_Moving_11.g_D_W_04.g_ticket == -1)
   {
      D_Moving_11.g_D_W_04.g_dLots  = g_fLotsCH;
   }
   if(D_Moving_11.g_D_W_05.g_ticket_buy == -1 && D_Moving_11.g_D_W_05.g_ticket_sell == -1)
   {
      D_Moving_11.g_D_W_05.g_dLots  = g_fLotsCH;
   }
   if(D_Moving_12.g_D_W_01.g_ticket == -1)
   {
      D_Moving_12.g_D_W_01.g_dLots  = g_fLotsCH;
   }
   if(D_Moving_12.g_D_W_04.g_ticket == -1)
   {
      D_Moving_12.g_D_W_04.g_dLots  = g_fLotsCH;
   }
   if(D_Moving_12.g_D_W_05.g_ticket_buy == -1 && D_Moving_12.g_D_W_05.g_ticket_sell == -1)
   {
      D_Moving_12.g_D_W_05.g_dLots  = g_fLotsCH;
   }
   
   
   if(D_Moving_21.g_ticket == -1)
   {
      D_Moving_21.g_dLots  = g_fLotsCH;
   }
   if(D_Moving_22.g_ticket == -1)
   {
      D_Moving_22.g_dLots  = g_fLotsCH;
   }
   
   if(D_Moving_21.g_D_W_02.g_ticket == -1)
   {
      D_Moving_21.g_D_W_02.g_dLots  = g_fLotsCH;
   }
   if(D_Moving_22.g_D_W_02.g_ticket == -1)
   {
      D_Moving_22.g_D_W_02.g_dLots  = g_fLotsCH;
   }
   

}



void Process()
{
   CheckCustomOrder();
   
   D_Moving_11.MFMainProcess();
   D_Moving_12.MFMainProcess();
   
   
   D_Moving_21.MFMainProcess();
   D_Moving_22.MFMainProcess();
   
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
   D_Moving_11.g_name                  = Symbol();
   D_Moving_11.g_dLots                 = g_dLots;
   D_Moving_11.g_iSlippage             = g_iSlippage;
   D_Moving_11.g_iMagic                = g_iMagic_11;
   D_Moving_11.g_iMovingPeriod_1       = 13;
   D_Moving_11.g_iMovingPeriod_2       = 56;
   D_Moving_11.g_iMovingShift          = g_iMovingShift;
   D_Moving_11.g_fStopProfitFactor     = g_fStopProfitFactor;
   D_Moving_11.timeframe_b             = PERIOD_W1;
   D_Moving_11.timeframe_s             = PERIOD_H4;
   D_Moving_11.timeframe_m             = PERIOD_M30;
   D_Moving_11.g_D_W_01.g_name         = Symbol();
   D_Moving_11.g_D_W_01.g_iMagic       = g_iMagic_11_01;
   D_Moving_11.g_D_W_01.g_dLots        = g_dLots;
   D_Moving_11.g_D_W_01.g_iSlippage    = g_iSlippage;
   D_Moving_11.g_D_W_01.timeframe      = PERIOD_H4;
   D_Moving_11.g_D_W_01.g_iWR_Period   = 13;
   D_Moving_11.g_D_W_01.g_iWR_HighMax  = -6;
   D_Moving_11.g_D_W_01.g_iWR_LowMax   = -94;
   D_Moving_11.g_D_W_01.g_iWR_HighSign = -20;
   D_Moving_11.g_D_W_01.g_iWR_LowSign  = -80;
   D_Moving_11.g_D_W_01.g_fLowPrice    = iLow(D_Moving_11.g_D_W_01.g_name,D_Moving_11.g_D_W_01.timeframe,0);
   D_Moving_11.g_D_W_01.g_fHighPrice   = iHigh(D_Moving_11.g_D_W_01.g_name,D_Moving_11.g_D_W_01.timeframe,0);
   D_Moving_11.g_D_W_04.g_bPermission  = false;
   //D_Moving_11.g_D_W_04.g_name         = Symbol();
   //D_Moving_11.g_D_W_04.g_iMagic       = g_iMagic_11_02;
   //D_Moving_11.g_D_W_04.g_dLots        = g_dLots;
   //D_Moving_11.g_D_W_04.g_iSlippage    = g_iSlippage;
   //D_Moving_11.g_D_W_04.g_iMovingShift = g_iMovingShift;
   //D_Moving_11.g_D_W_04.g_iMA_Period   = g_iMovingPeriod_1;
   //D_Moving_11.g_D_W_04.timeframe      = PERIOD_H4;
   D_Moving_11.g_D_W_05.g_name         = Symbol();
   D_Moving_11.g_D_W_05.g_iMagic       = g_iMagic_11_03;
   D_Moving_11.g_D_W_05.g_dLots        = g_dLots;
   D_Moving_11.g_D_W_05.g_iSlippage    = g_iSlippage;
   D_Moving_11.g_D_W_05.g_sFileName    = "SAV_DM11_DW05.txt";
   D_Moving_11.g_D_W_05.Load();
   
   D_Moving_12.g_name                  = Symbol();
   D_Moving_12.g_dLots                 = g_dLots;
   D_Moving_12.g_iSlippage             = g_iSlippage;
   D_Moving_12.g_iMagic                = g_iMagic_12;
   D_Moving_12.g_iMovingPeriod_1       = 27;
   D_Moving_12.g_iMovingPeriod_2       = 68;
   D_Moving_12.g_iMovingShift          = g_iMovingShift;
   D_Moving_12.g_fStopProfitFactor     = g_fStopProfitFactor;
   D_Moving_12.timeframe_b             = PERIOD_D1;
   D_Moving_12.timeframe_s             = PERIOD_H4;
   D_Moving_12.timeframe_m             = PERIOD_M30;
   D_Moving_12.g_D_W_01.g_name         = Symbol();
   D_Moving_12.g_D_W_01.g_iMagic       = g_iMagic_12_01;
   D_Moving_12.g_D_W_01.g_dLots        = g_dLots;
   D_Moving_12.g_D_W_01.g_iSlippage    = g_iSlippage;
   D_Moving_12.g_D_W_01.timeframe      = PERIOD_H4;
   D_Moving_12.g_D_W_01.g_iWR_Period   = 13;
   D_Moving_12.g_D_W_01.g_iWR_HighMax  = -6;
   D_Moving_12.g_D_W_01.g_iWR_LowMax   = -94;
   D_Moving_12.g_D_W_01.g_iWR_HighSign = -20;
   D_Moving_12.g_D_W_01.g_iWR_LowSign  = -80;
   D_Moving_12.g_D_W_01.g_fLowPrice    = iLow(D_Moving_12.g_D_W_01.g_name,D_Moving_12.g_D_W_01.timeframe,0);
   D_Moving_12.g_D_W_01.g_fHighPrice   = iHigh(D_Moving_12.g_D_W_01.g_name,D_Moving_12.g_D_W_01.timeframe,0);
   D_Moving_12.g_D_W_04.g_name         = Symbol();
   D_Moving_12.g_D_W_04.g_iMagic       = g_iMagic_12_02;
   D_Moving_12.g_D_W_04.g_dLots        = g_dLots;
   D_Moving_12.g_D_W_04.g_iSlippage    = g_iSlippage;
   D_Moving_12.g_D_W_04.g_iMovingShift = g_iMovingShift;
   D_Moving_12.g_D_W_04.g_iMA_Period   = 34;
   D_Moving_12.g_D_W_04.timeframe      = PERIOD_H4;
   D_Moving_12.g_D_W_05.g_name         = Symbol();
   D_Moving_12.g_D_W_05.g_iMagic       = g_iMagic_12_03;
   D_Moving_12.g_D_W_05.g_dLots        = g_dLots;
   D_Moving_12.g_D_W_05.g_iSlippage    = g_iSlippage;
   D_Moving_12.g_D_W_05.g_sFileName    = "SAV_DM12_DW05.txt";
   D_Moving_12.g_D_W_05.Load();
   //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>//
   
   
   //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>//
   D_Moving_21.g_name                  = Symbol();
   D_Moving_21.g_dLots                 = g_dLots;
   D_Moving_21.g_iSlippage             = g_iSlippage;
   D_Moving_21.g_iMagic                = g_iMagic_21;
   D_Moving_21.g_iMovingPeriod_1       = 26;
   D_Moving_21.g_iMovingPeriod_2       = 52;
   D_Moving_21.g_iMovingShift          = g_iMovingShift;
   D_Moving_21.g_fStopProfitFactor     = g_fATRFactor;
   D_Moving_21.timeframe_b             = PERIOD_W1;
   D_Moving_21.timeframe_s             = PERIOD_D1;
   D_Moving_21.timeframe_m             = PERIOD_H4;
   D_Moving_21.g_iWR_HighMax           = -50;
   D_Moving_21.g_iWR_LowMax            = -50;
   D_Moving_21.g_D_W_02.g_name         = Symbol();
   D_Moving_21.g_D_W_02.g_iMagic       = g_iMagic_21_01;
   D_Moving_21.g_D_W_02.g_dLots        = g_dLots;
   D_Moving_21.g_D_W_02.g_iSlippage    = g_iSlippage;
   D_Moving_21.g_D_W_02.timeframe      = PERIOD_H4;
   D_Moving_21.g_D_W_02.g_iWR_Period   = 15;
   D_Moving_21.g_D_W_02.g_iWR_HighMax  = -20;
   D_Moving_21.g_D_W_02.g_iWR_LowMax   = -80;
   D_Moving_21.g_D_W_02.g_iWR_HighSign = -20;
   D_Moving_21.g_D_W_02.g_iWR_LowSign  = -80;
   D_Moving_21.g_D_W_03.g_name         = Symbol();
   D_Moving_21.g_D_W_03.timeframe      = PERIOD_H4;
   D_Moving_21.g_D_W_03.g_iWR_Period   = 15;
   D_Moving_21.g_D_W_03.g_TestCount    = 2;
   D_Moving_21.g_D_W_03.g_sFileName    = "SAV_DM21_DW03.txt";
   D_Moving_21.g_D_W_03.Load();
   
   D_Moving_22.g_name                  = Symbol();
   D_Moving_22.g_dLots                 = g_dLots;
   D_Moving_22.g_iSlippage             = g_iSlippage;
   D_Moving_22.g_iMagic                = g_iMagic_22;
   D_Moving_22.g_iMovingPeriod_1       = 22;
   D_Moving_22.g_iMovingPeriod_2       = 81;
   D_Moving_22.g_iMovingShift          = g_iMovingShift;
   D_Moving_22.g_fStopProfitFactor     = g_fATRFactor;
   D_Moving_22.timeframe_b             = PERIOD_D1;
   D_Moving_22.timeframe_s             = PERIOD_H4;
   D_Moving_22.timeframe_m             = PERIOD_H1;
   D_Moving_22.g_iWR_HighMax           = -30;
   D_Moving_22.g_iWR_LowMax            = -70;
   D_Moving_22.g_D_W_02.g_name         = Symbol();
   D_Moving_22.g_D_W_02.g_iMagic       = g_iMagic_21_02;
   D_Moving_22.g_D_W_02.g_dLots        = g_dLots;
   D_Moving_22.g_D_W_02.g_iSlippage    = g_iSlippage;
   D_Moving_22.g_D_W_02.timeframe      = PERIOD_H1;
   D_Moving_22.g_D_W_02.g_iWR_Period   = 17;
   D_Moving_22.g_D_W_02.g_iWR_HighMax  = -20;
   D_Moving_22.g_D_W_02.g_iWR_LowMax   = -80;
   D_Moving_22.g_D_W_02.g_iWR_HighSign = -20;
   D_Moving_22.g_D_W_02.g_iWR_LowSign  = -80;
   D_Moving_22.g_D_W_03.g_name         = Symbol();
   D_Moving_22.g_D_W_03.timeframe      = PERIOD_H1;
   D_Moving_22.g_D_W_03.g_iWR_Period   = 17;
   D_Moving_22.g_D_W_03.g_TestCount    = 4;
   D_Moving_22.g_D_W_03.g_sFileName    = "SAV_DM22_DW03.txt";
   D_Moving_22.g_D_W_03.Load();
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
