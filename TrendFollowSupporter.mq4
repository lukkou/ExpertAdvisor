//+------------------------------------------------------------------+
//|                                         TrendFollowSupporter.mq4 |
//| CandleStickHelper v1.0.0                  Copyright 2017, Lukkou |
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
#include <Mysql/MQLMySQL.mqh>

//マジックナンバー 他のEAと当らない値を使用する。
input int MagicNumber = 11180001; 
input double SpreadFilter = 2;    //最大スプレット値(PIPS)

extern int MaxPosition = 1;        //最大ポジション数
extern int SdSigma = 3;
extern double RiskPercent = 2.0;

input double Slippage = 40;      //許容スリッピング（Pips単位）
input uint TakeProfit = 100;      //利益確定

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
    //int db = MySqlConnect(_host, _user, _password, _database, _port, _socket, _clientFlag);
    Print ("-------------------Tick Start-------------------");
    int db = 1;
    if (db == -1){
        Print ("Connection failed! Error: " + MySqlErrorDescription);

        //エラーだったら繋がらない情報をツイッターリプライで告知
        return;
    }

    //自身の通貨ペアポジションがあるか？
    bool hasPosition = (OrderHelper.GetPositionCount() > 0);

    //通貨ペアの現在時刻より30分後 又は15分前に重要指標の発表があるか？
    bool importantExist = IsImportantReleaseExist(db);
    if(importantExist == true)
    {
        if(hasPosition)
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

        //MySqlDisconnect(db);

        //バックテスト時のみ一秒止める(Mysqlへの過剰接続を止めるため)
        //Sleep(500);
        return;
    }

    //平日のみトレードを行う（日本時間土曜日は行わない）
    int weekCount = GetNowWeekCount(db);
    if(weekCount == 1 || weekCount == 7)
    {
        if(hasPosition)
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

        //MySqlDisconnect(db);

        //バックテスト時のみ一秒止める(Mysqlへの過剰接続を止めるため)
        //Sleep(500);
        return;
    }

    //現在の4hトレンドを確認
    //トレンド判定(-1:ダウントレンド,0:トレンド無し,1:アップトレンド)
    int longTrend = GetNowLongGemaTrend();
    if(longTrend == 2147483647)
    {
        Print("現在のトレンドは「2147483647」のため判断不可　何もしない！！！");
        //MySqlDisconnect(db);

        //バックテスト時のみ一秒止める(Mysqlへの過剰接続を止めるため)
        //Sleep(500);
        return;
    }
    Print("現在のトレンドは：" + IntegerToString(longTrend));

    //---売却確認用ロジック---
    if(hasPosition)
    {
        //4時間足のトレンドによって決済を変更
        int orderType = OrderHelper.GetOrderType(0);
        Print("現在のorderTypeは：" + IntegerToString(orderType));
        if(longTrend == 0)
        {
            bool checkFlg = IsSettlementCheckNonTrade(orderType);
            bool settlementFlg = false;
            if(checkFlg == true)
            {
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
        else if(longTrend == 1)
        {
            bool settlementFlg = false;
            if(orderType == OP_BUY)
            {
                //アップトレンドかつポジションが買いの場合
                bool checkFlg =  IsSettlementCheck(OP_BUY);
                if(checkFlg == true)
                {
                    settlementFlg = true;
                }
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
                bool checkFlg =  IsSettlementCheck(OP_SELL);
                if(checkFlg == true)
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
        //MySqlDisconnect(db);

        //バックテスト時のみ一秒止める(Mysqlへの過剰接続を止めるため)
        //Sleep(500);
        return;
    }
    else
    {
        bool saleFlg = false;
        Print("▽▽▽▽▽ポジションを取る前に決済判断をチェック▽▽▽▽▽");
        
        if(longTrend == 0)
        {
            //4h足トレンドがない場合
            saleFlg = IsSettlementCheckNonTrade(OP_BUY);

            if(saleFlg == false)
            {
                saleFlg = IsSettlementCheckNonTrade(OP_SELL);
            }
        }
        else if (longTrend == 1)
        {
            //4hトレンドが上の場合
            saleFlg = IsSettlementCheck(OP_BUY);
        }
        else if (longTrend == -1)
        {
            //4hトレンドが下の場合
            saleFlg = IsSettlementCheck(OP_SELL);
        }

        if (saleFlg)
        {
            //売りフラグが立っている場合は新規売買判断を行わず次のティックへ
            //MySqlDisconnect(db);

            //バックテスト時のみ一秒止める(Mysqlへの過剰接続を止めるため)
            //Sleep(500);
            Print("△△△△△△△△△△△△△△△△△△△△△△△△△△△△△");
            return;
        }
        
        Print("▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲");
    }

    //---ここから新規ポジション用ロジック---
    if(longTrend == 0)
    {
        //4hトレンドが無い場合
        int trendStatus = IsNonTradeCheck();
        Print("トレンドが無い場合の売買判定は" + IntegerToString(trendStatus));
        if(trendStatus != 0)
        {
            double lossRenge = LotHelper.GetSdLossRenge();
            //double lotSize = LotHelper.GetSdLotSize(lossRenge);
            double pLotSize = LotHelper.GetLotSize(lossRenge);

            //新規ポジション
            int orderCmd = 0;
            string orderType = "";
            if(trendStatus == 1)
            {
                orderCmd = OP_BUY;
                orderType = "OP_BUY";
            }
            else
            {
                orderCmd = OP_SELL;
                orderType = "OP_SELL";
            }
            OrderHelper.SendOrder(orderCmd, pLotSize, 0, Slippage, lossRenge, TakeProfit );

            //ツイート用の情報取得
            int orderNo = OrderHelper.GetTicket(0);
            string symbol = OrderHelper.GetSymbol();
            double price = OrderHelper.GetOrderClose(0);
            double profits = OrderHelper.GetOrderProfit(0);
            string type = "New";
            
            //ついーと！！
            TweetHelper.NewOrderTweet(orderNo, symbol, orderType, price, type);
        }
    }
    else if(longTrend == 1)
    {
        bool tradeFlg = false;

        //アップトレンドの場合
        int upTrendStatus = GetUpTrendCandleStatus();
        Print("アップトレンドの場合の売買判定は" + IntegerToString(upTrendStatus));
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
            //double lotSize = LotHelper.GetSdLotSize(lossRenge);
            double pLotSize = LotHelper.GetLotSize(lossRenge);

            //新規ポジション
            int orderCmd = OP_BUY;
            OrderHelper.SendOrder(orderCmd, pLotSize, 0, Slippage, lossRenge, TakeProfit );

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
        Print("ダウントレンドの場合の売買判定は" + IntegerToString(downTrendStatus));
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
            //double lotSize = LotHelper.GetSdLotSize(lossRenge);
            double pLotSize = LotHelper.GetLotSize(lossRenge);

            //新規ポジション
            int orderCmd = OP_SELL;
            OrderHelper.SendOrder(orderCmd, pLotSize, 0, Slippage, lossRenge, TakeProfit );

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

    //MySqlDisconnect(db);

    //バックテスト時のみ一秒止める(Mysqlへの過剰接続を止めるため)
    //Sleep(500);
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
    datetime startTime = GetCileTime(-1800);
    datetime endTime = GetCileTime(900);

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
/// GMMAWigth(4H)より現在のトレンドを取得
/// <summary>
/// <returns>トレンド判定(-1:ダウントレンド,0:トレンド無し,1:アップトレンド)</returns>
int GetNowLongGemaTrend()
{
    int result = 0;

    //現在足のwidth数値
    double nowWidthValuePlus = GetGmmaWidth(PERIOD_H4,0,0);
    double nowWidthValueMinus = GetGmmaWidth(PERIOD_H4,1,0);

    Print("ValuePlus:" + DoubleToStr(GetGmmaWidth(PERIOD_H4,0,0)));
    Print("ValueMinus:" + DoubleToStr(GetGmmaWidth(PERIOD_H4,1,0)));

    if(nowWidthValueMinus == 2147483647 || nowWidthValuePlus == 2147483647)
    {
        return 2147483647;
    }

    //4時間前足のwidth数値
    double beforeWidthValuePlus = GetGmmaWidth(PERIOD_H4,0,1);
    double beforeWidthValueMinus = GetGmmaWidth(PERIOD_H4,1,1);


    //現在足のGMMA幅(35-60)を取得
    double gmmaWightLong = GetGmmaWidth(PERIOD_H4,2,0);

    //現在足のGMMA幅(3-15)を取得
    double gmmaWidthShort = GetGmmaWidth(PERIOD_H4,3,0);

    //現在のGMMA幅の位置を取得
    if(nowWidthValuePlus > 0.01 && beforeWidthValuePlus > 0)
    {
        result = 1;
    }
    else if(nowWidthValueMinus < -0.01 && beforeWidthValueMinus < 0)
    {
        result = -1;
    }
    else
    {
        //トレンドが無い判断のため以降をチェックする必要なし
        return result;
    }


    //トレンドがあってもLong Shortの幅が無ければトレンドなしの判断
    if(MathAbs(gmmaWightLong) < 0.05 && MathAbs(gmmaWidthShort) < 0.05)
    {
        Print("幅がNGだった:Short" + DoubleToStr(gmmaWidthShort) + "//Long:" + DoubleToStr(gmmaWightLong));
        result = 0;
    }

    //RCI中、長期がオーバー+-70でなければトレンドなしと判断（前足もトレンドありの場合）
    double rciMiddle = GetThreeLineRci(PERIOD_H4,1,0);
    double rciLong = GetThreeLineRci(PERIOD_H4,2,0);
    Print(DoubleToStr(MathAbs(rciMiddle)));
    Print(DoubleToStr(MathAbs(rciLong)));
    if(MathAbs(rciMiddle) < 70 && MathAbs(rciLong) < 50)
    {
        Print("RCIがNGだった:Middle" + DoubleToStr(rciMiddle) + "//Long:" + DoubleToStr(rciLong));
        //RCIがNGでもポジションとRCI数値で再度確認
        double nowPrice = iClose(Symbol(),PERIOD_H4,0);
        
        
        if(rciMiddle > 0 && rciLong > 0)
        {
            //RCI中期長期がプラスの場合は過去12時間の高値を上抜いたか
            double beforeOneHigh = iHigh(Symbol(),PERIOD_H4,1);
            double beforeTowHigh = iHigh(Symbol(),PERIOD_H4,2); 
            double beforeThreeHigh = iHigh(Symbol(),PERIOD_H4,3);
            
            //糞ロジック　MT4で華麗に書くのしんどい(´・ω・`)
            double highPrice = 0;
            if(beforeOneHigh > beforeTowHigh)
            {
                highPrice = beforeOneHigh;
            }
            else
            {
                highPrice = beforeTowHigh;
            }
            
            if(beforeThreeHigh > highPrice)
            {
                highPrice = beforeThreeHigh;
            }
            
            if(nowPrice > highPrice)
            {
                Print("RCIがNGだったが過去高値を上抜く" + DoubleToStr(nowPrice) + ">" + DoubleToStr(highPrice));
                result = 1;
            }
            else
            {
                result = 0;
            }
        }
        else if(rciMiddle < 0 && rciLong < 0)
        {
            //RCI中期長期がマイナスの場合は過去12時間の安値を上抜いたか
            double beforeOneHigh = iLow(Symbol(),PERIOD_H4,1);
            double beforeTowHigh = iLow(Symbol(),PERIOD_H4,2); 
            double beforeThreeHigh = iLow(Symbol(),PERIOD_H4,3);
            
            //糞ロジック　MT4で華麗に書くのしんどい(´・ω・`)
            double lowPrice = 0;
            if(beforeOneHigh < beforeTowHigh)
            {
                lowPrice = beforeOneHigh;
            }
            else
            {
                lowPrice = beforeTowHigh;
            }
            
            if(beforeThreeHigh < lowPrice)
            {
                lowPrice = beforeThreeHigh;
            }
            
            if(nowPrice < lowPrice)
            {
                Print("RCIがNGだったが過去安値を下抜く" + DoubleToStr(nowPrice) + "<" + DoubleToStr(lowPrice));
                result = -1;
            }
            else
            {
                result = 0;
            }
        }
        else
        {
            result = 0;
        }
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

    double upPrice_4h = CandleHelper.GetUpBeardPrice(PERIOD_H4,0);
    double bodyPrice_4h = CandleHelper.GetBodyPrice(PERIOD_H4,0);
    bool starFlg = CandleHelper.IsCandleStickStar(PERIOD_H4,0);
    if(upPrice_4h * 1.2 >= bodyPrice_4h && starFlg == false)
    {
        return result;
    }

    double upPrice_15M = CandleHelper.GetUpBeardPrice(PERIOD_M15,1);
    double bodyPrice_15M = CandleHelper.GetBodyPrice(PERIOD_M15,1);
    int bodyStyle = CandleHelper.CandleBodyStyle(PERIOD_M15,1);
    if(upPrice_15M * 1.2 >= bodyPrice_15M && bodyStyle == -1)
    {
        return result;
    }

    double temaUp = GetTema(PERIOD_M15,1,0);
    double temaDown = GetTema(PERIOD_M15,2,0);
    if (temaUp == 0 && temaDown <= 0)
    {
        return result;
    }

    //今足の形状を取得(0 = 星 1 = 陽線 -1 = 陰線)
    int nowCandleStyle = CandleHelper.CandleBodyStyle(PERIOD_H4,0);
    //前足の形状を取得(0 = 星 1 = 陽線 -1 = 陰線)
    int beforeCandleStyle = CandleHelper.CandleBodyStyle(PERIOD_H4,1);
    //現在値
    double nowPrice = iClose(Symbol(),PERIOD_H4,0);
    //double nowPrice = iClose[0];
    Print("一つ前の足は：" + IntegerToString(beforeCandleStyle) + "//////今の足は：" + IntegerToString(nowCandleStyle));

    if(beforeCandleStyle == -1 && nowCandleStyle == 1)
    {
        Print("陰陽線の場合");
        double beforeOpen = iOpen(Symbol(),PERIOD_H4,1);

        //現在足のGMMA幅(35-60)を取得
        double gmmaWightLong = GetGmmaWidth(PERIOD_H4,2,0);

        //現在足のGMMA幅(3-15)を取得
        double gmmaWidthShort = GetGmmaWidth(PERIOD_H4,3,0);
        Print("WightLong：" + DoubleToStr(gmmaWightLong) + "///WidthShort：" + DoubleToStr(gmmaWidthShort));
        if(nowPrice > beforeOpen && MathAbs(gmmaWightLong) > 0.05 && MathAbs(gmmaWidthShort) > 0.05)
        {
            result = 1;
        }
    }
    else if(beforeCandleStyle == 1 && nowCandleStyle == 1)
    {
        Print("陰陽線の場合");
        double beforeHigh = iHigh(Symbol(),PERIOD_H4,1);
        Print("前の高値：" + DoubleToStr(beforeHigh) + "///今の値段：" + DoubleToStr(nowPrice));
        if(nowPrice > beforeHigh)
        {
            Print("陽線で高値越えた");
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

    double downpPrice_4h = CandleHelper.GetDownBeardPrice(PERIOD_H4,0);
    double bodyPrice_4h = CandleHelper.GetBodyPrice(PERIOD_H4,0);
    bool starFlg = CandleHelper.IsCandleStickStar(PERIOD_H4,0);
    if(downpPrice_4h * 1.2 >= bodyPrice_4h && starFlg == false)
    {
        return result;
    }

    double downpPrice_15M = CandleHelper.GetUpBeardPrice(PERIOD_M15,1);
    double bodyPrice__15M = CandleHelper.GetBodyPrice(PERIOD_M15,1);
    int bodyStyle = CandleHelper.CandleBodyStyle(PERIOD_M15,1);
    if(downpPrice_15M * 1.2 >= bodyPrice__15M && bodyStyle == 1)
    {
        return result;
    }

    double temaUp = GetTema(PERIOD_M15,1,0);
    double temaDown = GetTema(PERIOD_M15,2,0);
    if (temaUp >= 0 && temaDown == 0)
    {
        return result;
    }

    //今足の形状を取得(0 = 星 1 = 陽線 -1 = 陰線)
    int nowCandleStyle = CandleHelper.CandleBodyStyle(PERIOD_H4,0);
    //前足の形状を取得(0 = 星 1 = 陽線 -1 = 陰線)
    int beforeCandleStyle = CandleHelper.CandleBodyStyle(PERIOD_H4,1);
    //現在値
    double nowPrice = iClose(Symbol(),PERIOD_H4,0);
    //double nowPrice = iClose[0];

    if(beforeCandleStyle == 1 && nowCandleStyle == -1)
    {
        double beforeOpen = iOpen(Symbol(),PERIOD_H4,1);

        //現在足のGMMA幅(35-60)を取得
        double gmmaWightLong = GetGmmaWidth(PERIOD_H4,2,0);

        //現在足のGMMA幅(3-15)を取得
        double gmmaWidthShort = GetGmmaWidth(PERIOD_H4,3,0);

        if(nowPrice < beforeOpen && MathAbs(gmmaWightLong) < 0.05 && MathAbs(gmmaWidthShort) < 0.05)
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

    //4h足はエントリーの形になっているか？
    bool candleStyle = CandleHelper.CandleBodyStyle(PERIOD_H4,0);

    if(candleStyle == 0)
    {
        //ローソク足にトレンドがないので無視
        return result;
    }
    
    //　共通で使用する必要情報取得
    double open = iOpen(Symbol(),PERIOD_H4,0);
    double close = iClose(Symbol(),PERIOD_H4,0);

    double nowOpneEma30 = iMA(Symbol(),PERIOD_H4,30,0,MODE_EMA,PRICE_OPEN,0);
    double nowOpneEma60 = iMA(Symbol(),PERIOD_H4,60,0,MODE_EMA,PRICE_OPEN,0);
    double nowCloseEma30 = iMA(Symbol(),PERIOD_H4,30,0,MODE_EMA,PRICE_CLOSE,0);
    double nowCloseEma60 = iMA(Symbol(),PERIOD_H4,60,0,MODE_EMA,PRICE_CLOSE,0);

    double gmmaWidthLongNow = GetGmmaWidth(PERIOD_H4,2,0);
    double gmmaWidthLongBefore = GetGmmaWidth(PERIOD_H4,2,1);
    double gmmaWidthLongSecondBefore = GetGmmaWidth(PERIOD_H4,2,2);
    if(candleStyle == 1)
    {
        //陽線の場合
        if(gmmaWidthLongNow < 0)
        {
            Print("トレンドなし前提なし" + DoubleToStr(gmmaWidthLongNow));
            return result;
        }
        Print(DoubleToStr(nowOpneEma60) + ">" + DoubleToStr(open) + ":" + DoubleToStr(nowCloseEma30) + "<" + DoubleToStr(close));
        if(nowOpneEma60 > open && nowCloseEma30 < close)
        {
            Print("上トレンドブレイクの前提OK");
            //前提がそろった場合のみ15mをチェック
            double nowTema = GetTema(PERIOD_M15,0,0);
            double gmmaIndexShort = GetGmmaIndex(PERIOD_M15,0,0);
            double gmmaWidthShortNow = MathAbs(GetGmmaWidth(PERIOD_M15,2,0));
            double gmmaWidthShortBefore = MathAbs(GetGmmaWidth(PERIOD_M15,2,1));
            
            double changePercent = 0 ;
            if(gmmaWidthShortBefore != 0)
            {
                changePercent = MathAbs((gmmaWidthShortBefore - gmmaWidthShortNow) / gmmaWidthShortNow);
            }
            
            
            Print("nowTema:" + DoubleToStr(nowTema) + " // gmmaIndexShort:" + DoubleToStr(gmmaIndexShort) + " // changePercent:" + DoubleToStr(changePercent) + " // gmmaWidthSHortNow:" + DoubleToStr(gmmaWidthShortNow));
            if(nowTema > 0 && gmmaIndexShort == 5 && changePercent >= 0.2 && gmmaWidthShortNow >= 0.5)
            {
                result = 1;
            }
        }
    }
    else if(candleStyle == -1)
    {
        //陰線の場合
        if(gmmaWidthLongNow > 0)
        {
            return result;
        }

        if(nowOpneEma60 < open && nowCloseEma30 > close)
        {
            Print("下トレンドブレイクの前提OK");
            //前提がそろった場合のみ15mをチェック
            double nowTema = GetTema(PERIOD_M15,0,0);
            double gmmaIndexLong = GetGmmaIndex(PERIOD_M15,0,0);
            double gmmaIndexShort = GetGmmaIndex(PERIOD_M15,0,0);
            double gmmaWidthShortNow = MathAbs(GetGmmaWidth(PERIOD_M15,2,0));
            double gmmaWidthShortBefore = MathAbs(GetGmmaWidth(PERIOD_M15,2,1));

            double changePercent = 0 ;
            if(gmmaWidthShortBefore != 0)
            {
                changePercent = MathAbs((gmmaWidthShortBefore - gmmaWidthShortNow) / gmmaWidthShortNow);
            }
            
            
            Print("nowTema:" + DoubleToStr(nowTema) + " // gmmaIndexShort:" + DoubleToStr(gmmaIndexShort) +" // changePercent:" + DoubleToStr(changePercent));
            if(nowTema < 0 && gmmaIndexShort == -5 && changePercent >= 0.2 && gmmaWidthShortNow <= -0.5)
            {
                result = 2;
            }
        }
    }

    return result;
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
        //ポシジョンの方向が買いの場合に決済するかの判断
        double gmmaShortIndex =  GetGmmaIndex(PERIOD_M15,0,0);
        double ema13 = iMA(Symbol(),PERIOD_M15,13,0,MODE_EMA,PRICE_CLOSE,0);
        Print("ShortIndex = " + DoubleToStr(gmmaShortIndex));
        Print("Ema13 = " + DoubleToStr(ema13) + "/// 現在値 = " + DoubleToStr(nowPrice));
        if(gmmaShortIndex <= 0 && ema13 < nowPrice)
        {
            Print("15分 ShortIndexかつEma13より現在値段が小さい");
            return true;
        }

        double temaUp = GetTema(PERIOD_M15,0,0);
        double temaDown = GetTema(PERIOD_M15,1,0);
        Print("TemaUp = " + DoubleToStr(temaUp) + "/// TemaDown = " + DoubleToStr(temaDown));
        if(temaUp == 0 && temaDown <= 0)
        {
            Print("15分TEMAがマイナストレンドに");
            return true;
        }

        double upPrice_4h = CandleHelper.GetUpBeardPrice(PERIOD_H4,0);
        double bodyPrice_4h = CandleHelper.GetBodyPrice(PERIOD_H4,0);
        bool starFlg = CandleHelper.IsCandleStickStar(PERIOD_H4,0);
        
        if(upPrice_4h >= bodyPrice_4h && starFlg == false)
        {
            Print("4時間足　上ひげの値段が本体足値段より大きくなった");
            return true;
        }

        double upPrice_15M = CandleHelper.GetUpBeardPrice(PERIOD_M15,1);
        double bodyPrice_15M = CandleHelper.GetBodyPrice(PERIOD_M15,1);
        int bodyStyle = CandleHelper.CandleBodyStyle(PERIOD_M15,1);
        if(upPrice_15M >= bodyPrice_15M && bodyStyle == -1)
        {
            Print("15分足　上ひげの値段が本体足値段より大きくなった");
            return true;
        }

        int afterBodyStyle = CandleHelper.CandleBodyStyle(PERIOD_H4,1);
        if(afterBodyStyle == 1)
        {
            Print("4時間足　ひとつ前が陽線だった場合");
            double afterBodyMiddlePrice = CandleHelper.GetBodyMiddlePrice(PERIOD_H4,1);
            if(afterBodyMiddlePrice > nowPrice)
            {
                Print("1本前の足の中間値より現在値段がしたになった");
                return true;
            }
        }
        else if(afterBodyStyle == -1)
        {
            Print("4時間足　ひとつ前が陰線だった場合");
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

        double downpPrice_4h = CandleHelper.GetDownBeardPrice(PERIOD_H4,0);
        double bodyPrice_4h = CandleHelper.GetBodyPrice(PERIOD_H4,0);
        bool starFlg = CandleHelper.IsCandleStickStar(PERIOD_H4,0);
        if(downpPrice_4h >= bodyPrice_4h && starFlg == false)
        {
            return true;
        }

        double downpPrice_15M = CandleHelper.GetUpBeardPrice(PERIOD_M15,1);
        double bodyPrice__15M = CandleHelper.GetBodyPrice(PERIOD_M15,1);
        int bodyStyle = CandleHelper.CandleBodyStyle(PERIOD_M15,1);
        if(downpPrice_15M >= bodyPrice__15M && bodyStyle == 1)
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
bool IsSettlementCheckNonTrade(int positionTrend)
{
    double nowPrice = iClose(Symbol(),PERIOD_M15,0);
    double gmmaIndexShort = GetGmmaIndex(PERIOD_M15,0,0);
    double ema15 = iMA(Symbol(),PERIOD_M15,43,0,MODE_EMA,PRICE_CLOSE,0);
    double nowTema = GetTema(PERIOD_M15,0,0);
    
    double candleBodyValue = CandleHelper.GetBodyPrice(PERIOD_M15,0);
    double candleBodyMiddleBeforePrice = CandleHelper.GetBodyMiddlePrice(PERIOD_M15,1);
    
    if(positionTrend == OP_BUY)
    {
        Print("OP_BUYの場合の判定");
        if(nowTema <= 0)
        {
            Print("nowTemaがマイナス" + DoubleToStr(nowTema));
            return true;
        }

        if(gmmaIndexShort != 5 && nowPrice <= candleBodyMiddleBeforePrice)
        {
            Print("前回本体値段より今値段がした");
            Print("本体中央値段：" + DoubleToStr(candleBodyMiddleBeforePrice));
            Print("今値段：" + DoubleToStr(nowPrice));
            return true;
        }

        if(nowPrice <= ema15)
        {
            Print("ema15より現在値段がした");
            Print("ema15" + DoubleToStr(ema15));
            Print("今値段：" + DoubleToStr(nowPrice));
            return true;
        }
    }
    else if(positionTrend == OP_SELL)
    {
        if(nowTema >= 0)
        {
            Print("nowTemaがプラス" + DoubleToStr(nowTema));
            return true;
        }

        if(nowPrice >= candleBodyMiddleBeforePrice)
        {
            Print("前回本体値段より今値段がした");
            Print("本体中央値段：" + DoubleToStr(candleBodyMiddleBeforePrice));
            Print("今値段：" + DoubleToStr(nowPrice));
            return true;
        }

        if(nowPrice >= ema15)
        {
            Print("ema15より現在値段がうえ");
            return true;
        }
    }
    
    return false;
}

/// <summary>
/// EMAの位置取りと
/// <summary>
/// <returns>結果</returns>
bool IsMovingAveragePosition()
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
