//+------------------------------------------------------------------+
//|                                                   BaseDefine.mqh |
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


// 开仓类型
enum OpenType
{ 
   OT_NULL = 0,
   OT_BUY  = 1,            // 多单 
   OT_SELL = 2,            // 空单 
};

// 开仓有效性
enum OpenValid
{ 
   OV_NULL  = 0,            // 无效 
   OV_Valid = 1,            // 有效 
};


// 趋势
enum Trend
{ 
   T_NULL = 0,
   T_RISE = 1,              // 上升 
   T_DECREASE = 2,          // 下降 
};

// KDJ 指标中 K线上穿80 或 下穿20
enum KDJ_K_Trend
{ 
   KT_NULL = 0,
   KT_UP_80 = 1,            // 上穿80 
   KT_DOWN_20 = 2,          // 下穿20
};


// 价格区域
enum PriceArea
{ 
   PA_NULL = 0,
   PA_Low = 1,              // 低位 
   PA_High = 2,             // 高位 
};
