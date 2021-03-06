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


// 检测趋势有效性



#include "BaseDefine.mqh"
#include "MFSendMail2.mqh"


struct TestResult
{
   int TestIndex;
   int TestCount;
   double ProfitTotal;
};


class D_W_03
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
      
      double g_PriceOpen;
      double g_PriceClose;
      double g_ProfitTotal;
      
      int g_TestIndex;
      int g_TestCount;
      
      PriceArea g_PriceArea;
      
      Trend g_MainTrend;                  // 主趋势
      Trend g_CurTrend;                   // 当前趋势

      int g_ticket;                       // 开仓的订单号
      bool g_bPermission;                 // 开仓权限  
      bool g_bNeedStopLoss;               // 止损权限 
      bool g_bNeedTrend;                  // 顺势开仓权限
      
      MFSendMail g_SendMail;
      string g_sMsgTitle;
      string g_sMsgContent;
      
      string g_sFileName;
      TestResult g_TestResult;
      
      bool g_bIsClear;
      
   public:
      D_W_03();
      ~D_W_03();
      
   public:
      void MFMainProcess();
      
      void MFOrder();
      bool OpenBuy();
      bool OpenSell();
      bool CloseBuy();
      bool CloseSell();

      double PointValue();
      void CheckWR(double fWR);
      void SetOpenSignal();
      void Closed();
      bool NeedOpenOrder(OpenType type, int mode, bool& isDouble);
      void ClearStatus();
      bool IsOpen();
      
      void Save();
      void Load();
      
};



D_W_03::D_W_03(void)
{
   g_dLots = 0.01;                        // 开仓手数
   g_iSlippage = 5;                       // 滑点
   g_iMagic = 20151126;
   g_iWR_Period               = 13;
   g_iWR_HighMax              = -20;
   g_iWR_LowMax               = -80;
   g_iWR_HighSign             = -20;
   g_iWR_LowSign              = -80;
   
   g_PriceArea                = PA_NULL;
   
   g_MainTrend                = T_NULL;
   g_CurTrend                 = T_NULL;
   
   timeframe                  = PERIOD_H4;
   
   g_name = ""; 
   g_OpenType = OT_NULL;
   g_OpenValid = OV_NULL; 
   
   g_PriceOpen = 0;
   g_PriceClose = 0;
   g_ProfitTotal = 0;
   
   g_TestIndex = 0;
   g_TestCount = 4;
   
   g_ticket = -1;                         // 开仓的订单号
   g_bPermission = false;
   g_bNeedStopLoss = false;
   g_bNeedTrend = false;
   
   g_sMsgTitle = " , Equity is ";
   g_sMsgContent = "";
   
   g_sFileName = "SAV_DM_DW03.txt";
   
   g_TestResult.TestIndex = 0;
   g_TestResult.TestCount = 0;
   g_TestResult.ProfitTotal = 0;
   
   g_bIsClear = false;
}

D_W_03::~D_W_03(void)
{

}



bool D_W_03::OpenBuy()
{
   if(g_TestIndex >= g_TestCount)
   {
      return false;
   }
   
   g_PriceOpen = Ask;
   g_ticket = 1;
            
   if(g_ticket >= 0)
   {
      g_OpenType = OT_BUY;
      g_OpenValid = OV_Valid;
      g_PriceArea = PA_NULL;

      return true;
   }
   else
   {
      return false;
   }
}

bool D_W_03::OpenSell()
{
   if(g_TestIndex >= g_TestCount)
   {
      return false;
   }
   
   g_PriceOpen = Bid;
   g_ticket = 1;
            
   if(g_ticket >= 0)
   {
      g_OpenType = OT_SELL;
      g_OpenValid = OV_Valid;
      g_PriceArea = PA_NULL;

      return true;
   }
   else
   {
      return false;
   }
}

