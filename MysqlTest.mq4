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
#include <Arrays\ArrayDouble.mqh>
#include <Custom/ExpertAdvisorTradeHelper.mqh>
#include <Custom/TradeQuantityHelper.mqh>
#include <Custom/CandleStickHelper.mqh>
#include <Custom/TwitterHelper.mqh>
#include <Mysql/MQLMySQL.mqh>

// ローソク足補助クラス
CandleStickHelper CandleHelper();

int DB;
string iniInfo;
string host;
string user;
string password;
int port;
string database;
int socket;
int clientFlag;

// ローソク足補助クラス
CandleStickHelper CandleHelper();

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
    double bb = 0;
    double a = GetRegressionLine(PERIOD_M15,8,bb);
    PrintFormat("▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽");
    PrintFormat("y = " + DoubleToString(bb) + "x + " + DoubleToString(a));

    PrintFormat("▽▽▽▽▽▽▽▽▽▽▽▽▽三兵▽▽▽▽▽▽▽▽▽▽▽▽▽");
    
    return;
//---
    string mySymbol = Symbol();
    datetime tm = TimeLocal();
    //Print("現在の時刻は…" + tm);
    string s = TimeToStr(tm,TIME_SECONDS);

    datetime startTime = GetCileTime(-3600);
    datetime endTime = GetCileTime(1800);
    Print("1時間前の時刻は…" + startTime);
    ////Print("30分前の時刻は…" + endTime);
    string startTimeStr = TimeToStr(startTime,TIME_DATE|TIME_SECONDS);
    //Print("1時間前の文字列変換時刻は…" + startTimeStr);
    string endTimeStr = TimeToStr(endTime,TIME_DATE|TIME_SECONDS);
    //Print("30分前の文字列変換時刻は…" + endTimeStr);
    StringReplace(startTimeStr,".","/");
    StringReplace(endTimeStr,".","/");
    
    //Print("確認時間の範囲は…" + startTimeStr + "～" + endTimeStr);
    
    //Print ("Connecting...");
    //Print ("Host: ",host, ", User: ", user, ", Database: ",database,", password: ",password);
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
    Query = Query + "  , T.importance ";
    Query = Query + "from";
    Query = Query + "  IndexCalendars T ";
    Query = Query + "where";
    Query = Query + "  T.myreleasedate between '" + startTimeStr + "' and '" + endTimeStr + "' ";
    Query = Query + "  and T.eventtype <> 2 ";
    Query = Query + "order by";
    Query = Query + "  T.releasedate desc";

    Print ("SQL> ", Query);
    
    int result = MySqlCursorOpen(DB, Query);
    Print ("result> ", result);
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
    
    string myPair = Symbol();
    //Print ("通貨ペア" , myPair);
    string pair1 = StringSubstr(myPair,0,3);
    string pair2 = StringSubstr(myPair,3,3);
    
    string query2 = "";
    query2 = query2 + "select";
    query2 = query2 + " count(T.guidkey) as DataCount";
    query2 = query2 + " from";
    query2 = query2 + " IndexCalendars T ";
    query2 = query2 + " where";
    query2 = query2 + " T.importance='high' ";
    query2 = query2 + " and T.eventtype<>2 and T.myreleasedate between '" + startTimeStr + "' and '" + endTimeStr + "'";
    query2 = query2 + " and(T.currencycode='" + pair1 + "'||T.currencycode='" + pair2 + "') ";
    Print ("SQL> ", query2);
    
    //query発行
    int queryResult = MySqlCursorOpen(DB,query2);
    Print ("queryResult> ", queryResult);
    if(queryResult > -1)
    {
        int row = MySqlCursorRows(queryResult);
        for(int i = 0; i < row; i++){
            if(MySqlCursorFetchRow(queryResult))
            {
                int indexCount = MySqlGetFieldAsInt(queryResult,0);
                if(indexCount > 0)
                {
                    //Print ("指標あり");
                }
                else
                {
                    //Print ("指標なし");
                }
            }
        }
    }
    
    
    MySqlCursorClose(result);
    MySqlCursorClose(queryResult);
    MySqlDisconnect(DB);
    //Print ("Disconnected. Script done!");

    //Print ("一次元目の配列数" , ArrayRange(indexData,0));


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

