//+------------------------------------------------------------------+
//|                                                       D_M_01.mqh |
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


#include "BaseDefine.mqh"
#include "MFSendMail2.mqh"
#include "D_W_02.mqh"
#include "D_W_03.mqh"


class D_M_02
{
   public:
      double   g_dLots;                      // 开仓手数
      int      g_iSlippage;                  // 滑点
      int      g_iMagic;
      int      g_iMovingPeriod_1;
      int      g_iMovingPeriod_2;
      int      g_iMovingShift;
      double   g_fStopProfitFactor;          // 止赢系数
      int      g_iATRPeriod;
      
   public:
      string g_name; 
      int timeframe_b;                       // 大时间周期
      int timeframe_s;                       // 小时间周期
      int timeframe_m;                       // 极小时间周期
      
      int g_iWR_HighMax;
      int g_iWR_LowMax;
   
      OpenType g_OpenType;
      OpenValid g_OpenValid;

      int g_ticket;                          // 开仓的订单号
      double g_fIncreasePoint;               // 最小点数间隔
      double g_fMaxProfit;                   // 最大赢利点起数
      double g_fMaxPrice;                    // 最大赢利价格
      double g_fStopProfit;                  // 止赢价格
      bool   g_bSetStopPrice;                // 是否开始止损价
      
      bool g_bOpenBySignal;
      bool g_bOpenByTime;
      bool g_bDouble;
      
      int g_TrendType;                       // 0: 无     1: 单边趋势     2: 振荡
      int g_TrendProperty;                   // 0: 无     1: 上升         2: 下降
      
      MFSendMail g_SendMail;
      string g_sMsgTitle;
      string g_sMsgContent;
      
      datetime g_tLastCloseTime;             // 上一次的平仓时间
      
      PriceArea g_PriceArea;
      
      bool g_bTestOpen;
      bool g_bTestClose;
      double g_TestPriceOpen;
      double g_TestPriceClose;
      
      D_W_02 g_D_W_02;
      D_W_03 g_D_W_03;
      
   public:
      D_M_02();
      ~D_M_02();
      
   public:
      void MFMainProcess();
      void MFClose();
      
      void MFOrder();
      bool OpenBuy();
      bool OpenSell();
      bool CloseBuy();
      bool CloseSell();
      bool CheckCloseCur(int type, double dMA);
      bool CheckCloseContinuity(int type, double dMA);
      string GetTimeframeName(string sMsgTitle);
      void GetMaxProfit();
      void CheckPrice();
      double PointValue();
      int GetTrendType();
      int GetTrendProperty();
      void Condition(double dMA);
      void CheckWR(double fWR);
      void CheckAddOrder();
};


D_M_02::D_M_02(void)
{
   g_dLots = 0.01;                        // 开仓手数
   g_iSlippage = 5;                       // 滑点
   g_iMagic = 20151123;
   g_iMovingPeriod_1          = 13;
   g_iMovingPeriod_2          = 56;
   g_iMovingShift             = 0;
   g_fStopProfitFactor        = 1.8;
   g_iATRPeriod               = 13;
   
   timeframe_b                = PERIOD_W1;
   timeframe_s                = PERIOD_D1;
   timeframe_m                = PERIOD_H4;
   
   g_iWR_HighMax              = -30;
   g_iWR_LowMax               = -70;
   
   g_name = ""; 
   g_OpenType = OT_NULL;
   g_OpenValid = OV_NULL;
   
   g_ticket = -1;                      // 开仓的订单号
   g_fIncreasePoint = 10;
   g_fMaxProfit = 200;
   g_fMaxPrice = 0;
   g_fStopProfit = 0;
   g_bSetStopPrice = false;
   
   g_bOpenBySignal = false;
   g_bOpenByTime = false;
   g_bDouble = false;
   
   g_TrendType = 0;
   g_TrendProperty = 0;
   
   g_tLastCloseTime = 0;
   
   g_PriceArea = PA_NULL;
   
   g_bTestOpen = false;
   g_bTestClose = false;
   g_TestPriceOpen = 0;
   g_TestPriceClose = 0;
 
   g_sMsgTitle = " , Equity is ";
   g_sMsgContent = "";
}

