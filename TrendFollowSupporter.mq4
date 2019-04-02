//+------------------------------------------------------------------+
//|                                         TrendFollowSupporter.mq4 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017,  lukkou"
#property link      "https://twitter.com/lukkou_position"
#property version   "1.00"
#property strict

#include <Custom/ExpertAdvisorTradeHelper.mqh>
#include <Custom/TradeQuantityHelper.mqh>
#include <Custom/CandleStickHelper.mqh>
#include <Custom/TwitterHelper.mqh>
#include <MQLMySQL.mqh>

//マジックナンバー 他のEAと当らない値を使用する。
input int MagicNumber = 11180001; 
input double SpreadFilter = 2;    //最大スプレット値(PIPS)

extern int MaxPosition = 1;        //最大ポジション数
extern int SdSigma = 3;
extern double RiskPercent = 2.0;

input double Slippage = 10;      //許容スリッピング（Pips単位）
input uint TakeProfit = 50;      //利益確定

input string TweetCmdPash = "C:\\PROGRA~2\\dentakurou\\Tweet\\Tweet.exe";       //自動投稿exeパス

// トレード補助クラス
ExpertAdvisorTradeHelper OrderHelper(Symbol(), MagicNumber, MaxPosition, SpreadFilter);
// 取引数調整クラスSide BarVSide Bar
TradeQuantityHelper LotHelper(Symbol(), PERIOD_M15, 15, 0, MODE_EMA, PRICE_CLOSE, 2, SdSigma, RiskPercent);
//Tweetクラス
TwitterHelper TweetHelper(TweetCmdPash);
// ローソク足補助クラス
CandleStickHelper CandleHelper();
 
string _host;
string _user;
string _password;
int _port;
string _database;
int _socket;
int _clientFlag;

/// <summary>
/// Expert initialization function(ロード時)
/// </summary>
int OnInit()
{
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

}

