//+------------------------------------------------------------------+
//|                                                       D_M_03.mqh |
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
#include "MFSendMail.mqh"




class D_M_04
{
   public:
      double   g_dLots;                      // 开仓手数
      int      g_iSlippage;                  // 滑点
      int      g_iMagic;
      int      g_iMovingShift;
      double   g_StopLoss;                   //止损点
      double   g_StopProfit;                 //止盈点
      double   g_ProfitFactor;
      
   public:
      string g_name; 
      OpenType g_OpenType;
      OpenValid g_OpenValid;
      int  TradePeriod_D;
      int  TradePeriod;

      int g_ticket;                            // 开仓的订单号
      int MACD_Signal_Period;                //macd 信号线周期
      int MACD_Fast_Period;                  //macd 快线周期
      int MACD_Slow_Period;                  //macd 慢线周期
      
      
      double StopPrice;
      double LossPrice;
      double CurPrice;
      bool   g_bSetStopPrice;                // 是否开始止损价
      
      int g_TrendDuration;                   // 趋势持续次数
      Trend g_MACD_Trend_D; 
      Trend g_MACD_Trend;                    // MACD 趋势, 以0轴为水平，上穿、下穿
      
      MFSendMail g_SendMail;
      string g_sMsgTitle;
      string g_sMsgContent;
      
   public:
      D_M_04();
      ~D_M_04();
      
   public:
      void MFMainProcess();
      
      void MFOrder();
      bool OpenBuy();
      bool OpenSell();
      bool CloseBuy();
      bool CloseSell();
      
      void CheckTrend();
      void ModifyOrder();
      double PointValue();
      
      void SetLots(double dLos);
      
};



D_M_04::D_M_04(void)
{
   g_dLots = 0.01;                        // 开仓手数
   g_iSlippage = 5;                       // 滑点
   g_iMagic = 20151018;
   g_iMovingShift = 0;
   
   g_StopLoss = 60;                       //止损点
   g_StopProfit = 44;                     //止盈点
   g_ProfitFactor = 0.1;
   
   g_name = ""; 
   g_OpenType = OT_NULL;
   g_OpenValid = OV_NULL;
   
   TradePeriod_D = PERIOD_W1;
   TradePeriod = PERIOD_D1;

   g_ticket = -1;
   MACD_Signal_Period = 8;                //macd 信号线周期
   MACD_Fast_Period = 14;                 //macd 快线周期
   MACD_Slow_Period = 36;                 //macd 慢线周期
   
   StopPrice = 0;
   LossPrice = 0;
   CurPrice = 0;
   g_bSetStopPrice = false;
   
   g_TrendDuration = 3;
   g_MACD_Trend_D = T_NULL;
   g_MACD_Trend = T_NULL;
   
   g_sMsgTitle = " , Equity is ";
   g_sMsgContent = "";
}

D_M_04::~D_M_04(void)
{

}


bool D_M_04::OpenBuy()
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
      g_bSetStopPrice = false;
      CurPrice = Ask + PointValue() * g_StopProfit;
      LossPrice = Ask + PointValue() * g_StopProfit * g_ProfitFactor;
      StopPrice = Ask - PointValue() * g_StopLoss;   

      return true;
   }
   else
   {
      return false;
   }
}

bool D_M_04::OpenSell()
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
      g_bSetStopPrice = false;
      CurPrice = Bid - PointValue() * g_StopProfit;
      LossPrice = Bid - PointValue() * g_StopProfit * g_ProfitFactor;
      StopPrice = Bid + PointValue() * g_StopLoss;

      return true;
   }
   else
   {
      return false;
   }
}

bool D_M_04::CloseBuy()
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
      g_MACD_Trend = T_NULL;
      g_bSetStopPrice = false;
      CurPrice = 0;
      LossPrice = 0;
      StopPrice = 0;
      
      return true;
   }
   else
   {
      return false;
   }
}

bool D_M_04::CloseSell()
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
      g_MACD_Trend = T_NULL;
      g_bSetStopPrice = false;
      CurPrice = 0;
      LossPrice = 0;
      StopPrice = 0;
      
      return true;
   }
   else
   {
      return false;
   }
}