D_M_02::~D_M_02(void)
{

}


int D_M_02::GetTrendType()
{
   return g_TrendType;
}

int D_M_02::GetTrendProperty()
{
   return g_TrendProperty;
}


bool D_M_02::OpenBuy()
{
   g_ticket = OrderSend(g_name,OP_BUY,g_dLots,Ask,g_iSlippage,0,0,"",g_iMagic,0,Blue);
            
   if(g_ticket >= 0)
   {
      if(OrderSelect(g_ticket,SELECT_BY_TICKET,MODE_TRADES))
      {
         g_sMsgContent = StringConcatenate("open: ", OrderOpenPrice()); 
      }
      
      g_OpenType = OT_BUY;
      g_OpenValid = OV_Valid;
      g_bOpenBySignal = false;
      g_fStopProfit = Ask;
      g_bSetStopPrice = false;
      g_bDouble = false;
      
      g_PriceArea = PA_NULL;
      
      GetMaxProfit();

      return true;
   }
   else
   {
      return false;
   }
}

bool D_M_02::OpenSell()
{
   g_ticket = OrderSend(g_name,OP_SELL,g_dLots,Bid,g_iSlippage,0,0,"",g_iMagic,0,Red);
            
   if(g_ticket >= 0)
   {
      if(OrderSelect(g_ticket,SELECT_BY_TICKET,MODE_TRADES))
      {
         g_sMsgContent = StringConcatenate("open: ", OrderOpenPrice()); 
      }
      
      g_OpenType = OT_SELL;
      g_OpenValid = OV_Valid;
      g_bOpenBySignal = false;
      g_fStopProfit = Bid;
      g_bSetStopPrice = false;
      g_bDouble = false;
      
      g_PriceArea = PA_NULL;
      
      GetMaxProfit();

      return true;
   }
   else
   {
      return false;
   }
}

bool D_M_02::CloseBuy()
{
   if(OrderClose(g_ticket,g_dLots,Bid,g_iSlippage,White))
   {
      if(OrderSelect(g_ticket,SELECT_BY_TICKET,MODE_HISTORY))
      {
         g_sMsgContent = StringConcatenate("open: ", OrderOpenPrice(), " ---- close: ", OrderClosePrice(), "  [", OrderClosePrice()-OrderOpenPrice(), "]"); 
      }
      
      g_ticket = -1;
      g_OpenType = OT_NULL;
      g_OpenValid = OV_NULL;
      g_bOpenBySignal = false;
      g_bOpenByTime = false;
      g_bSetStopPrice = false;
      g_bDouble = false;
      
      g_bTestOpen = false;
      g_bTestClose = false;
      g_tLastCloseTime = iTime(g_name,timeframe_m,0);
      
      GetMaxProfit();
      
      return true;
   }
   else
   {
      return false;
   }
}

bool D_M_02::CloseSell()
{
   if(OrderClose(g_ticket,g_dLots,Ask,g_iSlippage,White))
   {
      if(OrderSelect(g_ticket,SELECT_BY_TICKET,MODE_HISTORY))
      {
         g_sMsgContent = StringConcatenate("open: ", OrderOpenPrice(), " ---- close: ", OrderClosePrice(), "  [", OrderOpenPrice()-OrderClosePrice(), "]"); 
      }
      
      g_ticket = -1;
      g_OpenType = OT_NULL;
      g_OpenValid = OV_NULL;
      g_bOpenBySignal = false;
      g_bOpenByTime = false;
      g_bSetStopPrice = false;
      g_bDouble = false;
      
      g_bTestOpen = false;
      g_bTestClose = false;
      g_tLastCloseTime = iTime(g_name,timeframe_m,0);
      
      GetMaxProfit();
      
      return true;
   }
   else
   {
      return false;
   }
}



// 检查最前收盘价是否低于或高于 指定平均线 (21天、55天)
// type : 0  低于      
//        1  高于
bool D_M_02::CheckCloseCur(int type, double dMA)
{
   if(type == 0)
   {
      if(iLow(g_name,timeframe_s,0) > dMA)
      {
         return false;
      } 
   }
   else if(type == 1)
   {
      if(iHigh(g_name,timeframe_s,0) < dMA)
      {
         return false;
      } 
   }
   
   return true;
}