/// <summary>
/// Expert tick function(ローソク足ごとの実行)
/// </summary>
void OnTick()
{
    //自身の通貨ペアポジションがあるか？
    bool hasPosition = (OrderHelper.GetPositionCount() > 0);

    //通貨ペアの現在時刻より30分後 又は15分前に重要指標の発表があるか？
    bool importantExist = IsImportantReleaseExist();
    if(importantExist == true)
    {
        if(hasPosition)
        {
            //発表がある場合、自身に通貨ペアを強制決済
            OrderHelper.CloseOrder(0, Slippage);
        }

        //ツイッターに告知
        //TweetImportantRelease();
        return;
    }

    //現在の4hトレンドを確認
    //トレンド判定(-1:ダウントレンド,0:トレンド無し,1:アップトレンド)
    int longTrend = GetNowLongGemaTrend();

    //---売却確認用ロジック---
    if(hasPosition)
    {
        //4時間足のトレンドによって決済を変更
        int orderType = OrderHelper.GetOrderType(0);

        if(longTrend == 0)
        {
            if(orderType == OP_BUY)
            {
                //
            }
            else if(orderType == OP_SELL)
            {
                //
            }
        }
        else if(longTrend == 1)
        {
            bool settlementFlg = false;
            if(orderType == OP_BUY)
            {
                //アップトレンドかつポジションが買いの場合
                settlementFlg = true;
            }
            else if(orderType == OP_SELL)
            {
                //アップトレンドかつポジションが売りの場合
                settlementFlg = true;
            }

            if(settlementFlg == true)
            {
                //ツイート用の情報取得
                int orderNo = OrderHelper.GetTicket(0);
                string symbol = OrderHelper.GetSymbol();
                string orderType = "OP_SELL";
                double price = OrderHelper.GetOrderClose(0);
                double profits = OrderHelper.GetOrderProfit(0);
                string type = "Settlement";

                //決済
                OrderHelper.CloseOrder(0, Slippage);

                //ついーと！！
                TweetHelper.SettementOrderTweet(orderNo, symbol, orderType, price, profits, type);
            }
        }
        else if(longTrend == -1)
        {
            bool settlementFlg = false;
            if(orderType == OP_BUY)
            {
                //ダウントレンドかつポジションが買いの場合
                settlementFlg = true;
            }
            else if(orderType == OP_SELL)
            {
                //ダウントレンドかつポジションが売りの場合
                bool settlementFlg =  IsSettlementCheck(OP_SELL);
                if(settlementFlg = true)
                {
                    settlementFlg = true;
                }
            }

            if(settlementFlg == true)
            {
                //ツイート用の情報取得
                int orderNo = OrderHelper.GetTicket(0);
                string symbol = OrderHelper.GetSymbol();
                string orderType = "OP_SELL";
                double price = OrderHelper.GetOrderClose(0);
                double profits = OrderHelper.GetOrderProfit(0);
                string type = "Settlement";

                //決済
                OrderHelper.CloseOrder(0, Slippage);

                //ついーと！！
                TweetHelper.SettementOrderTweet(orderNo, symbol, orderType, price, profits, type);
            }
        }
    }

    if(hasPosition == true)
    {
        return;
    }

    //---ここから新規ポジション用ロジック---
    if(longTrend == 0)
    {
        //4hトレンドが無い場合

    }
    else if(longTrend == 1)
    {
        bool tradeFlg = false;

        //アップトレンドの場合
        int upTrendStatus = GetUpTrendCandleStatus();

        if(upTrendStatus == 1)
        {
            tradeFlg = true;
        }
        else if(upTrendStatus == 2)
        {
            bool upShortTimeFlg = IsUpTrendShortCheck();
            if(upShortTimeFlg)
            {
                tradeFlg = true;
            }
        }

        if(tradeFlg)
        {
            double lossRenge = LotHelper.GetSdLossRenge();
            double lotSize = LotHelper.GetSdLotSize(lossRenge);
            double pLotSize = LotHelper.GetLotSize(lossRenge);

            //新規ポジション
            int orderCmd = OP_BUY;
            OrderHelper.SendOrder(orderCmd, lotSize, 0, Slippage, lossRenge, TakeProfit );

            //ツイート用の情報取得
            int orderNo = OrderHelper.GetTicket(0);
            string symbol = OrderHelper.GetSymbol();
            string orderType = "OP_BUY";
            double price = OrderHelper.GetOrderClose(0);
            double profits = OrderHelper.GetOrderProfit(0);
            string type = "New";
            
            //ついーと！！
            TweetHelper.NewOrderTweet(orderNo, symbol, orderType, price, type);
        }
    }
    else if(longTrend == -1)
    {
        bool tradeFlg = false;

        //ダウントレンドの場合
        int downTrendStatus = GetDownTrendCandleStatus();

        if(downTrendStatus == 1)
        {
            tradeFlg = true;
        }
        else if(downTrendStatus == 2)
        {
            bool downShortTimeFlg = InDownTrendShortCheck();
            if(downShortTimeFlg)
            {
                tradeFlg = true;
            }
        }

        if(tradeFlg)
        {
            double lossRenge = LotHelper.GetSdLossRenge();
            double lotSize = LotHelper.GetSdLotSize(lossRenge);
            double pLotSize = LotHelper.GetLotSize(lossRenge);

            //新規ポジション
            int orderCmd = OP_SELL;
            OrderHelper.SendOrder(orderCmd, lotSize, 0, Slippage, lossRenge, TakeProfit );

            //ツイート用の情報取得
            int orderNo = OrderHelper.GetTicket(0);
            string symbol = OrderHelper.GetSymbol();
            string orderType = "OP_SELL";
            double price = OrderHelper.GetOrderClose(0);
            double profits = OrderHelper.GetOrderProfit(0);
            string type = "New";
            
            //ついーと！！
            TweetHelper.NewOrderTweet(orderNo, symbol, orderType, price, type);
        }
    }
}

/// <summary>
/// 指定時間内に重要指標が存在すかのチェック
/// </summary>
/// <returns>bool</returns>
bool IsImportantReleaseExist(){
    bool result = false;

    string myPair = Symbol();
    string pair1 = StringSubstr(myPair,0,3);
    string pair2 = StringSubstr(myPair,3,3);

    int db = MySqlConnect(_host, _user, _password, _database, _port, _socket, _clientFlag);
    
    if (db == -1){
      Print ("Connection failed! Error: " + MySqlErrorDescription);

      //エラーだったら繋がらない情報をツイッターリプライで告知
      return result;
    }

    //現在時刻から30分後と15分前の時刻を取得
    datetime startTime = GetCileTime(-1800);
    datetime endTime = GetCileTime(900);

    string startTimeStr = TimeToStr(startTime,TIME_DATE|TIME_SECONDS);
    string endTimeStr = TimeToStr(endTime,TIME_DATE|TIME_SECONDS);

    StringReplace(startTimeStr,".","/");
    StringReplace(endTimeStr,".","/");

    string query = "";
    query = query + "select";
    query = query + "  count(T.guidkey) as DataCount ";
    query = query + "from";
    query = query + "  IndexCalendars T ";
    query = query + "where";
    query = query + "  T.importance = 'high' ";
    query = query + "  and T.timemode = '0' ";
    query = query + "  and T.eventtype = 1 ";
    query = query + "  and T.myreleasedate between date_format('" + startTimeStr + "', '%Y/%m/%d %H:%i:%s') and date_format('" + endTimeStr + "', '%Y/%m/%d %H:%i:%s')";
    query = query + "  and ( ";
    query = query + "    T.currencycode = '" + pair1 + "' || T.currencycode = '" + pair2 + "'";
    query = query + "  ) ";

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

    MySqlDisconnect(db);

    return result;
}

