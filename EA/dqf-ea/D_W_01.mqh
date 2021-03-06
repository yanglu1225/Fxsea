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
#include "MFSendMail2.mqh"




class D_W_01
{
   public:
      double   g_dLots;                      // 开仓手数
      int      g_iSlippage;                  // 滑点
      int      g_iMagic;
      int      g_iWR_Period;
      int      g_iWR_HighMax;
      int      g_iWR_LowMax;
      int      g_iWR_HighSign;
      int      g_iWR_LowSign;
      
   public:
      string g_name; 
      int timeframe;                       // 时间周期
      OpenType g_OpenType;
      OpenValid g_OpenValid;
      
      PriceArea g_PriceArea;
      PriceArea g_PriceArea_EX;
      
      double g_fHighPrice;                // 区域内高位价格
      double g_fLowPrice;                 // 区域内低位价格
      
      Trend g_MainTrend;                  // 主趋势
      Trend g_CurTrend;                   // 当前趋势

      int g_ticket;                       // 开仓的订单号
      bool g_bPermission;                 // 开仓权限  
      bool g_bNeedStopLoss;               // 止损权限 
      bool g_bNeedTrend;                  // 顺势开仓权限
      
      MFSendMail g_SendMail;
      string g_sMsgTitle;
      string g_sMsgContent;
      
   public:
      D_W_01();
      ~D_W_01();
      
   public:
      void MFMainProcess();
      
      void MFOrder();
      bool OpenBuy();
      bool OpenSell();
      bool CloseBuy();
      bool CloseSell();

      double PointValue();
      void CheckWR(double fWR);
      void CheckLimitPrice();
      void SetOpenSignal();
      void Closed();
      bool NeedOpenOrder(OpenType type, int mode, bool& isDouble);
      
};



D_W_01::D_W_01(void)
{
   g_dLots = 0.01;                        // 开仓手数
   g_iSlippage = 5;                       // 滑点
   g_iMagic = 20151116;
   g_iWR_Period               = 13;
   g_iWR_HighMax              = -20;
   g_iWR_LowMax               = -80;
   g_iWR_HighSign             = -20;
   g_iWR_LowSign              = -80;
   
   g_PriceArea                = PA_NULL;
   g_PriceArea_EX             = PA_NULL;
   
   g_MainTrend                = T_NULL;
   g_CurTrend                 = T_NULL;
   
   timeframe                  = PERIOD_D1;
   
   g_name = ""; 
   g_OpenType = OT_NULL;
   g_OpenValid = OV_NULL; 
   
   g_ticket = -1;                         // 开仓的订单号
   g_bPermission = false;
   g_bNeedStopLoss = false;
   g_bNeedTrend = false;
   
   g_sMsgTitle = " , Equity is ";
   g_sMsgContent = "";
}

D_W_01::~D_W_01(void)
{

}



bool D_W_01::OpenBuy()
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
      g_PriceArea = PA_NULL;
      g_PriceArea_EX = PA_NULL;

      return true;
   }
   else
   {
      return false;
   }
}

bool D_W_01::OpenSell()
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
      g_PriceArea = PA_NULL;
      g_PriceArea_EX = PA_NULL;

      return true;
   }
   else
   {
      return false;
   }
}

bool D_W_01::CloseBuy()
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
      
      return true;
   }
   else
   {
      return false;
   }
}

bool D_W_01::CloseSell()
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
      
      return true;
   }
   else
   {
      return false;
   }
}


void D_W_01::SetOpenSignal()
{
   g_PriceArea = PA_NULL;
   g_PriceArea_EX = PA_NULL;
}


// 判断是否在低位或高位
void D_W_01::CheckWR(double fWR)
{
   if(fWR > g_iWR_HighMax)
   {
      if(g_PriceArea != PA_High)
      {
         g_fHighPrice = iHigh(g_name,timeframe,0);
      }
      g_PriceArea = PA_High;
   }
   
   if(fWR < g_iWR_LowMax)
   {
      if(g_PriceArea != PA_Low)
      {
         g_fLowPrice = iLow(g_name,timeframe,0);
      }
      g_PriceArea = PA_Low;
   }
   
   //----------------------------------------------------------//
   // 用于平仓信号
   if(fWR > g_iWR_HighSign)
   {
      g_PriceArea_EX = PA_High;
   }
   
   if(fWR < g_iWR_LowSign)
   {
      g_PriceArea_EX = PA_Low;
   }
}


// 更新限定区域内的高位或低位价格，作为阻力位或支撑位
void D_W_01::CheckLimitPrice()
{
   if(g_PriceArea == PA_Low)
   {
      if(g_fLowPrice > iLow(g_name,timeframe,1))
      {
         g_fLowPrice = iLow(g_name,timeframe,1);
      }
   }
   
   if(g_PriceArea == PA_High)
   {
      if(g_fHighPrice < iHigh(g_name,timeframe,1))
      {
         g_fHighPrice = iHigh(g_name,timeframe,1);
      }
   }
}


