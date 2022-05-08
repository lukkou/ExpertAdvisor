//+------------------------------------------------------------------+
//|                                       ThreePointsTrendFollow.mq4 |
//| ThreePointsTrendFollow v1.0.0             Copyright 2022, Lukkou |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022,  lukkou"
#property link      "https://twitter.com/lukkou_position"
#property version   "1.00"
#property strict

#include <Custom/ExpertAdvisorTradeHelper.mqh>
#include <Custom/TradeQuantityHelper.mqh>
#include <Custom/CandleStickHelper.mqh>
#include <Custom/TwitterHelper.mqh>
#include <Logics/TrendCheckLogic.mqh>
#include <Mysql/MQLMySQL.mqh>

//マジックナンバー 他のEAと当らない値を使用する。
input int MagicNumber = 11180002; 
input double SpreadFilter = 2;    //最大スプレット値(PIPS)

extern int MaxPosition = 1;        //最大ポジション数
extern int SdSigma = 3;
extern double RiskPercent = 2.0;

input double Slippage = 40;      //許容スリッピング（Pips単位）
input uint TakeProfit = 100;      //利益確定

input string TweetCmdPash = "C:\\PROGRA~2\\dentakurou\\Tweet\\Tweet.exe";       //自動投稿exeパス

string Host;
string User;
string Password;
int Port;
string Database;
int Socket;
int ClientFlag;


// トレード補助クラス
ExpertAdvisorTradeHelper *OrderHelper;

// 取引数調整クラスSide BarVSide Bar
TradeQuantityHelper *LotHelper;

//Tweetクラス
TwitterHelper *TweetHelper;

// 売買判定クラス
TrendCheckLogic *TrendCheckLogic;

/// <summary>
/// Expert initialization function(ロード時)
/// </summary>
int OnInit()
{
    string iniInfo = TerminalInfoString(TERMINAL_DATA_PATH) + "\\MQL4\\Experts\\MyConnection.ini";
    Print ("パス: ",iniInfo);

    Host = ReadIni(iniInfo, "MYSQL", "Host");
    User = ReadIni(iniInfo, "MYSQL", "User");
    Password = ReadIni(iniInfo, "MYSQL", "Password");
    Port = StrToInteger(ReadIni(iniInfo, "MYSQL", "Port"));
    Database = ReadIni(iniInfo, "MYSQL", "Database");
    Socket =  ReadIni(iniInfo, "MYSQL", "Socket");
    ClientFlag = StrToInteger(ReadIni(iniInfo, "MYSQL", "ClientFlag"));  

    Print ("Host: ",_host, ", User: ", _user, ", Database: ",_database);

    OrderHelper = OrderHelper(Symbol(), MagicNumber, MaxPosition, SpreadFilter);
    LotHelper = LotHelper(Symbol(), PERIOD_H4, 15, 0, MODE_EMA, PRICE_CLOSE, 2, SdSigma, RiskPercent);
    TweetHelper = TweetHelper(TweetCmdPash);
    TrendCheckLogic = TrendCheckLogic();

    return(INIT_SUCCEEDED);
}

/// <summary>
/// Expert deinitialization function(ロード解除時)
/// </summary>
void OnDeinit(const int reason)
{

}

/// <summary>
/// Expert tick function(ローソク足ごとの実行)
/// </summary>
void OnTick()
{
    Print ("-------------------Tick Start-------------------");
    //int db = MySqlConnect(_host, _user, _password, _database, _port, _socket, _clientFlag);
    int db = 1;
    if (db == -1){
        Print ("Connection failed! Error: " + MySqlErrorDescription);

        //エラーだったら繋がらない情報をツイッターリプライで告知
        return;
    }


}

/// <summary>
/// 指定時間内に重要指標が存在すかのチェック
/// </summary>
/// <returns>bool</returns>
bool IsImportantReleaseExist(int db){
    bool result = false;
    return result;
    string myPair = Symbol();
    string pair1 = StringSubstr(myPair,0,3);
    string pair2 = StringSubstr(myPair,3,3);

    //現在時刻から30分後と15分前の時刻を取得
    datetime startTime = TrendCheckLogic.GetCileTime(-3600);
    datetime endTime = TrendCheckLogic.GetCileTime(3600);

    string startTimeStr = TimeToStr(startTime,TIME_DATE|TIME_SECONDS);
    string endTimeStr = TimeToStr(endTime,TIME_DATE|TIME_SECONDS);

    StringReplace(startTimeStr,".","/");
    StringReplace(endTimeStr,".","/");

    string query = "";
    query = query + "select";
    query = query + " count(T.guidkey) as DataCount";
    query = query + " from";
    query = query + " IndexCalendars T ";
    query = query + " where";
    query = query + " T.importance='high' ";
    query = query + " and T.eventtype<>2 and T.myreleasedate between '" + startTimeStr + "' and '" + endTimeStr + "'";
    query = query + " and(T.currencycode='" + pair1 + "'||T.currencycode='" + pair2 + "') ";

    //query発行
    int queryResult = MySqlCursorOpen(db,query);
    if(queryResult > -1)
    {
        int row = MySqlCursorRows(queryResult);
        for(int i = 0; i < row; i++){
            if(MySqlCursorFetchRow(queryResult))
            {
                int indexCount = MySqlGetFieldAsInt(queryResult,0);
                if(indexCount > 0)
                {
                    result = true;
                }
            }
        }
    }

    MySqlCursorClose(queryResult);

    return result;
}

/// <summary>
/// 現在の曜日を取得
/// 1：日曜日、2：月曜日、3：火曜日、4：水曜日、5：木曜日、6：金曜日、7：土曜日
/// <summary>
/// <returns>システム日付の曜日を１～７で取得
int GetNowWeekCount(int db)
{
    int result = 0;
    return 2;
    string query = "";
    query = query + "select DAYOFWEEK(now()) as weekcount";

    //query発行
    int queryResult = MySqlCursorOpen(db,query);
    if(queryResult > -1)
    {
        int row = MySqlCursorRows(queryResult);
        for(int i = 0; i < row; i++)
        {
            if(MySqlCursorFetchRow(queryResult))
            {
                result = MySqlGetFieldAsInt(queryResult,0);
            }
        }
    }

    MySqlCursorClose(queryResult);

    return result;
}