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




class D_W_04
{
   public:
      double   g_dLots;                      // 开仓手数
      int      g_iSlippage;                  // 滑点
      int      g_iMagic;
      int      g_iMovingShift;
      int      g_iMA_Period;
      double   g_fStopProfitFactor;
      
   public:
      string g_name; 
      int timeframe;                       // 时间周期
      OpenType g_OpenType;
      OpenValid g_OpenValid;
      
      Trend g_MainTrend;                  // 主趋势
      Trend g_CurTrend;                   // 当前趋势

      int g_ticket;                          // 开仓的订单号
      bool g_bPermission;                    // 开仓权限  
      
      double g_fIncreasePoint;               // 最小点数间隔
      double g_fMaxProfit;                   // 最大赢利点起数
      double g_fMaxPrice;                    // 最大赢利价格
      double g_fStopProfit;                  // 止赢价格
      bool   g_bSetStopPrice;                // 是否开始止损价
      
      bool g_bOpenBuy;
      bool g_bOpenSell;
      
      MFSendMail g_SendMail;
      string g_sMsgTitle;
      string g_sMsgContent;
      
   public:
      D_W_04();
      ~D_W_04();
      
   public:
      void MFMainProcess();
      void MFClose();
      
      void MFOrder();
      bool OpenBuy();
      bool OpenSell();
      bool CloseBuy();
      bool CloseSell();

      string GetTimeframeName(string sMsgTitle);
      void GetMaxProfit();
      void CheckPrice();
      double PointValue();
      void Closed();
      void SetOpenBuy();
      void SetOpenSell();
      
};



D_W_04::D_W_04(void)
{
   g_dLots = 0.01;                        // 开仓手数
   g_iSlippage = 5;                       // 滑点
   g_iMagic = 20151018;
   g_iMovingShift = 0;
   g_iMA_Period               = 35;
   g_fStopProfitFactor        = 0.1;
   
   
   timeframe                  = PERIOD_D1;
   
   g_name = ""; 
   g_OpenType = OT_NULL;
   g_OpenValid = OV_NULL;  
   
   g_MainTrend                = T_NULL;
   g_CurTrend                 = T_NULL;
   
   g_bOpenBuy = false;
   g_bOpenSell = false;
   
   g_bSetStopPrice = false;
   
   g_ticket = -1;                         // 开仓的订单号
   g_bPermission = false;
   g_fStopProfit = 0;
   
   g_sMsgTitle = " , Equity is ";
   g_sMsgContent = "";
}

D_W_04::~D_W_04(void)
{

}



bool D_W_04::OpenBuy()
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
      g_fStopProfit = Ask;
      g_bSetStopPrice = false;
      
      g_bOpenBuy = false;
      g_bOpenSell = false;
      
      GetMaxProfit();

      return true;
   }
   else
   {
      return false;
   }
}

bool D_W_04::OpenSell()
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
      g_fStopProfit = Bid;
      g_bSetStopPrice = false;
      
      g_bOpenBuy = false;
      g_bOpenSell = false;
      
      GetMaxProfit();

      return true;
   }
   else
   {
      return false;
   }
}

bool D_W_04::CloseBuy()
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
      g_bSetStopPrice = false;
      
      g_bOpenBuy = false;
      g_bOpenSell = false;
      
      GetMaxProfit();
      
      return true;
   }
   else
   {
      return false;
   }
}

bool D_W_04::CloseSell()
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
      g_bSetStopPrice = false;
      
      g_bOpenBuy = false;
      g_bOpenSell = false;
      
      GetMaxProfit();
      
      return true;
   }
   else
   {
      return false;
   }
}

void D_W_04::SetOpenBuy()
{
   g_bOpenBuy = true;
}

void D_W_04::SetOpenSell()
{
   g_bOpenSell = true;
}


string D_W_04::GetTimeframeName(string sMsgTitle)
{
   string sTimeName = " ---- ";
   
   if(timeframe == PERIOD_M30)
   {
      sTimeName = StringConcatenate(sTimeName, "[M30]"); 
   }
   else if(timeframe == PERIOD_H1)
   {
      sTimeName = StringConcatenate(sTimeName, "[H1]"); 
   }
   else if(timeframe == PERIOD_H4)
   {
      sTimeName = StringConcatenate(sTimeName, "[H4]"); 
   }
   else if(timeframe == PERIOD_D1)
   {
      sTimeName = StringConcatenate(sTimeName, "[D1]"); 
   }
   
   sMsgTitle = StringConcatenate(sMsgTitle, sTimeName); 
   return sMsgTitle;
}