// mode  0: 大趋势与当前趋势 相反，不建议开单
//       1: 大趋势与当前趋势 相同，建议开单
bool D_W_01::NeedOpenOrder(OpenType type, int mode, bool& isDouble)
{
   if(g_ticket < 0)
   {
      return true;
   }
   
   double dProfit = 0;
   if(OrderSelect(g_ticket,SELECT_BY_TICKET,MODE_TRADES))
   {
      dProfit = OrderProfit();
   }
   
   if(type == OT_BUY)
   {
      if(g_OpenType == OT_BUY)
      {
         if(dProfit > 0)
         {
            return true;
         }
         else
         {
            return false;
         }
      }
      
      if(g_OpenType == OT_SELL)
      {
         if(dProfit > 0)
         {
            return false;
         }
         else
         {
            isDouble = true;
            return true;
         }
      }
   }
   
   if(type == OT_SELL)
   {
      if(g_OpenType == OT_SELL)
      {
         if(dProfit > 0)
         {
            return true;
         }
         else
         {
            return false;
         }
      }
      
      if(g_OpenType == OT_BUY)
      {
         if(dProfit > 0)
         {
            return false;
         }
         else
         {
            isDouble = true;
            return true;
         }
      }
   }
   
   if(mode == 0)
   {
      return false;
   }
   
   return true;
}


