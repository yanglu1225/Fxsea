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

// 爆利加仓


#include "BaseDefine.mqh"
#include "BaseFunction.mqh"
#include "MFSendMail2.mqh"




class D_W_02
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
      int g_OpenCount;
      OpenType g_OpenType;
      OpenValid g_OpenValid;
      
      PriceArea g_PriceArea;
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
      
      D_BaseFunction BaseFunction;
      
   public:
      D_W_02();
      ~D_W_02();
      
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
      void Closed(Trend trend);
      bool NeedOpenOrder(OpenType type, int mode, bool& isDouble);
      void OpenPermission();
      void ClosePermission();
      
};



D_W_02::D_W_02(void)
{
   g_dLots = 0.01;                        // 开仓手数
   g_iSlippage = 5;                       // 滑点
   g_iMagic = 20151125;
   g_iWR_Period               = 13;
   g_iWR_HighMax              = -20;
   g_iWR_LowMax               = -80;
   g_iWR_HighSign             = -20;
   g_iWR_LowSign              = -80;
   
   g_PriceArea                = PA_NULL;
   
   g_MainTrend                = T_NULL;
   g_CurTrend                 = T_NULL;
   
   timeframe                  = PERIOD_D1;
   
   g_name = ""; 
   g_OpenCount = 0;
   g_OpenType = OT_NULL;
   g_OpenValid = OV_NULL; 
   
   g_ticket = -1;                         // 开仓的订单号
   g_bPermission = true;
   g_bNeedStopLoss = false;
   g_bNeedTrend = false;
   
   g_sMsgTitle = " , Equity is ";
   g_sMsgContent = "";
}

D_W_02::~D_W_02(void)
{

}



bool D_W_02::OpenBuy()
{
   if(!BaseFunction.AvailableLots(g_name, OP_BUY, g_dLots, 0.6, 250))
   {
      return false;
   }
   
   g_ticket = OrderSend(g_name,OP_BUY,g_dLots,Ask,g_iSlippage,0,0,"",g_iMagic,0,Blue);
            
   if(g_ticket >= 0)
   {
      g_OpenCount += 1;
      g_PriceArea = PA_NULL;

      return true;
   }
   else
   {
      return false;
   }
}

bool D_W_02::OpenSell()
{
   if(!BaseFunction.AvailableLots(g_name, OP_SELL, g_dLots, 0.6, 250))
   {
      return false;
   }
   
   g_ticket = OrderSend(g_name,OP_SELL,g_dLots,Bid,g_iSlippage,0,0,"",g_iMagic,0,Red);
            
   if(g_ticket >= 0)
   { 
      g_OpenCount += 1;
      g_PriceArea = PA_NULL;

      return true;
   }
   else
   {
      return false;
   }
}

bool D_W_02::CloseBuy()
{
   int iIndex = 0;
   int i = 0;
   int iOrderCount = OrdersTotal();
   
   while(iOrderCount > 0)
   {
      if(iIndex == g_OpenCount)
      {
         break;
      }
      
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) == false)
      {
         i += 1;
         continue;
      }
      
      if(OrderMagicNumber() == g_iMagic)
      {
         int iTicket = OrderTicket();
         int iType = OrderType();
         double fLots = OrderLots();
         
         if(iType == OP_BUY)
         {
            while(true)
            {
               if(OrderClose(iTicket,fLots,Bid,g_iSlippage,White))
               { 
                  iIndex += 1;
                  iOrderCount -= 1;
                  
                  break;
               }
               else
               {
                  continue;
               }
            }
         }
         else
         {
            i += 1;
         }
      }
      else
      {
         i += 1;
      }
   }
   
   g_MainTrend = T_NULL;
   g_CurTrend  = T_NULL;
   g_ticket    = -1;
   
   if(iIndex > 0 && iIndex == g_OpenCount)
   {
      g_OpenCount = 0;
      g_PriceArea = PA_NULL;
      return true;
   }
   
   return false;
}

bool D_W_02::CloseSell()
{
   int iIndex = 0;
   int i = 0;
   int iOrderCount = OrdersTotal();
   
   while(iOrderCount > 0)
   {
      if(iIndex == g_OpenCount)
      {
         break;
      }
      
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) == false)
      {
         i += 1;
         continue;
      }
      
      if(OrderMagicNumber() == g_iMagic)
      {
         int iTicket = OrderTicket();
         int iType = OrderType();
         double fLots = OrderLots();
         
         if(iType == OP_SELL)
         {
            while(true)
            {
               if(OrderClose(iTicket,fLots,Ask,g_iSlippage,White))
               { 
                  iIndex += 1;
                  iOrderCount -= 1;
                  
                  break;
               }
               else
               {
                  continue;
               }
            }
         }
         else
         {
            i += 1;
         }
      }
      else
      {
         i += 1;
      }
   }

   g_MainTrend = T_NULL;
   g_CurTrend  = T_NULL;
   g_ticket    = -1;
   
   if(iIndex > 0 && iIndex == g_OpenCount)
   {
      g_OpenCount = 0;
      g_PriceArea = PA_NULL;
      return true;
   }
   
   return false;
}