// 检查收盘价是否连续3次低于或高于 21天平均线
// type : 0  低于      
//        1  高于
bool D_M_02::CheckCloseContinuity(int type, double dMA)
{
   int iCount = 8;
   bool bCheck = false;
   
   for(int i = 1; i <= iCount; i++)
   {
      if(type == 0)
      {
         if(iClose(g_name,timeframe_s,i) > dMA)
         {
            return false;
         } 
      }
      else if(type == 1)
      {
         if(iClose(g_name,timeframe_s,i) < dMA)
         {
            return false;
         } 
      }
   }
   
   return true;
}


string D_M_02::GetTimeframeName(string sMsgTitle)
{
   string sTimeName = " ---- ";
   
   if(timeframe_b == PERIOD_M5)
   {
      sTimeName = StringConcatenate(sTimeName, "[M5]-->"); 
   }
   else if(timeframe_b == PERIOD_M15)
   {
      sTimeName = StringConcatenate(sTimeName, "[M15]-->"); 
   }
   else if(timeframe_b == PERIOD_M30)
   {
      sTimeName = StringConcatenate(sTimeName, "[M30]-->"); 
   }
   else if(timeframe_b == PERIOD_H1)
   {
      sTimeName = StringConcatenate(sTimeName, "[H1]-->"); 
   }
   else if(timeframe_b == PERIOD_H4)
   {
      sTimeName = StringConcatenate(sTimeName, "[H4]-->"); 
   }
   else if(timeframe_b == PERIOD_D1)
   {
      sTimeName = StringConcatenate(sTimeName, "[D1]-->"); 
   }
   else if(timeframe_b == PERIOD_W1)
   {
      sTimeName = StringConcatenate(sTimeName, "[W1]-->"); 
   }
   
   
   if(timeframe_s == PERIOD_M5)
   {
      sTimeName = StringConcatenate(sTimeName, "[M5]"); 
   }
   else if(timeframe_s == PERIOD_M15)
   {
      sTimeName = StringConcatenate(sTimeName, "[M15]"); 
   }
   else if(timeframe_s == PERIOD_M30)
   {
      sTimeName = StringConcatenate(sTimeName, "[M30]"); 
   }
   else if(timeframe_s == PERIOD_H1)
   {
      sTimeName = StringConcatenate(sTimeName, "[H1]"); 
   }
   else if(timeframe_s == PERIOD_H4)
   {
      sTimeName = StringConcatenate(sTimeName, "[H4]"); 
   }
   else if(timeframe_s == PERIOD_D1)
   {
      sTimeName = StringConcatenate(sTimeName, "[D1]"); 
   }
   
   sMsgTitle = StringConcatenate(sMsgTitle, sTimeName); 
   return sMsgTitle;
}


void D_M_02::GetMaxProfit()
{
   g_fIncreasePoint = 20;
   if(timeframe_s == PERIOD_M15)
   {
      g_fIncreasePoint = 15;
   }
   else if(timeframe_s == PERIOD_M30)
   {
      g_fIncreasePoint = 30;
   }
   else if(timeframe_s == PERIOD_H1)
   {
      g_fIncreasePoint = 60;
   }
   else if(timeframe_s == PERIOD_H4)
   {
      g_fIncreasePoint = 130;
   }
   else if(timeframe_s == PERIOD_D1)
   {
      g_fIncreasePoint = 600;
   }
   
   if(g_OpenType == OT_BUY)
   {
      g_fMaxPrice = g_fStopProfit + g_fIncreasePoint * PointValue();
      g_fStopProfit = g_fStopProfit + g_fIncreasePoint * PointValue() * g_fStopProfitFactor;
   }
   else if(g_OpenType == OT_SELL)
   {
      g_fMaxPrice = g_fStopProfit - g_fIncreasePoint * PointValue();
      g_fStopProfit = g_fStopProfit - g_fIncreasePoint * PointValue() * g_fStopProfitFactor;
   }
   else
   {
      g_fMaxPrice = 0;
      g_fStopProfit = 0;
   }
   
   //g_fMaxPrice = NormalizeDouble(g_fMaxPrice, Digits);
   //g_fStopProfit = NormalizeDouble(g_fStopProfit, Digits);
}