bool D_W_03::CloseBuy()
{
   if(g_ticket > 0)
   {
      g_PriceClose = Bid;
      g_ProfitTotal += (g_PriceClose - g_PriceOpen);
      
      g_ticket = -1;
      g_OpenType = OT_NULL;
      g_OpenValid = OV_NULL;
      
      g_TestIndex += 1;
      
      g_TestResult.TestIndex = g_TestIndex;
      g_TestResult.TestCount = g_TestCount;
      g_TestResult.ProfitTotal = g_ProfitTotal;
      
      Save();
      
      g_bIsClear = false;
      
      return true;
   }
   else
   {
      return false;
   }
}

bool D_W_03::CloseSell()
{
   if(g_ticket > 0)
   {
      g_PriceClose = Ask;
      g_ProfitTotal += (g_PriceOpen - g_PriceClose);
      
      g_ticket = -1;
      g_OpenType = OT_NULL;
      g_OpenValid = OV_NULL;
      
      g_TestIndex += 1;
      
      g_TestResult.TestIndex = g_TestIndex;
      g_TestResult.TestCount = g_TestCount;
      g_TestResult.ProfitTotal = g_ProfitTotal;
      
      Save();
      
      g_bIsClear = false;
      
      return true;
   }
   else
   {
      return false;
   }
}

bool D_W_03::IsOpen()
{
   if(g_TestIndex < g_TestCount)
   {
      return false;
   }
   
   if(g_ProfitTotal > 0)
   {
      return true;
   }
   else
   {
      return false;
   }
}


void D_W_03::ClearStatus()
{
   g_ticket = -1;
   g_TestIndex = 0;
   g_PriceOpen = 0;
   g_PriceClose = 0;
   g_ProfitTotal = 0;
   
   g_OpenType = OT_NULL;
   g_OpenValid = OV_NULL;
   
   g_TestResult.TestIndex = 0;
   g_TestResult.TestCount = 0;
   g_TestResult.ProfitTotal = 0;
   
   if(!g_bIsClear)
   {
      Save();
      g_bIsClear = true;
   }
}

void D_W_03::SetOpenSignal()
{
   g_PriceArea = PA_NULL;
}


// 判断是否在低位或高位
void D_W_03::CheckWR(double fWR)
{
   if(fWR > g_iWR_HighMax)
   {
      g_PriceArea = PA_High;
   }
   
   if(fWR < g_iWR_LowMax)
   {
      g_PriceArea = PA_Low;
   }
}


// mode  0: 大趋势与当前趋势 相反，不建议开单
//       1: 大趋势与当前趋势 相同，建议开单
bool D_W_03::NeedOpenOrder(OpenType type, int mode, bool& isDouble)
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


void D_W_03::Closed()
{
   Print("------------- Closed -------  g_OpenType: ",g_OpenType, "   g_OpenValid: ", g_OpenValid );
   while(true)
   {
      if(g_OpenType == OT_BUY && g_OpenValid == OV_Valid)
      {
         if(CloseBuy())
         {
            g_PriceArea = PA_NULL;
            return;
         }
      }
         
      if(g_OpenType == OT_SELL && g_OpenValid == OV_Valid)
      {
         if(CloseSell())
         {
            g_PriceArea = PA_NULL;
            return;
         }
      }
   
      return;
   }
}


