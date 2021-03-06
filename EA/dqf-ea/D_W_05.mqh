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

// 反马丁格尔策略


#include "BaseDefine.mqh"
#include "MFSendMail2.mqh"


struct ResultDW05
{
   int Correct;
   int ProfitLevel;
};


class D_W_05
{
   public:
      double   g_dLots;                      // 开仓手数
      int      g_iSlippage;                  // 滑点
      int      g_iMagic;
      double   g_dPoint;                     // 盈利点数
      int      g_ProfitLevel;                // 盈利等级
      int      g_FirstLevel;                 // 初始等级
      
   public:
      string g_name; 
      OpenValid g_OpenValid;
      
      Trend g_MainTrend;                     // 主趋势
      Trend g_CurTrend;                      // 当前趋势

      int g_ticket_buy;                      // 开仓的订单号
      int g_ticket_sell;                     // 开仓的订单号
      double g_dLots_buy;                    // 多单开仓手数
      double g_dLots_sell;                   // 空单开仓手数
      int g_MultiArray[5];
      
      bool g_bPermission;                    // 开仓权限  
      int g_iCorrect;                        // 正确次数
      
      double g_fStopProfit_buy;              // 止赢价格
      double g_fStopProfit_sell;             // 止赢价格
      bool   g_bSetStopPrice;                // 是否开始止损价
      
      bool g_bOpenBuy;
      bool g_bOpenSell;
      
      MFSendMail g_SendMail;
      string g_sMsgTitle;
      string g_sMsgContent;
      
      string g_sFileName;
      ResultDW05 g_Result;
      
      bool g_bIsClear;
      
   public:
      D_W_05();
      ~D_W_05();
      
   public:
      void MFMainProcess();
      
      void MFOrder();
      bool OpenBuy();
      bool OpenSell();
      bool CloseBuy();
      bool CloseSell();

      void CheckPoint();
      double PointValue();
      void Opened();
      void Closed();
      void Clear();
      void SetOpenBuy();
      void SetOpenSell();
      
      void SetOpenValid();
      void ClearOpenValid();
      void ClearCorrect();
      void AddCorrect();
      
      void SetStopProfit(double fOpenPrice, OpenType opentype);
      void GetLevel(int iB);
      
      void Save();
      void Load();
};



D_W_05::D_W_05(void)
{
   g_dLots = 0.01;                        // 开仓手数
   g_iSlippage = 5;                       // 滑点
   g_iMagic = 20151207;
   g_dPoint = 75;
   g_ProfitLevel = 4;
   g_FirstLevel = 0;
   
   g_name = "";  
   g_OpenValid = OV_NULL;
   
   g_MainTrend                = T_NULL;
   g_CurTrend                 = T_NULL;
   
   g_bOpenBuy = false;
   g_bOpenSell = false;
 
   g_ticket_buy = -1;                      // 开仓的订单号
   g_ticket_sell = -1;                     // 开仓的订单号
   g_dLots_buy = g_dLots;                  // 多单开仓手数
   g_dLots_sell = g_dLots;                 // 空单开仓手数
   g_MultiArray[0] = 1;
   g_MultiArray[1] = 2;
   g_MultiArray[2] = 4;
   g_MultiArray[3] = 8;
   g_MultiArray[4] = 16;
      
   g_bPermission = false;
   g_iCorrect = g_FirstLevel;
   
   g_bSetStopPrice = false;
   g_fStopProfit_buy = 0;
   g_fStopProfit_sell = 0;
   
   g_sMsgTitle = " , Equity is ";
   g_sMsgContent = "";
   
   g_sFileName = "SAV_DM_DW05.txt";
   
   g_Result.Correct = 0;
   g_Result.ProfitLevel = g_ProfitLevel;
   
   g_bIsClear = false;
}

D_W_05::~D_W_05(void)
{

}