/// <summary>
/// 重要指標発表直前をツイッターで通知
/// <summary>
void TweetImportantRelease()
{
    string myPair = Symbol();
    string pair1 = StringSubstr(myPair,0,3);
    string pair2 = StringSubstr(myPair,3,3);

    int db = MySqlConnect(_host, _user, _password, _database, _port, _socket, _clientFlag);
    
    if (db == -1){
      Print ("Connection failed! Error: " + MySqlErrorDescription);

      //エラーだったら繋がらない情報をツイッターリプライで告知

      return;
    }

    //現在時刻から30分後と15分前の時刻を取得
    datetime startTime = GetCileTime(-1800);
    datetime endTime = GetCileTime(900);

    string startTimeStr = TimeToStr(startTime,TIME_DATE|TIME_SECONDS);
    string endTimeStr = TimeToStr(endTime,TIME_DATE|TIME_SECONDS);

    StringReplace(startTimeStr,".","/");
    StringReplace(endTimeStr,".","/");

    string query = "";
    query = query + "select";
    query = query + "  T1.guidkey";
    query = query + "  , T1.idkey";
    query = query + "  , T1.eventname";
    query = query + "  , date_format(T1.myreleasedate,'%Y/%m/%d %H:%i') as myreleasedate";
    query = query + "  , T1.forecastvalue";
    query = query + "  , T1.previousvalue";
    query = query + "  , ifnull(T2.tweetflg,0) as flg";
    query = query + "from";
    query = query + "  IndexCalendars T1 ";
    query = query + "  inner join NotificationFlg T2 ";
    query = query + "    on T2.guidkey = T1.guidkey ";
    query = query + "    and T2.idkey = T1.idkey ";
    query = query + "where";
    query = query + "  T1.importance = 'high' ";
    query = query + "  and T1.timemode = '0' ";
    query = query + "  and T1.eventtype = 1 ";
    query = query + "  and T1.myreleasedate between date_format('" + startTimeStr + "', '%Y/%m/%d %H:%i:%s') and date_format('" + endTimeStr + "', '%Y/%m/%d %H:%i:%s')";
    query = query + "  and ( ";
    query = query + "    T1.currencycode = '" + pair1 + "' || T1.currencycode = '" + pair2 + "'";
    query = query + "  ) ";

    //query発行
    int queryResult = MySqlCursorOpen(db,query);
    if(queryResult > -1)
    {
        int row = MySqlCursorRows(queryResult);
        for(int i = 0; i < row; i++)
        {
            if(MySqlCursorFetchRow(queryResult))
            {
                int flg = MySqlGetFieldAsInt(queryResult,6);
                if(flg == 0)
                {
                    //またTwitterに通知していないので通知
                    string guid = MySqlGetFieldAsString(queryResult,0);
                    string id = MySqlGetFieldAsString(queryResult,1);
                    string title =  MySqlGetFieldAsString(queryResult,2);
                    string day = MySqlGetFieldAsString(queryResult,3);
                    double forecast = MySqlGetFieldAsDouble(queryResult,4);
                    double previous = MySqlGetFieldAsDouble(queryResult,5);

                    string tweetStr = "";
                    tweetStr = tweetStr + "@lukkou" + "\n";
                    tweetStr = tweetStr + "指標名：" + title + "\n";
                    tweetStr = tweetStr + "発表日：[" + day + "]\n";
                    tweetStr = tweetStr + "前回値：[" + DoubleToString(previous) + "]\n";
                    tweetStr = tweetStr + "予想値：[" + DoubleToString(forecast) + "]";

                    //ついーと！！
                    TweetHelper.ExecTweet(tweetStr);

                    //通知完了レコード登録
                    InsertTweetFlg(db, guid, id);
                }
            }
        }
    }

    MySqlDisconnect(db);
}

