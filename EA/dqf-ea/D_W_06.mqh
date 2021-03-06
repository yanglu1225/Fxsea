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

// 马丁格尔策略


#include "BaseDefine.mqh"
#include "BaseFunction.mqh"
#include "MFSendMail2.mqh"


struct ResultDW06
{
   int OpenCount_buy;
   int OpenCount_sell;
   datetime OpenBuyTime;
   datetime OpenSellTime;
};


class D_W_06
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
      int g_OpenCount_buy;
      int g_OpenCount_sell;
      datetime g_OpenBuyTime;
      datetime g_OpenSellTime;
   
      OpenType g_OpenType;
      OpenValid g_OpenValid;
      
      PriceArea g_PriceArea;
      PriceArea g_PriceArea_EX;
      
      Trend g_MainTrend;                     // 主趋势
      Trend g_CurTrend;                      // 当前趋势

      int g_ticket;                          // 开仓的订单号
      
      bool g_bPermission;                    // 开仓权限  
      int g_iCorrect;                        // 正确次数
      
      bool g_bOpenBuy;
      bool g_bOpenSell;
      
      MFSendMail g_SendMail;
      string g_sMsgTitle;
      string g_sMsgContent;
      
      D_BaseFunction BaseFunction;
      
      string g_sFileName;
      ResultDW06 g_Result;
      
   public:
      D_W_06();
      ~D_W_06();
      
   public:
      void MFMainProcess();
      
      void MFOrder();
      bool OpenBuy();
      bool OpenSell();
      bool CloseBuy();
      bool CloseSell();

      void CheckWR(double fWR);
      void CheckPoint();
      double PointValue();
      void Closed(Trend trend);
      
      void OpenPermission();
      void ClosePermission();
      
      void Save();
      void Load();
};



D_W_06::D_W_06(void)
{
   g_dLots = 0.01;                        // 开仓手数
   g_iSlippage = 5;                       // 滑点
   g_iMagic = 20151208;
   g_iWR_Period               = 21;
   g_iWR_HighMax              = -10;
   g_iWR_LowMax               = -90;
   g_iWR_HighSign             = -20;
   g_iWR_LowSign              = -80;
   
   g_PriceArea                = PA_NULL;
   g_PriceArea_EX             = PA_NULL;
   
   timeframe                  = PERIOD_D1;
   
   g_name = "";  
   g_OpenCount_buy = 0;
   g_OpenCount_sell = 0;
      
   g_OpenType = OT_NULL;
   g_OpenValid = OV_NULL;
   
   g_MainTrend                = T_NULL;
   g_CurTrend                 = T_NULL;
   
   g_bOpenBuy = false;
   g_bOpenSell = false;
 
   g_ticket = -1;                      // 开仓的订单号
      
   g_bPermission = false;
   
   g_sMsgTitle = " , Equity is ";
   g_sMsgContent = "";
   
   g_sFileName = "SAV_DM_DW06.txt";
   
   g_Result.OpenCount_buy = 0;
   g_Result.OpenCount_sell = 0;

}

D_W_06::~D_W_06(void)
{

}



bool D_W_06::OpenBuy()
{
   // 必须空单平仓后，才能开多单
   if(g_OpenType == OT_SELL)
   {
      return false;
   }
   
   if(iTime(g_name,timeframe,1) <= g_OpenBuyTime)
   {
      return false;
   }
   
   if(!BaseFunction.AvailableLots(g_name, OP_BUY, g_dLots, 0.6, 400))
   {
      return false;
   }
   
   g_ticket = OrderSend(g_name,OP_BUY,g_dLots,Ask,g_iSlippage,0,0,"",g_iMagic,0,Blue);
            
   if(g_ticket >= 0)
   {
      g_OpenCount_buy += 1;
      g_OpenBuyTime = iTime(g_name,timeframe,1);
      
      g_OpenType = OT_BUY;
      g_OpenValid = OV_Valid;
      g_PriceArea = PA_NULL;

      Save();

      return true;
   }
   else
   {
      return false;
   }
}