/// <summary>
///　回帰直線を取得
/// <summary>
/// <param name="timeSpan">取得する時間軸</param>
/// <param name="term">取得するインジケーター値</param>
/// <param name="regressionTilt">取得するTick(0 = NowTick, 1 = -1Tick, 2 = -2Tick, ...)</param>
/// <returns>TEMAのインジケーター値を取得</returns>
double GetRegressionLine(double timeSpan,double term,double &regressionTilt)
{
    double result = 0;


    int timeList[]; 
    ArrayResize(timeList, term);
    double valueList[];
    ArrayResize(valueList, term);

    int timeTotal = 0;
    double valueTotal = 0;

    double timeAverage = 0;
    double valueAverage = 0;

    int mqlIndex = term;

    for(int i = 1; i < term; i++)
    {
        timeList[i - 1] = i;
        //ここでインジケーターの値を取得
        double indicatorValue = GetGmmaWidth(timeSpan,2,mqlIndex);
        valueList[i - 1] = indicatorValue;

        //ついで合計値を計算
        timeAverage += i;
        valueAverage += indicatorValue;
        mqlIndex--;
    }

    //平均を計算
    timeAverage = timeAverage / term;
    valueAverage = valueAverage / term;

    double alphaOne = 0;
    double alphaTwo = 0;

    //最小二乗法でロスを計算
    for(int i = 1; i < term; i++)
    {
        //timeDiff = (Xn - Xave)
        double timeDiff = timeAverage - timeList[i - 1];

        //valueDiff = (Yn - Yave)
        double valueDiff = valueAverage - valueList[i - 1];

        //Σ(Xn - Xave)(Yn - Yave)
        alphaOne = alphaOne + (timeDiff * valueDiff);

        //Σ(Xn - Xave)(Xn - Xave)
        alphaTwo = alphaTwo + (timeDiff * timeDiff);
    }

    //傾き計算
    double alpha = alphaOne / alphaTwo;
    regressionTilt = alpha;

    //切片計算
    double regressionSection = valueAverage - alpha * timeAverage;
    result = regressionSection;

    return result;
}

/// <summary>
/// GMMAWidthのインジケーター値を取得
/// <summary>
/// <param name="timeSpan">取得する時間軸</param>
/// <param name="mode">取得するインジケーター値</param>
/// <param name="shift">取得するTick(0 = NowTick, 1 = -1Tick, 2 = -2Tick, ...)</param>
/// <returns>TEMAのインジケーター値を取得</returns>
double GetGmmaWidth(int timeSpan,int mode,int shift)
{
    double result = iCustom(Symbol(),timeSpan,"GMMAWidth",mode,shift);
    return result;
}

/// <summary>
/// 指定の時間足の自身の前足が上三兵かを取得
/// <summary>
///<param name="time">取得時間</param>
/// <returns>上三兵の結果</returns>
bool IsUpThreeSoldiers(int time)
{
    bool result = false;

    double beforOneOopen = iOpen(NULL,time,1);
    double beforOneClose = iClose(NULL,time,1);

    double beforTwoOopen = iOpen(NULL,time,2);
    double beforTwoClose = iClose(NULL,time,2);

    double beforThreeOopen = iOpen(NULL,time,3);
    double beforThreeClose = iClose(NULL,time,3);

    if (beforOneOopen > beforOneClose)
    {
        return result;
    }

    if (beforTwoOopen > beforTwoClose)
    {
        return result;
    }

    if (beforThreeOopen > beforThreeClose)
    {
        return result;
    }

    if (beforOneOopen > beforTwoOopen || beforOneClose > beforTwoClose)
    {
        return result;
    }

    if (beforTwoOopen > beforThreeOopen || beforTwoClose > beforThreeClose)
    {
        return result;
    }

    //最後が上ひげでなければOKにする
    double brow = CandleHelper.GetUpBeardPrice(time, 1);
    double body = CandleHelper.GetBodyPrice(time,1);
    bool star =  CandleHelper.IsCandleStickStar(time,1);

    if (body * 1.2 >  brow &&  star != false)
    {
        result = true;
    }

    return result;
}


/// <summary>
/// 指定の時間足の自身の前足が下三兵かを取得
/// <summary>
///<param name="time">取得時間</param>
/// <returns>下三兵の結果</returns>
bool IsDownThreeSoldiers(int time)
{
    bool result = false;

    double beforOneOopen = iOpen(NULL,time,1);
    double beforOneClose = iClose(NULL,time,1);

    double beforTwoOopen = iOpen(NULL,time,2);
    double beforTwoClose = iClose(NULL,time,2);

    double beforThreeOopen = iOpen(NULL,time,3);
    double beforThreeClose = iClose(NULL,time,3);

    if (beforOneOopen < beforOneClose)
    {
        return result;
    }

    if (beforTwoOopen < beforTwoClose)
    {
        return result;
    }

    if (beforThreeOopen < beforThreeClose)
    {
        return result;
    }

    if (beforOneOopen < beforTwoOopen || beforOneClose < beforTwoClose)
    {
        return result;
    }

    if (beforTwoOopen < beforThreeOopen || beforTwoClose < beforThreeClose)
    {
        return result;
    }

    //最後が上ひげでなければOKにする
    double brow = CandleHelper.GetDownBeardPrice(time, 1);
    double body = CandleHelper.GetBodyPrice(time,1);
    bool star =  CandleHelper.IsCandleStickStar(time,1);

    if (body * 1.2 >  brow &&  star != false)
    {
        result = true;
    }

    return result;
}