void D_M_04::CheckTrend()
{
   // MACD
   double macd_0 = iMACD(g_name,TradePeriod,MACD_Fast_Period,MACD_Slow_Period,MACD_Signal_Period,PRICE_CLOSE,MODE_MAIN,1); 
   double macd_1 = iMACD(g_name,TradePeriod,MACD_Fast_Period,MACD_Slow_Period,MACD_Signal_Period,PRICE_CLOSE,MODE_MAIN,2); 
   double macd_2 = iMACD(g_name,TradePeriod,MACD_Fast_Period,MACD_Slow_Period,MACD_Signal_Period,PRICE_CLOSE,MODE_MAIN,3);
   
   //Print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>-macd_0 ", macd_0, " macd_1 ", macd_1, " macd_2", macd_2); 
   
   if(g_MACD_Trend == T_RISE)
   {
      if(macd_0 < 0 || macd_1 < 0 || macd_2 < 0)
      {
         g_MACD_Trend = T_NULL;
      }
   }
   
   if(g_MACD_Trend == T_DECREASE)
   {
      if(macd_0 > 0 || macd_1 > 0 || macd_2 > 0)
      {
         g_MACD_Trend = T_NULL;
      }
   }
   
   if(macd_0 > 0 && macd_1 > 0 && macd_2 > 0)
   {
      if(macd_0 > macd_1 && macd_1 > macd_2)
      {
         g_MACD_Trend = T_RISE;
      }
   } 
   
   if(macd_0 < 0 && macd_1 < 0 && macd_2 < 0)
   {
      if(macd_0 < macd_1 && macd_1 < macd_2)
      {
         g_MACD_Trend = T_DECREASE;
      }
   }
 
}



void D_M_04::ModifyOrder()
{                                 
   if(g_OpenType == OT_BUY)
   {                         
     if(Bid > CurPrice)
     {
         LossPrice = LossPrice + (Bid - CurPrice);
         CurPrice = Bid;
         g_bSetStopPrice = true;
     }
   }
   
   if(g_OpenType == OT_SELL)
   {
     if(Ask < CurPrice)
     {
         LossPrice = LossPrice - (CurPrice - Ask);
         CurPrice = Ask;
         g_bSetStopPrice = true;
     }
      
   }  

}

