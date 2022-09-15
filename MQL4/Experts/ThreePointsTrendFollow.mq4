//+------------------------------------------------------------------+
//|                                       ThreePointsTrendFollow.mq4 |
//| ThreePointsTrendFollow v0.0.1             Copyright 2022, Lukkou |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022,  lukkou"
#property link      "https://twitter.com/lukkou_position"
#property version   "0.01"
#property strict

#include <Custom/ExpertAdvisorTradeHelper.mqh>
#include <Custom/TradeQuantityHelper.mqh>
#include <Custom/CandleStickHelper.mqh>
#include <Custom/TwitterHelper.mqh>
#include <Logics/TrendCheckLogic.mqh>
#include <Mysql/MQLMySQL.mqh>

//マジックナンバー 他のEAと当らない値を使用する。
input int MagicNumber = 11180003; 
input double SpreadFilter = 5;    //最大スプレット値(PIPS)

extern int MaxPosition = 1;        //最大ポジション数
extern int SdSigma = 1;
extern double RiskPercent = 0.3;

input double MaxCount = 10;      //許容スリッピング（Pips単位）

input double Slippage = 20;      //許容スリッピング（Pips単位）
input uint TakeProfit = 50;      //利益確定幅
input uint LoseProfit = 10;      //ロスカット確定幅

input string TweetCmdPash = "C:\\PROGRA~2\\dentakurou\\Tweet\\Tweet.exe";       //自動投稿exeパス

string _host;
string _user;
string _password;
int _port;
string _database;
int _socket;
int _clientFlag;

uint startTime;
uint endTime;


// トレード補助クラス
ExpertAdvisorTradeHelper OrderHelper(Symbol(), MagicNumber, MaxPosition, SpreadFilter);

// 取引数調整クラスSide BarVSide Bar
TradeQuantityHelper LotHelper(Symbol(), PERIOD_H4, 15, 0, MODE_EMA, PRICE_CLOSE, 2, SdSigma, RiskPercent);

//Tweetクラス
TwitterHelper TweetHelper(TweetCmdPash);

// 売買判定クラス
TrendCheckLogic TrendCheck();

/// <summary>
/// Expert initialization function(ロード時)
/// </summary>
int OnInit()
{
    PrintFormat("Version:" + DoubleToString(0.1));

    // EA開始時刻を記録
    startTime = GetTickCount();
    
    string iniInfo = TerminalInfoString(TERMINAL_DATA_PATH) + "\\MQL4\\Experts\\MyConnection.ini";
    Print ("パス: ",iniInfo);

    _host = ReadIni(iniInfo, "MYSQL", "Host");
    _user = ReadIni(iniInfo, "MYSQL", "User");
    _password = ReadIni(iniInfo, "MYSQL", "Password");
    _port = StrToInteger(ReadIni(iniInfo, "MYSQL", "Port"));
    _database = ReadIni(iniInfo, "MYSQL", "Database");
    _socket =  ReadIni(iniInfo, "MYSQL", "Socket");
    _clientFlag = StrToInteger(ReadIni(iniInfo, "MYSQL", "ClientFlag"));  

    Print ("Host: ",_host, ", User: ", _user, ", Database: ",_database);

    return(INIT_SUCCEEDED);
}

/// <summary>
/// Expert deinitialization function(ロード解除時)
/// </summary>
void OnDeinit(const int reason)
{
    // EA終了時刻を記録
    endTime = GetTickCount();
    // EA稼働時間をレポート
    Print("処理時間:" +string((double)(endTime - startTime) / 1000) +"秒");
}