bool D_W_06::OpenSell()
{
   // 必须多单平仓后，才能开空单
   if(g_OpenType == OT_BUY)
   {
      return false;
   }
   
   if(iTime(g_name,timeframe,1) <= g_OpenSellTime)
   {
      return false;
   }
   
   if(!BaseFunction.AvailableLots(g_name, OP_SELL, g_dLots, 0.6, 400))
   {
      return false;
   }
   
   g_ticket = OrderSend(g_name,OP_SELL,g_dLots,Bid,g_iSlippage,0,0,"",g_iMagic,0,Red);
            
   if(g_ticket >= 0)
   { 
      g_OpenCount_sell += 1;
      g_OpenSellTime = iTime(g_name,timeframe,1);
      
      g_OpenType = OT_SELL;
      g_OpenValid = OV_Valid;
      g_PriceArea = PA_NULL;
      
      Save();

      return true;
   }
   else
   {
      return false;
   }
}

bool D_W_06::CloseBuy()
{
   int iIndex = 0;
   int i = 0;
   int iOrderCount = OrdersTotal();
   
   while(iOrderCount > 0)
   {
      if(iIndex == g_OpenCount_buy)
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
   
   g_ticket    = -1;
   
   if(iIndex > 0 && iIndex == g_OpenCount_buy)
   {
      g_OpenCount_buy = 0;
      g_OpenType = OT_NULL;
      g_OpenValid = OV_NULL;
      
      Save();
      
      return true;
   }
   
   return false;
}

bool D_W_06::CloseSell()
{  
   int iIndex = 0;
   int i = 0;
   int iOrderCount = OrdersTotal();
   
   while(iOrderCount > 0)
   {
      if(iIndex == g_OpenCount_sell)
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

   g_ticket    = -1;
   
   if(iIndex > 0 && iIndex == g_OpenCount_sell)
   {
      g_OpenCount_sell = 0;
      g_OpenType = OT_NULL;
      g_OpenValid = OV_NULL;
      
      Save();
      
      return true;
   }
   
   return false;
}


void D_W_06::Closed(Trend trend)
{
   while(true)
   {
      if(trend == T_RISE)
      {
         if(CloseBuy())
         {
            string sMsgTitle = "D_W_06: Stop BUY";
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
            string sMsgTitle = "D_W_06: Stop SELL";
            Print(sMsgTitle); // 提醒
            sMsgTitle = StringConcatenate(sMsgTitle, g_sMsgTitle); 
            g_SendMail.SendMailToFxseaServer(sMsgTitle, g_sMsgContent);
            
            return;
         }
      }
   
      return;
   }
}


// 判断是否在低位或高位
void D_W_06::CheckWR(double fWR)
{
   /*
   if(fWR > g_iWR_HighMax)
   {
      g_PriceArea = PA_High;
   }
   
   if(fWR < g_iWR_LowMax)
   {
      g_PriceArea = PA_Low;
   }
   */
   
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




void D_W_06::CheckPoint()
{
/*
   if(g_iCorrect == g_ProfitLevel)
   {
      g_iCorrect = g_FirstLevel;
   }
   
   if(g_iCorrect == 0)
   {
      if(g_MainTrend == T_RISE && g_OpenValid == OV_NULL)
      {
         g_dLots_buy = g_dLots * g_MultiArray[0];
         g_dLots_sell = g_dLots;
      }
      if(g_MainTrend == T_DECREASE && g_OpenValid == OV_NULL)
      {
         g_dLots_buy = g_dLots;
         g_dLots_sell = g_dLots * g_MultiArray[0];
      }
   }
   else if(g_iCorrect == 1)
   {
      if(g_MainTrend == T_RISE && g_OpenValid == OV_NULL)
      {
         g_dLots_buy = g_dLots * g_MultiArray[1];
         g_dLots_sell = g_dLots;
      }
      if(g_MainTrend == T_DECREASE && g_OpenValid == OV_NULL)
      {
         g_dLots_buy = g_dLots;
         g_dLots_sell = g_dLots * g_MultiArray[1];
      }
   }
   else if(g_iCorrect == 2)
   {
      if(g_MainTrend == T_RISE && g_OpenValid == OV_NULL)
      {
         g_dLots_buy = g_dLots * g_MultiArray[2];
         g_dLots_sell = g_dLots;
      }
      if(g_MainTrend == T_DECREASE && g_OpenValid == OV_NULL)
      {
         g_dLots_buy = g_dLots;
         g_dLots_sell = g_dLots * g_MultiArray[2];
      }
   }
   else if(g_iCorrect == 3)
   {
      if(g_MainTrend == T_RISE && g_OpenValid == OV_NULL)
      {
         g_dLots_buy = g_dLots * g_MultiArray[3];
         g_dLots_sell = g_dLots;
      }
      if(g_MainTrend == T_DECREASE && g_OpenValid == OV_NULL)
      {
         g_dLots_buy = g_dLots;
         g_dLots_sell = g_dLots * g_MultiArray[3];
      }
   }
   else if(g_iCorrect == 4)
   {
      if(g_MainTrend == T_RISE && g_OpenValid == OV_NULL)
      {
         g_dLots_buy = g_dLots * g_MultiArray[4];
         g_dLots_sell = g_dLots;
      }
      if(g_MainTrend == T_DECREASE && g_OpenValid == OV_NULL)
      {
         g_dLots_buy = g_dLots;
         g_dLots_sell = g_dLots * g_MultiArray[4];
      }
   }
   */
}


void D_W_06::OpenPermission()
{
   g_bPermission = true;
}

void D_W_06::ClosePermission()
{
   g_bPermission = false;
}


void D_W_06::MFOrder()
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
   

   //------------------------------------------------------------------------------------------------------------
   while(true)
   {
      //=================================================================//
      // 如果主趋势上升，当前趋势上升，只做低买高卖
      if(g_MainTrend == T_RISE && g_CurTrend == T_RISE)
      {
         //#########################################################//
         if(g_bPermission)
         {
            // 强制 平仓空单
            if(CloseSell())
            {
               string sMsgTitle = "D_W_06: Stop SELL";
               Print(sMsgTitle); // 提醒
               sMsgTitle = StringConcatenate(sMsgTitle, g_sMsgTitle); 
               g_SendMail.SendMailToFxseaServer(sMsgTitle, g_sMsgContent);
            }
         }
         else
         {
            // 开仓空单
            if(dWR > g_iWR_HighMax)
            {
               if(OpenSell())
               {
                  string sMsgTitle = "D_W_06: Open SELL";
                  Print(sMsgTitle); // 提醒
                  sMsgTitle = StringConcatenate(sMsgTitle, g_sMsgTitle); 
                  g_SendMail.SendMailToFxseaServer(sMsgTitle, g_sMsgContent);
               }
            }
            
            // 平仓空单
            if(g_PriceArea_EX == PA_Low && dWR > g_iWR_LowSign)
            {
               if(CloseSell())
               {
                  string sMsgTitle = "D_W_06: Stop SELL";
                  Print(sMsgTitle); // 提醒
                  sMsgTitle = StringConcatenate(sMsgTitle, g_sMsgTitle); 
                  g_SendMail.SendMailToFxseaServer(sMsgTitle, g_sMsgContent);
               }
            }
            
            // 开仓多单
            if(dWR < g_iWR_LowMax)
            {
               if(OpenBuy())
               {
                  string sMsgTitle = "D_W_06: Open BUY";
                  Print(sMsgTitle); // 提醒
                  sMsgTitle = StringConcatenate(sMsgTitle, g_sMsgTitle); 
                  g_SendMail.SendMailToFxseaServer(sMsgTitle, g_sMsgContent);
               }
            }
         }
         //#########################################################//
         
         //#########################################################//
         // 平仓多单
         if(g_PriceArea_EX == PA_High && dWR < g_iWR_HighSign)
         {
            if(CloseBuy())
            {
               string sMsgTitle = "D_W_06: Stop BUY";
               Print(sMsgTitle); // 提醒
               sMsgTitle = StringConcatenate(sMsgTitle, g_sMsgTitle); 
               g_SendMail.SendMailToFxseaServer(sMsgTitle, g_sMsgContent);
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
         // 强制 平仓多单
         if(g_bPermission)
         {
            if(CloseBuy())
            {
               string sMsgTitle = "D_W_06: Stop BUY";
               Print(sMsgTitle); // 提醒
               sMsgTitle = StringConcatenate(sMsgTitle, g_sMsgTitle); 
               g_SendMail.SendMailToFxseaServer(sMsgTitle, g_sMsgContent);
            }
         }
         else
         {
            // 开仓多单
            if(dWR < g_iWR_LowMax)
            {
               if(OpenBuy())
               {
                  string sMsgTitle = "D_W_06: Open BUY";
                  Print(sMsgTitle); // 提醒
                  sMsgTitle = StringConcatenate(sMsgTitle, g_sMsgTitle); 
                  g_SendMail.SendMailToFxseaServer(sMsgTitle, g_sMsgContent);
               }
            }
         
            // 平仓多单
            if(g_PriceArea_EX == PA_High && dWR < g_iWR_HighSign)
            {
               if(CloseBuy())
               {
                  string sMsgTitle = "D_W_06: Stop BUY";
                  Print(sMsgTitle); // 提醒
                  sMsgTitle = StringConcatenate(sMsgTitle, g_sMsgTitle); 
                  g_SendMail.SendMailToFxseaServer(sMsgTitle, g_sMsgContent);
               }
            }
            
            // 开仓空单
            if(dWR > g_iWR_HighMax)
            {
               if(OpenSell())
               {
                  string sMsgTitle = "D_W_06: Open SELL";
                  Print(sMsgTitle); // 提醒
                  sMsgTitle = StringConcatenate(sMsgTitle, g_sMsgTitle); 
                  g_SendMail.SendMailToFxseaServer(sMsgTitle, g_sMsgContent);
               }
            }
         }
         //#########################################################//
         
         //#########################################################//
         // 平仓空单
         if(g_PriceArea_EX == PA_Low && dWR > g_iWR_LowSign)
         {
            if(CloseSell())
            {
               string sMsgTitle = "D_W_06: Stop SELL";
               Print(sMsgTitle); // 提醒
               sMsgTitle = StringConcatenate(sMsgTitle, g_sMsgTitle); 
               g_SendMail.SendMailToFxseaServer(sMsgTitle, g_sMsgContent);
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
         // 开仓多单
         if(g_bPermission == false && dWR < g_iWR_LowMax)
         {
            if(OpenBuy())
            {
               string sMsgTitle = "D_W_06: Open BUY";
               Print(sMsgTitle); // 提醒
               sMsgTitle = StringConcatenate(sMsgTitle, g_sMsgTitle); 
               g_SendMail.SendMailToFxseaServer(sMsgTitle, g_sMsgContent);
            }
         }
         
         // 平仓多单
         if(g_PriceArea_EX == PA_High && dWR < g_iWR_HighSign)
         {
            if(CloseBuy())
            {
               string sMsgTitle = "D_W_06: Stop BUY";
               Print(sMsgTitle); // 提醒
               sMsgTitle = StringConcatenate(sMsgTitle, g_sMsgTitle); 
               g_SendMail.SendMailToFxseaServer(sMsgTitle, g_sMsgContent);
            }
         }
         //#########################################################//
         
         //#########################################################//
         // 开仓空单
         if(g_bPermission == false && dWR > g_iWR_HighMax)
         {
            if(OpenSell())
            {
               string sMsgTitle = "D_W_06: Open SELL";
               Print(sMsgTitle); // 提醒
               sMsgTitle = StringConcatenate(sMsgTitle, g_sMsgTitle); 
               g_SendMail.SendMailToFxseaServer(sMsgTitle, g_sMsgContent);
            }
         }
         
         // 平仓空单
         if(g_PriceArea_EX == PA_Low && dWR > g_iWR_LowSign)
         {
            if(CloseSell())
            {
               string sMsgTitle = "D_W_06: Stop SELL";
               Print(sMsgTitle); // 提醒
               sMsgTitle = StringConcatenate(sMsgTitle, g_sMsgTitle); 
               g_SendMail.SendMailToFxseaServer(sMsgTitle, g_sMsgContent);
            }
         }
         //#########################################################//
      }
      //=================================================================//
     
   
      return;
   }
                 
   
}




void D_W_06::MFMainProcess()
{
   MFOrder();
}

double D_W_06::PointValue() 
{
   if (MarketInfo(Symbol(), MODE_DIGITS) == 5.0 || MarketInfo(Symbol(), MODE_DIGITS) == 3.0) return (10.0 * Point);
   return (Point);
}



void D_W_06::Save()
{
   g_Result.OpenCount_buy     = g_OpenCount_buy;
   g_Result.OpenCount_sell    = g_OpenCount_sell;
   g_Result.OpenBuyTime       = g_OpenBuyTime;
   g_Result.OpenSellTime      = g_OpenSellTime;
   
   Print("$$$$$$$$$$$$$$$$$$$$ file save : ", g_sFileName, " $$$$$$$$$$$$$$$$$$$$");
   int FileHandle = FileOpen(g_sFileName, FILE_WRITE|FILE_BIN);
   if(FileHandle != INVALID_HANDLE)
   {
      uint byteswritten = FileWriteStruct(FileHandle, g_Result);
      if(byteswritten != sizeof(ResultDW06))
      {
         Print("$$$$$$$$$$$$$$$$$$$$ file write error: ", g_sFileName, " $$$$$$$$$$$$$$$$$$$$");
      }
      else
      {
         Print("$$$$$$$$$$$$$$$$$$$$ file write:  OpenCount_buy = ", g_Result.OpenCount_buy, "  OpenCount_sell = ", g_Result.OpenCount_sell, "  OpenBuyTime = ", g_Result.OpenBuyTime, "  OpenSellTime = ", g_Result.OpenSellTime, " $$$$$$$$$$$$$$$$$$$$");
      }
      FileClose(FileHandle);
   }
   else
   {
      Print("$$$$$$$$$$$$$$$$$$$$ file open fail: ", g_sFileName, " $$$$$$$$$$$$$$$$$$$$");
   }
}


void D_W_06::Load()
{
   Print("$$$$$$$$$$$$$$$$$$$$ file load : ", g_sFileName, " $$$$$$$$$$$$$$$$$$$$");
   int FileHandle = FileOpen(g_sFileName, FILE_READ|FILE_BIN);
   if(FileHandle != INVALID_HANDLE)
   {
      uint bytesread = FileReadStruct(FileHandle, g_Result);
      if(bytesread != sizeof(ResultDW06))
      {
         Print("$$$$$$$$$$$$$$$$$$$$ file read error: ", g_sFileName, " $$$$$$$$$$$$$$$$$$$$");
      }
      else
      {
         g_OpenCount_buy    = g_Result.OpenCount_buy;
         g_OpenCount_sell   = g_Result.OpenCount_sell;
         g_OpenBuyTime      = g_Result.OpenBuyTime;
         g_OpenSellTime     = g_Result.OpenSellTime;
         
         Print("$$$$$$$$$$$$$$$$$$$$ file result:  OpenCount_buy = ", g_OpenCount_buy, "  OpenCount_sell = ", g_OpenCount_sell, "  OpenBuyTime = ", g_OpenBuyTime, "  OpenSellTime = ", g_OpenSellTime, " $$$$$$$$$$$$$$$$$$$$");
      }
      FileClose(FileHandle);
   }
   else
   {
      Print("$$$$$$$$$$$$$$$$$$$$ file open fail: ", g_sFileName, " $$$$$$$$$$$$$$$$$$$$");
   }
}