/// <summary>
/// 指標通知フラグを登録
/// <summary>
void InsertTweetFlg(int db, string guid, string id)
{
    string query = "";
    query = query + "insert ";
    query = query + "into NotificationFlg(";
    query = query + "  guidkey";
    query = query + "  , idkey";
    query = query + "  , tweetflg";
    query = query + ") ";
    query = query + "values (";
    query = query + "  '" + guid + "'";
    query = query + "  , '" + id + "'";
    query = query + "  , 1";
    query = query + " )";

    MySqlExecute(db, query);
}

/// <summary>
/// GMMAWigth(4H)より現在のトレンドを取得
/// <summary>
/// <returns>トレンド判定(-1:ダウントレンド,0:トレンド無し,1:アップトレンド)</returns>
int GetNowLongGemaTrend()
{
    int result = 0;

    //現在足のwidth数値
    double nowWidthValuePlus = GetGmmaWidth(PERIOD_H4,1,0);
    double nowWidthValueMinus = GetGmmaWidth(PERIOD_H4,2,0);

    //4時間前足のwidth数値
    double beforeWidthValuePlus = GetGmmaWidth(PERIOD_H4,1,1);
    double beforeWidthValueMinus = GetGmmaWidth(PERIOD_H4,2,1);

    //現在足のGMMA幅(35-60)を取得
    double gmmaWightLong = GetGmmaWidth(PERIOD_H4,4,0);

    //現在のGMMA幅の位置を取得
    if(nowWidthValuePlus > 0)
    {
        result = 1;
    }
    else if(nowWidthValueMinus < 0)
    {
        result = -1;
    }


    //トレンドがあってもLong Shortの幅が無ければトレンドなしの判断
    if(MathAbs(gmmaWightLong) < 0.01)
    {
        result = 0;
    }

    //RCI中期がオーバー+-70でなければトレンドなしと判断（前足もトレンドありの場合）
    double rci = GetThreeLineRci(PERIOD_H4,1,0);
    if(MathAbs(rci) < 70)
    {
        result = 0;
    }

    return result;
}

/// <summary>
/// 上トレンドの場合にポジションを取って良いかのチェック
/// <summary>
/// <returns>0：ポジション無し、1：陰陽足、2：陽陽足</returns>
int GetUpTrendCandleStatus()
{
    bool result = 0;

    //今足の形状を取得
    int nowCandleStyle = CandleHelper.CandleBodyStyle(PERIOD_H4,0);
    //前足の形状を取得
    int beforeCandleStyle = CandleHelper.CandleBodyStyle(PERIOD_H4,1);
    //現在値
    double nowPrice = iClose(Symbol(),PERIOD_H4,0);
    //double nowPrice = iClose[0];

    if(beforeCandleStyle == -1 && nowCandleStyle == 1)
    {
        double beforeClose = iClose(Symbol(),PERIOD_H4,1);

        if(nowPrice > beforeClose)
        {
            result = 1;
        }
    }
    else if(beforeCandleStyle == 1 && nowCandleStyle == 1)
    {
        double beforeHigh = iHigh(Symbol(),PERIOD_H4,1);

        if(nowPrice > beforeHigh)
        {
            result = 2;
        }
    }

    return result;
}

/// <summary>
/// 下トレンドの場合にポジションを取って良いかのチェック
/// <summary>
/// <returns>0：ポジション無し、1：陽陰足、2：陰陰足</returns>
bool GetDownTrendCandleStatus()
{
    bool result = 0;

    //今足の形状を取得
    int nowCandleStyle = CandleHelper.CandleBodyStyle(PERIOD_H4,0);
    //前足の形状を取得
    int beforeCandleStyle = CandleHelper.CandleBodyStyle(PERIOD_H4,1);
    //現在値
    double nowPrice = iClose(Symbol(),PERIOD_H4,0);
    //double nowPrice = iClose[0];

    if(beforeCandleStyle == 1 && nowCandleStyle == -1)
    {
        double beforeOpen = iOpen(Symbol(),PERIOD_H4,1);

        if(nowPrice < beforeOpen)
        {
            result = 1;
        }
    }
    else if(beforeCandleStyle == -1 && nowCandleStyle == -1)
    {
        double beforeLow = iLow(Symbol(),PERIOD_H4,1);

        if(nowPrice < beforeLow)
        {
            result = 2;
        }
    }

    return result;
}

