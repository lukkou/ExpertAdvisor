//+------------------------------------------------------------------+
//|                                              GMMATrendFollow.mq4 |
//| GMMATrendFollow v0.1            Copyright 2017, Lukkou_EA_Trader |
//|                                   http://fxborg-labo.hateblo.jp/ |
//+------------------------------------------------------------------+

#property copyright "Copyright 2017,  lukkou"
#property link      "https://twitter.com/lukkou_position"
#property version   "1.00"
#property strict

#include <Custom/ExpertAdvisorTradeHelper.mqh>
#include <Custom/TradeQuantityHelper.mqh>
#include <Custom/CandleStickHelper.mqh>
#include <Custom/TwitterHelper.mqh>
#include <Custom/EAX_Mysql.mqh>

input int MagicNumber = 11180002;   //マジックナンバー 他のEAと当らない値を使用する。
input double SpreadFilter = 2;      //最大スプレット値(PIPS)
input int MaxPosition = 1;          //最大ポジション数
input double RiskPercent = 2.0;     //資金に対する最大リスク％
input double Slippage = 10;         //許容スリッピング（Pips単位）
input uint TakeProfit = 200;        //利益確定Pips
input string TweetCmdPash = "C:\\PROGRA~2\\dentakurou\\Tweet\\Tweet.exe";       //自動投稿exeパス