bool D_W_05::OpenBuy()
{
   g_ticket_buy = OrderSend(g_name,OP_BUY,g_dLots_buy,Ask,g_iSlippage,0,0,"",g_iMagic,0,Blue);
   
   if(g_ticket_buy >= 0)
   {
      g_fStopProfit_buy = Ask + g_dPoint * PointValue();
      g_bSetStopPrice = true;
      
      g_bOpenBuy = false;
      g_bOpenSell = false;

      return true;
   }
   else
   {
      return false;
   }
}

bool D_W_05::OpenSell()
{
   g_ticket_sell = OrderSend(g_name,OP_SELL,g_dLots_sell,Bid,g_iSlippage,0,0,"",g_iMagic,0,Red);
       
   if(g_ticket_sell >= 0)
   {
      g_fStopProfit_sell = Bid - g_dPoint * PointValue();
      g_bSetStopPrice = true;
      
      g_bOpenBuy = false;
      g_bOpenSell = false;

      return true;
   }
   else
   {
      return false;
   }
}

bool D_W_05::CloseBuy()
{
   if(OrderClose(g_ticket_buy,g_dLots_buy,Bid,g_iSlippage,White))
   {
      g_ticket_buy = -1;
      g_bSetStopPrice = false;
      
      g_bOpenBuy = false;
      g_bOpenSell = false;
      
      return true;
   }
   else
   {
      return false;
   }
}

bool D_W_05::CloseSell()
{
   if(OrderClose(g_ticket_sell,g_dLots_sell,Ask,g_iSlippage,White))
   {
      g_ticket_sell = -1;
      g_bSetStopPrice = false;
      
      g_bOpenBuy = false;
      g_bOpenSell = false;
      
      return true;
   }
   else
   {
      return false;
   }
}

void D_W_05::SetStopProfit(double fOpenPrice, OpenType opentype)
{
   if(opentype == OT_BUY)
   {
      g_fStopProfit_buy = fOpenPrice + g_dPoint * PointValue();
   }
   if(opentype == OT_SELL)
   {
      g_fStopProfit_sell = fOpenPrice - g_dPoint * PointValue();
   }
   g_bSetStopPrice = true;
}

void D_W_05::SetOpenValid()
{
   g_OpenValid = OV_Valid;
}

void D_W_05::ClearOpenValid()
{
   g_OpenValid = OV_NULL;
}

void D_W_05::ClearCorrect()
{
   g_iCorrect = g_FirstLevel;
}

void D_W_05::SetOpenBuy()
{
   g_bOpenBuy = true;
}

void D_W_05::SetOpenSell()
{
   g_bOpenSell = true;
}


void D_W_05::CheckPoint()
{
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
}



void D_W_05::Closed()
{
   while(true)
   {
      if(g_OpenValid == OV_Valid)
      {
         if(CloseBuy() == false)
         {
            continue;
         }
         if(CloseSell() == false)
         {
            continue;
         }
      }
      
      return;
   }
}


void D_W_05::Clear()
{
   Closed();
   ClearOpenValid();
   ClearCorrect();
   
   if(!g_bIsClear)
   {
      Save();
      g_bIsClear = true;
   }
}

void D_W_05::AddCorrect()
{
   g_iCorrect += 1;
   Save();
   
   g_bIsClear = false;
}


void D_W_05::Opened()
{
   while(true)
   {
      if(OpenBuy() == false)
      {
         continue;
      }
      if(OpenSell() == false)
      {
         continue;
      }
      
      SetOpenValid();
      return;
   }
}


void D_W_05::GetLevel(int iB)
{
   if(iB == 1)
   {
      g_iCorrect = 0;
   }
   else if(iB == 2)
   {
      g_iCorrect = 1;
   }
   else if(iB == 4)
   {
      g_iCorrect = 2;
   }
   else if(iB == 8)
   {
      g_iCorrect = 3;
   }
   else if(iB == 16)
   {
      g_iCorrect = 4;
   }
}

