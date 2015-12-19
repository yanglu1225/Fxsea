//+------------------------------------------------------------------+
//|                                                   MFSendMail.mqh |
//|                                                     hu jianglong |
//|                                                      qq:47217817 |
//+------------------------------------------------------------------+
#property copyright "hu jianglong"
#property link      "qq:47217817"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class MFSendMail
  {
private:
     
public:
     MFSendMail();
     ~MFSendMail();
     void SendMailToMeMsg(string strMsg);
     void SendMailToMeMsg(string strMsgTitle, string strMsg);
     void SendMailToFxseaServer(string title,string contents); 
     void SendMailToFxseaServer(string contents);
     
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
MFSendMail::MFSendMail()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
MFSendMail::~MFSendMail()
  {
  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| send mail to user                                                |
//+------------------------------------------------------------------+ 
void MFSendMail::SendMailToMeMsg(string strMsg)
{

  double dAccountEquity = AccountEquity();
  string strTitle = StringConcatenate("From Money Fly,Equity is ",DoubleToStr(dAccountEquity),"$"); 
  SendMail(strTitle,strMsg);

}


void MFSendMail::SendMailToMeMsg(string strMsgTitle, string strMsg)
{

  double dAccountEquity = AccountEquity();
  string strTitle = StringConcatenate(strMsgTitle, DoubleToStr(dAccountEquity),"$"); 
  SendMail(strTitle,strMsg);

}

//+------------------------------------------------------------------+ 
//| send mail to fxsea server, then server send this mail to fxsea member  |
//| title --- title, use can include EA name and equity, banlance etc.
//| contents  ---- mail content, open order info, close order info etc.
//|
//+------------------------------------------------------------------+ 
void MFSendMail::SendMailToFxseaServer(string title,string contents) 
 { 
   int    res;     // To receive the operation execution result 
   char   data[];  // Data array to send POST requests 
   char   result[];  // Read the image here 

//--- Create the body of the POST request for authorization 
   string strPostBody = "signature=ZnhzZWFfc2VydmVy&title=" + title + "&" + "content=" + contents;
   ArrayResize(data,StringToCharArray(strPostBody,data,0,WHOLE_ARRAY,CP_UTF8)-1); 
//--- Resetting error code 
   ResetLastError(); 
//--- Authorization request 
   string str;
   res=WebRequest("POST","http://180.76.148.60/sendmail.php",NULL,0,data,data,str); 
   if(res == -1)
   {
      int err = GetLastError();
      //Alert("WebRequest error:",err);
      Print("WebRequest error:",err);
   }
} 

void MFSendMail::SendMailToFxseaServer(string contents) 
 { 
  double dAccountEquity = AccountEquity();
  string strTitle = StringConcatenate("From fxsea-FroxGrid,Equity is ",DoubleToStr(dAccountEquity),"$"); 
  SendMailToFxseaServer(strTitle,contents);
} 