// トレード補助クラス
ExpertAdvisorTradeHelper OrderHelper(Symbol(), MagicNumber, MaxPosition, SpreadFilter);
// 取引数調整クラス
TradeQuantityHelper LotHelper(Symbol(), PERIOD_M15, 15, 0, MODE_EMA, PRICE_CLOSE, 2, AccountBalance(), RiskPercent);
//Tweetクラス
TwitterHelper TweetHelper(TweetCmdPash);
//ローソク足補助クラス
CandleStickHelper　CandleStickHelper();

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(){
    PrintFormat(TimeLocal() + ":GMMATrendFollow Load");
    return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason){
    PrintFormat(TimeLocal() + ":GMMATrendFollow End");
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick(){
    PrintFormat(TimeLocal() + ":GMMATrendFollow Move");
    //DBオブジェクト
    EAX_Mysql *db = new EAX_Mysql();
    db.connect("localhost","StockManager","password","StockDatabase","3306");

    int rowCount = GetNoTradeTime();
    bool importanceFlg = IsImportance();



    bool hasPosition = (OrderHelper.GetPositionCount() > 0);
    if(hasPosition){
        bool closeOrder = false;
        //ポジションが存在する場合、決裁するかチェック
        if(importanceFlg == true){
            closeOrder = true;
        }

        //自身が上髭の場合

        //TEAMのトレンド転換の場合

        if(closeOrder == true){
            OrderHelper.CloseOrderAll(Slippage);
        }
    }

    //同通貨のポジションがある場合4hトレンド無し中のポジションの場合のみ
    //同方向へポジションを取る　それ以外はなにもしない


    //4hのトレンド発生の確認
    double 4hGmmaWidthUp_0 = GetGmmaWidth(PERIOD_H4,1,0);
    double 4hGmmaWidthDown_0 = GetGmmaWidth(PERIOD_H4,2,0);
    double 4hGmmaWidthUp_1 = GetGmmaWidth(PERIOD_H4,1,1);
    double 4hGmmaWidthDown_1 = GetGmmaWidth(PERIOD_H4,2,1);

    int tradeJudgement = 0;

    if(4hGmmaWidthUp_1 == 0　&& 4hGmmaWidthDown_1 == 0){
        //1Tick前(4h)がトレンド無しの場合
        if(4hGmmaWidthUp_0 == 0 && 4hGmmaWidthDown_0 == 0){
            //NowTick(4H)がトレンド無しの場合

            tradeJudgement = IsNoTrend();
        }else{
            //NowTick(4H)がトレンド有りの場合
            int trend = 0;

            if(4hGmmaWidthUp_0 == 0 && 4hGmmaWidthDown_0 < 0){
                trend = 1;
            }

            tradeJudgement = IsNewTrendFollow(trend);
        }
    }else{
        //1Tick前(4h)がトレンド有りの場合
        if(4hGmmaWidthUp_0 > 0 && 4hGmmaWidthDown_0 == 0){
            //NowTickは上トレンド


        }else if(4hGmmaWidthUp_0 == 0 && 4hGmmaWidthDown_0 < 0){
            //NowTickは下トレンド

        }
    }

    if(tradeJudgement != 0){
        double lossSize = LotHelper.GetSdLossRenge();
        double lotSize = LotHelper.GetSdLotSize(lossSize);

        int orderCmd;
        if(tradeJudgement == 1){
            orderCmd = OP_BUY;
        }else{
            orderCmd = OP_SELL;
        }

        OrderHelper.SendOrder(orderCmd, lotSize, 0, Slippage, lossSize, TakeProfit );
    }

    db.close();
    delete db;
}

//------------------------------------------------------------------
// 上トレンドが継続中の場合の売買判定のチェック
/// Return   売買判断(0 = NoTrade, 1 = Bull, 2 = Bear)
int IsUpTrendFollow(){
    int result = 0;

    return result;
}

//------------------------------------------------------------------
// 下トレンドが継続中の場合の売買判定のチェック
/// Return   売買判断(0 = NoTrade, 1 = Bull, 2 = Bear)
int IsDownTrendFollow(){
    int result = 0;

    return result;
}

//------------------------------------------------------------------
// 新たにトレンドが発生した場合の売買判定のチェック
///param name="nowTrend":取得するTick(0 = UpTrend, 1 = DownTrend)
/// Return   売買判断(0 = NoTrade, 1 = Bull, 2 = Bear)
int IsNewTrendFollow(int nowTrend){
    int result = 0;
    bool checkResult[5] = {false,false,false,false,false};

    if(nowTrend = 0){
        //UpTrend
        if(GetGmmaIndex(PERIOD_H4,1,0) == 5){
            checkResult[0] = true;
        }

        if(GetGmmaIndex(PERIOD_H4,2,0) => -4){
            checkResult[1] = true;
        }

        if(CandleStickHelper.IsCandleStickStar(PERIOD_H4,1) == true){
            checkResult[2] = true;
        }

        if(CandleStickHelper.IsCandleBodyStyle(PERIOD_H4,0) == 1){
            checkResult[3] = true;
        }

        double myClose = iClose(NULL,PERIOD_H4,0);
        double oldClose = iClose(NULL,PERIOD_H4,1);
        if(myClose > oldClose){
            checkResult[4] = true;
        }
    }else{
        //DownTrend
        if(GetGmmaIndex(PERIOD_H4,1,0) == -5){
            checkResult[0] = true;
        }

        if(GetGmmaIndex(PERIOD_H4,2,0) <= 4){
            checkResult[1] = true;
        }

        if(CandleStickHelper.IsCandleStickStar(PERIOD_H4,1) == true){
            checkResult[2] = true;
        }

        if(CandleStickHelper.IsCandleBodyStyle(PERIOD_H4,0) == 2){
            checkResult[3] = true;
        }

        double myClose = iClose(NULL,PERIOD_H4,0);
        double oldClose = iClose(NULL,PERIOD_H4,1);
        if(myClose < oldClose){
            checkResult[4] = true;
        }
    }

    bool tradeFlg = true;
    for(int i = 0; i < ArraySize(checkResult); i++){
        if(checkResult[i] == false){
            tradeFlg = false;
        }
    }

    if(tradeFlg == true){
        if(nowTrend == 1){
            result = 1;
        }else{
            result = 2;
        }
    }

    return result;
}

//------------------------------------------------------------------
// トレンドが無い場合の売買判定のチェック
/// Return   売買判断(0 = NoTrade, 1 = Bull, 2 = Bear)
int IsNoTrend(){
    int result = 0;

    double 30ema = GetEma(PERIOD_H4,30,0);
    double 35ema = GetEma(PERIOD_H4,35,0);
    double 40ema = GetEma(PERIOD_H4,40,0);
    double 45ema = GetEma(PERIOD_H4,45,0);
    double 50ema = GetEma(PERIOD_H4,50,0);
    double 60ema = GetEma(PERIOD_H4,60,0);

    double maxEma = GetMaxEma(30ema,35ema,40ema,45ema,50ema,60ema);
    double miniEma = GetMiniEma(30ema,35ema,40ema,45ema,50ema,60ema);

    double open = iOpen(NULL,PERIOD_H4,0);
    double close = iClose(NULL,PERIOD_H4,0);

    if()(open < miniEma){
        if(close > maxEma){
            result = 1;
        }
    }else if(open > maxEma){
        if(close < miniEma){
            result = 2;
        }
    }

    return result;
}

//------------------------------------------------------------------
/// EMAの値を取得する
/// param name="time":取得時間(足の時間)
/// param name="span":取得する平均の期間(5EMAなのか25EMAなのかなど)
/// param name="shift":取得するTick(0 = NowTick, 1 = -1Tick, 2 = -2Tick, ...)
/// Return   EMA値
double GetEma(int time,int span, int shift){
    return iMA(NULL,time,span,shift,MODE_EMA,PRICE_CLOSE);
}

//------------------------------------------------------------------
// GMMAWidthの値を取得する
///param name="time":取得時間
///param name="mode":取得する値(1 = Up, 2 = Down ,3 = ShortWidth ,4 = LongWidth)
///param name="shift":取得するTick(0 = NowTick, 1 = -1Tick, 2 = -2Tick, ...)
/// Return   GMMAWidth値
double GetGmmaWidth(int time,int mode,int shift){
    string indicatorName = "GMMA Width"; 
    double result = 0;

    result = iCustom(NULL,time,indicatorName,mode,shift);

    return result;
}

//------------------------------------------------------------------
// GmmaIndexの値を取得する
///param name="time":取得時間
///param name="mode":取得する値(1 = ShortIndex, 2 = LongIndex)
///param name="shift":取得するTick(0 = NowTick, 1 = -1Tick, 2 = -2Tick, ...)
/// Return   GmmaIndex値
double GetGmmaIndex(int time, int mode, int shift){
    string indicatorName = "GMMA Index"; 
    double result = 0;

    result = iCustom(NULL,time,indicatorName,mode,shift);

    return result;
}

//------------------------------------------------------------------
// 3RCIの値を取得する
///param name="time":取得時間
///param name="mode":取得する値(1 = ShortRci, 2 = MiddleRci, 3 = LongRci)
///param name="shift":取得するTick(0 = NowTick, 1 = -1Tick, 2 = -2Tick, ...)
/// Return   3RCI値
double GetThreeRciLine(int time, int mode, int shift){
    string indicatorName = "RCI 3line"; 
    double result = 0;

    result = iCustom(NULL,time,indicatorName,mode,shift);

    return result;
}

//------------------------------------------------------------------
// TEMAの値を取得する
///param name="time":取得時間
///param name="mode":取得する値(1 = TemaUp, 2 = TemaDown, 3 = Ema1, 4 = Ema2, 5 = Ema3)
///param name="shift":取得するTick(0 = NowTick, 1 = -1Tick, 2 = -2Tick, ...)
/// Return   TEMA値
double GetTripleEma(int time, int mode, int shift){
    string indicatorName = "TEMA"; 
    double result = 0;

    result = iCustom(NULL,time,indicatorName,mode,shift);

    return result;
}

//------------------------------------------------------------------
// GMMAのグループ(LongがShort)の中で最大値を取得
///param name="e1":EMA
///param name="e2":EMA
///param name="e3":EMA
///param name="e4":EMA
///param name="e5":EMA
///param name="e6":EMA
/// Return   最大のEMA
double GetMaxEma(double e1,double e2,double e3,double e4,double e5,double e6){
    double result = 0;
    double emaArray[6];
    emaArray[0] = e1;
    emaArray[1] = e2;
    emaArray[2] = e3;
    emaArray[3] = e4;
    emaArray[4] = e5;
    emaArray[5] = e6;

    result =  emaArray[0];
    for(int i = 0; i <= 5; i++){
        if(result <= emaArray[i]){
            result = emaArray[i];
        }
    }

    return result;
}

//------------------------------------------------------------------
// GMMAのグループ(LongがShort)の中で最小値を取得
///param name="e1":EMA
///param name="e2":EMA
///param name="e3":EMA
///param name="e4":EMA
///param name="e5":EMA
///param name="e6":EMA
/// Return   最小のEMA
double GetMiniEma(double e1,double e2,double e3,double e4,double e5,double e6){
    double result = 0;
    double emaArray[6];
    emaArray[0] = e1;
    emaArray[1] = e2;
    emaArray[2] = e3;
    emaArray[3] = e4;
    emaArray[4] = e5;
    emaArray[5] = e6;

    result =  emaArray[0];
    for(int i = 0; i < 6; i++){
        if(result => emaArray[i]){
            result = emaArray[i];
        }
    }

    return result;
}

//------------------------------------------------------------------
// 現在の時間より1時間前から2時間後の指標データを取得
/// Return   selectした行数
int GetNoTradeTime(){
    datetime startTime = GetCileTime(-3600);
    datetime endTime = GetCileTime(7200);
    string startTimeStr = TimeToStr(startTime,TIME_DATE|TIME_SECONDS);
    string endTime = TimeToStr(endTime,TIME_DATE|TIME_SECONDS)

    string query = "";
    query = query + "select";
    query = query + "  eventname,";
    query = query + "  currencycode,";
    query = query + "  importance";
    query = query + "from";
    query = query + "  indexcalendars ";
    query = query + "where";
    query = query + "  myreleasedate between '"+ StringReplace(startTimeStr,".","-") + "' and '"+ StringReplace(endTime,".","-") + "'";
    query = query + "  order by releasedategmt";

    int result = db.read_rows(query);
    return result;
}

void GetHighIndexTime(int rowCount){
    for (int i=0; i < rowCount; i++) {
        if((string) db.get("importance",i) == "high"){
            
        }
    }
}

//------------------------------------------------------------------
// 取得した指標の中に重要度（high）があるか確認
/// Return   selectした行数
bool IsImportance(int rowCount){
    bool result = false;

    for (int i=0; i < rowCount; i++) {
        if((string) db.get("importance",i) == "high"){
            result = true;
        }
    }

    return result;
}

//------------------------------------------------------------------
// 現在時刻からの計算時間を取得
///param name="cileTime":計算する時間(3600:1時間後,-1800:30分前,86400:1日後)
/// Return   最小のEMA
datetime GetCileTime(int cileTime){
    datetime tm = TimeLocal();
    return tm + cileTime;
}

