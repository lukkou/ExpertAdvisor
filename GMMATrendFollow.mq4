//+------------------------------------------------------------------+
//|                                              GMMATrendFollow.mq4 |
//| GMMATrendFollow v0.1            Copyright 2017, Lukkou_EA_Trader |
//|                                   http://fxborg-labo.hateblo.jp/ |
//+------------------------------------------------------------------+
#property copyright " Copyright 2017, Lukkou_EA_Trader"
#property link      "https://www.xxx"
#property version   "1.00"
#property strict

#property copyright "Copyright 2017,  lukkou"
#property link      "https://twitter.com/lukkou_position"
#property version   "1.00"
#property strict

#include <Custom/ExpertAdvisorTradeHelper.mqh>
#include <Custom/TradeQuantityHelper.mqh>
#include <Custom/TwitterHelper.mqh>

input int MagicNumber = 11180002;   //マジックナンバー 他のEAと当らない値を使用する。
input double SpreadFilter = 2;      //最大スプレット値(PIPS)
input int MaxPosition = 1;          //最大ポジション数
input double RiskPercent = 2.0;     //資金に対する最大リスク％
input double Slippage = 10;         //許容スリッピング（Pips単位）
input uint TakeProfit = 200;        //利益確定
input string TweetCmdPash = "C:\\PROGRA~2\\dentakurou\\Tweet\\Tweet.exe";       //自動投稿exeパス

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

    bool hasPosition = (OrderHelper.GetPositionCount() > 0);
    if(hasPosition){
        for(int i = 0; OrderHelper.GetPositionCount() - 1; i++){
            
        }
    }


}