void D_W_05::MFOrder()
{
   if(Bars < 3)
   {
      return;
   }
   
   CheckPoint();
   
   
   //------------------------------------------------------------------------------------------------------------
   //while(true)
   {
      //=================================================================//
      // 强制 开仓
      if(g_bOpenBuy == true || g_bOpenSell == true)
      {
         if(g_bPermission && g_OpenValid == OV_NULL)
         {
            Opened();
         }
         
         return;
      }
      //=================================================================//
      
      //=================================================================//
      // 如果主趋势上升，当前趋势上升
      if(g_MainTrend == T_RISE && g_CurTrend == T_RISE)
      {
         //#########################################################//
         // 正向盈利
         if(g_OpenValid == OV_Valid && Bid > g_fStopProfit_buy)
         {
            Closed();
            ClearOpenValid();
            AddCorrect();
            
            g_bOpenBuy = true;
            g_bOpenSell = true;
         }
         
         // 反向亏损
         if(g_OpenValid == OV_Valid && Ask < g_fStopProfit_sell)
         {
            Clear();
            
            g_bOpenBuy = true;
            g_bOpenSell = true;
         }
         //#########################################################//
         
         return;
      }
      //=================================================================//
   
   
      //=================================================================//
      // 如果主趋势下降，当前趋势下降，只做高卖低买
      if(g_MainTrend == T_DECREASE && g_CurTrend == T_DECREASE)
      {
         //#########################################################//
         // 正向盈利
         if(g_OpenValid == OV_Valid && Ask < g_fStopProfit_sell)
         {
            Closed();
            ClearOpenValid();
            AddCorrect();
            
            g_bOpenBuy = true;
            g_bOpenSell = true;
         }
         
         // 反向亏损
         if(g_OpenValid == OV_Valid && Bid > g_fStopProfit_buy)
         {
            Clear();
            
            g_bOpenBuy = true;
            g_bOpenSell = true;
         }
         //#########################################################//
         
         return;
      }
      //=================================================================//
   
   
      //=================================================================//
      // 如果主趋势上升，当前趋势下降，低买高卖，高卖低买
      // 如果主趋势下降，当前趋势上升，低买高卖，高卖低买
      if(g_MainTrend != T_NULL && g_CurTrend != T_NULL && g_MainTrend != g_CurTrend)
      {
         // 平仓
         Clear();
         
         return;
      }
      //=================================================================//
     
   
      return;

   }
                 
   
}



void D_W_05::MFMainProcess()
{
   MFOrder();
}

double D_W_05::PointValue() 
{
   if (MarketInfo(Symbol(), MODE_DIGITS) == 5.0 || MarketInfo(Symbol(), MODE_DIGITS) == 3.0) return (10.0 * Point);
   return (Point);
}


void D_W_05::Save()
{
   g_Result.Correct     = g_iCorrect;
   g_Result.ProfitLevel = g_ProfitLevel;
   
   Print("****************** file save : ", g_sFileName, " ******************");
   int FileHandle = FileOpen(g_sFileName, FILE_WRITE|FILE_BIN);
   if(FileHandle != INVALID_HANDLE)
   {
      uint byteswritten = FileWriteStruct(FileHandle, g_Result);
      if(byteswritten != sizeof(ResultDW05))
      {
         Print("****************** file write error: ", g_sFileName, " ******************");
      }
      else
      {
         Print("****************** file write:  Correct = ", g_Result.Correct, "  ProfitLevel = ", g_Result.ProfitLevel, " ******************");
      }
      FileClose(FileHandle);
   }
   else
   {
      Print("****************** file open fail: ", g_sFileName, " ******************");
   }
}


void D_W_05::Load()
{
   Print("****************** file load : ", g_sFileName, " ******************");
   int FileHandle = FileOpen(g_sFileName, FILE_READ|FILE_BIN);
   if(FileHandle != INVALID_HANDLE)
   {
      uint bytesread = FileReadStruct(FileHandle, g_Result);
      if(bytesread != sizeof(ResultDW05))
      {
         Print("****************** file read error: ", g_sFileName, " ******************");
      }
      else
      {
         g_iCorrect    = g_Result.Correct;
         
         Print("****************** file result:  Correct = ", g_iCorrect, "  ProfitLevel = ", g_Result.ProfitLevel, " ******************");
      }
      FileClose(FileHandle);
   }
   else
   {
      Print("****************** file open fail: ", g_sFileName, " ******************");
   }
}
