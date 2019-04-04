//+------------------------------------------------------------------+
//|                                                    MysqlTest.mq4 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <Mysql\MQLMySQL.mqh>
#include <Arrays\ArrayObj.mqh>
#include <Arrays\ArrayString.mqh>
#include <Arrays\ArrayInt.mqh>

int DB;
string iniInfo;
string host;
string user;
string password;
int port;
string database;
int socket;
int clientFlag;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   iniInfo = TerminalInfoString(TERMINAL_DATA_PATH) + "\\MQL4\\Experts\\MyConnection.ini";
   Print ("パス: ",iniInfo);
   
Print ("パスaaa: ",TerminalInfoString(TERMINAL_DATA_PATH));
   host = ReadIni(iniInfo, "MYSQL", "Host");
   user = ReadIni(iniInfo, "MYSQL", "User");
   password = ReadIni(iniInfo, "MYSQL", "Password");
   port = StrToInteger(ReadIni(iniInfo, "MYSQL", "Port"));
   database = ReadIni(iniInfo, "MYSQL", "Database");
   socket =  ReadIni(iniInfo, "MYSQL", "Socket");
   clientFlag = StrToInteger(ReadIni(iniInfo, "MYSQL", "ClientFlag"));  
   
   Print ("Host: ",host, ", User: ", user, ", Database: ",database);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---


    
    string mySymbol = Symbol();
    datetime tm = TimeLocal();
    Print("現在の時刻は…" + tm);
    string s = TimeToStr(tm,TIME_SECONDS);
    if(StringFind(s,"00:00") == -1)
    {
       return;
    }
    datetime startTime = GetCileTime(-3600);
    datetime endTime = GetCileTime(1800);
    Print("1時間前の時刻は…" + startTime);
    Print("30分前の時刻は…" + endTime);
    string startTimeStr = TimeToStr(startTime,TIME_DATE|TIME_SECONDS);
    Print("1時間前の文字列変換時刻は…" + startTimeStr);
    string endTimeStr = TimeToStr(endTime,TIME_DATE|TIME_SECONDS);
    Print("30分前の文字列変換時刻は…" + endTimeStr);
    StringReplace(startTimeStr,".","/");
    StringReplace(endTimeStr,".","/");
    
    Print("確認時間の範囲は…" + startTimeStr + "～" + endTimeStr);
    
    Print ("Connecting...");
    Print ("Host: ",host, ", User: ", user, ", Database: ",database,", password: ",password);
    DB = MySqlConnect(host, user, password, database, port, socket, clientFlag);
    
    if (DB == -1){
      Print ("Connection failed! Error: "+MySqlErrorDescription); } else { Print ("Connected! DBID#",DB);
    }
    
    string Query = "";
    Query = Query + "select";
    Query = Query + "  T.guidkey";
    Query = Query + "  , T.idkey";
    Query = Query + "  , T.currencycode";
    Query = Query + "  , T.eventtype";
    Query = Query + "  , T.myreleasedate ";
    Query = Query + "from";
    Query = Query + "  IndexCalendars T ";
    Query = Query + "where";
    Query = Query + "  T.myreleasedate between '" + startTimeStr + "' and '" + endTimeStr + "' ";
    Query = Query + "  and T.eventtype <> 1 ";
    Query = Query + "order by";
    Query = Query + "  T.releasedate desc";

    Print ("SQL> ", Query);
    
    int result = MySqlCursorOpen(DB, Query);
    string indexData[][5];
    if (result >= 0)
    {
      int row = MySqlCursorRows(result);
      ArrayResize(indexData,row);
      for(int i=0; i<row; i++)
      {
         if (MySqlCursorFetchRow(result))
         {
            string guid =  MySqlGetFieldAsString(result, 0);
            string idKye = MySqlGetFieldAsString(result, 1);
            string currency = MySqlGetFieldAsString(result, 2);
            string eventType = MySqlGetFieldAsString(result, 3);
            string importance = MySqlGetFieldAsString(result, 4);
            Print ("ROW[",i,"]: guid = ", guid, ", IdKye = ", idKye, ", 通貨 = ", currency,", イベントタイプ = ", eventType,", 重要度 = ", importance );
            
            indexData[i][0] = guid;
            indexData[i][1] = idKye;
            indexData[i][2] = currency;
            indexData[i][3] = eventType;
            indexData[i][4] = importance;
         }
      }    
    }
    else
    {
      Print ("セレクト無し");
    }
    
    MySqlDisconnect(DB);
    Print ("Disconnected. Script done!");
    
    string myPair = Symbol();
    Print ("通貨ペア" , myPair);
    Print ("一次元目の配列数" , ArrayRange(indexData,0));


   if(ArrayRange(indexData,0) > 0){
      for(int i=0; i<ArrayRange(indexData,0);i++)
      {
         Print ("配列取得: guid = ", indexData[i][0], ", IdKye = ", indexData[i][1], ", 通貨 = ", indexData[i][2],", イベントタイプ = ", indexData[i][3],", 重要度 = ", indexData[i][4] );
         
         int pairMatch = IsPairMatch(myPair,indexData[i][2]);
         if(pairMatch >= 0)
         {
            Print ("通貨ペア：" + myPair + "指標ペア：" + indexData[i][2] + "でMatch");
         }
         
         if(indexData[i][4] == "high")
         {
            Print ("イベントHIFGHがある"); 
         }
      }
   }
 }
//+------------------------------------------------------------------+


//------------------------------------------------------------------
// 現在時刻からの計算時間を取得
///param name="cileTime":計算する時間(3600:1時間後,-1800:30分前,86400:1日後)
/// Return   最小のEMA
datetime GetCileTime(int cileTime){
    datetime tm = TimeLocal();
    return tm + cileTime;
}

int IsPairMatch(string myPair,string indexPair){
   int result = StringFind(myPair,indexPair);
   
   return result;
}