//+------------------------------------------------------------------+
//|                                                    OrderTest.mq4 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <Custom/ExpertAdvisorTradeHelper.mqh>
#include <Custom/TradeQuantityHelper.mqh>
#include <Custom/TwitterHelper.mqh>

input int MagicNumber = 11180002; //マジックナンバー 他のEAと当らない値を使用する。
input double SpreadFilter = 2;    //最大スプレット値(PIPS)

extern int MaxPosition = 1;        //最大ポジション数
extern int SdSigma = 3;
extern double RiskPercent = 2.0;

input double Slippage = 10;      //許容スリッピング（Pips単位）
input uint TakeProfit = 200;      //利益確定

// トレード補助クラス
ExpertAdvisorTradeHelper OrderHelper(Symbol(), MagicNumber, MaxPosition, SpreadFilter);
// 取引数調整クラスSide BarVSide Bar
TradeQuantityHelper LotHelper(Symbol(), PERIOD_M15, 15, 0, MODE_EMA, PRICE_CLOSE, 2, SdSigma, RiskPercent);

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   double lossRenge = LotHelper.GetSdLossRenge();
   double lotSize = LotHelper.GetSdLotSize(lossRenge);
   double pLotSize = LotHelper.GetLotSize(lossRenge);

                PrintFormat("ポジション時間：" + TimeCurrent());
                PrintFormat("ロスカット値段：" + lossRenge);
                PrintFormat("ロットサイズ：" + lotSize);
                PrintFormat("%ロットサイズ：" + pLotSize);

                int orderCmd = OP_BUY;
                OrderHelper.SendOrder(orderCmd, lotSize, 0, Slippage, lossRenge, TakeProfit );
                double orderPrice = OrderHelper.GetOrderClose(0);
                //PrintFormat("通貨ペア：" + Symbol() + "オーダー：OP_BUY 約定価格：" + DoubleToStr(orderPrice,2));
                
                                int positionCount = OrderHelper.GetPositionCount();
                double orderProfit = OrderHelper.GetOrderProfit(0);
                double orderLimit = OrderHelper.GetOrderLimit(0);

                PrintFormat("決済時間：" + TimeCurrent());
                PrintFormat("ポジション数：" + positionCount);
                PrintFormat("利益：" + orderProfit);
                
                //ポジションを保持していれば決済する
                //OrderHelper.CloseOrder(0, Slippage);
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
   
  }
//+------------------------------------------------------------------+