void D_W_03::MFOrder()
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
         // 开仓多单
         if(g_PriceArea == PA_Low && dWR > g_iWR_LowSign)
         {
            if(g_OpenType == OT_NULL && g_OpenValid == OV_NULL)
            {
               if(OpenBuy())
               {
                  string sMsgTitle = "D_W_03: Open BUY";
                  Print(sMsgTitle); // 提醒
            
                  return;
               }
            }
         }
         //#########################################################//
         
         //#########################################################//
         // 平仓多单
         if(g_PriceArea == PA_High && dWR < g_iWR_HighSign)
         {
            if(g_OpenType == OT_BUY && g_OpenValid == OV_Valid)
            {
               if(CloseBuy())
               {
                  string sMsgTitle = "D_W_03: Stop BUY";
                  Print(sMsgTitle); // 提醒
                  
                  return;
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
         // 开仓空单
         if(g_PriceArea == PA_High && dWR < g_iWR_HighSign)
         {
            if(g_OpenType == OT_NULL && g_OpenValid == OV_NULL)
            {
               if(OpenSell())
               {
                  string sMsgTitle = "D_W_03: Open SELL";
                  Print(sMsgTitle); // 提醒
                  
                  return;
               }
            }
         }
         //#########################################################//
         
         //#########################################################//
         // 平仓空单
         if(g_PriceArea == PA_Low && dWR > g_iWR_LowSign)
         {
            if(g_OpenType == OT_SELL && g_OpenValid == OV_Valid)
            {
               if(CloseSell())
               {
                  string sMsgTitle = "D_W_03: Stop SELL";
                  Print(sMsgTitle); // 提醒
                  
                  return;
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
         // 平仓空单
         if(g_OpenType == OT_SELL && g_OpenValid == OV_Valid)
         {
            if(CloseSell())
            {
               string sMsgTitle = "D_W_03: Stop SELL";
               Print(sMsgTitle); // 提醒
               
               return;
            }
         }
         
         // 平仓多单
         if(g_OpenType == OT_BUY && g_OpenValid == OV_Valid)
         {
            if(CloseBuy())
            {
               string sMsgTitle = "D_W_03: Stop BUY";
               Print(sMsgTitle); // 提醒
               
               return;
            }
         }
      }
      //=================================================================//
     
   
      return;
   }
                 
   
}


void D_W_03::MFMainProcess()
{
   MFOrder();
}

double D_W_03::PointValue() 
{
   if (MarketInfo(Symbol(), MODE_DIGITS) == 5.0 || MarketInfo(Symbol(), MODE_DIGITS) == 3.0) return (10.0 * Point);
   return (Point);
}


void D_W_03::Save()
{
   Print("++++++++++++++++ file save : ", g_sFileName, " +++++++++++++++++++");
   int FileHandle = FileOpen(g_sFileName, FILE_WRITE|FILE_BIN);
   if(FileHandle != INVALID_HANDLE)
   {
      uint byteswritten = FileWriteStruct(FileHandle, g_TestResult);
      if(byteswritten != sizeof(TestResult))
      {
         Print("++++++++++++++++ file write error: ", g_sFileName, " +++++++++++++++++++");
      }
      else
      {
         Print("++++++++++++++++ file write:  TestIndex = ", g_TestResult.TestIndex, "  TestCount = ", g_TestResult.TestCount ,"  ProfitTotal = ", g_TestResult.ProfitTotal, " +++++++++++++++++++");
      }
      FileClose(FileHandle);
   }
   else
   {
      Print("++++++++++++++++ file open fail: ", g_sFileName, " +++++++++++++++++++");
   }
}


void D_W_03::Load()
{
   Print("++++++++++++++++ file load : ", g_sFileName, " +++++++++++++++++++");
   int FileHandle = FileOpen(g_sFileName, FILE_READ|FILE_BIN);
   if(FileHandle != INVALID_HANDLE)
   {
      uint bytesread = FileReadStruct(FileHandle, g_TestResult);
      if(bytesread != sizeof(TestResult))
      {
         Print("++++++++++++++++ file read error: ", g_sFileName, " +++++++++++++++++++");
      }
      else
      {
         g_TestIndex    = g_TestResult.TestIndex;
         g_ProfitTotal  = g_TestResult.ProfitTotal;
         
         g_ticket       = -1;
         g_OpenType     = OT_NULL;
         g_OpenValid    = OV_NULL;
         
         Print("++++++++++++++++ file result:  TestIndex = ", g_TestIndex, "  ProfitTotal = ", g_ProfitTotal, " +++++++++++++++++++");
      }
      FileClose(FileHandle);
   }
   else
   {
      Print("++++++++++++++++ file open fail: ", g_sFileName, " +++++++++++++++++++");
   }
}