void D_M_02::CheckPrice()
{
/*
   if(g_OpenType == OT_BUY && (Bid - g_fMaxPrice) > 0)
   {
      g_fStopProfit = g_fStopProfit + (Bid - g_fMaxPrice);
      g_fMaxPrice = Bid;
      g_bSetStopPrice = true;
   }
   
   if(g_OpenType == OT_SELL && (g_fMaxPrice - Ask) > 0)
   {
      g_fStopProfit = g_fStopProfit - (g_fMaxPrice - Ask);
      g_fMaxPrice = Ask;
      g_bSetStopPrice = true;
   }
*/

   // 大于 24小时
   int time = iTime(g_name,timeframe_m,1) - g_tLastCloseTime;
   //if(time > 86400)
   {
      g_bOpenByTime = true;
   }
   
   if(!g_bOpenByTime)
   {
      return;
   }

   if(g_OpenType == OT_BUY && g_OpenValid == OV_Valid)
   {
      double dClose = iClose(g_name,timeframe_s,1);
      double dATR = iATR(g_name,timeframe_s,g_iATRPeriod,1);
      g_fStopProfit = dClose - (dATR * g_fStopProfitFactor);
      //g_bSetStopPrice = true;
   }
   
   if(g_OpenType == OT_SELL && g_OpenValid == OV_Valid)
   {
      double dClose = iClose(g_name,timeframe_s,1);
      double dATR = iATR(g_name,timeframe_s,g_iATRPeriod,1);
      g_fStopProfit = dClose + (dATR * g_fStopProfitFactor);
      //g_bSetStopPrice = true;
   }
}

void D_M_02::Condition(double dMA)
{ 
   // 上升
   if(g_TrendType == 1 && g_TrendProperty == 1)
   {
      if(g_D_W_03.IsOpen())
      {
         g_bOpenBySignal = true;
      }
   }
   
   if(g_TrendType == 2 && g_TrendProperty == 2)
   {
      g_D_W_03.ClearStatus();
   }
   
   //-------------------------------------------------------------------------//
   
   // 下降
   if(g_TrendType == 1 && g_TrendProperty == 2)
   {
      if(g_D_W_03.IsOpen())
      {
         g_bOpenBySignal = true;
      }
   }
   
   if(g_TrendType == 2 && g_TrendProperty == 1)
   {
      g_D_W_03.ClearStatus();
   }
   
   
}

// 判断是否在低位或高位
void D_M_02::CheckWR(double fWR)
{
   if(!g_bOpenBySignal)
   {
      return;
   }
   
   if(fWR > g_D_W_02.g_iWR_HighMax)
   {
      g_PriceArea = PA_High;
   }
   
   if(fWR < g_D_W_02.g_iWR_LowMax)
   {
      g_PriceArea = PA_Low;
   }
}

// 判断是否加仓条件
void D_M_02::CheckAddOrder()
{
   double wr = iWPR(g_name,timeframe_s,g_D_W_03.g_iWR_Period,1);   
   
   if(g_D_W_02.g_MainTrend == T_RISE && g_D_W_02.g_CurTrend == T_RISE)
   {
      if(wr < g_iWR_LowMax)
      {
         g_D_W_02.OpenPermission();
      }
      else
      {
         g_D_W_02.ClosePermission();
      }
   }
   
   if(g_D_W_02.g_MainTrend == T_DECREASE && g_D_W_02.g_CurTrend == T_DECREASE)
   {
      if(wr > g_iWR_HighMax)
      {
         g_D_W_02.OpenPermission();
      }
      else
      {
         g_D_W_02.ClosePermission();
      }
   }
}

