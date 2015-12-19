//+------------------------------------------------------------------+
//|                                                       MFSave.mqh |
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
class MFSave
  {
private:
   int m_fFileSave;
   string m_strFileName;
private:
   int OpenFile(string filename = "save.txt");
   void LogError();
   void CloseFile();
public:
    MFSave();
    MFSave(string filename);
    ~MFSave();
    void SetFileName(string filename = "save.txt");
    bool SetSaveValue(double dValue);
    double GetSaveValue();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
MFSave::MFSave()
  {
    m_strFileName = "save.txt";
    m_fFileSave = -1;
  }
  
MFSave::MFSave(string filename)
  {
    m_strFileName = filename;
    m_fFileSave = -1;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
MFSave::~MFSave()
  {
  }
//+------------------------------------------------------------------+
void MFSave::SetFileName(string filename)
{
    m_strFileName = filename;
    
}

//+------------------------------------------------------------------+
//| get file handle                                                  |
//+------------------------------------------------------------------+ 
int MFSave::OpenFile(string filename)
{
  
  if(StringLen(filename) == 0) return -1; 
  
  int iFileHandle = -1;
  iFileHandle = FileOpen(filename,FILE_CSV|FILE_READ|FILE_WRITE);
  if(iFileHandle<0)
  { 
      LogError();
  }
  else
  {
       int iSize = FileSize(iFileHandle);
       if(iSize == 0) 
       {
           FileSeek(iFileHandle, 0, SEEK_SET);
           FileWrite(iFileHandle,0.0);
           FileFlush(iFileHandle);
       }
             
   }

  
  return iFileHandle;
  
}

void MFSave::CloseFile()
{
  if(m_fFileSave > 0)
  {
    FileClose(m_fFileSave);
  }
}



//+------------------------------------------------------------------+
//| dValue --  save dValue to save file                              |
//+------------------------------------------------------------------+
bool MFSave::SetSaveValue(double dValue)
{
  bool bRet = false;
  if(m_fFileSave <0)
  m_fFileSave = OpenFile(m_strFileName);
  if(m_fFileSave > 0)
  {
     FileSeek(m_fFileSave, 0, SEEK_SET);
     FileWrite(m_fFileSave,dValue);
     FileFlush(m_fFileSave);
     bRet = true;
  }
  return bRet;
}

//+------------------------------------------------------------------+
//read dValue from save file                                         |
//+------------------------------------------------------------------+
double MFSave::GetSaveValue()
{
  double dValue = 0.0;
   if(m_fFileSave <0)
  m_fFileSave = OpenFile(m_strFileName);
  if(m_fFileSave > 0)
  {
    FileSeek(m_fFileSave, 0, SEEK_SET);
    dValue = FileReadNumber(m_fFileSave);
     
  }
  return dValue;
}


void MFSave::LogError()
{


}