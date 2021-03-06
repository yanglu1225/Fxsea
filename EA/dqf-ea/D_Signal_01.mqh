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


class D_Signal_01
{
   public:
      int      g_iMovingPeriod_1;
      int      g_iMovingPeriod_2;
      int      g_iMovingShift;
      
   public:
      string g_name; 
      int timeframe_b;                       // 大时间周期
      int timeframe_s;                       // 小时间周期

      int g_ticket;                          // 开仓的订单号
      
      int g_TrendType;                       // 0: 无     1: 单边趋势     2: 振荡
      int g_TrendProperty;                   // 0: 无     1: 上升         2: 下降
      
   public:
      D_Signal_01();
      ~D_Signal_01();
      
   public:
      void MFMainProcess();
      void MFOrder();
     
      int GetTrendType();
      int GetTrendProperty();
      
};


D_Signal_01::D_Signal_01(void)
{
   g_iMovingPeriod_1          = 17;
   g_iMovingPeriod_2          = 52;
   g_iMovingShift             = 0;
   
   timeframe_b                = PERIOD_D1;
   timeframe_s                = PERIOD_H4;
   
   g_name = ""; 
   
   g_TrendType = 0;
   g_TrendProperty = 0;
}

D_Signal_01::~D_Signal_01(void)
{

}


int D_Signal_01::GetTrendType()
{
   return g_TrendType;
}

int D_Signal_01::GetTrendProperty()
{
   return g_TrendProperty;
}


void D_Signal_01::MFOrder()
{
   if(Bars < 3)
   {
      return;
   }
   
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
   
   
   if(D_K_0 < 0.0001 || D_K_1 < 0.0001 || D_J_0 < 0.0001 || D_J_1 < 0.0001)
   {
      return;
   }
   if(S_K_0 < 0.0001 || S_K_1 < 0.0001 || S_J_0 < 0.0001 || S_J_1 < 0.0001)
   {
      return;
   }
   
   
   
                                  // 分析数据  
                              
   while(true)
   {
      //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>//
      // 大周期 快线上穿慢线
      if( D_K_1 < D_J_1 && D_K_0 >= D_J_0 )    
      {
         
      }
      //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>//
      
      
      //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>//
      // 大周期 快线下穿慢线
      if( D_K_1 > D_J_1 && D_K_0 <= D_J_0 )    
      {
         
      } 
      //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>//
       
      
      
      //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>//
      // 大周期 持续 快线在慢线 上方 
      if( D_K_1 > D_J_1 && D_K_0 > D_J_0 )
      {
         //===================================================================//
         // 小周期 快线上穿慢线
         if( S_K_1 < S_J_1 && S_K_0 >= S_J_0 ) 
         {
            g_TrendType = 1;
            g_TrendProperty = 1;
         }
         
         // 小周期 快线下穿慢线
         if( S_K_1 > S_J_1 && S_K_0 <= S_J_0 )
         {
            g_TrendType = 2;
            g_TrendProperty = 2;
         }
         //===================================================================//
         
         //===================================================================//
         // 小周期 持续 快线在慢线 上方 
         if( S_K_1 > S_J_1 && S_K_0 > S_J_0 )
         {
            g_TrendType = 1;
            g_TrendProperty = 1;
         }
         
         // 小周期 持续 快线在慢线 下方 
         if( S_K_1 < S_J_1 && S_K_0 < S_J_0 )
         {
            g_TrendType = 2;
            g_TrendProperty = 2;
         }
         //===================================================================//
      }
      //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>//
      
      
      //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>//
      // 大周期 持续 快线在慢线 下方 
      if( D_K_1 < D_J_1 && D_K_0 < D_J_0 ) 
      {
         //===================================================================//
         // 小周期 快线下穿慢线
         if( S_K_1 > S_J_1 && S_K_0 <= S_J_0 )
         {
            g_TrendType = 1;
            g_TrendProperty = 2;
         }
         
         // 小周期 快线上穿慢线
         if( S_K_1 < S_J_1 && S_K_0 >= S_J_0 )    
         {
            g_TrendType = 2;
            g_TrendProperty = 1;
         }
         //===================================================================//
         
         //===================================================================//
         // 小周期 持续 快线在慢线 下方  
         if( S_K_1 < S_J_1 && S_K_0 < S_J_0 )
         {
            g_TrendType = 1;
            g_TrendProperty = 2;
         }
         
         // 小周期 持续 快线在慢线 上方 
         if( S_K_1 > S_J_1 && S_K_0 > S_J_0 )
         {
            g_TrendType = 2;
            g_TrendProperty = 1;
         }
         //===================================================================//
      }
      //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>//
      
      
      return;
    }                              
   
}


void D_Signal_01::MFMainProcess()
{
   MFOrder();
}