void D_M_04::MFOrder()
{
   if(Bars < 3)
   {
      return;
   }
   
   g_sMsgContent = "";
   
   
   //--------------------------------------------------------------------------------------------------------  
                                  // 大周期 
   
   double D_macd_0 = iMACD(g_name,TradePeriod_D,MACD_Fast_Period,MACD_Slow_Period,MACD_Signal_Period,PRICE_CLOSE,MODE_MAIN,1); 
   double D_macd_1 = iMACD(g_name,TradePeriod_D,MACD_Fast_Period,MACD_Slow_Period,MACD_Signal_Period,PRICE_CLOSE,MODE_MAIN,2); 
   double D_macd_2 = iMACD(g_name,TradePeriod_D,MACD_Fast_Period,MACD_Slow_Period,MACD_Signal_Period,PRICE_CLOSE,MODE_MAIN,3); 
   
   
   if(D_macd_0 > 0 && D_macd_1 > 0 && D_macd_2 > 0)
   {
      if(D_macd_0 > D_macd_1 && D_macd_1 > D_macd_2)
      {
         g_MACD_Trend_D = T_RISE;
      }
   }
   if(D_macd_0 < 0 && D_macd_1 < 0 && D_macd_2 < 0)
   {
      if(D_macd_0 < D_macd_1 && D_macd_1 < D_macd_2)
      {
         g_MACD_Trend_D = T_DECREASE;
      }
   }
   //---------------------------------------------------------------------------------------------------------

   
   CheckTrend();
   ModifyOrder();
   
   
   while(true)
   {
      //--------------------------------------------------------------------------------------//
      // 止损，平仓多单
      if(g_OpenType == OT_BUY && g_OpenValid == OV_Valid && g_MACD_Trend == T_DECREASE)
      {
         if(CloseBuy())
         {
            string sMsgTitle = "D_M_04: Stop Close BUY";
            Alert(sMsgTitle); // 提醒
            sMsgTitle = StringConcatenate(sMsgTitle, g_sMsgTitle); 
            g_SendMail.SendMailToMeMsg(sMsgTitle, g_sMsgContent);
            
            return;
         }
         else
         {
            continue;
         }
      }
      
      // 止损，平仓空单
      if(g_OpenType == OT_SELL && g_OpenValid == OV_Valid && g_MACD_Trend == T_RISE)
      {
         if(CloseSell())
         {
            string sMsgTitle = "D_M_04: Stop Close SELL";
            Alert(sMsgTitle); // 提醒
            sMsgTitle = StringConcatenate(sMsgTitle, g_sMsgTitle); 
            g_SendMail.SendMailToMeMsg(sMsgTitle, g_sMsgContent);
            
            return;
         }
         else
         {
            continue;
         }
      }
      //--------------------------------------------------------------------------------------//
      
      
      //--------------------------------------------------------------------------------------//
      // 止赢，平仓多单
      if(g_OpenType == OT_BUY && g_OpenValid == OV_Valid && g_bSetStopPrice && Bid < LossPrice)
      {
         if(CloseBuy())
         {
            string sMsgTitle = "D_M_04: Stop Profit Close BUY";
            Alert(sMsgTitle); // 提醒
            sMsgTitle = StringConcatenate(sMsgTitle, g_sMsgTitle); 
            g_SendMail.SendMailToMeMsg(sMsgTitle, g_sMsgContent);
            
            return;
         }
         else
         {
            continue;
         }
      }
      
      // 止赢，平仓空单
      if(g_OpenType == OT_SELL && g_OpenValid == OV_Valid && g_bSetStopPrice && Ask > LossPrice)
      {
         if(CloseSell())
         {
            string sMsgTitle = "D_M_04: Stop Profit Close SELL";
            Alert(sMsgTitle); // 提醒
            sMsgTitle = StringConcatenate(sMsgTitle, g_sMsgTitle); 
            g_SendMail.SendMailToMeMsg(sMsgTitle, g_sMsgContent);
            
            return;
         }
         else
         {
            continue;
         }
      }
      //--------------------------------------------------------------------------------------//
      
      
      //--------------------------------------------------------------------------------------//
      // 上升趋势
      if(g_MACD_Trend_D == T_RISE && g_MACD_Trend == T_RISE)
      {
         if(g_OpenType == OT_NULL && g_OpenValid == OV_NULL)
         {
            // 开仓多单
            if(OpenBuy())
            {
               string sMsgTitle = "D_M_04: Open BUY";
               Alert(sMsgTitle); // 提醒
               sMsgTitle = StringConcatenate(sMsgTitle, g_sMsgTitle); 
               g_SendMail.SendMailToMeMsg(sMsgTitle, g_sMsgContent);
               
               return;
            }
            else
            {
               continue;
            }
         }
      } 
      //--------------------------------------------------------------------------------------//
      
      
      //--------------------------------------------------------------------------------------//
      
      // 下降趋势
      if(g_MACD_Trend_D == T_DECREASE && g_MACD_Trend == T_DECREASE)
      {
         if(g_OpenType == OT_NULL && g_OpenValid == OV_NULL)
         {
            // 开仓空单
            if(OpenSell())
            {
               string sMsgTitle = "D_M_04: Open SELL";
               Alert(sMsgTitle); // 提醒
               sMsgTitle = StringConcatenate(sMsgTitle, g_sMsgTitle); 
               g_SendMail.SendMailToMeMsg(sMsgTitle, g_sMsgContent);
               
               return;
            }
            else
            {
               continue;
            }
         }
      } 
      //--------------------------------------------------------------------------------------//
      
      
      return;
   }
}


double D_M_04::PointValue() 
{
   if (MarketInfo(g_name, MODE_DIGITS) == 5.0 || MarketInfo(g_name, MODE_DIGITS) == 3.0) return (10.0 * Point);
   return (Point);
}


void D_M_04::SetLots(double dLos)
{
   g_dLots = dLos * 1;
}


void D_M_04::MFMainProcess()
{
   MFOrder();
}