/// <summary>
/// 4Hが陽陽足の場合に15分足をチェック
/// <summary>
/// <returns>結果</returns>
bool IsUpTrendShortCheck()
{
    bool result = false;

    //今から４本前(一時間前)までのGMMAIndexを取得
    double indexNow = GetGmmaIndex(PERIOD_M15,2,0);
    double indexBefore15 = GetGmmaIndex(PERIOD_M15,2,1);
    double indexBefore30 = GetGmmaIndex(PERIOD_M15,2,2);
    double indexBefore45 = GetGmmaIndex(PERIOD_M15,2,3);

    double temaUp = GetTema(PERIOD_M15,1,0);
    double temaDown = GetTema(PERIOD_M15,2,0);

    if(indexNow > 0 && indexBefore15 > 0 && indexBefore30 > 0 && indexBefore45 > 0)
    {
        if(temaUp > 0 && temaDown == 0)
        {
            result = true;
        }
    }

    return result;
}

/// <summary>
/// 4Hが陰陰足の場合に15分足をチェック
/// <summary>
/// <returns>結果</returns>
bool InDownTrendShortCheck()
{
    bool result = false;

    //今から４本前(一時間前)までのGMMAIndexを取得
    double indexNow = GetGmmaIndex(PERIOD_M15,2,0);
    double indexBefore15 = GetGmmaIndex(PERIOD_M15,2,1);
    double indexBefore30 = GetGmmaIndex(PERIOD_M15,2,2);
    double indexBefore45 = GetGmmaIndex(PERIOD_M15,2,3);

    double temaUp = GetTema(PERIOD_M15,1,0);
    double temaDown = GetTema(PERIOD_M15,2,0);

    if(indexNow < 0 && indexBefore15 < 0 && indexBefore30 < 0 && indexBefore45 < 0)
    {
        if(temaUp == 0 && temaDown < 0)
        {
            result = true;
        }
    }

    return result;
}

/// <summary>
/// 4Hがトレンドなしの場合のエントリするかのチェック
/// <summary>
/// <returns>結果</returns>
int IsNonTradeCheck()
{
    int result = 0;

    //15分足のトレンドは存在しているか？
    double gmmaShortWidth = GetGmmaWidth(PERIOD_M15, 0, 3);
    double gmmaLongWidth = GetGmmaWidth(PERIOD_M15, 0, 4);
    if(gmmaShortWidth == 0 && gmmaLongWidth == 0);
    {
        return result;
    }

    //４時間足のロング幅を取得
    double twoAfertEma30 = iMA(Symbol(),PERIOD_H4,30,0,MODE_EMA,PRICE_CLOSE,2);
    double twoAfertEma60 = iMA(Symbol(),PERIOD_H4,60,0,MODE_EMA,PRICE_CLOSE,2);
    double oneAfertEma30 = iMA(Symbol(),PERIOD_H4,30,0,MODE_EMA,PRICE_CLOSE,1);
    double oneAfertEma60 = iMA(Symbol(),PERIOD_H4,60,0,MODE_EMA,PRICE_CLOSE,1);
    double nowEma30 = iMA(Symbol(),PERIOD_H4,30,0,MODE_EMA,PRICE_CLOSE,0);
    double nowEma60 = iMA(Symbol(),PERIOD_H4,60,0,MODE_EMA,PRICE_CLOSE,0);

    //15分足がアップトレンドの場合



    //15分足がダウントレンドの場合


}