void D_W_04::GetMaxProfit()
{
   g_fIncreasePoint = 20;
   if(timeframe == PERIOD_M30)
   {
      g_fIncreasePoint = 30;
   }
   else if(timeframe == PERIOD_H1)
   {
      g_fIncreasePoint = 60;
   }
   else if(timeframe == PERIOD_H4)
   {
      g_fIncreasePoint = 120;
   }
   else if(timeframe == PERIOD_D1)
   {
      g_fIncreasePoint = 500;
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


void D_W_04::CheckPrice()
{
   
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
}



void D_W_04::Closed()
{
   while(true)
   {
      if(g_OpenType == OT_BUY && g_OpenValid == OV_Valid)
      {
         if(CloseBuy())
         {
            string sMsgTitle = "D_W_04: Stop BUY";
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
            string sMsgTitle = "D_W_04: Stop SELL";
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



void D_W_04::MFOrder()
{
   if(Bars < 3)
   {
      return;
   }

   g_sMsgContent = "";
   
   //------------------------------------------------------------------------------------------------------------ 
                     
   double C_0 = iClose(g_name,timeframe,1);
   double C_1 = iClose(g_name,timeframe,2);
                  
   double D_K_0 = iMA(g_name,timeframe,g_iMA_Period,g_iMovingShift,MODE_SMA,PRICE_CLOSE,1);// 35日  1 柱  
   double D_K_1 = iMA(g_name,timeframe,g_iMA_Period,g_iMovingShift,MODE_SMA,PRICE_CLOSE,2);// 35日  2 柱  
  
   
   if(D_K_0 < 0.0001 || D_K_1 < 0.0001)
   {
      return;
   }
   
   //------------------------------------------------------------------------------------------------------------ 
   
   //CheckPrice();
   
   
   //------------------------------------------------------------------------------------------------------------
   while(true)
   {
      //=================================================================//
      // 强制 开仓多单
      if(g_bOpenBuy)
      {
         if(g_bPermission && g_OpenType == OT_NULL && g_OpenValid == OV_NULL)
         {
            if(OpenBuy())
            {
               string sMsgTitle = "D_W_04: Open BUY";
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
      
      // 强制 开仓空单
      if(g_bOpenSell)
      {
         if(g_bPermission && g_OpenType == OT_NULL && g_OpenValid == OV_NULL)
         {
            if(OpenSell())
            {
               string sMsgTitle = "D_W_04: Open SELL";
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
      //=================================================================//
      
      //=================================================================//
      // 如果主趋势上升，当前趋势上升，只做低买高卖
      if(g_MainTrend == T_RISE && g_CurTrend == T_RISE)
      {
         //#########################################################//
         // 止赢 平仓多单
         if(g_bSetStopPrice && Bid < g_fStopProfit && g_OpenType == OT_BUY && g_OpenValid == OV_Valid)
         {
            if(CloseBuy())
            {
               string sMsgTitle = "D_M_04: Stop Profit Close BUY";
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
         //#########################################################//
         
         //#########################################################//
         // 开仓多单
         if(C_1 < D_K_1 && C_0 > D_K_0)
         {
            if(g_OpenType == OT_SELL && g_OpenValid == OV_Valid)
            {
               if(CloseSell())
               {
                  string sMsgTitle = "D_W_04: Stop SELL";
                  Print(sMsgTitle); // 提醒
                  sMsgTitle = StringConcatenate(sMsgTitle, g_sMsgTitle); 
                  g_SendMail.SendMailToFxseaServer(sMsgTitle, g_sMsgContent);
               }
               else
               {
                  continue;
               }
            }
            
            if(g_bPermission && g_OpenType == OT_NULL && g_OpenValid == OV_NULL)
            {
               if(OpenBuy())
               {
                  string sMsgTitle = "D_W_04: Open BUY";
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
         if(C_1 > D_K_1 && C_0 < D_K_0)
         {
            if(g_OpenType == OT_BUY && g_OpenValid == OV_Valid)
            {
               if(CloseBuy())
               {
                  string sMsgTitle = "D_W_04: Stop BUY";
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
         // 止赢 平仓空单
         if(g_bSetStopPrice && Ask > g_fStopProfit && g_OpenType == OT_SELL && g_OpenValid == OV_Valid)
         {
            if(CloseSell())
            {
               string sMsgTitle = "D_M_04: Stop Profit Close SELL";
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
         //#########################################################//
         
         //#########################################################//
         // 开仓空单
         if(C_1 > D_K_1 && C_0 < D_K_0)
         {
            if(g_OpenType == OT_BUY && g_OpenValid == OV_Valid)
            {
               if(CloseBuy())
               {
                  string sMsgTitle = "D_W_04: Stop BUY";
                  Print(sMsgTitle); // 提醒
                  sMsgTitle = StringConcatenate(sMsgTitle, g_sMsgTitle); 
                  g_SendMail.SendMailToFxseaServer(sMsgTitle, g_sMsgContent);
               }
               else
               {
                  continue;
               }
            }
            
            if(g_bPermission && g_OpenType == OT_NULL && g_OpenValid == OV_NULL)
            {
               if(OpenSell())
               {
                  string sMsgTitle = "D_W_04: Open SELL";
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
         if(C_1 < D_K_1 && C_0 > D_K_0)
         {
            if(g_OpenType == OT_SELL && g_OpenValid == OV_Valid)
            {
               if(CloseSell())
               {
                  string sMsgTitle = "D_W_04: Stop SELL";
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
      if(g_MainTrend != g_CurTrend)
      {
         // 平仓多单
         if(g_OpenType == OT_BUY && g_OpenValid == OV_Valid)
         {
            if(CloseBuy())
            {
               string sMsgTitle = "D_W_04: Stop BUY";
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
            
         // 平仓空单
         if(g_OpenType == OT_SELL && g_OpenValid == OV_Valid)
         {
            if(CloseSell())
            {
               string sMsgTitle = "D_W_04: Stop SELL";
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
      //=================================================================//
     
   
      return;

   }
                 
   
}


// 退出时，平仓
void D_W_04::MFClose()
{
   //while(true)
   {
      if(g_OpenType == OT_BUY && g_OpenValid == OV_Valid)
      {
         if(CloseBuy())
         {
            Print("2: Close BUY."); // 提醒
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
            Print("2: Close SELL."); // 提醒
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


void D_W_04::MFMainProcess()
{
   MFOrder();
}

double D_W_04::PointValue() 
{
   if (MarketInfo(Symbol(), MODE_DIGITS) == 5.0 || MarketInfo(Symbol(), MODE_DIGITS) == 3.0) return (10.0 * Point);
   return (Point);
}