void D_M_02::MFOrder()
{
   if(Bars < 3)
   {
      return;
   }
   
   g_sMsgContent = "";

   //--------------------------------------------------------------------------------------------------------  
                                  // 大周期 移动平均线指标
                                  
   double D_K_0, D_K_1,               // 指标快速线第0柱和1柱的值
          D_J_0, D_J_1;               // 指标慢速线第0柱和1柱的值
          
   D_K_0 = iMA(g_name,timeframe_b,g_iMovingPeriod_1,g_iMovingShift,MODE_SMA,PRICE_CLOSE,1);// 1 柱  
   D_K_1 = iMA(g_name,timeframe_b,g_iMovingPeriod_1,g_iMovingShift,MODE_SMA,PRICE_CLOSE,2);// 2 柱 
   D_J_0 = iMA(g_name,timeframe_b,g_iMovingPeriod_2,g_iMovingShift,MODE_SMA,PRICE_CLOSE,1);// 1 柱   
   D_J_1 = iMA(g_name,timeframe_b,g_iMovingPeriod_2,g_iMovingShift,MODE_SMA,PRICE_CLOSE,2);// 2 柱   
   //---------------------------------------------------------------------------------------------------------
   
   //--------------------------------------------------------------------------------------------------------  
                                  // 小周期 移动平均线指标
                                  
   double S_K_0, S_K_1,               // 指标快速线第0柱和1柱的值
          S_J_0, S_J_1;               // 指标慢速线第0柱和1柱的值
          
   S_K_0 = iMA(g_name,timeframe_s,g_iMovingPeriod_1,g_iMovingShift,MODE_SMA,PRICE_CLOSE,1);// 1 柱  
   S_K_1 = iMA(g_name,timeframe_s,g_iMovingPeriod_1,g_iMovingShift,MODE_SMA,PRICE_CLOSE,2);// 2 柱 
   S_J_0 = iMA(g_name,timeframe_s,g_iMovingPeriod_2,g_iMovingShift,MODE_SMA,PRICE_CLOSE,1);// 1 柱   
   S_J_1 = iMA(g_name,timeframe_s,g_iMovingPeriod_2,g_iMovingShift,MODE_SMA,PRICE_CLOSE,2);// 2 柱   
   //---------------------------------------------------------------------------------------------------------
   
   //--------------------------------------------------------------------------------------------------------  
                                  // 极小周期 移动平均线指标
                                  
   double M_K_0, M_K_1,               // 指标快速线第0柱和1柱的值
          M_J_0, M_J_1;               // 指标慢速线第0柱和1柱的值
          
   M_K_0 = iMA(g_name,timeframe_m,g_iMovingPeriod_1,g_iMovingShift,MODE_SMA,PRICE_CLOSE,1);// 1 柱  
   M_K_1 = iMA(g_name,timeframe_m,g_iMovingPeriod_1,g_iMovingShift,MODE_SMA,PRICE_CLOSE,2);// 2 柱 
   M_J_0 = iMA(g_name,timeframe_m,g_iMovingPeriod_2,g_iMovingShift,MODE_SMA,PRICE_CLOSE,1);// 1 柱   
   M_J_1 = iMA(g_name,timeframe_m,g_iMovingPeriod_2,g_iMovingShift,MODE_SMA,PRICE_CLOSE,2);// 2 柱   
   //---------------------------------------------------------------------------------------------------------
   
   //---------------------------------------------------------------------------------------------------------
   double dWR = iWPR(g_name,g_D_W_03.timeframe,g_D_W_03.g_iWR_Period,1);       
   //--------------------------------------------------------------------------------------------------------- 
   
   
   if(D_K_0 < 0.0001 || D_K_1 < 0.0001 || D_J_0 < 0.0001 || D_J_1 < 0.0001)
   {
      return;
   }
   if(S_K_0 < 0.0001 || S_K_1 < 0.0001 || S_J_0 < 0.0001 || S_J_1 < 0.0001)
   {
      return;
   }
   if(M_K_0 < 0.0001 || M_K_1 < 0.0001 || M_J_0 < 0.0001 || M_J_1 < 0.0001)
   {
      return;
   }
   
   
   //CheckPrice();
   
   if(!g_bOpenByTime)
   {
      //return;
   }
   
   Condition(S_J_0);
   CheckWR(dWR);
   
   CheckAddOrder();
   


                                  // 分析数据  
                              
   while(true)
   {
      //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>//
      // 大周期 快线上穿慢线
      if( D_K_1 < D_J_1 && D_K_0 >= D_J_0 )    
      {
         g_TrendType = 0;
         g_TrendProperty = 0;
            
         g_bOpenBySignal = false;
         
         // 主趋势 上升
         g_D_W_02.g_MainTrend = T_RISE;
         g_D_W_03.g_MainTrend = T_RISE;
         
         // 止损，平仓空单
         if(g_OpenType == OT_SELL && g_OpenValid == OV_Valid)
         {
            // 平仓空单
            if(CloseSell())
            {
               g_D_W_02.Closed(T_DECREASE);
               g_D_W_03.Closed();
               
               string sMsgTitle = "D_M_02: Stop Close SELL";
               sMsgTitle = GetTimeframeName(sMsgTitle);
               Print(sMsgTitle); // 提醒
               sMsgTitle = StringConcatenate(sMsgTitle, g_sMsgTitle); 
               g_SendMail.SendMailToFxseaServer(sMsgTitle, g_sMsgContent);
               
               return;
            }
            else
            {
               continue;
            }
         }
      }
      //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>//
      
      
      //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>//
      // 大周期 快线下穿慢线
      if( D_K_1 > D_J_1 && D_K_0 <= D_J_0 )    
      {
         g_TrendType = 0;
         g_TrendProperty = 0;
         
         g_bOpenBySignal = false;
         
         // 主趋势 下降
         g_D_W_02.g_MainTrend = T_DECREASE;
         g_D_W_03.g_MainTrend = T_DECREASE;
         
         // 止损，平仓多单
         if(g_OpenType == OT_BUY && g_OpenValid == OV_Valid)
         {
            // 平仓多单
            if(CloseBuy())
            {
               g_D_W_02.Closed(T_RISE);
               g_D_W_03.Closed();
               
               string sMsgTitle = "D_M_02: Stop Close BUY";
               sMsgTitle = GetTimeframeName(sMsgTitle);
               Print(sMsgTitle); // 提醒
               sMsgTitle = StringConcatenate(sMsgTitle, g_sMsgTitle); 
               g_SendMail.SendMailToFxseaServer(sMsgTitle, g_sMsgContent);
               
               return;
            }
            else
            {
               continue;
            }
         }
      } 
      //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>//
       
      
      
      //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>//
      // 大周期 持续 快线在慢线 上方 
      if( D_K_1 > D_J_1 && D_K_0 > D_J_0 )
      {
         // 主趋势 上升
         g_D_W_02.g_MainTrend = T_RISE;
         g_D_W_03.g_MainTrend = T_RISE;
         
         //===================================================================//
         // 小周期 快线上穿慢线
         if( S_K_1 < S_J_1 && S_K_0 >= S_J_0 ) 
         {
            g_TrendType = 1;
            g_TrendProperty = 1;
            
            g_D_W_03.g_CurTrend = T_RISE;
            g_D_W_03.ClearStatus();
            
            if(g_OpenType == OT_SELL && g_OpenValid == OV_Valid)
            {
               // 平仓空单
               if(CloseSell())
               {
                  g_D_W_02.Closed(T_DECREASE);
                  g_D_W_03.Closed();
                  
                  string sMsgTitle = "D_M_02: Close SELL";
                  sMsgTitle = GetTimeframeName(sMsgTitle);
                  Print(sMsgTitle); // 提醒
                  sMsgTitle = StringConcatenate(sMsgTitle, g_sMsgTitle); 
                  g_SendMail.SendMailToFxseaServer(sMsgTitle, g_sMsgContent);
                  
                  return;
               }
               else
               {
                  continue;
               }
            }
         }
         
         // 小周期 快线下穿慢线
         if( S_K_1 > S_J_1 && S_K_0 <= S_J_0 )
         {
            g_TrendType = 2;
            g_TrendProperty = 2;
            
            g_D_W_03.g_CurTrend = T_DECREASE;
            g_D_W_03.ClearStatus();
            
            g_bOpenBySignal = false;
            
            if(g_OpenType == OT_BUY && g_OpenValid == OV_Valid)
            {
               // 平仓多单
               if(CloseBuy())
               {
                  g_D_W_02.Closed(T_RISE);
                  g_D_W_03.Closed();
                  
                  string sMsgTitle = "D_M_02: Close BUY";
                  sMsgTitle = GetTimeframeName(sMsgTitle);
                  Print(sMsgTitle); // 提醒
                  sMsgTitle = StringConcatenate(sMsgTitle, g_sMsgTitle); 
                  g_SendMail.SendMailToFxseaServer(sMsgTitle, g_sMsgContent);
                  
                  return;
               }
               else
               {
                  continue;
               }
            }
         }
         //===================================================================//
         
         //===================================================================//
         // 小周期 持续 快线在慢线 上方 
         if( S_K_1 > S_J_1 && S_K_0 > S_J_0 )
         {
            g_TrendType = 1;
            g_TrendProperty = 1;
            
            g_D_W_03.g_CurTrend = T_RISE;
            
            if(g_bSetStopPrice && Bid < g_fStopProfit && g_OpenType == OT_BUY && g_OpenValid == OV_Valid)
            {
               // 平仓多单
               if(CloseBuy())
               {
                  g_D_W_02.Closed(T_RISE);
                  
                  string sMsgTitle = "D_M_02: Stop Profit Close BUY";
                  sMsgTitle = GetTimeframeName(sMsgTitle);
                  Print(sMsgTitle); // 提醒
                  sMsgTitle = StringConcatenate(sMsgTitle, g_sMsgTitle); 
                  g_SendMail.SendMailToFxseaServer(sMsgTitle, g_sMsgContent);
                  
                  return;
               }
               else
               {
                  continue;
               }
            }
            
            if(g_bOpenBySignal && g_PriceArea == PA_Low && dWR > g_D_W_02.g_iWR_LowSign)
            {
               // 当前趋势 上升
               g_D_W_02.g_CurTrend = T_RISE; 
               
               if(g_OpenType == OT_NULL && g_OpenValid == OV_NULL)
               {
                  // 开仓多单
                  if(OpenBuy())
                  {
                     string sMsgTitle = "D_M_02: Open BUY";
                     sMsgTitle = GetTimeframeName(sMsgTitle);
                     Print(sMsgTitle); // 提醒
                     sMsgTitle = StringConcatenate(sMsgTitle, g_sMsgTitle); 
                     g_SendMail.SendMailToFxseaServer(sMsgTitle, g_sMsgContent);
                     
                     return;
                  }
                  else
                  {
                     continue;
                  }
               }
            }
         }
         
         // 小周期 持续 快线在慢线 下方 
         if( S_K_1 < S_J_1 && S_K_0 < S_J_0 )
         {
            g_TrendType = 2;
            g_TrendProperty = 2;
            
            g_D_W_03.g_CurTrend = T_DECREASE;
         }
         //===================================================================//
      }
      //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>//
      
      
      //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>//
      // 大周期 持续 快线在慢线 下方 
      if( D_K_1 < D_J_1 && D_K_0 < D_J_0 ) 
      {
         // 主趋势 下降
         g_D_W_02.g_MainTrend = T_DECREASE;
         g_D_W_03.g_MainTrend = T_DECREASE;
         
         //===================================================================//
         // 小周期 快线下穿慢线
         if( S_K_1 > S_J_1 && S_K_0 <= S_J_0 )  
         {
            g_TrendType = 1;
            g_TrendProperty = 2;
            
            g_D_W_03.g_CurTrend = T_DECREASE;
            g_D_W_03.ClearStatus();
            
            if(g_OpenType == OT_BUY && g_OpenValid == OV_Valid)
            {
               // 平仓多单
               if(CloseBuy())
               {
                  g_D_W_02.Closed(T_RISE);
                  g_D_W_03.Closed();
                  
                  string sMsgTitle = "D_M_02: Close BUY";
                  sMsgTitle = GetTimeframeName(sMsgTitle);
                  Print(sMsgTitle); // 提醒
                  sMsgTitle = StringConcatenate(sMsgTitle, g_sMsgTitle); 
                  g_SendMail.SendMailToFxseaServer(sMsgTitle, g_sMsgContent);
                  
                  return;
               }
               else
               {
                  continue;
               }
            }
         }
         
         // 小周期 快线上穿慢线
         if( S_K_1 < S_J_1 && S_K_0 >= S_J_0 )    
         {
            g_TrendType = 2;
            g_TrendProperty = 1;
            
            g_D_W_03.g_CurTrend = T_RISE;
            g_D_W_03.ClearStatus();
            
            g_bOpenBySignal = false;
            
            if(g_OpenType == OT_SELL && g_OpenValid == OV_Valid)
            {
               // 平仓空单
               if(CloseSell())
               {
                  g_D_W_02.Closed(T_DECREASE);
                  g_D_W_03.Closed();
                  
                  string sMsgTitle = "D_M_02: Close SELL";
                  sMsgTitle = GetTimeframeName(sMsgTitle);
                  Print(sMsgTitle); // 提醒
                  sMsgTitle = StringConcatenate(sMsgTitle, g_sMsgTitle); 
                  g_SendMail.SendMailToFxseaServer(sMsgTitle, g_sMsgContent);
                  
                  return;
               }
               else
               {
                  continue;
               }
            }
         }
         //===================================================================//
         
         //===================================================================//
         // 小周期 持续 快线在慢线 下方  
         if( S_K_1 < S_J_1 && S_K_0 < S_J_0 )
         {
            g_TrendType = 1;
            g_TrendProperty = 2;
            
            g_D_W_03.g_CurTrend = T_DECREASE;
            
            if(g_bSetStopPrice && Ask > g_fStopProfit && g_OpenType == OT_SELL && g_OpenValid == OV_Valid)
            {
               // 平仓空单
               if(CloseSell())
               {
                  g_D_W_02.Closed(T_DECREASE);
                  
                  string sMsgTitle = "D_M_02: Stop Profit Close SELL";
                  sMsgTitle = GetTimeframeName(sMsgTitle);
                  Print(sMsgTitle); // 提醒
                  sMsgTitle = StringConcatenate(sMsgTitle, g_sMsgTitle); 
                  g_SendMail.SendMailToFxseaServer(sMsgTitle, g_sMsgContent);
                  
                  return;
               }
               else
               {
                  continue;
               }
            }
             
            if(g_bOpenBySignal && g_PriceArea == PA_High && dWR < g_D_W_02.g_iWR_HighSign)
            {
               // 当前趋势 下降
               g_D_W_02.g_CurTrend = T_DECREASE;
               
               if(g_OpenType == OT_NULL && g_OpenValid == OV_NULL)
               {
                  // 开仓空单
                  if(OpenSell())
                  {
                     string sMsgTitle = "D_M_02: Open SELL";
                     sMsgTitle = GetTimeframeName(sMsgTitle);
                     Print(sMsgTitle); // 提醒
                     sMsgTitle = StringConcatenate(sMsgTitle, g_sMsgTitle); 
                     g_SendMail.SendMailToFxseaServer(sMsgTitle, g_sMsgContent);
                     
                     return;
                  }
                  else
                  {
                     continue;
                  }
               }
            }
         }
         
         // 小周期 持续 快线在慢线 上方 
         if( S_K_1 > S_J_1 && S_K_0 > S_J_0 )
         {
            g_TrendType = 2;
            g_TrendProperty = 1;
            
            g_D_W_03.g_CurTrend = T_RISE;
         }
         //===================================================================//
      }
      //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>//
      
      
      return;
    }                              
   
}


// 退出时，平仓
void D_M_02::MFClose()
{
   //while(true)
   {
      if(g_OpenType == OT_BUY && g_OpenValid == OV_Valid)
      {
         if(CloseBuy())
         {
            Print("1: Close BUY."); // 提醒
            return;
         }
         else
         {
            //continue;
         }
      }
      
      if(g_OpenType == OT_SELL && g_OpenValid == OV_Valid)
      {
         if(CloseSell())
         {
            Print("1: Close SELL."); // 提醒
            return;
         }
         else
         {
            //continue;
         }
      }
   
      return;
   }
}


void D_M_02::MFMainProcess()
{
   MFOrder();
   
   g_D_W_02.MFMainProcess();
   g_D_W_03.MFMainProcess();
}


double D_M_02::PointValue() 
{
   if (MarketInfo(Symbol(), MODE_DIGITS) == 5.0 || MarketInfo(Symbol(), MODE_DIGITS) == 3.0) return (10.0 * Point);
   return (Point);
}