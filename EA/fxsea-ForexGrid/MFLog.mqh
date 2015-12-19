//+------------------------------------------------------------------+
//|                                                        MFLog.mqh |
//|                                                     hu jianglong |
//|                                                      qq:47217817 |
//+------------------------------------------------------------------+
#property copyright "hu jianglong"
#property link      "qq:47217817"
#property version   "1.00"
#property strict
#include "MFDefine.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class MFLog
  {
private:
    int m_fFileLog;
    FType m_fileType;
    string m_strLogFileName;
    
private:
    void LogError();
    int OpenFile(string filename, FType fileType);
    string OrderTypeToStr(int iOrderType);
    string GetTicketInfo(int iTicket,TicketMarketMode tiketType);  
    void CloseFile();
    
public:
    MFLog();
    MFLog(string filename, FType fileType);
    ~MFLog();
    void SetFileName(string filename, FType fileType);
    void SaveLog2File(string strLog);
    void SaveTicketInfo2File(int iTicket,TicketMarketMode tiketType,string strAppe);   
    string GetFileContents();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
MFLog::MFLog()
  {
   m_strLogFileName = "Log.txt"; 
   m_fileType = FT_LOG;
   m_fFileLog = -1;
  
  }
  
MFLog::MFLog(string filename, FType fileType)
{
    m_fFileLog = -1;
   m_strLogFileName = filename; 
   m_fileType = fileType;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
MFLog::~MFLog()
  {
  }
//+------------------------------------------------------------------+



void MFLog::SetFileName(string filename, FType fileType)
{
   m_strLogFileName = filename; 
   m_fileType = fileType;
}

void MFLog::LogError()
{


}


//+------------------------------------------------------------------+
//| get file handle                                                  |
//+------------------------------------------------------------------+ 
int MFLog::OpenFile(string filename, FType fileType)
{
  if(StringLen(filename) == 0) return -1;  
  int iFileHandle = -1;
  switch(fileType)
  {
    case FT_LOG:
    {
      iFileHandle = FileOpen(m_strLogFileName,FILE_CSV|FILE_READ|FILE_WRITE);
      break;
    }
    case FT_PROFIT:
    {
      iFileHandle = FileOpen(m_strLogFileName,FILE_BIN|FILE_READ|FILE_WRITE);  
      break;
    }
  
  }
  
   if(iFileHandle<0)
   { 
      LogError();
   }
  
  return iFileHandle;
  
}

void MFLog::CloseFile()
{
  if(m_fFileLog > 0)
  {
    FileClose(m_fFileLog);
  }
}


//+------------------------------------------------------------------+
//| strLog --  string 
//| FType -- type  0 -- log file   1 -- profit log file 2 -- save file(do not use this to save value to save file)
//+------------------------------------------------------------------+
void MFLog::SaveLog2File(string strLog)
{
   if(m_fFileLog < 0) 
   m_fFileLog = OpenFile(m_strLogFileName,m_fileType);
   if(m_fFileLog>0)
   {   
       string str = StringConcatenate(strLog,"\r\n");  
       FileSeek(m_fFileLog,0,SEEK_END);
       FileWriteString(m_fFileLog,strLog,StringLen(strLog));
       FileFlush(m_fFileLog);
   }
}


//+------------------------------------------------------------------+
//| iTicket --  ticket id 
//| tiketType -- 
//| FType -- type  0 -- log file   1 -- profit log file 2 -- save file(do not use this to save value to save file)
//+------------------------------------------------------------------+
void MFLog::SaveTicketInfo2File(int iTicket,TicketMarketMode tiketType,string strAppe)
{

  string strTicket = GetTicketInfo(iTicket,tiketType);
  string str= StringConcatenate(strTicket,",",strAppe);  
  SaveLog2File(str);
}



//+------------------------------------------------------------------+
//| get the ticket information                                       |
//+------------------------------------------------------------------+ 
string MFLog::GetTicketInfo(int iTicket,TicketMarketMode tiketType)
{
    string str = "";
    if(iTicket == -1) return str;

    switch(tiketType)
     {
       case TMM_TRADES:
       {
         if(!OrderSelect(iTicket,SELECT_BY_TICKET,MODE_TRADES)) return str;
         break;
       }
       
       case TMM_HISTORY:
       {
         if(!OrderSelect(iTicket,SELECT_BY_TICKET,MODE_HISTORY)) return str;
         break;
       }
   
     }
   string strOT = OrderTypeToStr(OrderType());
   double dLots = OrderLots();
   double dOp = OrderOpenPrice();
   double dCp = OrderClosePrice();
   double dPf = OrderProfit();  
   double dSwp = OrderSwap();
   datetime dtOpenTime = OrderOpenTime();
   string strOpTime =TimeToStr(dtOpenTime,TIME_DATE|TIME_SECONDS); 
   datetime dtClsTime = OrderCloseTime();
   string strClsTime = TimeToStr(dtClsTime,TIME_DATE|TIME_SECONDS); 
   
   // ticket id,type,lots,open price,close price,profit,swap,open time,close time
   str = StringConcatenate(iTicket,",",strOT,",",dLots,",",dOp,",",dCp,",",dPf,",",dSwp,",",strOpTime,",",strClsTime);

   return str;
}



//+------------------------------------------------------------------+
//| get the order type                                               |
//+------------------------------------------------------------------+
string  MFLog::OrderTypeToStr(int iOrderType)
{
   string strRet = "unkown";
   switch(iOrderType)
   {
     case 0:
     {
       strRet = "buy";
       break;
     }
     case 1:
     {
       strRet = "sell";
       break;
     }
     
     case 2:
     {
       strRet = "buylimit";
       break;
     }
     
     case 3:
     {
       strRet = "selllimit";
       break;
     }
     
     case 4:
     {
       strRet = "buystop";
       break;
     }
     case 5:
     {
       strRet = "sellstop";
       break;
     }
     default: strRet = "unkown";
   } 

  return strRet;
  
}




//+------------------------------------------------------------------+
//| get the file contents. only use for profit type file             |
//+------------------------------------------------------------------+ 
string MFLog::GetFileContents()
{  
   string str = "";
   if(m_fileType == FT_LOG) Alert("warning! try to read the log type file,please use profit type file");
   if(m_fFileLog < 0) 
   m_fFileLog = OpenFile(m_strLogFileName,m_fileType);
   if(m_fFileLog>0)     
   {
     FileSeek(m_fFileLog,0,SEEK_END);
     int iPos = int( FileTell(m_fFileLog));
     FileSeek(m_fFileLog,0,SEEK_SET);
     str = FileReadString(m_fFileLog,iPos);
     FileSeek(m_fFileLog,0,SEEK_END);
   }
   return str;
}