/// <summary>
/// Expert tick function(ローソク足ごとの実行)
/// </summary>
void OnTick()
{
    //int db = MySqlConnect(_host, _user, _password, _database, _port, _socket, _clientFlag);
    int db = 1;
    if (db == -1){
        Print ("Connection failed! Error: " + MySqlErrorDescription);

        //エラーだったら繋がらない情報をツイッターリプライで告知
        ExpertRemove();
        return;
    }

    //自身の通貨ペアポジションがあるか？
    bool hasPosition = (OrderHelper.GetPositionCount() > 0);
    if(hasPosition)
    {
        //通貨ペアの現在時刻より60分後 又は30分前に重要指標の発表があるか？
        bool importantExist = IsImportantReleaseExist(db);
        if(importantExist == true)
        {
            PositionClose();

            //MySqlDisconnect(db);

            //バックテスト時のみ一秒止める(Mysqlへの過剰接続を止めるため)
            //Sleep(500);
            return;
        }

        //平日のみトレードを行う（日本時間土曜日は行わない）
        int weekCount = GetNowWeekCount(db);
        if(weekCount == 1 || weekCount == 7)
        {
            PositionClose();
            //MySqlDisconnect(db);

            //バックテスト時のみ一秒止める(Mysqlへの過剰接続を止めるため)
            //Sleep(500);
            return;
        }

        int orderType = OrderHelper.GetOrderType(0);
        if(orderType == OP_BUY)
        {
            int status = TrendCheck.GetUpTrendPositionCut();
            if(status == POSITION_CUT_ON)
            {
                PositionClose();
                //バックテスト時のみ一秒止める(Mysqlへの過剰接続を止めるため)
                //Sleep(500);
                return;
            }
        }else
        {
            int status = TrendCheck.GetDownTrendPositionCut();
            if(status == POSITION_CUT_ON)
            {
                PositionClose();
                //バックテスト時のみ一秒止める(Mysqlへの過剰接続を止めるため)
                //Sleep(500);
                return;
            }
        }
    }

    // トレード判定
    if(!hasPosition)
    {
        int dayTrend = TrendCheck.GetDayTrendStatus();
        int longTrend = TrendCheck.GetLongTrendStatus(dayTrend);
        if(longTrend == LONG_TREND_PLUS)
        {
            int trendEntry = TrendCheck.GetUpTrendEntryStatus();
            if(trendEntry == ENTRY_ON)
            {
                PositionOpen(OP_BUY);
            }
        }
        else if(longTrend == LONG_TREND_MINUS)
        {
            int trendEntry = TrendCheck.GetDownTrendEntryStatus();
            if(trendEntry == ENTRY_ON)
            {
                PositionOpen(OP_SELL);
            }
        }
        else
        {
        }
    }

    //MySqlDisconnect(db);

    //バックテスト時のみ一秒止める(Mysqlへの過剰接続を止めるため)
    //Sleep(500);
}

/// <summary>
/// 新規ポジションを建てる
/// </summary>
/// <param name="orderType">売買タイプ
///　買い:OP_BUY 売り:OP_SELL
/// </param>
void PositionOpen(int orderType)
{
    double lossRenge = LotHelper.GetSdLossRenge();
    //double lotSize = LotHelper.GetSdLotSize(lossRenge);
    double pLotSize = LotHelper.GetLotSize(lossRenge);

    Print ("pLotSize : " +  DoubleToString(pLotSize));
    Print ("lossRenge: " +  DoubleToString(lossRenge));
    if(MaxCount < pLotSize)
    {
        pLotSize = MaxCount;
    }
    if(lossRenge <= LoseProfit)
    {
        lossRenge = LoseProfit;
    }

    //新規ポジション
    int orderStatus = OrderHelper.SendOrder(orderType, pLotSize, 0, Slippage, lossRenge, TakeProfit );
    if(orderStatus == -2)
    {
        ExpertRemove();
    }

    //ツイート用の情報取得
    int orderNo = OrderHelper.GetTicket(0);
    string symbol = OrderHelper.GetSymbol();
    double price = OrderHelper.GetOrderClose(0);
    double profits = OrderHelper.GetOrderProfit(0);
    string type = "New";
    
    //ついーと！！
    TweetHelper.NewOrderTweet(orderNo, symbol, orderType, price, type);
}

/// <summary>
/// 現在のポジションを決済する
/// </summary>
void PositionClose()
{
    //ツイート用の情報取得
    int orderNo = OrderHelper.GetTicket(0);
    string symbol = OrderHelper.GetSymbol();
    string orderType = OrderHelper.GetOrderType(0);
    double price = OrderHelper.GetOrderClose(0);
    double profits = OrderHelper.GetOrderProfit(0);
    string type = "Settlement";

    //決済
    OrderHelper.CloseOrder(0, Slippage);

    //ついーと！！
    TweetHelper.SettementOrderTweet(orderNo, symbol, orderType, price, profits, type);
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

    //現在時刻から30分後と60分前の時刻を取得
    datetime startTime = GetCileTime(-1800);
    datetime endTime = GetCileTime(3600);

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

/// <summary>
/// 現在時刻からの計算時間を取得
/// <summary>
///param name="cileTime":計算する時間(3600:1時間後,-1800:30分前,86400:1日後)
/// <returns>最小のEMA</returns>
datetime GetCileTime(int cileTime)
{
    datetime tm = TimeLocal();
    return tm + cileTime;
}