//+------------------------------------------------------------------+
//|                                             ThreePointCharge.mq4 |
//|                                          Copyright 2017,  lukkou |
//|                              https://twitter.com/lukkou_position |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017,  lukkou"
#property link      "https://twitter.com/lukkou_position"
#property version   "1.00"
#property strict

#include <Custom/ExpertAdvisorTradeHelper.mqh>
#include <Custom/TradeQuantityHelper.mqh>
#include <Custom/TwitterHelper.mqh>

input int MagicNumber = 11180001; //マジックナンバー 他のEAと当らない値を使用する。
input double SpreadFilter = 2;    //最大スプレット値(PIPS)

extern int MaxPosition = 1;        //最大ポジション数
extern double RiskPercent = 2.0;

input double Slippage = 10;      //許容スリッピング（Pips単位）
input uint TakeProfit = 200;      //利益確定
input string TweetCmdPash = "C:\\PROGRA~2\\dentakurou\\Tweet\\Tweet.exe";


// トレード補助クラス
ExpertAdvisorTradeHelper OrderHelper(Symbol(), MagicNumber, MaxPosition, SpreadFilter);
// 取引数調整クラス
TradeQuantityHelper LotHelper(Symbol(), PERIOD_M15, 15, 0, MODE_EMA, PRICE_CLOSE, 2, AccountBalance(), RiskPercent);
//Tweetクラス
TwitterHelper TweetHelper(TweetCmdPash);

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(){
    PrintFormat("ThreePointCharge Load");
    
    return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason){
    PrintFormat("ThreePointCharge End");
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick(){
    //MACDとRSIとADXの三点チャージのEA
    //エントリー  ：ADX +DI>-DIかつRSI14が70以上の場合でMACDシグナルのゴールデンクロス
    //クローズ   ：MACDがデットクロス
    PrintFormat("ThreePointCharge Move" + TimeCurrent());
   
    //買いポジションが存在するか確認
    bool hasPosition = (OrderHelper.GetPositionCount() > 0 );
   
    //macdデータ取得
    double macd = iMACD(NULL, PERIOD_M15, 12, 26, 9, PRICE_CLOSE, 0, 0);
    double macdDelay = iMACD(NULL, PERIOD_M15 ,12 ,26 ,9 ,PRICE_CLOSE, 0, 1);
    double macdSignal = iMACD(NULL, PERIOD_M15, 12, 26, 9, PRICE_CLOSE, 1, 0);
    double macdSignaDelay = iMACD(NULL, PERIOD_M15, 12, 26, 9, PRICE_CLOSE, 1, 1);
   
    //adxデータ取得
    double plusDi = iADX(NULL, PERIOD_M15, 14, PRICE_CLOSE, MODE_PLUSDI, 0);
    double minusDi = iADX(NULL, PERIOD_M15, 14, PRICE_CLOSE, MODE_MINUSDI, 0);
   
    //rsi情報取得
    double rsi = iRSI(NULL, PERIOD_M15 , 14, PRICE_CLOSE , 0);
   
    if(hasPosition){
        //ポジションが存在する場合クローズするか確認
        if(macd < macdSignal && macdDelay >= macdSignaDelay){
            int positionCount = LotHelper.GetPositionCount();
            double orderProfit = LotHelper.GetOrderProfit(0)
            double orderLimit = LotHelper.GetOrderLimit(0);

            PrintFormat("決済時間：" + TimeCurrent());
            PrintFormat("ポジション数：" + positionCount);
            PrintFormat("利益：" + orderProfit);
            PrintFormat("ポジション数：" + positionCount);

            //ポジションを保持していれば決済する
            OrderHelper.CloseOrder(0, Slippage );
        }
    }
    else{
        //エントリーシグナルを確認
        if (plusDi > minusDi && plusDi > 20 && rsi >= 70){
            if (macd > macdSignal && macdDelay < macdSignaDelay){
                double lossRenge = LotHelper.GetSdLossRenge();
                double lotSize = LotHelper.GetSdLotSize(lossRenge);

                double pLotSize = LotHelper:GetLotSize(lossRenge);

                PrintFormat("ポジション時間：" + TimeCurrent());
                PrintFormat("ロスカット値段：" + lossRenge);
                PrintFormat("ロットサイズ：" + lotSize);
                PrintFormat("%ロットサイズ：" + pLotSize);

                int orderCmd = OP_BUY;
                OrderHelper.SendOrder(orderCmd, lotSize, 0, Slippage, lossRenge, TakeProfit );
                //TweetHelper.ExecTradeTweet(Symbol(),"OP_BUY","105.12",TimeToStr(TimeLocal(),TIME_DATE|TIME_SECONDS));
            }
        }
    }
}