void D_W_02::SetOpenSignal()
{
   g_PriceArea = PA_NULL;
}


// 判断是否在低位或高位
void D_W_02::CheckWR(double fWR)
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
}


// 更新限定区域内的高位或低位价格，作为阻力位或支撑位
void D_W_02::CheckLimitPrice()
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
bool D_W_02::NeedOpenOrder(OpenType type, int mode, bool& isDouble)
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

void D_W_02::OpenPermission()
{
   g_bPermission = true;
}

void D_W_02::ClosePermission()
{
   g_bPermission = false;
}


void D_W_02::Closed(Trend trend)
{
   while(true)
   {
      if(trend == T_RISE)
      {
         if(CloseBuy())
         {
            g_OpenType = OT_NULL;
            g_OpenValid = OV_NULL;
            g_PriceArea = PA_NULL;
            
            string sMsgTitle = "D_W_02: Stop BUY";
            Print(sMsgTitle); // 提醒
            sMsgTitle = StringConcatenate(sMsgTitle, g_sMsgTitle); 
            g_SendMail.SendMailToFxseaServer(sMsgTitle, g_sMsgContent);
            
            return;
         }
      }
         
      if(trend == T_DECREASE)
      {
         if(CloseSell())
         {
            g_OpenType = OT_NULL;
            g_OpenValid = OV_NULL;
            g_PriceArea = PA_NULL;
            
            string sMsgTitle = "D_W_02: Stop SELL";
            Print(sMsgTitle); // 提醒
            sMsgTitle = StringConcatenate(sMsgTitle, g_sMsgTitle); 
            g_SendMail.SendMailToFxseaServer(sMsgTitle, g_sMsgContent);
            
            return;
         }
      }
   
      return;
   }
}


void D_W_02::MFOrder()
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
   //CheckLimitPrice();            // 更新限定区域内的高位或低位价格，作为阻力位或支撑位
   

   //------------------------------------------------------------------------------------------------------------
   while(true)
   {
      //=================================================================//
      // 如果主趋势上升，当前趋势上升，只做低买高卖
      if(g_MainTrend == T_RISE && g_CurTrend == T_RISE)
      {
         g_OpenType = OT_NULL;
         
         //#########################################################//
         // 开仓多单
         if(g_bPermission && g_PriceArea == PA_Low && dWR > g_iWR_LowSign)
         {
            if(OpenBuy())
            {
               string sMsgTitle = "D_W_02: Open BUY";
               Print(sMsgTitle); // 提醒
               sMsgTitle = StringConcatenate(sMsgTitle, g_sMsgTitle); 
               g_SendMail.SendMailToFxseaServer(sMsgTitle, g_sMsgContent);
         
               return;
            }
         }
         //#########################################################//
         
      }
      //=================================================================//
   
   
      //=================================================================//
      // 如果主趋势下降，当前趋势下降，只做高卖低买
      if(g_MainTrend == T_DECREASE && g_CurTrend == T_DECREASE)
      {
         g_OpenType = OT_NULL;
         
         //#########################################################//
         // 开仓空单
         if(g_bPermission && g_PriceArea == PA_High && dWR < g_iWR_HighSign)
         {
            if(OpenSell())
            {
               string sMsgTitle = "D_W_02: Open SELL";
               Print(sMsgTitle); // 提醒
               sMsgTitle = StringConcatenate(sMsgTitle, g_sMsgTitle); 
               g_SendMail.SendMailToFxseaServer(sMsgTitle, g_sMsgContent);
               
               return;
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
         {
            // 平仓空单
            if(CloseSell())
            {
               g_OpenType = OT_NULL;
               
               string sMsgTitle = "D_W_02: Stop SELL";
               Print(sMsgTitle); // 提醒
               sMsgTitle = StringConcatenate(sMsgTitle, g_sMsgTitle); 
               g_SendMail.SendMailToFxseaServer(sMsgTitle, g_sMsgContent);
            }
         }
         
         
         {
            // 平仓多单
            if(CloseBuy())
            {
               g_OpenType = OT_NULL;
               
               string sMsgTitle = "D_W_02: Stop BUY";
               Print(sMsgTitle); // 提醒
               sMsgTitle = StringConcatenate(sMsgTitle, g_sMsgTitle); 
               g_SendMail.SendMailToFxseaServer(sMsgTitle, g_sMsgContent);
            }
            
         }
      }
      //=================================================================//
     
   
      return;
   }
                 
   
}


void D_W_02::MFMainProcess()
{
   MFOrder();
}

double D_W_02::PointValue() 
{
   if (MarketInfo(Symbol(), MODE_DIGITS) == 5.0 || MarketInfo(Symbol(), MODE_DIGITS) == 3.0) return (10.0 * Point);
   return (Point);
}