/// <summary>
/// 対象通貨を決済しないといけないかのチェック
/// <param name="positionTrend"></param>
/// <summary>
/// <returns>結果</returns>
bool IsSettlementCheck(int positionTrend)
{
    double nowPrice = iClose(Symbol(),PERIOD_M15,0);

    if(positionTrend == OP_BUY)
    {
        //ポシジョンの方向が売りの場合に決済するかの判断

        double gmmaShortIndex =  GetGmmaIndex(PERIOD_M15,0,0);
        double ema13 = iMA(Symbol(),PERIOD_M15,13,0,MODE_EMA,PRICE_CLOSE,0);
        if(gmmaShortIndex <= 0 && ema13 < nowPrice)
        {
            return true;
        }

        double temaUp = GetTema(PERIOD_M15,0,0);
        double temaDown = GetTema(PERIOD_M15,1,0);
        if(temaUp == 0 && temaDown <= 0)
        {
            return true;
        }

        double upPrice = CandleHelper.GetUpBeardPrice(PERIOD_M15,0);
        double bodyPrice = CandleHelper.GetBodyPrice(PERIOD_M15,0);
        bool starFlg = CandleHelper.IsCandleStickStar(PERIOD_M15,0);
        if(upPrice >= bodyPrice && starFlg == false)
        {
            return true;
        }

        int afterBodyStyle = CandleHelper.CandleBodyStyle(PERIOD_H4,1);
        if(afterBodyStyle == 1)
        {
            double afterBodyMiddlePrice = CandleHelper.GetBodyMiddlePrice(PERIOD_H4,1);
            if(afterBodyMiddlePrice > nowPrice)
            {
                return true;
            }
        }
    }
    else if(positionTrend == OP_SELL)
    {
        //ポシジョンの方向が売りの場合に決済するかの判断

        double gmmaShortIndex =  GetGmmaIndex(PERIOD_M15,0,0);
        double ema13 = iMA(Symbol(),PERIOD_M15,13,0,MODE_EMA,PRICE_CLOSE,0);
        if(gmmaShortIndex >= 0 && ema13 > nowPrice)
        {
            return true;
        }

        double temaUp = GetTema(PERIOD_M15,0,0);
        double temaDown = GetTema(PERIOD_M15,1,0);
        if(temaUp > 0 && temaDown == 0)
        {
            return true;
        }

        double downpPrice = CandleHelper.GetDownBeardPrice(PERIOD_M15,0);
        double bodyPrice = CandleHelper.GetBodyPrice(PERIOD_M15,0);
        bool starFlg = CandleHelper.IsCandleStickStar(PERIOD_M15,0);
        if(downpPrice >= bodyPrice && starFlg == false)
        {
            return true;
        }

        int afterBodyStyle = CandleHelper.CandleBodyStyle(PERIOD_H4,1);
        if(afterBodyStyle == 1)
        {
            double afterBodyMiddlePrice = CandleHelper.GetBodyMiddlePrice(PERIOD_H4,1);
            if(afterBodyMiddlePrice < nowPrice)
            {
                return true;
            }
        }
    }
    
    return false;
}

/// <summary>
/// トレンドが無い場合の対象通貨を決済しないといけないかのチェック
/// <param name="positionTrend"></param>
/// <summary>
/// <returns>結果</returns>
bool IsCandleStickStarNonTrade()
{
   return false;
}

/// <summary>
/// TEMAのインジケーター値を取得
/// <summary>
/// <param name="timeSpan">取得する時間軸</param>
/// <param name="mode">取得するインジケーター値</param>
/// <param name="shift">取得するTick(0 = NowTick, 1 = -1Tick, 2 = -2Tick, ...)</param>
/// <returns>TEMAのインジケーター値を取得</returns>
double GetTema(int timeSpan,int mode,int shift)
{
    double result = iCustom(Symbol(),timeSpan,"TemaCumulative",mode,shift);
    return result;
}

/// <summary>
/// GMMAIndexのインジケーター値を取得
/// <summary>
/// <param name="timeSpan">取得する時間軸</param>
/// <param name="mode">取得するインジケーター値</param>
/// <param name="shift">取得するTick(0 = NowTick, 1 = -1Tick, 2 = -2Tick, ...)</param>
/// <returns>TEMAのインジケーター値を取得</returns>
double GetGmmaIndex(int timeSpan,int mode,int shift)
{
    double result = iCustom(Symbol(),timeSpan,"GMMAIndex",mode,shift);
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
/// 3ラインRCIのインジケーター値を取得
/// <summary>
/// <param name="timeSpan">取得する時間軸</param>
/// <param name="mode">取得するインジケーター値</param>
/// <param name="shift">取得するTick(0 = NowTick, 1 = -1Tick, 2 = -2Tick, ...)</param>
/// <returns>TEMAのインジケーター値を取得</returns>
double GetThreeLineRci(int timeSpan,int mode,int shift)
{
    double result = iCustom(Symbol(),timeSpan,"RCI_3Line_v130",mode,shift);
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