void D_W_01::Closed()
{
   while(true)
   {
      if(g_OpenType == OT_BUY && g_OpenValid == OV_Valid)
      {
         if(CloseBuy())
         {
            g_PriceArea = PA_NULL;
            g_PriceArea_EX = PA_NULL;
            
            string sMsgTitle = "D_W_01: Stop BUY";
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
         
      if(g_OpenType == OT_SELL && g_OpenValid == OV_Valid)
      {
         if(CloseSell())
         {
            g_PriceArea = PA_NULL;
            g_PriceArea_EX = PA_NULL;
            
            string sMsgTitle = "D_W_01: Stop SELL";
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
   
      return;
   }
}


void D_W_01::MFOrder()
{
   if(Bars < 3)
   {
      return;
   }

   g_sMsgContent = "";
   
   //------------------------------------------------------------------------------------------------------------ 
   
   double dWR = iWPR(g_name,timeframe,g_iWR_Period,1);                                 
   
   //------------------------------------------------------------------------------------------------------------ 
   
   CheckWR(dWR);                 // 判断是否在低位或高位
   CheckLimitPrice();            // 更新限定区域内的高位或低位价格，作为阻力位或支撑位
   

   //------------------------------------------------------------------------------------------------------------
   while(true)
   {
      //=================================================================//
      // 如果主趋势上升，当前趋势上升，只做低买高卖
      if(g_MainTrend == T_RISE && g_CurTrend == T_RISE)
      {
         //#########################################################//
         // 止损 多单
         if(g_bNeedStopLoss && (Ask < g_fLowPrice && dWR < g_iWR_LowSign))
         {
            if(g_OpenType == OT_BUY && g_OpenValid == OV_Valid)
            {
               if(CloseBuy())
               {
                  string sMsgTitle = "D_W_01: Stop BUY";
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
         //#########################################################//
         
         //#########################################################//
         // 平仓空单
         if(g_PriceArea_EX == PA_Low && dWR > g_iWR_LowSign)
         {
            if(g_OpenType == OT_SELL && g_OpenValid == OV_Valid)
            {
               if(CloseSell())
               {
                  string sMsgTitle = "D_W_01: Stop SELL";
                  Print(sMsgTitle); // 提醒
                  sMsgTitle = StringConcatenate(sMsgTitle, g_sMsgTitle); 
                  g_SendMail.SendMailToFxseaServer(sMsgTitle, g_sMsgContent);
               }
               else
               {
                  continue;
               }
            }
         }
         
         // 开仓多单
         if(g_PriceArea == PA_Low && dWR > g_iWR_LowSign)
         {
            if(g_bPermission && g_OpenType == OT_NULL && g_OpenValid == OV_NULL)
            {
               if(OpenBuy())
               {
                  string sMsgTitle = "D_W_01: Open BUY";
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
         //#########################################################//
         
         //#########################################################//
         // 平仓多单
         if(g_PriceArea_EX == PA_High && dWR < g_iWR_HighSign)
         {
            if(g_OpenType == OT_BUY && g_OpenValid == OV_Valid)
            {
               if(CloseBuy())
               {
                  string sMsgTitle = "D_W_01: Stop BUY";
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
         //#########################################################//
         
      }
      //=================================================================//
   
   
      //=================================================================//
      // 如果主趋势下降，当前趋势下降，只做高卖低买
      if(g_MainTrend == T_DECREASE && g_CurTrend == T_DECREASE)
      {
         //#########################################################//
         // 止损 空单
         if(g_bNeedStopLoss && (Bid > g_fHighPrice && dWR > g_iWR_HighSign))
         {
            if(g_OpenType == OT_SELL && g_OpenValid == OV_Valid)
            {
               if(CloseSell())
               {
                  string sMsgTitle = "D_W_01: Stop SELL";
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
         //#########################################################//
         
         //#########################################################//
         // 平仓多单
         if(g_PriceArea_EX == PA_High && dWR < g_iWR_HighSign)
         {
            if(g_OpenType == OT_BUY && g_OpenValid == OV_Valid)
            {
               if(CloseBuy())
               {
                  string sMsgTitle = "D_W_01: Stop BUY";
                  Print(sMsgTitle); // 提醒
                  sMsgTitle = StringConcatenate(sMsgTitle, g_sMsgTitle); 
                  g_SendMail.SendMailToFxseaServer(sMsgTitle, g_sMsgContent);
               }
               else
               {
                  continue;
               }
            }
         }
         
         // 开仓空单
         if(g_PriceArea == PA_High && dWR < g_iWR_HighSign)
         {   
            if(g_bPermission && g_OpenType == OT_NULL && g_OpenValid == OV_NULL)
            {
               if(OpenSell())
               {
                  string sMsgTitle = "D_W_01: Open SELL";
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
         //#########################################################//
         
         //#########################################################//
         // 平仓空单
         if(g_PriceArea_EX == PA_Low && dWR > g_iWR_LowSign)
         {
            if(g_OpenType == OT_SELL && g_OpenValid == OV_Valid)
            {
               if(CloseSell())
               {
                  string sMsgTitle = "D_W_01: Stop SELL";
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
         //#########################################################//
         
      }
      //=================================================================//
   
   
      //=================================================================//
      // 如果主趋势上升，当前趋势下降，低买高卖，高卖低买
      // 如果主趋势下降，当前趋势上升，低买高卖，高卖低买
      if(g_MainTrend != T_NULL && g_CurTrend != T_NULL && g_MainTrend != g_CurTrend)
      {
         //#########################################################//
         // 止损 多单
         if(g_bNeedStopLoss && (Ask < g_fLowPrice && dWR < g_iWR_LowSign))
         {
            if(g_OpenType == OT_BUY && g_OpenValid == OV_Valid)
            {
               if(CloseBuy())
               {
                  string sMsgTitle = "D_W_01: Stop BUY";
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
         //#########################################################//
         
         //#########################################################//
         // 止损 空单
         if(g_bNeedStopLoss && (Bid > g_fHighPrice && dWR > g_iWR_HighSign))
         {
            if(g_OpenType == OT_SELL && g_OpenValid == OV_Valid)
            {
               if(CloseSell())
               {
                  string sMsgTitle = "D_W_01: Stop SELL";
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
         //#########################################################//
         
         if(g_PriceArea_EX == PA_Low && dWR > g_iWR_LowSign)
         {
            // 平仓空单
            if(g_OpenType == OT_SELL && g_OpenValid == OV_Valid)
            {
               if(CloseSell())
               {
                  string sMsgTitle = "D_W_01: Stop SELL";
                  Print(sMsgTitle); // 提醒
                  sMsgTitle = StringConcatenate(sMsgTitle, g_sMsgTitle); 
                  g_SendMail.SendMailToFxseaServer(sMsgTitle, g_sMsgContent);
               }
               else
               {
                  continue;
               }
            }
         }
            
         if(g_PriceArea == PA_Low && dWR > g_iWR_LowSign)
         {
            // 开仓多单
            if(g_bPermission && g_OpenType == OT_NULL && g_OpenValid == OV_NULL)
            {
               if(OpenBuy())
               {
                  string sMsgTitle = "D_W_01: Open BUY";
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
         
         
         if(g_PriceArea_EX == PA_High && dWR < g_iWR_HighSign)
         {
            // 平仓多单
            if(g_OpenType == OT_BUY && g_OpenValid == OV_Valid)
            {
               if(CloseBuy())
               {
                  string sMsgTitle = "D_W_01: Stop BUY";
                  Print(sMsgTitle); // 提醒
                  sMsgTitle = StringConcatenate(sMsgTitle, g_sMsgTitle); 
                  g_SendMail.SendMailToFxseaServer(sMsgTitle, g_sMsgContent);
               }
               else
               {
                  continue;
               }
            }
         }
            
         if(g_PriceArea == PA_High && dWR < g_iWR_HighSign)
         {
            // 开仓空单
            if(g_bPermission && g_OpenType == OT_NULL && g_OpenValid == OV_NULL)
            {
               if(OpenSell())
               {
                  string sMsgTitle = "D_W_01: Open SELL";
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
      //=================================================================//
     
   
      return;
   }
                 
   
}


void D_W_01::MFMainProcess()
{
   MFOrder();
}

double D_W_01::PointValue() 
{
   if (MarketInfo(Symbol(), MODE_DIGITS) == 5.0 || MarketInfo(Symbol(), MODE_DIGITS) == 3.0) return (10.0 * Point);
   return (Point);
}